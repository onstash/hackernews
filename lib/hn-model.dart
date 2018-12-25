import 'package:flutter/material.dart';

class FeedCard {
  int id;
  String title;
  int points;
  String user;
  String timeAgo;
  int commentsCount;
  String url;
  String domain;

  FeedCard({
    this.id,
    this.title,
    this.points,
    this.user,
    this.timeAgo,
    this.commentsCount,
    this.url,
    this.domain
  });

  factory FeedCard.fromJSON(Map<String, dynamic> postJSON) {
    return FeedCard(
      id: postJSON["id"] as int,
      title: postJSON["title"] as String,
      points: postJSON["points"] as int,
      user: postJSON["user"] as String,
      timeAgo: postJSON["time_ago"] as String,
      commentsCount: postJSON["comments_count"] as int,
      url: postJSON["url"] as String,
      domain: postJSON["domain"] as String,
    );
  }
}
