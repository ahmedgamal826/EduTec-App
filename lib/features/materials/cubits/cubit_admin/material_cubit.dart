import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:intl/intl.dart';
import '../../models/material_model_admin.dart';
import 'material_state1.dart';

class MaterialCubit extends Cubit<MaterialState1> {
  final String courseId;
  final int lectureNumber;
  final NotificationService _notificationService = NotificationService();

  MaterialCubit({required this.courseId, required this.lectureNumber})
      : super(MaterialState1(files: [])) {
    loadMaterials();
  }

  // تحميل الملفات من Firestore
  void loadMaterials() async {
    // نبدأ التحميل ونعمل set لـ isLoading على true
    emit(state.copyWith(files: [], isLoading: true));

    try {
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lectureSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      List<MaterialFile> materials = [];

      if (lectureSnapshot.docs.isEmpty) {
        emit(state.copyWith(files: materials, isLoading: false));
        return;
      }

      QuerySnapshot materialsSnapshot = await lectureSnapshot
          .docs.first.reference
          .collection('materials')
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in materialsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        materials.add(MaterialFile(
          name: data['name'] ?? 'Unknown',
          size: data['size'] ?? 'Unknown',
          url: data['url'],
        ));
      }

      // خلّصنا تحميل، نعمل set لـ isLoading على false
      emit(state.copyWith(files: materials, isLoading: false));
    } catch (e) {
      print('Error loading materials: $e');
      emit(state.copyWith(files: [], isLoading: false));
    }
  }

  // إضافة ملف جديد
  void addFile(MaterialFile file) async {
    try {
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lectureSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      if (lectureSnapshot.docs.isNotEmpty) {
        var lectureDoc = lectureSnapshot.docs.first;
        final now = Timestamp.now();

        // Get lecture data for notification
        final lectureData = lectureDoc.data() as Map<String, dynamic>;
        final lectureName = lectureData['name'] ?? 'Lecture $lectureNumber';

        // Add material to Firestore
        await lectureDoc.reference.collection('materials').add({
          'name': file.name,
          'size': file.size,
          'url': file.url,
          'created_at': now,
        });

        // Send notification to all students
        await _sendMaterialNotification(
          fileName: file.name,
          lectureName: lectureName,
          timestamp: now,
        );
      } else {
        throw Exception('Lecture not found');
      }

      loadMaterials();
    } catch (e) {
      print('Error adding material: $e');
    }
  }

  // إرسال إشعار عند إضافة ملف جديد
  Future<void> _sendMaterialNotification({
    required String fileName,
    required String lectureName,
    required Timestamp timestamp,
  }) async {
    try {
      // Get course name
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .get();

      String courseName = 'Course';
      if (courseDoc.exists) {
        final courseData = courseDoc.data() as Map<String, dynamic>;
        courseName = courseData['courseName'] ?? courseName;
      }

      // Format date and time
      final DateTime dateTime = timestamp.toDate();
      final String formattedDate =
          DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
      final String formattedTime = DateFormat('h:mm a').format(dateTime);

      // Get all students enrolled in this course
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toList();

      // Create notification using the dedicated method
      await _notificationService.createMaterialNotification(
        courseName: courseName,
        materialName: fileName,
        lectureName: lectureName,
        date: formattedDate,
        time: formattedTime,
        courseId: courseId,
        recipients: studentIds,
      );

      print('Material notification sent to all students');
    } catch (e) {
      print('Error sending material notification: $e');
      // We don't want to stop the process if notification fails
    }
  }

  // حذف ملف
  void deleteFile(int index) async {
    try {
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lectureSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      if (lectureSnapshot.docs.isNotEmpty) {
        var lectureDoc = lectureSnapshot.docs.first;
        QuerySnapshot materialsSnapshot = await lectureDoc.reference
            .collection('materials')
            .orderBy('created_at', descending: true)
            .get();

        if (index < materialsSnapshot.docs.length) {
          await materialsSnapshot.docs[index].reference.delete();
          loadMaterials();
        }
      }
    } catch (e) {
      print('Error deleting material: $e');
    }
  }

  // مشاركة ملف
  Future<String?> shareFile(String fileName, String? fileUrl) async {
    if (fileUrl == null || fileUrl.isEmpty) {
      return 'File URL is null or empty. Cannot share the file.';
    }

    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200) {
        return 'Failed to download file: HTTP ${response.statusCode}';
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (await file.exists()) {
        final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
        final xFile = XFile(filePath, mimeType: mimeType);
        await Share.shareXFiles(
          [xFile],
          subject: 'Sharing $fileName',
        );

        await file.delete();
        return null;
      } else {
        return 'Failed to save file to device.';
      }
    } catch (e) {
      print('Error sharing file: $e');
      return 'Error sharing file: $e';
    }
  }

  // تحديث اسم الملف
  Future<bool> updateFileName(int index, String newName) async {
    try {
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lectureSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      if (lectureSnapshot.docs.isNotEmpty) {
        var lectureDoc = lectureSnapshot.docs.first;
        QuerySnapshot materialsSnapshot = await lectureDoc.reference
            .collection('materials')
            .orderBy('created_at', descending: true)
            .get();

        if (index < materialsSnapshot.docs.length) {
          await materialsSnapshot.docs[index].reference.update({
            'name': newName,
          });
          loadMaterials();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating material name: $e');
      return false;
    }
  }
}
