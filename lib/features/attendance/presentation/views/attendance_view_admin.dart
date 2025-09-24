import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_state.dart';
import 'package:attendance_app/features/attendance/presentation/views/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/cubit_admin/lecture_cubit.dart';
import 'widgets/attendance_view_admin_body.dart';

class AttendanceScreenAdmin extends StatelessWidget {
  final String courseId;
  final String courseName;

  const AttendanceScreenAdmin({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LectureCubit(courseId: courseId),
      child: BlocBuilder<LectureCubit, LectureState>(
        builder: (context, state) {
          final lectureCubit = context.read<LectureCubit>();
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              title: Text(
                'Admin $courseName Attendance',
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
            body: AttendanceAdminBody(courseId: courseId),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleScreen(
                      courseId: courseId,
                      lectureCubit: lectureCubit,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
