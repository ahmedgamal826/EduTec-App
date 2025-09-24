import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/attendance/presentation/views/widgets/attendance_view_student_body.dart';
import 'package:flutter/material.dart';

class AttendanceScreenStudent extends StatelessWidget {
  final String courseId;
  final String courseName;

  const AttendanceScreenStudent({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        title: Text(
          '$courseName Attendance',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       Colors.blue[100]!,
        //       Colors.white,
        //     ],
        //   ),
        // ),
        color: Colors.white,

        child: AttendanceScreenBodyView(courseId: courseId),
      ),
    );
  }
}
