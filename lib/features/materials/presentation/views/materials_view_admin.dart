import 'package:attendance_app/features/materials/presentation/views/widgets/file_upload_screen_admin.dart';
import 'package:attendance_app/features/materials/presentation/views/widgets/materials_view_admin_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/cubit_admin/material_cubit.dart';

class MaterialsAdminScreen extends StatelessWidget {
  final String courseId;
  final int lectureNumber;

  const MaterialsAdminScreen({
    super.key,
    required this.courseId,
    required this.lectureNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MaterialCubit(courseId: courseId, lectureNumber: lectureNumber),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Materials',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1565C0),
          elevation: 4,
        ),
        body: Container(
          color: Colors.white,
          child: const MaterialsAdminBodyView(),
        ),
        floatingActionButton: Builder(builder: (context) {
          final materialCubit = context.read<MaterialCubit>();
          return FloatingActionButton(
            onPressed: () {
              _addNewFile(context, materialCubit);
            },
            backgroundColor: const Color(0xFF1565C0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          );
        }),
      ),
    );
  }

  void _addNewFile(BuildContext context, MaterialCubit materialCubit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: materialCubit, // مرر الـ Cubit مباشرة
          child: const FileUploadScreenAdmin(),
        ),
      ),
    );
  }
}
