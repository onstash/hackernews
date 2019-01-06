import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';

import 'package:hackernews/hn-components.dart';

class HNWebView extends StatefulWidget {
  final String url;
  final String title;

  HNWebView({Key key, @required this.url, @required this.title}): super(key: key);

  @override
  HNWebViewState createState() => new HNWebViewState(
    url: this.url,
    title: this.title
  );
}

class HNWebViewState extends State<HNWebView> {
  final String url;
  final String title;
  bool loading;

  HNWebViewState({
    Key key,
    @required this.url,
    @required this.title
  });

  void initState() {
    super.initState();
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
                  Share.share(this.title + " - " + this.url);
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
        title: Text(title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(this.title + " - " + this.url);
              }
          )
        ],
      ),
      withZoom: false,
      withLocalStorage: true,
    );
  }
}