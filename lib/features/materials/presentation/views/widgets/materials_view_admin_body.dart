import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/features/materials/presentation/views/pdf_material_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/cubit_admin/material_cubit.dart';
import '../../../cubits/cubit_admin/material_state1.dart';
import '../widgets/material_item_admin.dart';

class MaterialsAdminBodyView extends StatelessWidget {
  const MaterialsAdminBodyView({super.key});

  // دالة للتحقق إذا كان الملف PDF
  bool _isPDF(String fileName) {
    return fileName.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialCubit, MaterialState1>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1565C0),
            ),
          );
        }

        if (state.isEmpty) {
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: state.files.length,
          itemBuilder: (context, index) {
            final file = state.files[index];
            return FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: Duration(milliseconds: index * 500),
              child: MaterialItemAdmin(
                file: file,
                index: index,
                onDelete: () {
                  context.read<MaterialCubit>().deleteFile(index);
                },
                onShare: () async {
                  final errorMessage = await context
                      .read<MaterialCubit>()
                      .shareFile(file.name, file.url);
                  if (errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                parentContext: context,
                onTap: () {
                  // لما تضغط على الملف
                  if (_isPDF(file.name)) {
                    // لو الملف PDF، نفتحه في PDFViewerScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfMaterialViewer(
                          fileUrl: file.url!,
                          fileName: file.name,
                        ),
                      ),
                    );
                  } else {
                    // لو مش PDF، نعرض رسالة
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Only PDF files are supported for viewing.'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
