import 'dart:io';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/materials/presentation/views/widgets/file_picker_card.dart';
import 'package:attendance_app/features/materials/presentation/views/widgets/upload_file_button.dart';
import 'package:attendance_app/features/materials/presentation/views/widgets/upload_progress_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import '../../../cubits/cubit_admin/material_cubit.dart';
import '../../../models/material_model_admin.dart';

class FileUploadScreenAdmin extends StatefulWidget {
  const FileUploadScreenAdmin({super.key});

  @override
  State<FileUploadScreenAdmin> createState() => _FileUploadScreenAdminState();
}

class _FileUploadScreenAdminState extends State<FileUploadScreenAdmin> {
  File? selectedFile;
  String? fileName;
  bool isUploading = false;
  double uploadProgress = 0.0; // لتتبع نسبة التحميل
  final _sizeController = TextEditingController();

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.storage.status.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.photos.status.isDenied) {
      await Permission.photos.request();
    }
    if (await Permission.videos.status.isDenied) {
      await Permission.videos.request();
    }
    if (await Permission.audio.status.isDenied) {
      await Permission.audio.request();
    }
  }

  Future<void> _pickFile() async {
    try {
      await _checkPermissions();
      await FilePicker.platform.clearTemporaryFiles();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedFile = File(result.files.single.path!);
          fileName = result.files.single.name;

          int fileSize = selectedFile!.lengthSync();
          String formattedSize;
          if (fileSize < 1024) {
            formattedSize = "$fileSize B";
          } else if (fileSize < 1024 * 1024) {
            formattedSize = "${(fileSize / 1024).toStringAsFixed(1)} KB";
          } else {
            formattedSize =
                "${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB";
          }
          _sizeController.text = formattedSize;
        });
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a file first'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
    });

    try {
      // رفع الملف لـ Firebase Storage مع تتبع نسبة التحميل
      final storageRef =
          FirebaseStorage.instance.ref().child('materials').child(fileName!);
      final uploadTask = storageRef.putFile(selectedFile!);

      // تتبع نسبة التحميل
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          uploadProgress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        });
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      context.read<MaterialCubit>().addFile(
            MaterialFile(
              name: fileName!,
              size: _sizeController.text,
              url: downloadUrl,
            ),
          );

      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName uploaded successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // دالة لتحديد أيقونة بناءً على نوع الملف
  IconData _getFileIcon(String fileName) {
    String extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      case '.doc':
      case '.docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Materials',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          // gradient: LinearGradient(
          //   colors: [
          //     Color(0xFFE3F2FD),
          //     Colors.white,
          //   ],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  fileName: fileName,
                  fileSizeText: _sizeController.text,
                  onTap: _pickFile,
                  getFileIcon: _getFileIcon,
                ),
                const SizedBox(height: 30),
                UploadProgressBar(
                  isUploading: isUploading,
                  uploadProgress: uploadProgress,
                ),
                const SizedBox(height: 40),
                UploadFileButton(
                  isUploading: isUploading,
                  onPressed: _uploadFile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
