import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/features/assignments/data/models/student_assignment_response.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignmentSubmissionsViewModel with ChangeNotifier {
  final String adminId; // This could be userId or courseId
  final String assignmentId;
  final String courseName;
  List<StudentAssignmentSubmission> _submissions = [];
  bool _isLoading = false;
  String _successMessage = '';
  String _errorMessage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add maps to store question data
  Map<String, dynamic> _questionData = {};
  Map<String, List<dynamic>> _optionsData = {};
  final Map<String, int> _correctAnswers = {};

  AssignmentSubmissionsViewModel({
    required this.adminId,
    required this.assignmentId,
    required this.courseName,
  });

  ///////////////
  // Add isAdmin getter
  bool get isAdmin {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('No user is logged in');
      return false;
    }
    final bool isAdminUser = currentUser.uid == adminId;
    print(
        'Checking isAdmin: currentUser.uid=${currentUser.uid}, adminId=$adminId, isAdmin=$isAdminUser');
    return isAdminUser;
  }

  List<StudentAssignmentSubmission> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String get successMessage => _successMessage;
  String get errorMessage => _errorMessage;

  // Getters for question data
  Map<String, dynamic> get questionData => _questionData;
  Map<String, List<dynamic>> get optionsData => _optionsData;
  Map<String, int> get correctAnswers => _correctAnswers;

  Future<String?> _findCourseDocumentId() async {
    try {
      print('Looking for course document with name: $courseName');

      // First try to find the course by courseName (most direct approach)
      final courseNameQuery = await _firestore
          .collection('Courses')
          .where('courseName', isEqualTo: courseName)
          .get();

      if (courseNameQuery.docs.isNotEmpty) {
        final docId = courseNameQuery.docs.first.id;
        print('Found course with matching courseName: $docId');
        return docId;
      }

      // Then check if adminId is directly a valid course document ID
      final directCheck =
          await _firestore.collection('Courses').doc(adminId).get();
      if (directCheck.exists) {
        print('Found course document directly with ID: $adminId');
        return adminId;
      }

      // If not, try to find a course document where the current user is the owner
      print('Looking for courses where user $adminId is the owner');

      // Get current user ID
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('Current user ID: $currentUserId');

      // Query for courses owned by current user
      final querySnapshot = await _firestore
          .collection('Courses')
          .where('adminId', isEqualTo: currentUserId)
          .get();

      print('Found ${querySnapshot.docs.length} courses owned by current user');

      if (querySnapshot.docs.isNotEmpty) {
        // Return the ID of the first matching document
        final docId = querySnapshot.docs.first.id;
        print('Using course document ID: $docId');
        return docId;
      }

      print('No matching course document found');
      return null;
    } catch (e) {
      print('Error finding course document: $e');
      return null;
    }
  }

  // دالة لجلب نص السؤال بناءً على questionId
  String? getQuestionText(String questionId) {
    final question = _questionData[questionId];
    if (question != null) {
      return question['text'] as String? ??
          question['questionText'] as String? ??
          'Solve this Question';
    }
    return 'Solve this Question';
  }

  // دالة لتحديث StudentResponse في القائمة
  void updateResponse(
      String studentId, String questionId, StudentResponse updatedResponse) {
    final submissionIndex =
        _submissions.indexWhere((s) => s.studentId == studentId);
    if (submissionIndex != -1) {
      final submission = _submissions[submissionIndex];
      final responseIndex =
          submission.responses.indexWhere((r) => r.questionId == questionId);
      if (responseIndex != -1) {
        submission.responses[responseIndex] = updatedResponse;
        notifyListeners();
      }
    }
  }

  // Future<void> _fetchQuestionData(String courseDocId) async {
  //   try {
  //     final assignmentDocRef = _firestore
  //         .collection('Courses')
  //         .doc(courseDocId)
  //         .collection('assignments')
  //         .doc(assignmentId);

  //     final assignmentDoc = await assignmentDocRef.get();
  //     if (!assignmentDoc.exists) {
  //       throw Exception('Assignment document not found');
  //     }

  //     Map<String, dynamic> questionDataMap = {};
  //     Map<String, List<dynamic>> optionsDataMap = {};
  //     Map<String, int> correctAnswersMap = {};

  //     // First approach: Check if questions are embedded in assignment document
  //     Map<String, dynamic> assignmentData =
  //         assignmentDoc.data() as Map<String, dynamic>;

  //     if (assignmentData.containsKey('questions') &&
  //         assignmentData['questions'] is List) {
  //       print('Found embedded questions in assignment document');
  //       List<dynamic> questionsList = assignmentData['questions'];

  //       for (var question in questionsList) {
  //         if (question is Map<String, dynamic>) {
  //           final questionId = question['id'] as String? ??
  //               question['questionId'] as String? ??
  //               '';
  //           if (questionId.isNotEmpty) {
  //             questionDataMap[questionId] = question;

  //             if (question['type'] == 'multiple_choice' ||
  //                 question['type'] == 'MCQ') {
  //               if (question['options'] != null &&
  //                   question['options'] is List) {
  //                 optionsDataMap[questionId] = question['options'] as List;
  //               }

  //               // Store correct answer
  //               if (question['correctOption'] != null) {
  //                 correctAnswersMap[questionId] =
  //                     question['correctOption'] as int;
  //               } else if (question['correct'] != null) {
  //                 var correctValue = question['correct'];
  //                 if (correctValue is String) {
  //                   // For true/false values, true=0, false=1
  //                   if (correctValue.toLowerCase() == 'true') {
  //                     correctAnswersMap[questionId] = 0; // True is option 0
  //                   } else if (correctValue.toLowerCase() == 'false') {
  //                     correctAnswersMap[questionId] = 1; // False is option 1
  //                   } else {
  //                     // Try to parse as int
  //                     try {
  //                       correctAnswersMap[questionId] = int.parse(correctValue);
  //                     } catch (_) {
  //                       // Ignore parse errors
  //                     }
  //                   }
  //                 } else if (correctValue is int) {
  //                   correctAnswersMap[questionId] = correctValue;
  //                 } else if (correctValue is bool) {
  //                   correctAnswersMap[questionId] =
  //                       correctValue ? 0 : 1; // true=0, false=1
  //                 }
  //               }
  //             } else if (question['type'] == 'true_false') {
  //               // For true/false, store the correct answer
  //               var correctValue = question['correctOption'] ??
  //                   question['correct'] ??
  //                   question['isTrue'];

  //               if (correctValue is String) {
  //                 correctAnswersMap[questionId] =
  //                     correctValue.toLowerCase() == 'true'
  //                         ? 0
  //                         : 1; // true=0, false=1
  //               } else if (correctValue is bool) {
  //                 correctAnswersMap[questionId] =
  //                     correctValue ? 0 : 1; // true=0, false=1
  //               } else if (correctValue is int) {
  //                 correctAnswersMap[questionId] = correctValue;
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }

  //     // Second approach: Check questions subcollection
  //     if (questionDataMap.isEmpty) {
  //       print('Fetching questions from subcollection');

  //       final questionsQuery =
  //           await assignmentDocRef.collection('questions').get();

  //       for (var questionDoc in questionsQuery.docs) {
  //         final data = questionDoc.data();
  //         final questionId = questionDoc.id;

  //         questionDataMap[questionId] = data;

  //         if (data['type'] == 'multiple_choice' || data['type'] == 'MCQ') {
  //           if (data['options'] != null && data['options'] is List) {
  //             optionsDataMap[questionId] = data['options'] as List;
  //           }

  //           // Store correct answer
  //           if (data['correctOption'] != null) {
  //             correctAnswersMap[questionId] = data['correctOption'] as int;
  //           } else if (data['correct'] != null) {
  //             var correctValue = data['correct'];
  //             if (correctValue is String) {
  //               // For true/false values, true=0, false=1
  //               if (correctValue.toLowerCase() == 'true') {
  //                 correctAnswersMap[questionId] = 0; // True is option 0
  //               } else if (correctValue.toLowerCase() == 'false') {
  //                 correctAnswersMap[questionId] = 1; // False is option 1
  //               } else {
  //                 // Try to parse as int
  //                 try {
  //                   correctAnswersMap[questionId] = int.parse(correctValue);
  //                 } catch (_) {
  //                   // Ignore parse errors
  //                 }
  //               }
  //             } else if (correctValue is int) {
  //               correctAnswersMap[questionId] = correctValue;
  //             } else if (correctValue is bool) {
  //               correctAnswersMap[questionId] =
  //                   correctValue ? 0 : 1; // true=0, false=1
  //             }
  //           }
  //         } else if (data['type'] == 'true_false') {
  //           // For true/false, store the correct answer
  //           var correctValue =
  //               data['correctOption'] ?? data['correct'] ?? data['isTrue'];

  //           if (correctValue is String) {
  //             correctAnswersMap[questionId] =
  //                 correctValue.toLowerCase() == 'true'
  //                     ? 0
  //                     : 1; // true=0, false=1
  //           } else if (correctValue is bool) {
  //             correctAnswersMap[questionId] =
  //                 correctValue ? 0 : 1; // true=0, false=1
  //           } else if (correctValue is int) {
  //             correctAnswersMap[questionId] = correctValue;
  //           }
  //         }
  //       }
  //     }

  //     _questionData = questionDataMap;
  //     _optionsData = optionsDataMap;
  //     _correctAnswers = correctAnswersMap;

  //     print('Loaded question data: ${_questionData.length} questions');
  //   } catch (e) {
  //     print('Error fetching question data: $e');
  //   }
  // }

  Future<void> _fetchQuestionData(String courseDocId) async {
    try {
      final assignmentDocRef = _firestore
          .collection('Courses')
          .doc(courseDocId)
          .collection('assignments')
          .doc(assignmentId);

      final assignmentDoc = await assignmentDocRef.get();
      if (!assignmentDoc.exists) {
        throw Exception('Assignment document not found');
      }

      Map<String, dynamic> questionDataMap = {};
      Map<String, List<dynamic>> optionsDataMap = {};

      // First approach: Check if questions are embedded in assignment document
      Map<String, dynamic> assignmentData =
          assignmentDoc.data() as Map<String, dynamic>;

      print('🔍 Raw assignment data: $assignmentData');

      if (assignmentData.containsKey('questions') &&
          assignmentData['questions'] is List) {
        print('Found embedded questions in assignment document');
        List<dynamic> questionsList = assignmentData['questions'];

        for (var question in questionsList) {
          if (question is Map<String, dynamic>) {
            final questionId = question['id'] as String? ??
                question['questionId'] as String? ??
                '';
            if (questionId.isNotEmpty) {
              print('🔍 Raw question data for $questionId: $question');
              questionDataMap[questionId] = question;

              if (question['type'] == 'multiple_choice' ||
                  question['type'] == 'MCQ') {
                if (question['options'] != null &&
                    question['options'] is List) {
                  optionsDataMap[questionId] = question['options'] as List;
                }
              }
            }
          }
        }
      }

      // Second approach: Check questions subcollection
      if (questionDataMap.isEmpty) {
        print('Fetching questions from subcollection');

        final questionsQuery =
            await assignmentDocRef.collection('questions').get();

        for (var questionDoc in questionsQuery.docs) {
          final data = questionDoc.data();
          final questionId = questionDoc.id;

          print(
              '🔍 Raw question data from subcollection for $questionId: $data');
          questionDataMap[questionId] = data;

          if (data['type'] == 'multiple_choice' || data['type'] == 'MCQ') {
            if (data['options'] != null && data['options'] is List) {
              optionsDataMap[questionId] = data['options'] as List;
            }
          }
        }
      }

      _questionData = questionDataMap;
      _optionsData = optionsDataMap;

      print('🔍 Final _questionData: $_questionData');
      print('🔍 Final _optionsData: $_optionsData');
    } catch (e) {
      print('Error fetching question data: $e');
    }
  }

  // Future<void> fetchSubmissions() async {
  //   _isLoading = true;
  //   _errorMessage = '';
  //   notifyListeners();

  //   try {
  //     print(
  //         'Fetching submissions for adminId: $adminId, courseName: $courseName, assignmentId: $assignmentId');

  //     // First, find the correct course document ID
  //     final courseDocId = await _findCourseDocumentId();
  //     if (courseDocId == null) {
  //       throw Exception(
  //           'Could not find a course document for user $adminId and courseName $courseName');
  //     }

  //     print('Using course document ID: $courseDocId');

  //     // Fetch question data first
  //     await _fetchQuestionData(courseDocId);

  //     // Build the correct path to the submissions
  //     final coursesRef = _firestore.collection('Courses');
  //     final courseDocRef = coursesRef.doc(courseDocId);

  //     print('Checking if course document exists at path: ${courseDocRef.path}');
  //     final courseDocSnapshot = await courseDocRef.get();
  //     if (!courseDocSnapshot.exists) {
  //       throw Exception('Course document not found with ID: $courseDocId');
  //     }

  //     // Access assignments collection directly under the course document
  //     final assignmentsCollectionRef = courseDocRef.collection('assignments');
  //     final assignmentDocRef = assignmentsCollectionRef.doc(assignmentId);

  //     // Check if assignment exists
  //     final assignmentDocSnapshot = await assignmentDocRef.get();
  //     if (!assignmentDocSnapshot.exists) {
  //       throw Exception('Assignment document not found with ID: $assignmentId');
  //     }

  //     // Create path for student submissions and status
  //     final studentSubmitsCollection =
  //         assignmentDocRef.collection('studentSubmits');
  //     final studentStatusCollection =
  //         assignmentDocRef.collection('studentStatus');

  //     print('Fetching submissions from: ${studentSubmitsCollection.path}');
  //     final submissionsSnapshot = await studentSubmitsCollection.get();

  //     print('Fetching student status from: ${studentStatusCollection.path}');
  //     final studentStatusSnapshot = await studentStatusCollection.get();

  //     print(
  //         'Found ${submissionsSnapshot.docs.length} submissions and ${studentStatusSnapshot.docs.length} status records');

  //     final Map<String, StudentAssignmentSubmission> submissionsMap = {};

  //     // Process submissions from studentSubmits collection
  //     for (var doc in submissionsSnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>? ?? {};
  //       final studentId = data['studentId'] as String? ?? doc.id;
  //       final studentName = data['studentName'] as String? ?? 'Unknown Student';

  //       // Parse date fields
  //       DateTime submittedAt;
  //       try {
  //         final timestamp = data['submittedAt'] as Timestamp?;
  //         if (timestamp != null) {
  //           submittedAt = timestamp.toDate();
  //         } else {
  //           submittedAt = DateTime.now();
  //         }
  //       } catch (e) {
  //         print('Error parsing submittedAt date: $e');
  //         submittedAt = DateTime.now();
  //       }

  //       // Get questions data from the new format
  //       final List<dynamic> questionsData =
  //           data['questions'] as List<dynamic>? ?? [];
  //       List<StudentResponse> responses = [];

  //       for (var questionData in questionsData) {
  //         final Map<String, dynamic> qData =
  //             questionData as Map<String, dynamic>;

  //         final questionId = qData['questionId'] as String? ?? '';
  //         final questionType = qData['questionType'] as String? ?? '';
  //         final selectedOptionIndex = qData['selectedOptionIndex'] as int?;
  //         final isCorrect = qData['isCorrect'] as bool?;
  //         final score = qData['score'] as int?;

  //         // Handle file upload questions
  //         String? fileUrl;
  //         String? fileName;
  //         if (questionType == 'file') {
  //           fileUrl = qData['fileUrl'] as String?;
  //           fileName = qData['fileName'] as String?;
  //         }

  //         // Get text-based answers for display
  //         final selectedAnswerText = qData['selectedAnswerText'] as String?;
  //         final correctAnswerText = qData['correctAnswerText'] as String?;

  //         // Create response object for the view
  //         final response = StudentResponse(
  //           questionId: questionId,
  //           questionType: questionType,
  //           selectedOption: selectedOptionIndex,
  //           selectedAnswerText: selectedAnswerText,
  //           correctAnswerText: correctAnswerText,
  //           fileUrl: fileUrl,
  //           fileName: fileName,
  //           isCorrect: isCorrect,
  //           score: score,
  //           teacherComment: qData['teacherComment'] as String?,
  //         );

  //         responses.add(response);
  //       }

  //       // Calculate scores
  //       final totalScore = data['totalScore'] as int? ?? 0;
  //       final maxScore = data['maxScore'] as int? ?? responses.length;
  //       final scorePercentage = data['scorePercentage'] as int? ?? 0;
  //       final scoreDisplay = '$totalScore/$maxScore ($scorePercentage%)';
  //       final status = data['status'] as String? ?? 'submitted';

  //       // Create submission object
  //       submissionsMap[studentId] = StudentAssignmentSubmission(
  //         assignmentId: assignmentId,
  //         studentId: studentId,
  //         studentName: studentName,
  //         responses: responses,
  //         totalScore: totalScore,
  //         maxScore: maxScore,
  //         scorePercentage: scorePercentage,
  //         scoreDisplay: scoreDisplay,
  //         status: status,
  //         submittedAt: submittedAt,
  //         gradedAt: null,
  //         teacherComment: data['teacherComment'] as String?,
  //       );
  //     }

  //     // Check student status for any submissions not already found
  //     for (var doc in studentStatusSnapshot.docs) {
  //       if (doc.exists) {
  //         final data = doc.data() as Map<String, dynamic>? ?? {};
  //         final studentId = doc.id;

  //         // Only process if we don't already have this student in our submissions
  //         if (!submissionsMap.containsKey(studentId)) {
  //           // Check if the student has completed the assignment
  //           final isCompleted = data['isCompleted'] as bool? ?? false;

  //           if (isCompleted) {
  //             // Get student details from users collection
  //             final userDoc =
  //                 await _firestore.collection('users').doc(studentId).get();

  //             final userData = userDoc.exists
  //                 ? userDoc.data() as Map<String, dynamic>? ?? {}
  //                 : {};
  //             final studentName =
  //                 userData['name'] as String? ?? 'Unknown Student';

  //             // Check if there's a submission in the new collection
  //             final submissionDoc =
  //                 await studentSubmitsCollection.doc(studentId).get();
  //             if (submissionDoc.exists) {
  //               continue; // Already processed this submission
  //             }

  //             // If no submission found, create a placeholder
  //             final scoreStr = data['score'] as String? ?? 'Not available';
  //             int? scorePercentage;

  //             if (scoreStr.contains('%')) {
  //               try {
  //                 scorePercentage =
  //                     int.parse(scoreStr.replaceAll('%', '').trim());
  //               } catch (e) {
  //                 scorePercentage = null;
  //               }
  //             }

  //             final submittedAt =
  //                 DateTime.now(); // Use current time as fallback
  //             final List<StudentResponse> responses = [];

  //             submissionsMap[studentId] = StudentAssignmentSubmission(
  //               assignmentId: assignmentId,
  //               studentId: studentId,
  //               studentName: studentName,
  //               responses: responses,
  //               totalScore: null,
  //               maxScore: 0,
  //               scorePercentage: scorePercentage,
  //               scoreDisplay: scoreStr,
  //               status: 'submitted',
  //               submittedAt: submittedAt,
  //               gradedAt: null,
  //               teacherComment: null,
  //             );
  //           }
  //         }
  //       }
  //     }

  //     _submissions = submissionsMap.values.toList();

  //     // Sort submissions by date (newest first)
  //     _submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

  //     if (_submissions.isEmpty) {
  //       print(
  //           'No submissions found for course: $courseDocId, courseName: $courseName, assignmentId: $assignmentId');
  //     } else {
  //       print('Loaded ${_submissions.length} submissions successfully');
  //     }

  //     _successMessage = 'Submissions loaded successfully';
  //   } catch (e) {
  //     _errorMessage = 'Failed to load submissions: $e';
  //     print('Error fetching submissions: $e');
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchSubmissions() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print(
          'Fetching submissions for adminId: $adminId, courseName: $courseName, assignmentId: $assignmentId');

      // First, find the correct course document ID
      final courseDocId = await _findCourseDocumentId();
      if (courseDocId == null) {
        throw Exception(
            'Could not find a course document for user $adminId and courseName $courseName');
      }

      print('Using course document ID: $courseDocId');

      // Fetch question data first
      await _fetchQuestionData(courseDocId);

      // Build the correct path to the submissions
      final coursesRef = _firestore.collection('Courses');
      final courseDocRef = coursesRef.doc(courseDocId);

      print('Checking if course document exists at path: ${courseDocRef.path}');
      final courseDocSnapshot = await courseDocRef.get();
      if (!courseDocSnapshot.exists) {
        throw Exception('Course document not found with ID: $courseDocId');
      }

      // Access assignments collection directly under the course document
      final assignmentsCollectionRef = courseDocRef.collection('assignments');
      final assignmentDocRef = assignmentsCollectionRef.doc(assignmentId);

      // Check if assignment exists
      final assignmentDocSnapshot = await assignmentDocRef.get();
      if (!assignmentDocSnapshot.exists) {
        throw Exception('Assignment document not found with ID: $assignmentId');
      }

      // Create path for student submissions and status
      final studentSubmitsCollection =
          assignmentDocRef.collection('studentSubmits');
      final studentStatusCollection =
          assignmentDocRef.collection('studentStatus');

      print('Fetching submissions from: ${studentSubmitsCollection.path}');
      final submissionsSnapshot = await studentSubmitsCollection.get();

      print('Fetching student status from: ${studentStatusCollection.path}');
      final studentStatusSnapshot = await studentStatusCollection.get();

      print(
          'Found ${submissionsSnapshot.docs.length} submissions and ${studentStatusSnapshot.docs.length} status records');

      final Map<String, StudentAssignmentSubmission> submissionsMap = {};

      // Process submissions from studentSubmits collection
      for (var doc in submissionsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final studentId = data['studentId'] as String? ?? doc.id;
        final studentName = data['studentName'] as String? ?? 'Unknown Student';

        // Parse date fields
        DateTime submittedAt;
        try {
          final timestamp = data['submittedAt'] as Timestamp?;
          if (timestamp != null) {
            submittedAt = timestamp.toDate();
          } else {
            submittedAt = DateTime.now();
          }
        } catch (e) {
          print('Error parsing submittedAt date: $e');
          submittedAt = DateTime.now();
        }

        // Get questions data from the new format
        final List<dynamic> questionsData =
            data['questions'] as List<dynamic>? ?? [];
        List<StudentResponse> responses = [];

        for (var questionData in questionsData) {
          final Map<String, dynamic> qData =
              questionData as Map<String, dynamic>;

          final questionId = qData['questionId'] as String? ?? '';
          final questionType = qData['questionType'] as String? ?? '';
          final selectedOptionIndex = qData['selectedOption'] as int?;
          final isCorrect = qData['isCorrect'] as bool?;
          final score = qData['score'] as int?;

          // Handle file upload questions
          String? fileUrl;
          String? fileName;
          String? textAnswer;
          print('Debug - Question Type for $questionId: "$questionType"');
          if (questionType == 'Upload File') {
            fileUrl = qData['fileUrl'] as String?;
            fileName = qData['fileName'] as String?;
            textAnswer = qData['textAnswer'] as String?;
            print('Debug - Extracted fileUrl: $fileUrl, fileName: $fileName, textAnswer: $textAnswer');
          }

          // Get text-based answers for display
          final selectedAnswerText = qData['selectedAnswerText'] as String?;
          final correctAnswerText = qData['correctAnswerText'] as String?;

          // Create response object for the view
          final response = StudentResponse(
            questionId: questionId,
            questionType: questionType,
            selectedOption: selectedOptionIndex,
            selectedAnswerText: selectedAnswerText,
            correctAnswerText: correctAnswerText,
            fileUrl: fileUrl,
            fileName: fileName,
            textAnswer: textAnswer,
            isCorrect: isCorrect,
            score: score,
            teacherComment: qData['teacherComment'] as String?,
          );

          responses.add(response);
        }

        // Calculate scores
        final totalScore = data['totalScore'] as int? ?? 0;
        final maxScore = data['maxScore'] as int? ?? responses.length;
        final scorePercentage = data['scorePercentage'] as int? ?? 0;
        final scoreDisplay = '$totalScore/$maxScore ($scorePercentage%)';
        final status = data['status'] as String? ?? 'submitted';

        // Create submission object
        submissionsMap[studentId] = StudentAssignmentSubmission(
          assignmentId: assignmentId,
          studentId: studentId,
          studentName: studentName,
          responses: responses,
          totalScore: totalScore,
          maxScore: maxScore,
          scorePercentage: scorePercentage,
          scoreDisplay: scoreDisplay,
          status: status,
          submittedAt: submittedAt,
          gradedAt: null,
          teacherComment: data['teacherComment'] as String?,
        );
      }

      // Check student status for any submissions not already found
      for (var doc in studentStatusSnapshot.docs) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final studentId = doc.id;

          // Only process if we don't already have this student in our submissions
          if (!submissionsMap.containsKey(studentId)) {
            // Check if the student has completed the assignment
            final isCompleted = data['isCompleted'] as bool? ?? false;

            if (isCompleted) {
              // Get student details from users collection
              final userDoc =
                  await _firestore.collection('users').doc(studentId).get();

              final userData = userDoc.exists
                  ? userDoc.data() ?? {}
                  : {};
              final studentName =
                  userData['name'] as String? ?? 'Unknown Student';

              // Check if there's a submission in the new collection
              final submissionDoc =
                  await studentSubmitsCollection.doc(studentId).get();
              if (submissionDoc.exists) {
                continue; // Already processed this submission
              }

              // If no submission found, create a placeholder
              final scoreStr = data['score'] as String? ?? 'Not available';
              int? scorePercentage;

              if (scoreStr.contains('%')) {
                try {
                  scorePercentage =
                      int.parse(scoreStr.replaceAll('%', '').trim());
                } catch (e) {
                  scorePercentage = null;
                }
              }

              final submittedAt =
                  DateTime.now(); // Use current time as fallback
              final List<StudentResponse> responses = [];

              submissionsMap[studentId] = StudentAssignmentSubmission(
                assignmentId: assignmentId,
                studentId: studentId,
                studentName: studentName,
                responses: responses,
                totalScore: null,
                maxScore: 0,
                scorePercentage: scorePercentage,
                scoreDisplay: scoreStr,
                status: 'submitted',
                submittedAt: submittedAt,
                gradedAt: null,
                teacherComment: null,
              );
            }
          }
        }
      }

      _submissions = submissionsMap.values.toList();

      // Sort submissions by date (newest first)
      _submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

      if (_submissions.isEmpty) {
        print(
            'No submissions found for course: $courseDocId, courseName: $courseName, assignmentId: $assignmentId');
      } else {
        print('Loaded ${_submissions.length} submissions successfully');
      }

      _successMessage = 'Submissions loaded successfully';
    } catch (e) {
      _errorMessage = 'Failed to load submissions: $e';
      print('Error fetching submissions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update this method to grade file responses in the new structure
  Future<bool> gradeFileResponse(
      String studentId, String questionId, int score, String? comment) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find course document ID
      final courseDocId = await _findCourseDocumentId();
      if (courseDocId == null) {
        throw Exception('Could not find course document ID');
      }

      // Reference to the student submission
      final submissionRef = _firestore
          .collection('Courses')
          .doc(courseDocId)
          .collection('assignments')
          .doc(assignmentId)
          .collection('studentSubmits')
          .doc(studentId);

      // Get the current submission data
      final submissionDoc = await submissionRef.get();
      if (!submissionDoc.exists) {
        throw Exception('Submission not found');
      }

      // Get submission data
      final submissionData = submissionDoc.data() as Map<String, dynamic>;
      final List<dynamic> questions =
          submissionData['questions'] as List<dynamic>;

      // Find the question to update
      int questionIndex = -1;
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i] as Map<String, dynamic>;
        if (question['questionId'] == questionId) {
          questionIndex = i;
          break;
        }
      }

      if (questionIndex == -1) {
        throw Exception('Question not found in submission');
      }

      // Update the question data
      final questionData = questions[questionIndex] as Map<String, dynamic>;
      questionData['score'] = score;
      questionData['isGraded'] = true;
      if (comment != null) {
        questionData['teacherComment'] = comment;
      }

      // Update the questions list
      questions[questionIndex] = questionData;

      // Recalculate total score
      int totalScore = 0;
      for (var q in questions) {
        final qData = q as Map<String, dynamic>;
        totalScore += (qData['score'] as int?) ?? 0;
      }

      // Update submission with new score
      final maxScore = submissionData['maxScore'] as int? ?? questions.length;
      final scorePercentage =
          maxScore > 0 ? ((totalScore / maxScore) * 100).round() : 0;

      // Update the submission document
      await submissionRef.update({
        'questions': questions,
        'totalScore': totalScore,
        'scorePercentage': scorePercentage,
        'status': 'graded',
      });

      // Update student status document
      try {
        await _firestore
            .collection('Courses')
            .doc(courseDocId)
            .collection('assignments')
            .doc(assignmentId)
            .collection('studentStatus')
            .doc(studentId)
            .update({
          'score': '$scorePercentage%',
          'lastUpdated': DateTime.now().toIso8601String(),
          'isGraded': true,
        });
      } catch (e) {
        print('Warning: Could not update student status: $e');
        // Continue anyway since the main submission was updated
      }

      _successMessage = 'Response graded successfully';
      await refreshSubmissions(); // Refresh to get updated data
      return true;
    } catch (e) {
      _errorMessage = 'Error grading response: $e';
      print('Error grading file response: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSubmissions() async {
    await fetchSubmissions();
  }

  void clearMessages() {
    _successMessage = '';
    _errorMessage = '';
    notifyListeners();
  }
}
