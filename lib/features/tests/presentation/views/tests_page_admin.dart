import 'package:attendance_app/features/tests/presentation/views/home_tests_view.dart';
import 'package:flutter/material.dart';

class TestsPageAdmin extends StatelessWidget {
  final String courseId;

  const TestsPageAdmin({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return HomeTestsView(courseId: courseId);
  }
}
