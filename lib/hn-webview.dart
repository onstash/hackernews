import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

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