import 'package:attendance_app/features/assignments/data/models/assignment_model_admin.dart';
import 'package:attendance_app/features/assignments/data/models/question_model_admin.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomeAssignmentsViewModel extends ChangeNotifier {
  List<AssignmentModel> _assignments = [];
  int? _selectedIndex;
  bool _isLoading = true;
  bool _isProcessing = false;
  String _errorMessage = '';
  String _successMessage = '';
  String? _courseName;

  final String courseId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  List<AssignmentModel> get assignments => _assignments;
  int? get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String get courseName => _courseName ?? 'assignments';

  HomeAssignmentsViewModel({required this.courseId}) {
    _initializeAssignments();
    _fetchCourseName();
  }

  void _initializeAssignments() async {
    try {
      final snapshot = await _firestore
          .collection('Courses')
          .doc(courseId)
          .collection('assignments')
          .get();

      _assignments = snapshot.docs.map((doc) {
        final data = doc.data();
        return AssignmentModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching assignments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAssignment(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  void deleteAssignment(int index) async {
    try {
      if (_assignments.isNotEmpty && index < _assignments.length) {
        await _firestore
            .collection('Courses')
            .doc(courseId)
            .collection('assignments')
            .doc(_assignments[index].name)
            .delete();

        _assignments.removeAt(index);
        _selectedIndex = null;
        _successMessage = 'Assignment deleted successfully';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error deleting assignment: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  // Get current user's name from Firestore
  Future<String> _getCurrentUserName() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;
      if (user != null) {
        // Get user document from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // Return the user's name from Firestore
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          return userData['name'] ?? 'Unknown User';
        }
      }
      return 'Unknown User';
    } catch (e) {
      print('Error getting user name: $e');
      return 'Unknown User';
    }
  }

  Future<AssignmentModel> addAssignment(
      String name, List<QuestionModel> questions,
      {String? deadline}) async {
    _isProcessing = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);

      // Get the current user's name
      String doctorName = await _getCurrentUserName();

      final newAssignment = AssignmentModel(
        name: name,
        questions: questions,
        date: formattedDate,
        doctor: doctorName,
        version: 1,
        deadline: deadline,
      );

      await _firestore
          .collection('Courses')
          .doc(courseId)
          .collection('assignments')
          .doc(name)
          .set(newAssignment.toMap());

      _assignments.add(newAssignment);
      _successMessage = 'Assignment added successfully';
      notifyListeners();

      // إرسال إشعار لجميع الطلاب بإضافة واجب جديد
      await _sendAssignmentNotification(name);

      return newAssignment;
    } catch (e) {
      _errorMessage = 'Error adding assignment: $e';
      print(_errorMessage);
      notifyListeners();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // إرسال إشعار لجميع الطلاب بإضافة واجب جديد
  Future<void> _sendAssignmentNotification(String assignmentName) async {
    try {
      // الحصول على الواجب لمعرفة الموعد النهائي
      final index = _assignments.indexWhere((a) => a.name == assignmentName);
      String? deadline;
      
      if (index != -1) {
        deadline = _assignments[index].deadline;
      }
      
      // إضافة الإشعار إلى Firestore
      await _notificationService.sendNotificationToAllStudents(
        subject: courseName,
        description: 'New assignment added: $assignmentName',
        courseId: courseId,
        type: 'assignment',
        deadline: deadline,
      );
      
      // إرسال إشعار FCM لجميع الطلاب
      await _sendPushNotificationToAllStudents(
        title: courseName,
        body: 'New assignment added: $assignmentName',
        type: 'assignment',
        courseId: courseId,
        deadline: deadline,
      );
      
      print('Successfully sent notification to all students');
    } catch (e) {
      print('Error sending notification: $e');
      // لا نريد توقف العملية إذا فشل إرسال الإشعار
    }
  }
  
  // إرسال إشعار FCM لجميع الطلاب
  Future<void> _sendPushNotificationToAllStudents({
    required String title,
    required String body,
    required String type,
    String? courseId,
    String? deadline,
  }) async {
    try {
      // الحصول على tokens FCM لجميع الطلاب
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      // استخراج الـ FCM tokens
      final List<String> fcmTokens = [];
      for (var doc in studentsSnapshot.docs) {
        final userData = doc.data();
        if (userData.containsKey('fcmToken') && userData['fcmToken'] != null) {
          fcmTokens.add(userData['fcmToken']);
        }
      }
      
      if (fcmTokens.isEmpty) {
        print('No FCM tokens found for students');
        return;
      }
      
      // الحصول على اسم الدكتور
      String? doctorName;
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          doctorName = userDoc.data()?['name'] ?? 'Unknown';
        }
      }
      
      // إرسال الإشعار لكل token
      for (String token in fcmTokens) {
        await _sendFCMNotification(
          token: token,
          title: title,
          body: body,
          type: type,
          courseId: courseId,
          deadline: deadline,
          doctorName: doctorName,
        );
      }
    } catch (e) {
      print('Error sending FCM notification to students: $e');
    }
  }
  
  // إرسال إشعار FCM
  Future<void> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    required String type,
    String? courseId,
    String? deadline,
    String? doctorName,
  }) async {
    try {
      // استخدام Firebase Cloud Messaging API
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
      
      // استخدام مفتاح خادم FCM (يجب استبداله بمفتاح الخادم الخاص بك)
      const String serverKey = 'AAAAfPZjuO0:APA91bGeGvDVdh9NQsMUd9Nq4LlCgmg_U-P4QmKFBGGf5SQUkdAo3XBX1xEcLLYWy2bSvGEGPj-OspZPvbDUTnvE77fLHv1w_YKG3UdF5aeMwrUhEijgFEVCbFiNd7RVIz8VUt1Yei32';
      
      final now = DateTime.now();
      final formattedTime = DateFormat('HH:mm').format(now);
      
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(<String, dynamic>{
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'android_channel_id': 'high_importance_channel',
            'badge': '1',
          },
          'data': {
            'type': type,
            'courseId': courseId,
            'deadline': deadline,
            'doctorName': doctorName,
            'time': formattedTime,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'android': {
            'priority': 'high',
            'notification': {
              'notification_priority': 'PRIORITY_MAX',
              'default_sound': true,
              'default_vibrate_timings': true,
              'default_light_settings': true,
              'visibility': 'PUBLIC',
              'channel_id': 'high_importance_channel',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
                'content-available': 1,
                'mutable-content': 1,
              }
            }
          },
          'priority': 'high',
          'content_available': true,
        }),
      );
      
      if (response.statusCode == 200) {
        print('Successfully sent FCM notification');
      } else {
        print('Failed to send FCM notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  Future<void> updateAssignment(
      String assignmentId, List<QuestionModel> updatedQuestions,
      {String? deadline}) async {
    _isProcessing = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final index = _assignments.indexWhere((a) => a.name == assignmentId);
      if (index != -1) {
        final currentAssignment = _assignments[index];

        final updatedAssignment = AssignmentModel(
          name: currentAssignment.name,
          questions: updatedQuestions,
          date: currentAssignment.date,
          doctor: currentAssignment.doctor,
          version: currentAssignment.version + 1, // Increment version
          deadline: deadline ??
              currentAssignment
                  .deadline, // Keep existing deadline if not provided
        );

        await _firestore
            .collection('Courses')
            .doc(courseId)
            .collection('assignments')
            .doc(assignmentId)
            .update(updatedAssignment.toMap());

        _assignments[index] = updatedAssignment;
        _successMessage = 'Assignment updated successfully';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating assignment: $e';
      print(_errorMessage);
      notifyListeners();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> updateAssignmentDetails(String assignmentId,
      {required String newName, String? deadline}) async {
    _isProcessing = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final index = _assignments.indexWhere((a) => a.name == assignmentId);
      if (index != -1) {
        final currentAssignment = _assignments[index];

        // Create updated assignment with new name and/or deadline
        final updatedAssignment = AssignmentModel(
          name: newName,
          questions: currentAssignment.questions,
          date: currentAssignment.date,
          doctor: currentAssignment.doctor,
          version: currentAssignment.version + 1, // Increment version
          deadline: deadline ??
              currentAssignment.deadline, // Update deadline if provided
        );

        // If the name has changed, we need to delete the old document and create a new one
        if (assignmentId != newName) {
          // Create a batch to perform multiple operations
          final batch = _firestore.batch();

          // Reference to the old document
          final oldDocRef = _firestore
              .collection('Courses')
              .doc(courseId)
              .collection('assignments')
              .doc(assignmentId);

          // Reference to the new document
          final newDocRef = _firestore
              .collection('Courses')
              .doc(courseId)
              .collection('assignments')
              .doc(newName);

          // Set the new document with updated data
          batch.set(newDocRef, updatedAssignment.toMap());

          // Delete the old document
          batch.delete(oldDocRef);

          // Commit the batch
          await batch.commit();
        } else {
          // Just update the existing document with new deadline
          await _firestore
              .collection('Courses')
              .doc(courseId)
              .collection('assignments')
              .doc(assignmentId)
              .update(updatedAssignment.toMap());
        }

        // Update the local list
        _assignments[index] = updatedAssignment;
        _successMessage = 'Assignment details updated successfully';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating assignment details: $e';
      print(_errorMessage);
      notifyListeners();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCourseName() async {
    try {
      final courseDoc =
          await _firestore.collection('Courses').doc(courseId).get();

      if (courseDoc.exists) {
        final courseData = courseDoc.data();
        _courseName = courseData?['courseName'] as String?;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching course name: $e');
    }
  }
}
