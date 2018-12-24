import 'package:flutter/material.dart';

import 'package:hackernews/hn-state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HackerNews',
      home: HackerNews(
        url: "https://api.hnpwa.com/v0/news/",
        currentPage: 1
      ),
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
      )
    );
  }
}

