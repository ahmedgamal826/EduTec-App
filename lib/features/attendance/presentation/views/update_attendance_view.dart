import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // لرفع الصور
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateStudentPage extends StatefulWidget {
  final Map<String, dynamic> student;
  final String studentId; // معرف الطالب في Firestore

  const UpdateStudentPage({super.key, required this.student, required this.studentId});

  @override
  _UpdateStudentPageState createState() => _UpdateStudentPageState();
}

class _UpdateStudentPageState extends State<UpdateStudentPage> {
  late TextEditingController nameController;
  String? oldImageUrl;
  File? _newImageFile;
  String? attendanceStatus; // حالة الحضور

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student['name']);
    oldImageUrl = widget.student['image'];
    attendanceStatus =
        widget.student['attendance'] ?? "Absent"; // الحالة الافتراضية
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  /// دالة لاختيار صورة جديدة من المعرض
  Future<void> _pickNewImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  /// دالة لرفع الصورة الجديدة إلى Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref =
        FirebaseStorage.instance.ref().child('user_images').child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// حفظ التغييرات وتحديث البيانات في Firestore
  Future<void> _saveChanges() async {
    Map<String, dynamic> updatedStudent = {
      'name': nameController.text,
      'image': oldImageUrl ?? '',
      'attendance': attendanceStatus, // تحديث حالة الحضور
    };

    if (_newImageFile != null) {
      String newImageUrl = await _uploadImage(_newImageFile!);
      updatedStudent['image'] = newImageUrl;
    }

    // تحديث البيانات في Firestore
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.studentId)
        .update(updatedStudent);

    // الرجوع للصفحة السابقة مع القيم الجديدة
    Navigator.pop(context, updatedStudent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Update Student Attendance",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff70ACF4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickNewImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _newImageFile != null
                    ? FileImage(_newImageFile!)
                    : (oldImageUrl != null && oldImageUrl!.isNotEmpty
                        ? NetworkImage(oldImageUrl!)
                        : null) as ImageProvider?,
                child: (oldImageUrl == null || oldImageUrl!.isEmpty) &&
                        _newImageFile == null
                    ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.black54)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // حقل الاسم
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // حقل البريد الإلكتروني (غير قابل للتعديل)
            // TextField(
            //   controller: TextEditingController(text: widget.student['email']),
            //   readOnly: true,
            //   decoration: const InputDecoration(
            //     labelText: "Email",
            //     border: OutlineInputBorder(),
            //     filled: true,
            //     fillColor: Colors.grey,
            //   ),
            // ),

            TextField(
              controller: TextEditingController(text: widget.student['email']),
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 20),

            // اختيار حالة الحضور
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Attendance: ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: "Present",
                      groupValue: attendanceStatus,
                      onChanged: (value) {
                        setState(() {
                          attendanceStatus = value;
                        });
                      },
                    ),
                    const Text("Present"),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: "Absent",
                      groupValue: attendanceStatus,
                      onChanged: (value) {
                        setState(() {
                          attendanceStatus = value;
                        });
                      },
                    ),
                    const Text("Absent"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // زر حفظ التعديلات
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff70ACF4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
