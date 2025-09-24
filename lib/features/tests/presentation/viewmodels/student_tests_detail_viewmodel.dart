import 'dart:io';
import 'package:attendance_app/features/tests/data/models/tests_question_model_admin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:attendance_app/features/tests/data/models/tests_question_model_student.dart';

class TestsStudentDetailViewModel extends ChangeNotifier {
  final String courseId;
  final String testId;

  List<TestsStudentQuestion> _questions = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';
  String _successMessage = '';
  int _currentQuestionIndex = 0;
  bool _allQuestionsAnswered = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _examDate;
  String? _startTime;
  String? _endTime;

  // Getters
  List<TestsStudentQuestion> get questions => _questions;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get allQuestionsAnswered => _allQuestionsAnswered;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get examDate => _examDate;
  String? get startTime => _startTime;
  String? get endTime => _endTime;
  TestsStudentQuestion? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;

  // Constructor
  TestsStudentDetailViewModel({
    required this.courseId,
    required this.testId,
  }) {
    _loadTestQuestions();
  }

  // Cargar las preguntas de la tarea
  Future<void> _loadTestQuestions() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final testDoc = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('tests')
          .doc(testId)
          .get();

      if (!testDoc.exists) {
        _errorMessage = 'Test not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final testData = testDoc.data()!;

      // Load exam date and time information
      _examDate = testData['examDate'];
      _startTime = testData['startTime'];
      _endTime = testData['endTime'];

      final List<dynamic> rawQuestions = testData['questions'] ?? [];

      _questions = List.generate(
        rawQuestions.length,
        (index) {
          final questionData = rawQuestions[index] as Map<String, dynamic>;
          final TestsQuestionModel adminModel =
              TestsQuestionModel.fromMap(questionData);
          return TestsStudentQuestion.fromAdminModel(adminModel, index);
        },
      );

      await _checkPreviousSubmission();
      _updateAllQuestionsAnsweredStatus();
    } catch (e) {
      _errorMessage = 'Error loading test: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkPreviousSubmission() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return;
      }

      final submissionDoc = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('tests')
          .doc(testId)
          .collection('submissions')
          .doc(currentUser.uid)
          .get();

      if (!submissionDoc.exists) {
        return;
      }

      final submissionData = submissionDoc.data()!;
      final List<dynamic> responses = submissionData['responses'] ?? [];

      for (final response in responses) {
        final questionId = response['questionId'] as String;
        final questionIndex = int.tryParse(questionId) ?? 0;

        if (questionIndex < _questions.length) {
          final question = _questions[questionIndex];

          if (question.type == 'multiple_choice' ||
              question.type == 'true_false') {
            question.selectedOption = response['selectedOption'] as int?;
            question.isAnswered = question.selectedOption != null;
            question.isCorrect = response['isCorrect'] as bool?;
          } else if (question.type == 'Upload File') {
            question.uploadedFileUrl = response['fileUrl'] as String?;
            question.uploadedFileName = response['fileName'] as String?;
            question.isAnswered = question.uploadedFileUrl != null &&
                question.uploadedFileUrl!.isNotEmpty;
          }
        }
      }
    } catch (e) {
      print('Error checking previous submission: $e');
    }
  }

  void updateSelectedOption(int questionIndex, int optionIndex) {
    if (questionIndex < 0 || questionIndex >= _questions.length) return;

    final question = _questions[questionIndex];
    question.selectedOption = optionIndex;
    question.isAnswered = true;

    print(
        "Question $questionIndex marked as answered with option $optionIndex");
    print("isAnswered: ${question.isAnswered}, type: ${question.type}");

    _updateAllQuestionsAnsweredStatus();
    notifyListeners();
  }

  // دالة لتحديث الإجابة النصية
  void updateTextAnswer(int questionIndex, String text) {
    if (questionIndex < 0 || questionIndex >= _questions.length) return;
    
    final question = _questions[questionIndex];
    question.textAnswer = text;
    
    // تحديث حالة الإجابة فقط إذا كان النص غير فارغ
    if (text.isNotEmpty) {
      question.isAnswered = true;
      print("Text answer updated for question $questionIndex: $text");
    } else if (question.uploadedFileUrl == null || question.uploadedFileUrl!.isEmpty) {
      // إذا كان النص فارغًا وليس هناك ملف مرفوع، فالسؤال غير مُجاب عليه
      question.isAnswered = false;
    }
    
    _updateAllQuestionsAnsweredStatus();
    notifyListeners();
  }

  Future<void> uploadFile(int questionIndex, File file, String fileName) async {
    if (questionIndex < 0 || questionIndex >= _questions.length) return;

    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final question = _questions[questionIndex];

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('tests')
          .child(courseId)
          .child(testId)
          .child(
              '${FirebaseAuth.instance.currentUser?.uid ?? 'unknown'}_$fileName');

      final uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      });

      await uploadTask.whenComplete(() {});

      final downloadUrl = await storageRef.getDownloadURL();

      question.uploadedFileUrl = downloadUrl;
      question.uploadedFileName = fileName;
      question.isAnswered = true; // تأكيد إن الإجابة مكتملة
      print(
          "File uploaded for question $questionIndex, isAnswered: ${question.isAnswered}");

      _updateAllQuestionsAnsweredStatus();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error uploading file: $e';
      notifyListeners();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
    _updateAllQuestionsAnsweredStatus();
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
    _updateAllQuestionsAnsweredStatus();
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      _updateAllQuestionsAnsweredStatus();
      notifyListeners();
    }
  }

  void _updateAllQuestionsAnsweredStatus() {
    try {
      if (_questions.isEmpty) {
        _allQuestionsAnswered = false;
        return;
      }
      
      bool allAnswered = true;

      for (var question in _questions) {
        if (question == null) continue;
        
        bool questionAnswered = false;
        try {
          questionAnswered = question.isQuestionAnswered();
        } catch (e) {
          print('Error checking if question ${question.id} is answered: $e');
          questionAnswered = false;
        }
        
        print(
            'Checking question ${question.id}: answered=$questionAnswered, type=${question.type}, uploadedFileUrl=${question.uploadedFileUrl}, selectedOption=${question.selectedOption}');

        allAnswered = allAnswered && questionAnswered;

        if (!allAnswered) {
          print('Found unanswered question ${question.id}');
          break;
        }
      }

      print('All questions answered: $allAnswered');
      _allQuestionsAnswered = allAnswered;
    } catch (e) {
      print('Error in _updateAllQuestionsAnsweredStatus: $e');
      _allQuestionsAnswered = false;
    }
    
    notifyListeners();
  }

  Future<bool> submitAssignment({bool forceSubmit = false}) async {
    if (!_allQuestionsAnswered && !forceSubmit) {
      _errorMessage = 'Please answer all questions before submitting';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _errorMessage = 'User not logged in';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final String studentName = userDoc.exists
          ? (userDoc.data()?['name'] ?? 'Unknown Student')
          : 'Unknown Student';

      final testDoc = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('tests')
          .doc(testId)
          .get();

      if (!testDoc.exists) {
        throw Exception('Test not found');
      }

      Map<String, dynamic> submissionData = {
        'studentId': currentUser.uid,
        'studentName': studentName,
        'submittedAt': FieldValue.serverTimestamp(),
        'testId': testId,
      };

      List<Map<String, dynamic>> questionAnswers = [];
      int totalScore = 0;
      int totalQuestions = _questions.length;

      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        String questionId = question.id;
        bool? isCorrect = false;
        int score = 0; // Initialize score for each question

        Map<String, dynamic> questionData = {
          'questionId': questionId,
          'questionType': question.type,
          'questionText': question.question,
        };

        if (question.type == 'multiple_choice' || question.type == 'MCQ') {
          questionData['options'] = question.options;

          String correctAnswerText = '';
          int correctIndex = -1;

          if (question.correct != null) {
            String correctStr = question.correct!.trim();
            print("Raw correct value: '$correctStr'");
            print("Available options: ${question.options}");

            bool foundDirectMatch = false;
            for (int j = 0; j < question.options.length; j++) {
              String optionText = question.options[j].trim();
              if (optionText == correctStr) {
                correctAnswerText = optionText;
                correctIndex = j;
                foundDirectMatch = true;
                print(
                    "Found exact option match at index $j: '$correctAnswerText'");
                break;
              }
            }

            if (!foundDirectMatch) {
              try {
                correctIndex = int.parse(correctStr);
                if (correctIndex >= 0 &&
                    correctIndex < question.options.length) {
                  correctAnswerText = question.options[correctIndex];
                  print(
                      "Using option text from index $correctIndex: '$correctAnswerText'");
                }
              } catch (e) {
                correctAnswerText = correctStr;
                print(
                    "Using raw correct value as answer text: '$correctAnswerText'");
              }
            }
          }

          questionData['correctAnswerText'] = correctAnswerText;

          // Check if the question was answered
          if (question.selectedOption == null) {
            // For unanswered questions
            questionData['selectedAnswerText'] = '';
            questionData['selectedOptionIndex'] = null;
            questionData['isCorrect'] = false;
            questionData['score'] = 0; // Score is 0 for unanswered questions
          } else {
            // For answered questions
            String selectedAnswerText = '';
            if (question.selectedOption! >= 0 &&
                question.selectedOption! < question.options.length) {
              selectedAnswerText = question.options[question.selectedOption!];
            }

            questionData['selectedAnswerText'] = selectedAnswerText;
            questionData['selectedOptionIndex'] = question.selectedOption;

            if (correctIndex >= 0) {
              questionData['correctOptionIndex'] = correctIndex;
            }

            if (correctAnswerText.isNotEmpty && selectedAnswerText.isNotEmpty) {
              isCorrect = selectedAnswerText.trim() == correctAnswerText.trim();
            } else {
              isCorrect = false;
            }

            score = isCorrect ? 1 : 0;

            questionData['isCorrect'] = isCorrect;
            questionData['score'] = score;
          }
        } else if (question.type == 'true_false' ||
            question.type == 'TrueFalse') {
          questionData['options'] = ["True", "False"];

          String correctAnswerText = '';
          if (question.correct != null) {
            String correctStr = question.correct!.toLowerCase().trim();

            if (correctStr == "true" ||
                correctStr == "0" ||
                correctStr == "\"true\"" ||
                correctStr == "'true'" ||
                correctStr == "t") {
              correctAnswerText = "True";
            } else if (correctStr == "false" ||
                correctStr == "1" ||
                correctStr == "\"false\"" ||
                correctStr == "'false'" ||
                correctStr == "f") {
              correctAnswerText = "False";
            } else {
              try {
                int index = int.parse(correctStr);
                correctAnswerText = index == 0 ? "True" : "False";
              } catch (e) {
                correctAnswerText = correctStr.isNotEmpty
                    ? correctStr[0].toUpperCase() + correctStr.substring(1)
                    : "";
              }
            }
          }

          questionData['correctAnswerText'] = correctAnswerText;

          // Check if the question was answered
          if (question.selectedOption == null) {
            // For unanswered questions
            questionData['selectedAnswerText'] = '';
            questionData['selectedOptionIndex'] = null;
            questionData['isCorrect'] = false;
            questionData['score'] = 0; // Score is 0 for unanswered questions
          } else {
            // For answered questions
            String selectedAnswerText =
                question.selectedOption == 0 ? "True" : "False";
            questionData['selectedAnswerText'] = selectedAnswerText;
            questionData['selectedOptionIndex'] = question.selectedOption;

            isCorrect = selectedAnswerText == correctAnswerText &&
                correctAnswerText.isNotEmpty;

            score = isCorrect ? 1 : 0;

            questionData['isCorrect'] = isCorrect;
            questionData['score'] = score;
          }
        } else if (question.type == 'Upload File') {
          questionData['fileUrl'] = question.uploadedFileUrl;
          questionData['fileName'] = question.uploadedFileName;
          questionData['textAnswer'] = question.textAnswer; // إضافة الإجابة النصية
          questionData['isGraded'] = false;
          questionData['score'] = 0;
        }

        questionAnswers.add(questionData);

        // Add the score to totalScore after processing each question
        if (questionData.containsKey('score')) {
          totalScore += questionData['score'] as int;
        }
      }

      submissionData['questions'] = questionAnswers;
      submissionData['totalScore'] = totalScore;
      submissionData['maxScore'] = totalQuestions;
      submissionData['scorePercentage'] = totalQuestions > 0
          ? ((totalScore / totalQuestions) * 100).round()
          : 0;
      // Si hay preguntas de archivo, marcar como 'needs_grading' en lugar de 'submitted'
      bool hasFileQuestions = questionAnswers.any((q) => 
          (q['questionType'] as String).toLowerCase() == 'upload file');
      submissionData['status'] = hasFileQuestions ? 'needs_grading' : 'submitted';

      await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('tests')
          .doc(testId)
          .collection('studentSubmits')
          .doc(currentUser.uid)
          .set(submissionData);

      // Verificar si hay preguntas de tipo archivo que necesitan calificación manual
      bool hasFileUploadQuestions = questionAnswers.any((q) => 
          (q['questionType'] as String).toLowerCase() == 'upload file');
      
      // Si hay preguntas de tipo archivo, marcar como no calificado hasta que el admin revise
      await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('tests')
          .doc(testId)
          .collection('studentStatus')
          .doc(currentUser.uid)
          .set({
        'isCompleted': true,
        'isGraded': !hasFileUploadQuestions, // Solo se marca como calificado si no hay archivos que revisar
        'score': hasFileUploadQuestions ? 'Pending' : '${submissionData['scorePercentage']}%',
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      _successMessage = 'Test submitted successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error submitting test: $e';
      print(_errorMessage);
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  // دالة لإعادة تعيين الملف المرفوع
  void resetFileUpload(int questionIndex) {
    if (questionIndex < 0 || questionIndex >= _questions.length) return;
    
    final question = _questions[questionIndex];
    question.uploadedFileUrl = null;
    question.uploadedFileName = null;
    
    // تحديث حالة الإجابة بناءً على وجود إجابة نصية
    if (question.textAnswer == null || question.textAnswer!.isEmpty) {
      question.isAnswered = false;
    }
    
    _updateAllQuestionsAnsweredStatus();
    notifyListeners();
  }
}
