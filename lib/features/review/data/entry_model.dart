import 'package:flutter/material.dart';

class Entry {
  final String author;
  final String time;
  final String content;
  final Color color;
  bool isSaved;
  Entry(this.author, this.time, this.content, this.color,{this.isSaved = false});
} 