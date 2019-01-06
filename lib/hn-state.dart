import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:hackernews/hn-webview.dart';
import 'package:hackernews/hn-components.dart';
import 'package:hackernews/hn-model.dart';

class HackerNews extends StatefulWidget {
  final String url;
  final int currentPage;
  final int maxPages;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  HackerNews({
    Key key,
    @required this.url,
    @required this.currentPage,
    @required this.maxPages,
    @required this.analytics,
    @required this.observer
  }): super(key: key);

  @override
  HackerNewsState createState() => new HackerNewsState(
    url: this.url,
    currentPage: this.currentPage,
    maxPages: this.maxPages,
    analytics: this.analytics,
    observer: this.observer
  );
}

class HackerNewsState extends State<HackerNews> {
  int currentPage;
  int maxPages;
  int lastItemIndex = -1;
  List data = [];
  List<int> loadedIndices = [];
  List<String> openedLinks = [];
  String url;
  bool loading = true;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  HackerNewsState({
    Key key,
    @required this.url,
    @required this.currentPage,
    @required this.maxPages,
    @required this.analytics,
    @required this.observer,
  });

  @override
  void initState() {
    super.initState();
    this._loadOpenedLinks();
    this._getJSONData();
  }

  void _loadOpenedLinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> _openedLinks = (prefs.getStringList("openedLinks") ?? []);
    setState(() {
      openedLinks = _openedLinks;
    });
  }

  Future _getJSONData() async {
    setState(() {
      loading = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () async {
      String _url = this.url + currentPage.toString() + ".json";
      var response = await http.get(
        Uri.encodeFull(_url),
        headers: {"Accept": "application/json"},
      );
      setState(() {
        for (var postJSON in jsonDecode(response.body)) {
          data.add(FeedCard.fromJSON(postJSON));
        }
        lastItemIndex = data.length - 1;
        loading = false;
      });
      return "Successful";
    });
  }

  bool _incrementPageNum() {
    if (currentPage + 1 > maxPages) {
      return false;
    }
    currentPage = currentPage + 1;
    return true;
  }

  void _updateOpenedLinks(String url, String source) async {
//    SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var urlOpened = openedLinks.contains(url) == true;
    var allowedStateUpdates = (source == "onTap" && urlOpened == false) || (source == "onLongPress");
    if (allowedStateUpdates) {
      setState(() {
        urlOpened ? openedLinks.remove(url) : openedLinks.add(url);
      });
      await prefs.setStringList("openedLinks", openedLinks);
    }
  }

  Future<void> _sendAnalyticsEvent(String eventName, Map<String, dynamic> parameters) async {
    await this.analytics.logEvent(
      name: eventName,
      parameters: parameters
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.loading) {
      return Loader(text: "Fetching stories...");
    }

    return ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (BuildContext context, int index) {
          var urlChecked = openedLinks.contains(data[index].url);
          if (currentPage < maxPages) {
            if (index > 0 && index % 29 == 0 && loadedIndices.contains(index) == false) {
              _incrementPageNum();
              _getJSONData();
              loadedIndices.add(index);
            }
          }
          return GestureDetector(
            onTap: () async {
              String __url = data[index].url.startsWith("item?") ? "https://news.ycombinator.com/" + data[index].url : data[index].url;
              DateTime start = DateTime.now();

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HNWebView(
                    url: __url,
                    title: data[index].title,
                    analytics: this.analytics,
                    observer: this.observer,
                  )
                )
              );

              this._sendAnalyticsEvent(
                "story_read",
                {
                  "url": __url,
                  "title": data[index].title,
                  "time_spent": DateTime.now().difference(start).inSeconds,
                }
              );

              _updateOpenedLinks(data[index].url, "onTap");
            },
            onLongPress: () {
              var flag = openedLinks.contains(data[index].url) ? "not read" : "read";
              String __url = data[index].url.startsWith("item?") ? "https://news.ycombinator.com/" + data[index].url : data[index].url;
              this._sendAnalyticsEvent(
                "story_bookmarked",
                {
                  "url": __url,
                  "title": data[index].title,
                  "bookmarked": !openedLinks.contains(data[index].url)
                }
              );
              final snackBar = SnackBar(content: Text("Marking as " + flag.toString() + ": " + data[index].url), duration: Duration(milliseconds: 500));
              Scaffold.of(context).showSnackBar(snackBar);
              Future.delayed(const Duration(milliseconds: 850), () {
                _updateOpenedLinks(data[index].url, "onLongPress");
              });
            },
            child: Container(
              child: Card(
                color: urlChecked ? Colors.grey[100] : Colors.white,
                child: Container(
                  child: Column(
                      children: <Widget>[
                        FeedCardTitle(
                          text: data[index].title,
                          urlOpened: urlChecked,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              TimeAgo(text: data[index].timeAgo),
                              Domain(text: data[index].url.startsWith("item?") ? "news.ycombinator.com" : data[index].domain),
                            ],
                          ),
                        )
                      ]
                  ),
                  padding: EdgeInsets.all(16.0),
                ),
                elevation: 2.0,
                margin: EdgeInsets.only(
                  top: 16.0,
                  bottom: index == data.length - 1 ? 16.0 : 0.0,
                  left: 10.0,
                  right: 10.0,
                ),
              ),
            )
        );
      }
    );
  }
}