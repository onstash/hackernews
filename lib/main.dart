import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HackerNews',
      home: HackerNews(),
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
      )
    );
  }
}

class HackerNews extends StatefulWidget {
  @override
  HackerNewsState createState() => new HackerNewsState();
}

class HNWebView extends StatelessWidget {
  final String url;
  final String title;

  HNWebView({Key key, @required this.url, @required this.title}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      appBar: AppBar(
        title: Text(title),
      ),
      withZoom: false,
      withLocalStorage: true,
    );
  }
}

class HackerNewsState extends State<HackerNews> {
  int currentPage = 1;
  int lastItemIndex = -1;
  List data = [];
  List<int> loadedIndices = [];
  List<String> openedLinks = [];

  @override
  void initState() {
    super.initState();
    this._getJSONData();
    this._loadOpenedLinks();
  }

  void _loadOpenedLinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List _openedLinks = (prefs.getStringList("openedLinks") ?? []);
    setState(() {
      openedLinks = _openedLinks;
    });
  }

  Future<String> _getJSONData() async {
    String url = "https://api.hnpwa.com/v0/news/" + currentPage.toString() + ".json";
    var response = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"},
    );
    setState(() {
      for (var value in jsonDecode(response.body)) {
        data.add(value);
      }
      lastItemIndex = data.length - 1;
    });
    return "Successful";
  }

  void _incrementPageNum() {
    if (currentPage + 1 == 4) {
      return;
    }
    currentPage = currentPage + 1;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("HackerNews top posts"),
      ),
      body: ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (BuildContext context, int index) {
          var urlChecked = openedLinks.contains(data[index]["url"]);
          if (index > 0 && index % 29 == 0 && loadedIndices.contains(index) == false) {
            _incrementPageNum();
            _getJSONData();
            loadedIndices.add(index);
          }
          return GestureDetector(
            onTap: () {
              if (data[index]["url"].startsWith("item?")) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HNWebView(
                            url: "https://news.ycombinator.com/" + data[index]["url"],
                            title: data[index]["title"]
                        )
                    )
                );
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HNWebView(
                            url: data[index]["url"],
                            title: data[index]["title"]
                        )
                    )
                );
              }
              _updateOpenedLinks(data[index]["url"], "onTap");
            },
            onLongPress: () {
              var flag = openedLinks.contains(data[index]["url"]) ? "not read" : "read";
              final snackBar = SnackBar(content: Text("Marking as " + flag.toString() + ": " + data[index]["title"]), duration: Duration(milliseconds: 500));
              Scaffold.of(context).showSnackBar(snackBar);
              Future.delayed(const Duration(milliseconds: 850), () {
                _updateOpenedLinks(data[index]["url"], "onLongPress");
              });
            },
            child: Container(
              child: Card(
                child: Padding(
                  child: Column(
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          Text(
                            data[index]["title"],
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: urlChecked ? Colors.blueGrey : Colors.black,
                            )
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: <Widget>[
                            Text(data[index]["time_ago"],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ))
                          ],
                        ),
                      )
                    ]
                  ),
                  padding: EdgeInsets.all(16.0),
                ),
                elevation: 2.0,
              ),
            )
          );
        }
      )
    );
  }
}
