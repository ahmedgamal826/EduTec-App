import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/features/materials/cubits/cubit_student/student_material_cubit.dart';
import 'package:attendance_app/features/materials/cubits/cubit_student/student_material_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/material_item_student.dart';

class MaterialsStudentBodyView extends StatelessWidget {
  final String courseId;
  final int lectureNumber;

  const MaterialsStudentBodyView({
    super.key,
    required this.courseId,
    required this.lectureNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Materials',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        elevation: 4,
      ),
      body: Container(
        color: Colors.white,
        child: BlocConsumer<StudentMaterialCubit, StudentMaterialState>(
          listener: (context, state) {
            if (state is MaterialError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is MaterialSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF1565C0),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MaterialLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1565C0),
                ),
              );
            } else if (state is MaterialLoaded) {
              final materials = state.materials;
              if (materials.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No materials available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: Duration(milliseconds: index * 500),
                    child: MaterialItemStudent(
                      material: materials[index],
                    ),
                  );
                },
              );
            } else if (state is MaterialError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              );
            }
            return const Center(
              child: Text(
                'No materials available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}
