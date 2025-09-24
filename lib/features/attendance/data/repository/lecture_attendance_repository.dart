import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class AttendanceRepository {
  final NotificationService _notificationService = NotificationService();

  Stream<QuerySnapshot> getAttendanceStream(
      String courseId, int lectureNumber) {
    return FirebaseFirestore.instance
        .collection('Courses')
        .doc(courseId)
        .collection('lectures')
        .where('lectureNumber', isEqualTo: lectureNumber)
        .snapshots();
  }

  Stream<QuerySnapshot> getStudentsStream(DocumentReference lectureRef) {
    return lectureRef.collection('attendance').snapshots();
  }

  // Future<void> addStudent(
  //   String courseId,
  //   int lectureNumber,
  //   String studentId,
  //   String name,
  //   String imageUrl,
  // ) async {
  //   try {
  //     DocumentReference courseRef =
  //         FirebaseFirestore.instance.collection('Courses').doc(courseId);
  //     QuerySnapshot lectureSnapshot = await courseRef
  //         .collection('lectures')
  //         .where('lectureNumber', isEqualTo: lectureNumber)
  //         .get();

  //     if (lectureSnapshot.docs.isNotEmpty) {
  //       var lectureDoc = lectureSnapshot.docs.first;
  //       String currentDate = DateTime.now().toString().split(' ')[0];
  //       String currentTime = DateTime.now()
  //           .toString()
  //           .split(' ')[1]
  //           .substring(0, 8); // الوقت الحالي (HH:MM:SS)

  //       await lectureDoc.reference.collection('attendance').doc(studentId).set({
  //         'name': name,
  //         'imageUrl': imageUrl,
  //         currentDate: {
  //           'Check-in': currentTime,
  //           'Check-out': currentTime,
  //           'imageUrl': imageUrl,
  //         },
  //         'isStarred': false,
  //       });
  //     }
  //   } catch (e) {
  //     throw Exception('Error adding student: $e');
  //   }
  // }

  Future<void> addStudent(
    String courseId,
    int lectureNumber,
    String studentId,
    String name,
    String imageUrl,
  ) async {
    try {
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lectureSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      if (lectureSnapshot.docs.isNotEmpty) {
        var lectureDoc = lectureSnapshot.docs.first;
        String currentDate = DateTime.now().toString().split(' ')[0];
        String currentTime =
            DateTime.now().toString().split(' ')[1].substring(0, 8);
            
        // Get lecture name for notification
        var lectureData = lectureDoc.data() as Map<String, dynamic>;
        String lectureName = lectureData['name'] ?? 'Lecture $lectureNumber';

        await lectureDoc.reference.collection('attendance').doc(studentId).set({
          'name': name,
          'imageUrl': imageUrl,
          currentDate: {
            'Check-in': currentTime,
            'Check-out': currentTime,
            'imageUrl': imageUrl,
          },
          'isStarred': false,
          'bonusCount': 0, // إضافة حقل bonusCount بقيمة افتراضية 0
        });
        
        // Send attendance notification to student
        await _sendAttendanceNotification(
          studentId: studentId, 
          studentName: name,
          courseId: courseId,
          lectureName: lectureName,
          lectureNumber: lectureNumber,
          date: currentDate,
          time: currentTime
        );
      }
    } catch (e) {
      throw Exception('Error adding student: $e');
    }
  }

  // إرسال إشعار للطالب بتسجيل حضوره
  Future<void> _sendAttendanceNotification({
    required String studentId,
    required String studentName,
    required String courseId,
    required String lectureName,
    required int lectureNumber,
    required String date,
    required String time,
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
      
      // Format date for better readability
      final DateTime parsedDate = DateTime.parse(date);
      final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(parsedDate);
      
      // Create attendance notification using both methods for better coverage
      // Method 1: Using the existing createAttendanceNotification
      await _notificationService.createAttendanceNotification(
        courseName: courseName,
        studentName: studentName,
        lectureName: '$lectureName (Lecture $lectureNumber)',
        date: formattedDate,
        time: time,
        courseId: courseId,
        studentId: studentId,
      );
      
      // Method 2: Using the new createStudentAttendanceRecordedNotification
      await _notificationService.createStudentAttendanceRecordedNotification(
        studentId: studentId,
        courseId: courseId,
        lectureName: '$lectureName (Lecture $lectureNumber)',
        courseName: courseName,
      );
      
      print('Attendance notification sent to student: $studentName');
    } catch (e) {
      // Just log the error but don't throw - attendance should be recorded even if notification fails
      print('Error sending attendance notification: $e');
    }
  }

  // تحديث بيانات طالب
  Future<void> updateStudent(
    String courseId,
    int lectureNumber,
    String studentId,
    String name,
    String? imageUrl,
  ) async {
    try {
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lectureSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      if (lectureSnapshot.docs.isNotEmpty) {
        var lectureDoc = lectureSnapshot.docs.first;
        await lectureDoc.reference
            .collection('attendance')
            .doc(studentId)
            .update({
          'name': name,
          'imageUrl': imageUrl,
        });
      }
    } catch (e) {
      throw Exception('Error updating student: $e');
    }
  }

  // حذف طالب
  Future<void> deleteStudent(
      String courseId, int lectureNumber, String studentId) async {
    try {
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lectureSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      if (lectureSnapshot.docs.isNotEmpty) {
        var lectureDoc = lectureSnapshot.docs.first;
        await lectureDoc.reference
            .collection('attendance')
            .doc(studentId)
            .delete();
      }
    } catch (e) {
      throw Exception('Error deleting student: $e');
    }
  }

  // رفع الصورة إلى Firebase Storage
  Future<String> uploadImageToStorage(
      String filePath, String studentName) async {
    try {
      File file = File(filePath);
      String encodedStudentName = Uri.encodeComponent(studentName);
      String fileName =
          'faces/$encodedStudentName-${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image to Firebase Storage: $e');
    }
  }

  // // تحديث حالة الـ Star للطالب
  // Future<void> toggleStarStatus(String courseId, int lectureNumber,
  //     String studentId, bool isStarred) async {
  //   try {
  //     DocumentReference courseRef =
  //         FirebaseFirestore.instance.collection('Courses').doc(courseId);
  //     QuerySnapshot lectureSnapshot = await courseRef
  //         .collection('lectures')
  //         .where('lectureNumber', isEqualTo: lectureNumber)
  //         .get();

  //     if (lectureSnapshot.docs.isNotEmpty) {
  //       var lectureDoc = lectureSnapshot.docs.first;
  //       await lectureDoc.reference
  //           .collection('attendance')
  //           .doc(studentId)
  //           .update({
  //         'isStarred': !isStarred,
  //       });
  //     }
  //   } catch (e) {
  //     throw Exception('Error updating star status: $e');
  //   }
  // }

  // Future<void> toggleStarStatus(String courseId, int lectureNumber,
  //     String studentId, bool isStarred) async {
  //   try {
  //     DocumentReference courseRef =
  //         FirebaseFirestore.instance.collection('Courses').doc(courseId);
  //     QuerySnapshot lectureSnapshot = await courseRef
  //         .collection('lectures')
  //         .where('lectureNumber', isEqualTo: lectureNumber)
  //         .get();

  //     if (lectureSnapshot.docs.isNotEmpty) {
  //       var lectureDoc = lectureSnapshot.docs.first;
  //       DocumentReference studentRef =
  //           lectureDoc.reference.collection('attendance').doc(studentId);

  //       // جلب بيانات الطالب الحالية
  //       DocumentSnapshot studentDoc = await studentRef.get();
  //       if (studentDoc.exists) {
  //         var studentData = studentDoc.data() as Map<String, dynamic>;
  //         int currentBonusCount = studentData['bonusCount'] ?? 0;

  //         // تحديث isStarred و bonusCount
  //         await studentRef.update({
  //           'isStarred': !isStarred,
  //           'bonusCount':
  //               !isStarred ? currentBonusCount + 1 : currentBonusCount,
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     throw Exception('Error updating star status: $e');
  //   }
  // }

  Future<void> toggleStarStatus(String courseId, int lectureNumber,
      String studentId, bool isStarred) async {
    try {
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lectureSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      if (lectureSnapshot.docs.isNotEmpty) {
        var lectureDoc = lectureSnapshot.docs.first;
        DocumentReference studentRef =
            lectureDoc.reference.collection('attendance').doc(studentId);

        DocumentSnapshot studentDoc = await studentRef.get();
        if (studentDoc.exists) {
          var studentData = studentDoc.data() as Map<String, dynamic>;
          int currentBonusCount = studentData['bonusCount'] ?? 0;

          int newBonusCount;
          if (!isStarred) {
            // إذا كانت النجمة غير مفعلة وتم تفعيلها، نزيد البونص
            newBonusCount = currentBonusCount + 1;
          } else {
            // إذا كانت النجمة مفعلة وتم إلغاؤها، ننقص البونص (لكن لا يقل عن 0)
            newBonusCount = currentBonusCount - 1;
            if (newBonusCount < 0) newBonusCount = 0;
          }

          await studentRef.update({
            'isStarred': !isStarred,
            'bonusCount': newBonusCount,
          });
        }
      }
    } catch (e) {
      throw Exception('Error updating star status: $e');
    }
  }
}
