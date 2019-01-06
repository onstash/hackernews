import 'package:flutter/material.dart';

class TimeAgo extends StatelessWidget {
  final String text;

  TimeAgo({Key key, @required this.text}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        )
      )
    );
  }
}

class FeedCardTitle extends StatelessWidget {
  final String text;
  final bool urlOpened;

  FeedCardTitle ({Key key, @required this.text, @required this.urlOpened}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: urlOpened ? Colors.grey : Colors.black,
          )
        )
      )
    );
  }
}

class Domain extends StatelessWidget {
  final String text;

  Domain({Key key, this.text}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(
            text ?? "",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w300,
              color: Colors.black87,
            )
        )
    );
  }
}

class Loader extends StatelessWidget {
  String text;

  Loader({Key key, this.text}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            Container(
              child: Text(this.text ?? "Loading..."),
              margin: EdgeInsets.only(left: 16.0),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
      )
    );
  }
}


