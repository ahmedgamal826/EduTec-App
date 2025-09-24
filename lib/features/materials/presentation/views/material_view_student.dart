import 'package:attendance_app/features/materials/cubits/cubit_student/student_material_cubit.dart';
import 'package:attendance_app/features/materials/presentation/views/widgets/material_view_student_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaterialsStudentScreen extends StatelessWidget {
  final String courseId;
  final int lectureNumber;

  const MaterialsStudentScreen({
    super.key,
    required this.courseId,
    required this.lectureNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudentMaterialCubit(
        courseId: courseId,
        lectureNumber: lectureNumber,
      ),
      child: MaterialsStudentBodyView(
        courseId: courseId,
        lectureNumber: lectureNumber,
      ),
    );
  }
}
