import 'package:flutter/material.dart';

class StudentScoreStudent {
  final String name;
  final double score;
  final Color color;
  final double attendance;
  final double assignments;
  final double tests;

  StudentScoreStudent(
    this.name,
    this.score,
    this.color, {
    this.attendance = 0.0,
    this.assignments = 0.0,
    this.tests = 0.0,
  });
}
