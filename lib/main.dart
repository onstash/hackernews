import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:hackernews/hn-state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HackerNews',
      navigatorObservers: <NavigatorObserver>[observer],
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("HackerNews"),
            bottom: TabBar(
              tabs: [
                Tab(text: "News"),
                Tab(text: "Newest"),
                Tab(text: "Ask"),
                Tab(text: "Show"),
              ],
              indicatorColor: Colors.white,
              isScrollable: true,
              labelStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              unselectedLabelStyle: TextStyle(
                color: Colors.white12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          body: TabBarView(children: [
            HackerNews(
              url: "https://api.hnpwa.com/v0/news/",
              currentPage: 1,
              maxPages: 10,
              analytics: analytics,
              observer: observer,
            ),
            HackerNews(
              url: "https://api.hnpwa.com/v0/newest/",
              currentPage: 1,
              maxPages: 12,
              analytics: analytics,
              observer: observer,
            ),
            HackerNews(
              url: "https://api.hnpwa.com/v0/ask/",
              currentPage: 1,
              maxPages: 2,
              analytics: analytics,
              observer: observer,
            ),
            HackerNews(
              url: "https://api.hnpwa.com/v0/show/",
              currentPage: 1,
              maxPages: 2,
              analytics: analytics,
              observer: observer,
            ),
          ]),
        )
      ),
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
      )
    );
  }
}

