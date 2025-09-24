import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/attendance/cubits/cubit_student/lecture_cubit.dart';
import 'package:attendance_app/features/attendance/cubits/cubit_student/lecture_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lecture_item_student.dart';

class AttendanceScreenBodyView extends StatefulWidget {
  final String courseId;

  const AttendanceScreenBodyView({
    super.key,
    required this.courseId,
  });

  @override
  State<AttendanceScreenBodyView> createState() =>
      _AttendanceScreenBodyViewState();
}

class _AttendanceScreenBodyViewState extends State<AttendanceScreenBodyView> {
  final TextEditingController _searchController = TextEditingController();
  late StudentLectureCubit _studentLectureCubit;

  @override
  void initState() {
    super.initState();
    _studentLectureCubit = StudentLectureCubit(courseId: widget.courseId);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _studentLectureCubit.close(); // Close the cubit to avoid memory leaks
    super.dispose();
  }

  void _onSearchChanged() {
    _studentLectureCubit.searchLectures(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _studentLectureCubit,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(12),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.05),
                //     blurRadius: 4,
                //     offset: const Offset(0, 2),
                //   ),
                // ],

                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                cursorColor: AppColors.primaryColor,
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  hintText: 'Search lectures...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _studentLectureCubit.searchLectures('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lectures List
            Expanded(
              child: BlocBuilder<StudentLectureCubit, StudentLectureState>(
                builder: (context, state) {
                  if (state.status == StudentLectureStatus.loading) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ));
                  }
                  if (state.status == StudentLectureStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Failed to load lectures',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (state.filteredLectures.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No lectures found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final lectures = state.filteredLectures;
                  return ListView.builder(
                    itemCount: lectures.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: Duration(milliseconds: index * 500),
                        child: LectureItemStudent(
                          lecture: lectures[index],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
