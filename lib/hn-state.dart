import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advanced_share/advanced_share.dart';

import 'package:hackernews/hn-webview.dart';
import 'package:hackernews/hn-components.dart';
import 'package:hackernews/hn-model.dart';

class HackerNews extends StatefulWidget {
  final String url;
  final int currentPage;
  final int maxPages;

  HackerNews({
    Key key,
    @required this.url,
    @required this.currentPage,
    @required this.maxPages
  }): super(key: key);

  @override
  HackerNewsState createState() => new HackerNewsState(
    url: this.url,
    currentPage: this.currentPage,
    maxPages: this.maxPages
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

  HackerNewsState({
    Key key,
    @required this.url,
    @required this.currentPage,
    @required this.maxPages
  });

  @override
  void initState() {
    super.initState();
    this._getJSONData();
    this._loadOpenedLinks();
  }

  void _loadOpenedLinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> _openedLinks = (prefs.getStringList("openedLinks") ?? []);
    setState(() {
      openedLinks = _openedLinks;
    });
  }

  Future<String> _getJSONData() async {
//    String url = "https://api.hnpwa.com/v0/news/" + currentPage.toString() + ".json";
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
    });
    print("currentPage: " + currentPage.toString() + "/" + maxPages.toString());
    return "Successful";
  }

  bool _incrementPageNum() {
    if (currentPage + 1 > maxPages) {
      return false;
    }
    currentPage = currentPage + 1;
    print("currentPage: " + currentPage.toString() + "/" + maxPages.toString());
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

  @override
  Widget build(BuildContext context) {
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
              onTap: () {
                if (data[index].url.startsWith("item?")) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HNWebView(
                              url: "https://news.ycombinator.com/" + data[index].url,
                              title: data[index].title
                          )
                      )
                  );
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HNWebView(
                              url: data[index].url,
                              title: data[index].title
                          )
                      )
                  );
                }
                _updateOpenedLinks(data[index].url, "onTap");
              },
              onLongPress: () {
                var flag = openedLinks.contains(data[index].url) ? "not read" : "read";
                final snackBar = SnackBar(content: Text("Marking as " + flag.toString() + ": " + data[index].url), duration: Duration(milliseconds: 500));
                Scaffold.of(context).showSnackBar(snackBar);
                Future.delayed(const Duration(milliseconds: 850), () {
                  _updateOpenedLinks(data[index].url, "onLongPress");
                });
              },
              child: Container(
                child: Card(
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
                                Domain(text: data[index].domain),
                                GestureDetector(
                                  onTap: () {
                                    String __url = data[index].url.startsWith("item?") ? "https://news.ycombinator.com/" + data[index].url : data[index].url;
                                    AdvancedShare.whatsapp(
                                        msg: data[index].title + " - " + __url
                                    ).then((_) => {

                                    });
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          child: Icon(Icons.share, color: Colors.grey, size: 22.0,),
                                          margin: EdgeInsets.only(left: 5.0),
                                        )
                                      ]
                                    ),
                                  ),
                                ),
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