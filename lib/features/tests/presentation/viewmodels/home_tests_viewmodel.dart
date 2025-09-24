import 'package:attendance_app/features/tests/data/models/tests_model_admin.dart';
import 'package:attendance_app/features/tests/data/models/tests_question_model_admin.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestsHomeViewModel extends ChangeNotifier {
  List<TestsAssignmentModel> _assignments = [];
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

  List<TestsAssignmentModel> get assignments => _assignments;
  int? get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String get courseName => _courseName ?? 'tests';

  TestsHomeViewModel({required this.courseId}) {
    _initializeAssignments();
    _fetchCourseName();
  }

  void _initializeAssignments() async {
    try {
      final snapshot = await _firestore
          .collection('Courses')
          .doc(courseId)
          .collection('tests')
          .get();

      _assignments = snapshot.docs.map((doc) {
        final data = doc.data();
        return TestsAssignmentModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching tests: $e');
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
            .collection('tests')
            .doc(_assignments[index].name)
            .delete();

        _assignments.removeAt(index);
        _selectedIndex = null;
        _successMessage = 'Test deleted successfully';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error deleting test: $e';
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

  Future<TestsAssignmentModel> addAssignment(
      String name, List<TestsQuestionModel> questions,
      {String? examDate, String? startTime, String? endTime}) async {
    _isProcessing = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);

      // Get the current user's name
      String doctorName = await _getCurrentUserName();

      final newAssignment = TestsAssignmentModel(
        name: name,
        questions: questions,
        date: formattedDate,
        doctor: doctorName,
        version: 1,
        examDate: examDate,
        startTime: startTime,
        endTime: endTime,
      );

      await _firestore
          .collection('Courses')
          .doc(courseId)
          .collection('tests')
          .doc(name)
          .set(newAssignment.toMap());

      _assignments.add(newAssignment);
      _successMessage = 'Test added successfully';
      notifyListeners();

      // Send notification to all students about new test
      await _sendTestNotification(name, examDate, startTime);

      return newAssignment;
    } catch (e) {
      _errorMessage = 'Error adding test: $e';
      print(_errorMessage);
      notifyListeners();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Send notification to all students about new test
  Future<void> _sendTestNotification(String testName, String? examDate, String? startTime) async {
    try {
      // Create notification details with exam date and time
      String description = 'New test added: $testName';
      if (examDate != null) {
        description += ' (Date: $examDate';
        if (startTime != null) {
          description += ', Start time: $startTime';
        }
        description += ')';
      }
      
      // Create a specific test notification
      // Get all student IDs first
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toList();
      
      // Create a single notification with all student recipients
      await _notificationService.createNotification(
        subject: courseName,
        description: description,
        courseId: courseId,
        type: 'test',
        deadline: examDate,
        recipients: studentIds,
        isRead: false,
      );
      
      // Send FCM push notification to all students
      await _sendPushNotificationToAllStudents(
        title: courseName,
        body: description,
        type: 'test',
        courseId: courseId,
        deadline: examDate,
      );
      
      print('Successfully sent test notification to all students');
    } catch (e) {
      print('Error sending test notification: $e');
      // We don't want to stop the process if notification fails
    }
  }
  
  // Send FCM push notification to all students
  Future<void> _sendPushNotificationToAllStudents({
    required String title,
    required String body,
    required String type,
    String? courseId,
    String? deadline,
  }) async {
    try {
      // Get FCM tokens for all students
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      // Extract FCM tokens
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
      
      // Firebase Cloud Messaging API
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
      
      // Use your Firebase Cloud Messaging server key
      const String serverKey = 'AAAAfPZjuO0:APA91bGeGvDVdh9NQsMUd9Nq4LlCgmg_U-P4QmKFBGGf5SQUkdAo3XBX1xEcLLYWy2bSvGEGPj-OspZPvbDUTnvE77fLHv1w_YKG3UdF5aeMwrUhEijgFEVCbFiNd7RVIz8VUt1Yei32';
      
      // Send notification to each token
      for (String token in fcmTokens) {
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
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  Future<void> updateAssignment(
      String assignmentId, List<TestsQuestionModel> updatedQuestions,
      {String? examDate, String? startTime, String? endTime}) async {
    _isProcessing = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final index = _assignments.indexWhere((a) => a.name == assignmentId);
      if (index != -1) {
        final currentAssignment = _assignments[index];

        final updatedAssignment = TestsAssignmentModel(
          name: currentAssignment.name,
          questions: updatedQuestions,
          date: currentAssignment.date,
          doctor: currentAssignment.doctor,
          version: currentAssignment.version + 1, // Increment version
          examDate: examDate ?? currentAssignment.examDate,
          startTime: startTime ?? currentAssignment.startTime,
          endTime: endTime ?? currentAssignment.endTime,
        );

        await _firestore
            .collection('Courses')
            .doc(courseId)
            .collection('tests')
            .doc(assignmentId)
            .update(updatedAssignment.toMap());

        _assignments[index] = updatedAssignment;
        _successMessage = 'Test updated successfully';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating test: $e';
      print(_errorMessage);
      notifyListeners();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> updateAssignmentDetails(String assignmentId,
      {required String newName,
      String? examDate,
      String? startTime,
      String? endTime}) async {
    _isProcessing = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final index = _assignments.indexWhere((a) => a.name == assignmentId);
      if (index != -1) {
        final currentAssignment = _assignments[index];

        // Create updated assignment with new details
        final updatedAssignment = TestsAssignmentModel(
          name: newName,
          questions: currentAssignment.questions,
          date: currentAssignment.date,
          doctor: currentAssignment.doctor,
          version: currentAssignment.version + 1, // Increment version
          examDate: examDate ?? currentAssignment.examDate,
          startTime: startTime ?? currentAssignment.startTime,
          endTime: endTime ?? currentAssignment.endTime,
        );

        // If the name has changed, we need to delete the old document and create a new one
        if (assignmentId != newName) {
          // Create a batch to perform multiple operations
          final batch = _firestore.batch();

          // Reference to the old document
          final oldDocRef = _firestore
              .collection('Courses')
              .doc(courseId)
              .collection('tests')
              .doc(assignmentId);

          // Reference to the new document
          final newDocRef = _firestore
              .collection('Courses')
              .doc(courseId)
              .collection('tests')
              .doc(newName);

          // Set the new document with updated data
          batch.set(newDocRef, updatedAssignment.toMap());

          // Delete the old document
          batch.delete(oldDocRef);

          // Commit the batch
          await batch.commit();
        } else {
          // Just update the existing document with new details
          await _firestore
              .collection('Courses')
              .doc(courseId)
              .collection('tests')
              .doc(assignmentId)
              .update(updatedAssignment.toMap());
        }

        // Update the local list
        _assignments[index] = updatedAssignment;
        _successMessage = 'Test details updated successfully';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating test details: $e';
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
