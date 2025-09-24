import 'package:attendance_app/features/assignments/presentation/views/home_assignments_view.dart';
import 'package:flutter/material.dart';

class AssignmentsPageAdmin extends StatelessWidget {
  final String courseId;

  const AssignmentsPageAdmin({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return HomeAssignmentsView(courseId: courseId);
  }
}
