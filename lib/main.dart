import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HackerNews',
      home: HackerNews(),
      theme: ThemeData(
        primaryColor: Colors.purple,
      )
    );
  }
}

class HackerNews extends StatefulWidget {
  @override
  HackerNewsState createState() => new HackerNewsState();
}

class HackerNewsState extends State<HackerNews> {
  final String url = "https://api.hnpwa.com/v0/news/1.json";
  List data;

  @override
  void initState() {
    super.initState();

    this.getJSONData();
  }

  void _launchURL(String _url) async {
    print(_url);
    await launch(_url);
  }

  Future<String> getJSONData() async {
    var response = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"},
    );
    setState(() {
      data = jsonDecode(response.body);
    });

    return "Successful";
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
          return GestureDetector(
            onTap: () {
              print("Container clicked" + index.toString());
              if (data[index]["url"].startsWith("item?")) {
                _launchURL("https://news.ycombinator.com/" + data[index]["url"]);
              } else {
                _launchURL(data[index]["url"]);
              }

            },
            child: Container(
              child: Card(
                child: Padding(
                  child: Column(
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          Text(data[index]["title"]),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: <Widget>[
                            Text(data[index]["time_ago"],
                            style: TextStyle(
                              color: Colors.grey,
                            ))
                          ],
                        ),
                      )
                    ]
                  ),
                  padding: EdgeInsets.all(16.0)
                ),
              ),
            )
          );
        }
      )
    );
  }
}
