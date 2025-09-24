import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
import 'package:attendance_app/features/questionnaire/data/models/questionnaire_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';

class HomeQuestionnairesViewModel extends ChangeNotifier {
  final String courseId;
  List<QuestionnaireModel> _questionnaires = [];
  List<bool> _isCompletedList = [];
  List<bool> _isModifiedList = [];
  bool isLoading = false;
  int _selectedQuestionnaireIndex = -1;
  final NotificationService _notificationService = NotificationService();

  HomeQuestionnairesViewModel({required this.courseId}) {
    _initializeQuestionnaires();
  }

  List<QuestionnaireModel> get questionnaires => _questionnaires;
  List<bool> get isCompletedList => _isCompletedList;
  List<bool> get isModifiedList => _isModifiedList;

  Future<void> _initializeQuestionnaires() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      final snapshot = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('questionnaires')
          .get();

      _questionnaires = snapshot.docs
          .map((doc) => QuestionnaireModel.fromMap({
                ...doc.data(),
                'name': doc.id,
              }))
          .toList();

      _isCompletedList = [];
      _isModifiedList = [];

      if (user != null) {
        for (final questionnaire in _questionnaires) {
          final filledSnapshot = await FirebaseFirestore.instance
              .collection('Courses')
              .doc(courseId)
              .collection('questionnaires')
              .doc(questionnaire.name)
              .collection('filledBy')
              .doc(user.uid)
              .get();

          bool isCompleted = filledSnapshot.exists;
          bool isModified = false;

          if (isCompleted) {
            final filledData = filledSnapshot.data() as Map<String, dynamic>;
            final completedVersion =
                filledData['completedVersion'] as int? ?? 1;
            isModified = completedVersion < questionnaire.version;
            isCompleted = completedVersion >= questionnaire.version;
          }

          _isCompletedList.add(isCompleted);
          _isModifiedList.add(isModified);
        }
      } else {
        _isCompletedList = List.filled(_questionnaires.length, false);
        _isModifiedList = List.filled(_questionnaires.length, false);
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing questionnaires: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addQuestionnaire(List<QuestionModel> questions) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
      final user = FirebaseAuth.instance.currentUser;
      String doctor = 'Unknown';

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        doctor = userDoc.data()?['name'] ?? 'Unknown';
      }

      final newQuestionnaireId = FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('questionnaires')
          .doc()
          .id;
          
      final questionnaireName = 'Questionnaire $newQuestionnaireId';

      await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('questionnaires')
          .doc(newQuestionnaireId)
          .set({
        'name': questionnaireName,
        'questions': questions.map((q) => q.toMap()).toList(),
        'version': 1,
        'date': formattedDate,
        'doctor': doctor,
      });

      _questionnaires.add(QuestionnaireModel(
        name: newQuestionnaireId,
        questions: questions,
        date: formattedDate,
        doctor: doctor,
        version: 1,
      ));
      _isCompletedList.add(false);
      _isModifiedList.add(false);
      notifyListeners();
      
      // Send notification to all students
      await _sendQuestionnaireNotification(questionnaireName, formattedDate);
    } catch (e) {
      print('Error adding questionnaire: $e');
      rethrow;
    }
  }
  
  // Send notification to all students about new questionnaire
  Future<void> _sendQuestionnaireNotification(String questionnaireName, String date) async {
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
      
      // Parse the date for formatting
      final now = DateTime.now();
      final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
      final formattedTime = DateFormat('h:mm a').format(now);
      
      // Get all students enrolled in this course
      final enrolledStudents = <String>[];
      
      // First, get all users with student role
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      // Filter students who are enrolled in this course
      for (final studentDoc in studentsSnapshot.docs) {
        final studentData = studentDoc.data();
        final List<dynamic> enrolledCourses = studentData['enrolledCourses'] ?? [];
        
        // Get course code
        final courseCode = (await FirebaseFirestore.instance
            .collection('Courses')
            .doc(courseId)
            .get()).data()?['courseCode'];
        
        if (courseCode != null && enrolledCourses.contains(courseCode)) {
          enrolledStudents.add(studentDoc.id);
        }
      }
      
      if (enrolledStudents.isEmpty) {
        print('No enrolled students found for this course');
        return;
      }
      
      // Create notification using the dedicated method
      await _notificationService.createQuestionnaireNotification(
        courseName: courseName,
        questionnaireName: questionnaireName,
        date: formattedDate,
        time: formattedTime,
        courseId: courseId,
        recipients: enrolledStudents,
      );
      
      print('Questionnaire notification sent to ${enrolledStudents.length} students');
    } catch (e) {
      print('Error sending questionnaire notification: $e');
      // We don't want to stop the process if notification fails
    }
  }

  Future<void> updateQuestionnaire(
      String questionnaireId, List<QuestionModel> newQuestions) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('questionnaires')
          .doc(questionnaireId)
          .get();

      if (!doc.exists) {
        throw Exception('Questionnaire not found');
      }

      final currentData = doc.data() as Map<String, dynamic>;
      final currentVersion = currentData['version'] as int? ?? 1;

      await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('questionnaires')
          .doc(questionnaireId)
          .set({
        'questions': newQuestions.map((q) => q.toMap()).toList(),
        'version': currentVersion + 1,
        'name': currentData['name'],
        'date': currentData['date'],
        'doctor': currentData['doctor'],
      }, SetOptions(merge: true));

      final index = _questionnaires.indexWhere((q) => q.name == questionnaireId);
      if (index != -1) {
        _questionnaires[index] = QuestionnaireModel(
          name: questionnaireId,
          questions: newQuestions,
          date: currentData['date'],
          doctor: currentData['doctor'],
          version: currentVersion + 1,
        );
        _isCompletedList[index] = false;
        _isModifiedList[index] = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating questionnaire: $e');
      rethrow;
    }
  }

  Future<void> deleteQuestionnaire(int index) async {
    try {
      final questionnaireId = _questionnaires[index].name;
      await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('questionnaires')
          .doc(questionnaireId)
          .delete();

      _questionnaires.removeAt(index);
      _isCompletedList.removeAt(index);
      _isModifiedList.removeAt(index);
      _selectedQuestionnaireIndex = -1;
      notifyListeners();
    } catch (e) {
      print('Error deleting questionnaire: $e');
      rethrow;
    }
  }

  void selectQuestionnaire(int index) {
    _selectedQuestionnaireIndex = index;
    notifyListeners();
  }

  void markQuestionnaireAsCompleted(String questionnaireId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Courses')
            .doc(courseId)
            .collection('questionnaires')
            .doc(questionnaireId)
            .get();

        if (!doc.exists) {
          throw Exception('Questionnaire not found');
        }

        final version = doc.data()!['version'] as int? ?? 1;

        await FirebaseFirestore.instance
            .collection('Courses')
            .doc(courseId)
            .collection('questionnaires')
            .doc(questionnaireId)
            .collection('filledBy')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'completedVersion': version,
        }, SetOptions(merge: true));

        final index =
            _questionnaires.indexWhere((q) => q.name == questionnaireId);
        if (index != -1) {
          _isCompletedList[index] = true;
          _isModifiedList[index] = false;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error marking questionnaire as completed: $e');
    }
  }
}
