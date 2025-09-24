import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/home_questionnaires_view.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/student_home_questionnaires_view.dart';
import 'package:attendance_app/features/tests/presentation/views/tests_page_admin.dart';
import 'package:attendance_app/features/tests/presentation/views/tests_page_student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/analysis/presentation/views/analysis_view_student.dart';
import 'package:attendance_app/features/assignments/presentation/views/assignment_page_admin.dart';
import 'package:attendance_app/features/attendance/presentation/views/attendance_view_admin.dart';
import 'package:attendance_app/features/materials/presentation/views/material_view_student.dart';
import 'package:attendance_app/features/materials/presentation/views/materials_view_admin.dart';
import 'package:attendance_app/features/analysis/presentation/views/analysis_view_admin.dart';
import 'package:attendance_app/features/attendance/presentation/views/attendance_view_student.dart';
import 'package:attendance_app/features/assignments/presentation/views/assignment_page_student.dart';

class SubjectScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const SubjectScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen>
    with SingleTickerProviderStateMixin {
  String? activeButton;
  late AnimationController _animationController;
  String? role;
  int selectedLectureNumber =
      1; // قيمة افتراضية، ممكن تعمل شاشة لاختيار الـ lecture

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            role = doc.data()?['role'] ?? 'student';
          });
        } else {
          setState(() {
            role = 'student';
          });
        }
      }
    } catch (e) {
      print('Error fetching role: $e');
      setState(() {
        role = 'student';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setActiveButton(String buttonName) {
    setState(() {
      activeButton = buttonName;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void navigateBasedOnRole(BuildContext context, String buttonName) {
    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading user data...')),
      );
      return;
    }

    setActiveButton(buttonName);
    Widget destination;

    switch (buttonName) {
      case 'Analysis':
        destination = role == 'Admin'
            ? AnalysisViewAdmin(
                courseId: widget.courseId,
              )
            : AnalysisViewStudent(courseId: widget.courseId);
        break;
      case 'Attendance':
        destination = role == 'Admin'
            ? AttendanceScreenAdmin(
                courseId: widget.courseId,
                courseName: widget.courseName,
              )
            : AttendanceScreenStudent(
                courseId: widget.courseId,
                courseName: widget.courseName,
              );
        break;
      case 'Materials':
        destination = role == 'Admin'
            ? MaterialsAdminScreen(
                courseId: widget.courseId,
                lectureNumber: selectedLectureNumber,
              )
            : MaterialsStudentScreen(
                courseId: widget.courseId,
                lectureNumber: selectedLectureNumber,
              );
        break;
      case 'Assignments':
        destination = role == 'Admin'
            ? AssignmentsPageAdmin(courseId: widget.courseId)
            : AssignmentsPageStudent(
                courseId: widget.courseId,
              );
        break;
      case 'Test':
        destination = role == 'Admin'
            ? TestsPageAdmin(courseId: widget.courseId)
            : TestsPageStudent(
                courseId: widget.courseId,
              );
        break;

      case 'Questionnaires':
        destination = role == 'Admin'
            ? HomeQuestionnairesView(courseId: widget.courseId)
            : StudentHomeQuestionnairesView(
                courseId: widget.courseId,
              );
        break;

      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          widget.courseName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: role == null
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ))
          : Container(
              height: max(1, 1000),
              // color: const Color(0xFFE3F2FD),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: _buildRoundedButton(
                          context,
                          'Attendance',
                          () => navigateBasedOnRole(context, 'Attendance'),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 300),
                        child: _buildRoundedButton(
                          context,
                          'Materials',
                          () => navigateBasedOnRole(context, 'Materials'),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 500),
                        child: _buildRoundedButton(
                          context,
                          'Assignments',
                          () => navigateBasedOnRole(context, 'Assignments'),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 700),
                        child: _buildRoundedButton(
                          context,
                          'Test',
                          () => navigateBasedOnRole(context, 'Test'),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 900),
                        child: _buildRoundedButton(
                          context,
                          'Analysis',
                          () => navigateBasedOnRole(context, 'Analysis'),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 1100),
                        child: _buildRoundedButton(
                          context,
                          'Questionnaires',
                          () => navigateBasedOnRole(context, 'Questionnaires'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRoundedButton(
      BuildContext context, String title, VoidCallback onPressed) {
    final bool isActive = activeButton == title;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double scale =
            isActive ? 1.0 + (_animationController.value * 0.05) : 1.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Transform.scale(
            scale: scale,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(25.0),
              child: Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF42A5F5)
                        : const Color(0xFF90CAF9),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                  color: isActive ? const Color(0xFF90CAF9) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isActive ? Colors.black26 : Colors.black12,
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF0D47A1)
                          : const Color(0xFF1976D2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
