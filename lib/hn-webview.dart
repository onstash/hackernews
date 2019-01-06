import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:hackernews/hn-components.dart';

class HNWebView extends StatefulWidget {
  final String url;
  final String title;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  HNWebView({
    Key key,
    @required this.url,
    @required this.title,
    @required this.analytics,
    @required this.observer,
  }): super(key: key);

  @override
  HNWebViewState createState() => new HNWebViewState(
    url: this.url,
    title: this.title,
    analytics: this.analytics,
    observer: this.observer,
  );
}

class HNWebViewState extends State<HNWebView> {
  final String url;
  final String title;
  bool loading;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  DateTime start;

  HNWebViewState({
    Key key,
    @required this.url,
    @required this.title,
    @required this.analytics,
    @required this.observer,
  });

  void initState() {
    super.initState();
    this.start = DateTime.now();
    this._loadWebView();
  }

  void _loadWebView() async {
    setState(() {
      loading = true;
    });
    Future.delayed(const Duration(milliseconds: 850), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(this.title + " - " + this.url)
                  .then((onValue) {
                    this.analytics.logEvent(
                      name: "story_shared",
                      parameters: {
                        "url": this.url,
                        "title": this.title,
                        "time_spent": DateTime.now().difference(this.start).inSeconds,
                      }
                    );
                  }).catchError((onError) {
                    this.analytics.logEvent(
                      name: "story_share_canceled",
                      parameters: {
                        "url": this.url,
                        "title": this.title,
                        "time_spent": DateTime.now().difference(this.start).inSeconds,
                        "error": onError.toString()
                      }
                    );
                  });
              }
            )
          ],
        ),
        body: Loader(text: "Loading content..."),
      );
    }

    return WebviewScaffold(
      url: url,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(true);
            }
          ),
        title: Text(title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(this.title + " - " + this.url)
                  .then((onValue) {
                    this.analytics.logEvent(
                      name: "story_shared",
                      parameters: {
                        "url": this.url,
                        "title": this.title,
                        "time_spent": DateTime.now().difference(this.start).inSeconds,
                      }
                    );
                  }).catchError((onError) {
                    this.analytics.logEvent(
                      name: "story_share_canceled",
                      parameters: {
                        "url": this.url,
                        "title": this.title,
                        "time_spent": DateTime.now().difference(this.start).inSeconds,
                        "error": onError.toString()
                      }
                    );
                  });
              }
          )
        ],
      ),
      withZoom: false,
      withLocalStorage: true,
    );
  }
}