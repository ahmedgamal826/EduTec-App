import 'package:attendance_app/features/tests/data/models/student_tests_response.dart';
import 'package:attendance_app/features/tests/presentation/viewmodels/tests_submissions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/presentation/views/file_preview_view.dart';

class TestsStudentSubmissionDetailView extends StatefulWidget {
  final String adminId;
  final String testId;
  final String testTitle;
  final TestsStudentSubmission submission;
  final String courseName;

  const TestsStudentSubmissionDetailView({
    super.key,
    required this.adminId,
    required this.testId,
    required this.testTitle,
    required this.submission,
    required this.courseName,
  });

  @override
  State<TestsStudentSubmissionDetailView> createState() =>
      _StudentSubmissionDetailViewState();
}

class _StudentSubmissionDetailViewState
    extends State<TestsStudentSubmissionDetailView> {
  int _currentQuestionIndex = 0;
  final _scoreController = TextEditingController();
  final _commentController = TextEditingController();
  final bool _isSubmitting = false;
  final bool _hasLoadedData = false;

  // Add maps to store question data
  Map<String, dynamic> _questionData = {};
  Map<String, List<Map<String, dynamic>>> _optionsData = {};
  Map<String, int> _correctAnswers = {};
  bool _isLoadingQuestionData = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestionData();

    // Trigger score calculation after widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkResponsesAndUpdateScores();
    });
  }

  // Function to fetch question data from Firestore
  Future<void> _fetchQuestionData() async {
    setState(() {
      _isLoadingQuestionData = true;
    });

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      print('Fetching questions for test: ${widget.testId}');

      // First try to locate the course document
      final coursesRef = firestore.collection('Courses');
      DocumentSnapshot? courseDoc;

      try {
        // Try to find course by courseName
        final courseQuery = await coursesRef
            .where('courseName', isEqualTo: widget.courseName)
            .get();

        if (courseQuery.docs.isNotEmpty) {
          courseDoc = courseQuery.docs.first;
          print('Found course by name: ${courseDoc.id}');
        } else {
          // If not found, check if adminId is directly a course document ID
          final directDocSnapshot = await coursesRef.doc(widget.adminId).get();
          if (directDocSnapshot.exists) {
            courseDoc = directDocSnapshot;
            print('Found course by ID: ${courseDoc.id}');
          } else {
            throw Exception('Course not found');
          }
        }
      } catch (e) {
        print('Error finding course by name: $e');
        // Fallback: try to get the document directly
        final directDocSnapshot = await coursesRef.doc(widget.adminId).get();
        if (directDocSnapshot.exists) {
          courseDoc = directDocSnapshot;
          print('Found course directly by admin ID: ${courseDoc.id}');
        } else {
          throw Exception('Course not found');
        }
      }

      if (!courseDoc.exists) {
        throw Exception('Course document not found');
      }

      final assignmentRef =
          coursesRef.doc(courseDoc.id).collection('tests').doc(widget.testId);

      final assignmentDoc = await assignmentRef.get();

      if (!assignmentDoc.exists) {
        throw Exception('Assignment not found');
      }

      Map<String, dynamic> questionDataMap = {};
      Map<String, List<Map<String, dynamic>>> optionsDataMap = {};
      Map<String, int> correctAnswersMap = {};

      // Get assignment data
      Map<String, dynamic> assignmentData =
          assignmentDoc.data() as Map<String, dynamic>;

      print('Assignment data keys: ${assignmentData.keys.join(', ')}');

      // Check if we need to extract from the assignment document directly
      if (assignmentData.containsKey('type') &&
          (assignmentData['type'] == 'MCQ' ||
              assignmentData['type'] == 'TrueFalse' ||
              assignmentData['type'] == 'multiple_choice' ||
              assignmentData['type'] == 'true_false')) {
        // The assignment itself is a question
        print('Assignment document itself is a question');

        String questionId = widget.testId;
        questionDataMap[questionId] = assignmentData;

        // Handle options based on type
        if (assignmentData['type'] == 'MCQ' ||
            assignmentData['type'] == 'multiple_choice') {
          if (assignmentData.containsKey('options')) {
            List<dynamic> rawOptions =
                assignmentData['options'] as List<dynamic>;
            List<Map<String, dynamic>> options = [];

            // Process each option
            for (int i = 0; i < rawOptions.length; i++) {
              dynamic option = rawOptions[i];
              if (option is String) {
                options.add({'text': option});
              } else if (option is Map) {
                options.add(Map<String, dynamic>.from(option));
              }
            }

            optionsDataMap[questionId] = options;

            // Get the correct answer - primarily use 'correct' field
            if (assignmentData.containsKey('correct')) {
              var correctValue = assignmentData['correct'];

              // If correct is a direct index number
              if (correctValue is int) {
                correctAnswersMap[questionId] = correctValue;
                print(
                    '💯 Found correct as int: $correctValue for question $questionId');
              }
              // If correct is a string that could be an index or option text
              else if (correctValue is String) {
                // First try to parse as int (for backward compatibility)
                try {
                  correctAnswersMap[questionId] = int.parse(correctValue);
                  print(
                      '💯 Found correct as number string: $correctValue for question $questionId');
                } catch (_) {
                  // If it's not a number, it might be the text of the correct option
                  // We need to find which option matches this text
                  String correctText = correctValue.toString();
                  print(
                      '💯 Found correct as text: "$correctText" for question $questionId');

                  // Find the index of the option with this text
                  for (int i = 0; i < options.length; i++) {
                    String optionText = '';
                    var optionData = options[i];
                    if (optionData.containsKey('text')) {
                      var textValue = optionData['text'];
                      if (textValue != null) {
                        optionText = textValue.toString().toLowerCase();
                      }
                    } else if (optionData is String) {
                      optionText = optionData.toString().toLowerCase();
                    } else
                      optionText = optionData.toString().toLowerCase();

                    if (optionText.isNotEmpty &&
                        optionText == correctText.toLowerCase()) {
                      correctAnswersMap[questionId] = i;
                      print(
                          '💯 Matched correct text "$correctText" to option index $i');
                      break;
                    }
                  }
                }
              } else if (correctValue is bool) {
                // For true/false questions represented as boolean
                correctAnswersMap[questionId] = correctValue ? 0 : 1;
                print(
                    '💯 Found correct as boolean: $correctValue for question $questionId');
              }
            }
            // Fallback to correctOption if available
            else if (assignmentData.containsKey('correctOption')) {
              var correctValue = assignmentData['correctOption'];
              if (correctValue is int) {
                correctAnswersMap[questionId] = correctValue;
                print(
                    '💯 Found correctOption as int: $correctValue for question $questionId');
              } else if (correctValue is String) {
                try {
                  correctAnswersMap[questionId] = int.parse(correctValue);
                  print(
                      '💯 Found correctOption as number string: $correctValue for question $questionId');
                } catch (_) {
                  // Might be the text of the correct option
                  // Similar logic as above
                }
              }
            }
          }
        } else if (assignmentData['type'] == 'TrueFalse' ||
            assignmentData['type'] == 'true_false') {
          // For true/false questions
          optionsDataMap[questionId] = [
            {'text': 'True'},
            {'text': 'False'}
          ];

          // Determine correct answer - primarily use 'correct' field
          if (assignmentData.containsKey('correct')) {
            var correctValue = assignmentData['correct'];
            if (correctValue is String) {
              if (correctValue.toLowerCase() == 'true') {
                correctAnswersMap[questionId] = 0; // True is first option
                print(
                    '💯 Found correct as "true" string for TF question $questionId');
              } else if (correctValue.toLowerCase() == 'false') {
                correctAnswersMap[questionId] = 1; // False is second option
                print(
                    '💯 Found correct as "false" string for TF question $questionId');
              } else {
                // Try to parse as int
                try {
                  correctAnswersMap[questionId] = int.parse(correctValue);
                  print(
                      '💯 Found correct as number string: $correctValue for TF question $questionId');
                } catch (_) {
                  // Ignore parse error
                }
              }
            } else if (correctValue is bool) {
              correctAnswersMap[questionId] = correctValue ? 0 : 1;
              print(
                  '💯 Found correct as boolean: $correctValue for TF question $questionId');
            } else if (correctValue is int) {
              correctAnswersMap[questionId] = correctValue;
              print(
                  '💯 Found correct as int: $correctValue for TF question $questionId');
            }
          }
          // Fallback to correctOption if available
          else if (assignmentData.containsKey('correctOption')) {
            var correctValue = assignmentData['correctOption'];
            // Similar logic as the 'correct' case
            if (correctValue is int) {
              correctAnswersMap[questionId] = correctValue;
            } else if (correctValue is String) {
              if (correctValue.toLowerCase() == 'true') {
                correctAnswersMap[questionId] = 0;
              } else if (correctValue.toLowerCase() == 'false') {
                correctAnswersMap[questionId] = 1;
              } else {
                try {
                  correctAnswersMap[questionId] = int.parse(correctValue);
                } catch (_) {}
              }
            } else if (correctValue is bool) {
              correctAnswersMap[questionId] = correctValue ? 0 : 1;
            }
          }
        }
      } else if (assignmentData.containsKey('questions') &&
          assignmentData['questions'] is List) {
        // Handle embedded questions array
        print('Processing embedded questions array in assignment document');
        List<dynamic> questionsList = assignmentData['questions'];

        print('Found ${questionsList.length} questions in the assignment');

        for (int i = 0; i < questionsList.length; i++) {
          var question = questionsList[i];
          if (question is Map<String, dynamic>) {
            // Use index as ID if none provided
            final questionId = question['id'] as String? ??
                question['questionId'] as String? ??
                '${widget.testId}_q$i';

            print('Processing question $i with ID: $questionId');
            print(
                'Question content: ${question['question'] ?? 'No question text found'}');

            // Store the original question data
            questionDataMap[questionId] = question;

            // Create additional entries with response questionId for easier matching
            if (i < widget.submission.responses.length) {
              String responseQuestionId =
                  widget.submission.responses[i].questionId;
              if (responseQuestionId != questionId) {
                print(
                    'Mapping response ID $responseQuestionId to question ID $questionId');
                questionDataMap[responseQuestionId] = question;
              }
            }

            if (question['type'] == 'multiple_choice' ||
                question['type'] == 'MCQ') {
              List<Map<String, dynamic>> options = [];
              if (question['options'] != null && question['options'] is List) {
                List<dynamic> rawOptions = question['options'] as List;
                print(
                    'Found ${rawOptions.length} options for question $questionId');

                for (int j = 0; j < rawOptions.length; j++) {
                  dynamic option = rawOptions[j];
                  if (option is String) {
                    options.add({'text': option});
                    print('Option $j: $option');
                  } else if (option is Map) {
                    options.add(Map<String, dynamic>.from(option));
                    print('Option $j: ${option.toString()}');
                  }
                }
              }
              optionsDataMap[questionId] = options;

              // Add options with response questionId for easier matching
              if (i < widget.submission.responses.length) {
                String responseQuestionId =
                    widget.submission.responses[i].questionId;
                if (responseQuestionId != questionId) {
                  optionsDataMap[responseQuestionId] = options;
                }
              }

              // Store correct answer - prioritize 'correct' field
              if (question.containsKey('correct')) {
                var correctValue = question['correct'];

                // If correct is a direct index number
                if (correctValue is int) {
                  correctAnswersMap[questionId] = correctValue;
                  print(
                      '💯 Found correct as int: $correctValue for embedded question $questionId');
                }
                // If correct is a string
                else if (correctValue is String) {
                  // Try to parse as int
                  try {
                    correctAnswersMap[questionId] = int.parse(correctValue);
                    print(
                        '💯 Found correct as string number: $correctValue for embedded question $questionId');
                  } catch (_) {
                    // If it's not a number, look for a matching option text
                    String correctText = correctValue.toString();
                    print(
                        '💯 Found correct as text: "$correctText" for embedded question $questionId');

                    // Find which option matches this text
                    for (int j = 0; j < options.length; j++) {
                      String optionText = '';
                      var optionData = options[j];
                      if (optionData.containsKey('text')) {
                        var textValue = optionData['text'];
                        if (textValue != null) {
                          optionText = textValue.toString().toLowerCase();
                        }
                      } else if (optionData is String) {
                        optionText = optionData.toString().toLowerCase();
                      } else
                        optionText = optionData.toString().toLowerCase();

                      if (optionText.isNotEmpty &&
                          optionText == correctText.toLowerCase()) {
                        correctAnswersMap[questionId] = j;
                        print(
                            '💯 Matched correct text "$correctText" to option index $j');
                        break;
                      }
                    }
                  }
                } else if (correctValue is bool) {
                  // For true/false style questions
                  int correctIndex = correctValue ? 0 : 1;
                  correctAnswersMap[questionId] = correctIndex;
                  print(
                      '💯 Found correct as boolean: $correctValue for embedded question $questionId');
                }

                // Add to response questionId too
                if (i < widget.submission.responses.length) {
                  String responseQuestionId =
                      widget.submission.responses[i].questionId;
                  if (responseQuestionId != questionId &&
                      correctAnswersMap.containsKey(questionId)) {
                    correctAnswersMap[responseQuestionId] =
                        correctAnswersMap[questionId]!;
                    print(
                        '💯 Mapped correct from question $questionId to response ID $responseQuestionId');
                  }
                }
              }
              // Fall back to correctOption if needed
              else if (question.containsKey('correctOption')) {
                var correctValue = question['correctOption'];
                // Process correctOption similar to 'correct'
                // ...
              }
            } else if (question['type'] == 'true_false' ||
                question['type'] == 'TrueFalse') {
              // For true/false questions - similar logic
              // ... existing code ...
            }
          }
        }
      }

      // If no questions found yet, try looking in the questions subcollection
      if (questionDataMap.isEmpty) {
        print('Fetching questions from subcollection');

        final questionsQuery =
            await assignmentRef.collection('questions').get();

        print('Found ${questionsQuery.docs.length} questions in subcollection');

        for (int i = 0; i < questionsQuery.docs.length; i++) {
          final questionDoc = questionsQuery.docs[i];
          final data = questionDoc.data();
          final questionId = questionDoc.id;

          print('Processing question with ID: $questionId');

          questionDataMap[questionId] = data;

          // Create additional entries with response questionId for easier matching
          if (i < widget.submission.responses.length) {
            String responseQuestionId =
                widget.submission.responses[i].questionId;
            if (responseQuestionId != questionId) {
              print(
                  'Mapping response ID $responseQuestionId to question ID $questionId');
              questionDataMap[responseQuestionId] = data;
            }
          }

          if (data['type'] == 'multiple_choice' || data['type'] == 'MCQ') {
            List<Map<String, dynamic>> options = [];
            if (data['options'] != null && data['options'] is List) {
              List<dynamic> rawOptions = data['options'] as List;
              for (var option in rawOptions) {
                if (option is String) {
                  options.add({'text': option});
                } else if (option is Map) {
                  options.add(Map<String, dynamic>.from(option));
                }
              }
            }
            optionsDataMap[questionId] = options;

            // Add options with response questionId for easier matching
            if (i < widget.submission.responses.length) {
              String responseQuestionId =
                  widget.submission.responses[i].questionId;
              if (responseQuestionId != questionId) {
                optionsDataMap[responseQuestionId] = options;
              }
            }

            // Handle correct answer in various formats
            if (data.containsKey('correctOption')) {
              var correctValue = data['correctOption'];
              if (correctValue is int) {
                correctAnswersMap[questionId] = correctValue;
                print(
                    '💯 Found correctOption as int: $correctValue in subcollection question $questionId');
              } else if (correctValue is String) {
                try {
                  correctAnswersMap[questionId] = int.parse(correctValue);
                  print(
                      '💯 Found correctOption as string number: $correctValue in subcollection question $questionId');
                } catch (_) {
                  // Handle special case formats
                  if (correctValue.toLowerCase() == 'true') {
                    correctAnswersMap[questionId] = 0;
                    print(
                        '💯 Found correctOption as "true" string in subcollection question $questionId');
                  } else if (correctValue.toLowerCase() == 'false') {
                    correctAnswersMap[questionId] = 1;
                    print(
                        '💯 Found correctOption as "false" string in subcollection question $questionId');
                  }
                }
              }

              // Add for response ID too
              if (i < widget.submission.responses.length) {
                String responseQuestionId =
                    widget.submission.responses[i].questionId;
                if (responseQuestionId != questionId &&
                    correctAnswersMap.containsKey(questionId)) {
                  correctAnswersMap[responseQuestionId] =
                      correctAnswersMap[questionId]!;
                  print(
                      '💯 Mapped correctOption from subcollection question $questionId to response ID $responseQuestionId');
                }
              }
            } else if (data.containsKey('correct')) {
              var correctValue = data['correct'];
              int correctIndex = -1;

              if (correctValue is int) {
                correctIndex = correctValue;
                print(
                    '💯 Found correct as int: $correctValue in subcollection question $questionId');
              } else if (correctValue is String) {
                // Try to parse as int
                try {
                  correctIndex = int.parse(correctValue);
                  print(
                      '💯 Found correct as string number: $correctValue in subcollection question $questionId');
                } catch (_) {
                  // Handle string true/false values
                  if (correctValue.toLowerCase() == 'true') {
                    correctIndex = 0;
                    print(
                        '💯 Found correct as "true" string in subcollection question $questionId');
                  } else if (correctValue.toLowerCase() == 'false') {
                    correctIndex = 1;
                    print(
                        '💯 Found correct as "false" string in subcollection question $questionId');
                  }
                }
              } else if (correctValue is bool) {
                correctIndex = correctValue ? 0 : 1;
                print(
                    '💯 Found correct as boolean: $correctValue in subcollection question $questionId');
              }

              if (correctIndex >= 0) {
                correctAnswersMap[questionId] = correctIndex;

                // Add for response ID too
                if (i < widget.submission.responses.length) {
                  String responseQuestionId =
                      widget.submission.responses[i].questionId;
                  if (responseQuestionId != questionId) {
                    correctAnswersMap[responseQuestionId] = correctIndex;
                    print(
                        '💯 Mapped correct from subcollection question $questionId to response ID $responseQuestionId');
                  }
                }
              }
            }
          } else if (data['type'] == 'true_false' ||
              data['type'] == 'TrueFalse') {
            // For true/false questions
            optionsDataMap[questionId] = [
              {'text': 'True'},
              {'text': 'False'}
            ];

            // Add options with response questionId for easier matching
            if (i < widget.submission.responses.length) {
              String responseQuestionId =
                  widget.submission.responses[i].questionId;
              if (responseQuestionId != questionId) {
                optionsDataMap[responseQuestionId] = [
                  {'text': 'True'},
                  {'text': 'False'}
                ];
              }
            }

            // Handle various formats of correct answers
            var correctValue =
                data['correctOption'] ?? data['correct'] ?? data['isTrue'];

            int correctIndex = -1;
            if (correctValue is String &&
                correctValue.toLowerCase() == 'true') {
              correctIndex = 0;
              print(
                  '💯 Found correct/correctOption/isTrue as "true" string for TF subcollection question $questionId');
            } else if (correctValue is String &&
                correctValue.toLowerCase() == 'false') {
              correctIndex = 1;
              print(
                  '💯 Found correct/correctOption/isTrue as "false" string for TF subcollection question $questionId');
            } else if (correctValue is bool) {
              correctIndex = correctValue ? 0 : 1;
              print(
                  '💯 Found correct/correctOption/isTrue as boolean: $correctValue for TF subcollection question $questionId');
            } else if (correctValue is int) {
              correctIndex = correctValue;
              print(
                  '💯 Found correct/correctOption/isTrue as int: $correctValue for TF subcollection question $questionId');
            } else if (correctValue is String) {
              try {
                correctIndex = int.parse(correctValue);
                print(
                    '💯 Found correct/correctOption/isTrue as number string: $correctValue for TF subcollection question $questionId');
              } catch (_) {
                // Ignore parse errors
              }
            }

            if (correctIndex >= 0) {
              correctAnswersMap[questionId] = correctIndex;

              // Add for response questionId too
              if (i < widget.submission.responses.length) {
                String responseQuestionId =
                    widget.submission.responses[i].questionId;
                if (responseQuestionId != questionId) {
                  correctAnswersMap[responseQuestionId] = correctIndex;
                  print(
                      '💯 Mapped TF correct from subcollection question $questionId to response ID $responseQuestionId');
                }
              }
            }
          }
        }
      }

      // Check if we need to extract additional data from the assignment submissions
      if (questionDataMap.isEmpty && widget.submission.responses.isNotEmpty) {
        print('No questions found, creating from submission responses');

        for (int i = 0; i < widget.submission.responses.length; i++) {
          var response = widget.submission.responses[i];
          final questionId = response.questionId;

          print('Creating question data for response $i with ID: $questionId');

          // Create a basic question entry based on response data
          questionDataMap[questionId] = {
            'type': response.questionType,
            'question': 'Question #${i + 1}',
          };

          // Set up options based on question type
          if (response.questionType == 'multiple_choice' ||
              response.questionType == 'MCQ') {
            optionsDataMap[questionId] = [
              {'text': 'Option A'},
              {'text': 'Option B'},
              {'text': 'Option C'},
              {'text': 'Option D'}
            ];
          } else if (response.questionType == 'true_false' ||
              response.questionType == 'TrueFalse') {
            optionsDataMap[questionId] = [
              {'text': 'True'},
              {'text': 'False'}
            ];
          }

          // Extract correct answer from response if available
          if (response.isCorrect != null && response.selectedOption != null) {
            if (response.isCorrect == true) {
              // If response is correct, the selected option is the correct one
              correctAnswersMap[questionId] = response.selectedOption!;
              print(
                  'ℹ️ Created correctAnswer from isCorrect=true response: ${response.selectedOption}');
            } else {
              // This approach is problematic for questions with >2 options
              // Instead, we'll have to wait for teacher to grade or for data to come from elsewhere
              print(
                  '⚠️ Cannot determine correct answer from incorrect response');
            }
          }
        }
      }

      // Print debug info about what we found
      print('📊 Found ${correctAnswersMap.length} correct answers:');
      correctAnswersMap.forEach((qId, ans) {
        print('  Question $qId: Correct Option = $ans');
      });

      setState(() {
        _questionData = questionDataMap;
        _optionsData = optionsDataMap;
        _correctAnswers = correctAnswersMap;
        _isLoadingQuestionData = false;
      });

      // Update student responses with correct/incorrect status
      await _checkResponsesAndUpdateScores();
    } catch (e) {
      print('Error fetching question data: $e');
      setState(() {
        _isLoadingQuestionData = false;
      });
    }
  }

  Future<void> _checkResponsesAndUpdateScores() async {
    try {
      print('🔁 Starting to check responses and update scores...');

      // Calculate correct answers and update scores
      int correctCount = 0;
      bool needsScoreUpdate = false;

      // First analyze which answers are correct
      for (var response in widget.submission.responses) {
        final questionId = response.questionId;
        final selectedOption = response.selectedOption ?? -1;
        final questionType = response.questionType.toLowerCase();

        // Skip if no selection was made
        if (selectedOption == -1) {
          print('⏩ Skipping question $questionId - no selection made');
          continue;
        }

        // Get the question data and options
        final questionData = _questionData[questionId];
        final options = _optionsData[questionId] ?? [];

        // Get the correct answer directly from questionData as raw text
        String correctAnswer = '';
        if (questionData != null && questionData.containsKey('correct')) {
          var correctValue = questionData['correct'];
          print('🔍 Raw correct value: "$correctValue"');
          print('🔍 Available options: $options');

          // Use the raw correct value as correctAnswer directly
          correctAnswer = correctValue.toString();
        } else {
          print('⚠️ No correct answer found for question $questionId');
        }

        // Get selected answer text
        String selectedAnswer = '';
        if (response.selectedAnswerText != null &&
            response.selectedAnswerText!.isNotEmpty) {
          selectedAnswer = response.selectedAnswerText!;
          print('📌 Using selectedAnswerText from response: "$selectedAnswer"');
        } else if (selectedOption >= 0) {
          if (questionType == 'multiple_choice' || questionType == 'mcq') {
            if (selectedOption < options.length) {
              selectedAnswer = getOptionText(questionId, selectedOption);
              print('🔍 Selected option index: $selectedOption');
              print('🔍 Selected option text: "$selectedAnswer"');
              print('🔍 Available options: $options');
            }
          } else if (questionType == 'true_false' ||
              questionType == 'truefalse') {
            selectedAnswer = selectedOption == 0 ? "True" : "False";
            print('🔍 Selected TF answer: "$selectedAnswer"');
          }
        }

        print('📝 Processing question $questionId:');
        print('  Type: $questionType');
        print('  Selected: $selectedOption');
        print('  Selected Answer Text: "$selectedAnswer"');
        print('  Correct Answer (from correct): "$correctAnswer"');

        bool isCorrect = false;

        // Perform text comparison only between selectedAnswerText and correct
        if (questionType == 'multiple_choice' ||
            questionType == 'mcq' ||
            questionType == 'true_false' ||
            questionType == 'truefalse') {
          if (selectedAnswer.isNotEmpty && correctAnswer.isNotEmpty) {
            String normalizedSelected = selectedAnswer.trim().toLowerCase();
            String normalizedCorrect = correctAnswer.trim().toLowerCase();
            isCorrect = normalizedSelected == normalizedCorrect;
            print(
                '✅ TEXT COMPARISON: "$normalizedSelected" == "$normalizedCorrect" => $isCorrect');
          }
        }

        // Update the response's isCorrect status if needed
        if (response.isCorrect != isCorrect) {
          response.updateIsCorrect(isCorrect);
          needsScoreUpdate = true;
          print('🔄 Updated isCorrect for question $questionId to $isCorrect');
        }

        if (isCorrect) {
          correctCount++;
        }
      }

      // Update submission score if needed
      if (needsScoreUpdate) {
        final totalQuestions = widget.submission.responses.length;
        final scorePercentage = (totalQuestions > 0)
            ? ((correctCount / totalQuestions) * 100).round()
            : 0;

        print(
            '📊 Final Score: $correctCount/$totalQuestions ($scorePercentage%)');

        // Update the submission in Firestore
        try {
          final submissionRef = FirebaseFirestore.instance
              .collection('Courses')
              .doc(widget.adminId)
              .collection('tests')
              .doc(widget.testId)
              .collection('studentSubmits')
              .doc(widget.submission.studentId);

          // Convert responses to questions format
          List<Map<String, dynamic>> questionsData = [];

          for (var response in widget.submission.responses) {
            Map<String, dynamic> questionData = {
              'questionId': response.questionId,
              'questionType': response.questionType,
              'selectedOptionIndex': response.selectedOption,
              'isCorrect': response.isCorrect,
              'score': response.isCorrect == true ? 1 : 0,
            };

            // Add selected answer text
            if (response.selectedAnswerText != null &&
                response.selectedAnswerText!.isNotEmpty) {
              questionData['selectedAnswerText'] = response.selectedAnswerText;
            } else if (response.selectedOption != null) {
              final options = _optionsData[response.questionId] ?? [];
              if (response.questionType.toLowerCase() == 'multiple_choice' ||
                  response.questionType.toLowerCase() == 'mcq') {
                if (response.selectedOption! >= 0 &&
                    response.selectedOption! < options.length) {
                  questionData['selectedAnswerText'] = getOptionText(
                      response.questionId, response.selectedOption!);
                }
              } else if (response.questionType.toLowerCase() == 'true_false' ||
                  response.questionType.toLowerCase() == 'truefalse') {
                questionData['selectedAnswerText'] =
                    response.selectedOption == 0 ? "True" : "False";
              }
            }

            // For file questions
            if (response.questionType.toLowerCase() == 'file') {
              questionData['fileUrl'] = response.fileUrl;
              questionData['fileName'] = response.fileName;
              questionData['isGraded'] = response.score != null;
            }

            // Add teacher comment if exists
            if (response.teacherComment != null &&
                response.teacherComment!.isNotEmpty) {
              questionData['teacherComment'] = response.teacherComment;
            }

            questionsData.add(questionData);
          }

          await submissionRef.update({
            'questions': questionsData,
            'totalScore': correctCount,
            'maxScore': totalQuestions,
            'scorePercentage': scorePercentage,
            'status': 'graded',
            'lastAutoGraded': FieldValue.serverTimestamp(),
          });

          print('💾 Updated submission in Firestore');
        } catch (e) {
          print('❌ Error updating submission: $e');
        }
      }

      // Force UI update
      setState(() {});
    } catch (e) {
      print('❌ Error in _checkResponsesAndUpdateScores: $e');
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TestsSubmissionsViewModel(
        adminId: widget.adminId,
        testId: widget.testId,
        courseName: widget.courseName,
      ),
      child: Consumer<TestsSubmissionsViewModel>(
        builder: (context, viewModel, child) {
          // Handle success and error messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.successMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.successMessage),
                  backgroundColor: Colors.green,
                ),
              );
              viewModel.clearMessages();

              // CRITICAL: Re-calculate the scores after successful operations
              _checkResponsesAndUpdateScores();
            }

            if (viewModel.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${viewModel.errorMessage}"),
                  backgroundColor: Colors.red,
                ),
              );
              viewModel.clearMessages();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF0F7FF),
            appBar: AppBar(
              title: Text(
                'Submission by ${widget.submission.studentName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              // actions: [
              //   // Add refresh button to force recalculation of scores
              //   // IconButton(
              //   //   icon: const Icon(Icons.refresh),
              //   //   onPressed: () {
              //   //     _checkResponsesAndUpdateScores();
              //   //     ScaffoldMessenger.of(context).showSnackBar(
              //   //       const SnackBar(
              //   //         content: Text('Scores recalculated'),
              //   //         backgroundColor: Colors.blue,
              //   //         duration: Duration(seconds: 1),
              //   //       ),
              //   //     );
              //   //   },
              //   //   tooltip: 'Recalculate Scores',
              //   // ),
              // ],
            ),
            body: _buildSubmissionDetailContent(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildSubmissionDetailContent(
      BuildContext context, TestsSubmissionsViewModel viewModel) {
    if (widget.submission.responses.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            _buildSubmissionHeader(),
            const SizedBox(height: 32),
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No response details available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This student has submitted the assignment but no response details are available',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_currentQuestionIndex >= widget.submission.responses.length) {
      setState(() {
        _currentQuestionIndex = 0;
      });
    }

    final currentResponse = widget.submission.responses[_currentQuestionIndex];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubmissionHeader(),
            const SizedBox(height: 16),
            _buildQuestionNavigation(),
            const SizedBox(height: 24),
            _buildResponseDetail(currentResponse, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionHeader() {
    final statusColor = _getStatusColor(widget.submission.status);
    final statusText = _getStatusText(widget.submission.status);

    // Calculate correct answers count directly for display
    int correctCount = 0;
    for (var response in widget.submission.responses) {
      if (response.isCorrect == true) {
        correctCount++;
      }
    }

    // IMPORTANT: Use either the stored total score or our calculated count, whichever is higher
    final storedScore = widget.submission.totalScore ?? 0;
    final totalScore = correctCount > storedScore ? correctCount : storedScore;
    final maxScore =
        widget.submission.maxScore ?? widget.submission.responses.length;

    print(
        '🏆 Header displaying score: $totalScore/$maxScore (stored: $storedScore, calculated: $correctCount)');

    // Crear una visualización de puntuación que refleje el estado actual
    String scoreDisplay;

    // Verificar si hay preguntas de tipo archivo que necesitan calificación manual
    bool hasFileUploadQuestions = widget.submission.responses.any((response) =>
        response.questionType.toLowerCase() == 'upload file' &&
        response.score == null);

    // Si hay preguntas de archivo sin calificar, mostrar como pendiente
    if (hasFileUploadQuestions && widget.submission.status == 'needs_grading') {
      scoreDisplay = 'Pending';
    } else {
      scoreDisplay = '$totalScore/$maxScore';
    }

    return Card(
      elevation: 7,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Assignment Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.testTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(duration: 400.ms).slideX(),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Status: $statusText')),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.7),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon(
                          //   _getStatusIcon(statusText),
                          //   color: statusColor,
                          //   size: 16,
                          // ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 12),
              // Information Items
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildInfoCard(
                    label: 'Student',
                    value: widget.submission.studentName,
                    icon: Icons.person,
                    iconColor: Colors.blueAccent,
                  ),
                  _buildInfoCard(
                    label: 'Score',
                    value: scoreDisplay,
                    icon:
                        scoreDisplay == 'Pending' ? Icons.pending : Icons.star,
                    iconColor: scoreDisplay == 'Pending'
                        ? Colors.orange
                        : Colors.amber,
                  ),
                  _buildInfoCard(
                    label: 'Submitted',
                    value: _formatDate(widget.submission.submittedAt),
                    icon: Icons.schedule,
                    iconColor: Colors.green.shade600,
                  ),
                  if (widget.submission.gradedAt != null)
                    _buildInfoCard(
                      label: 'Graded',
                      value: _formatDate(widget.submission.gradedAt!),
                      icon: Icons.check_circle,
                      iconColor: Colors.purple.shade600,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale();
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label: $value')),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width *
            0.3, // Fixed width for consistency
        padding: const EdgeInsets.all(10), // Reduced padding for lower height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.50),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24, // Slightly reduced icon size
              color: iconColor,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).scale(),
    );
  }

  IconData _getStatusIcon(String statusText) {
    switch (statusText.toLowerCase()) {
      case 'submitted':
        return Icons.send;
      case 'graded':
        return Icons.check_circle;
      case 'partially graded':
        return Icons.hourglass_top;
      case 'late submission':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Widget _buildHeaderInfoItem(String label, String value,
      {IconData? icon, Color? iconColor}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNavigation() {
    if (widget.submission.responses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1} of ${widget.submission.responses.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: _currentQuestionIndex > 0
                ? () {
                    setState(() {
                      _currentQuestionIndex--;
                    });
                  }
                : null,
            color: _currentQuestionIndex > 0
                ? AppColors.primaryColor
                : Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed:
                _currentQuestionIndex < widget.submission.responses.length - 1
                    ? () {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      }
                    : null,
            color:
                _currentQuestionIndex < widget.submission.responses.length - 1
                    ? AppColors.primaryColor
                    : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseDetail(
      TestsStudentResponse response, TestsSubmissionsViewModel viewModel) {
    print(
        '📋 Question Type for ${response.questionId}: "${response.questionType}"');

    // Temporary direct check for "Upload File"
    if (response.questionType == "Upload File") {
      print('📋 Direct match for "Upload File"');
      return _buildFileResponse(response, viewModel);
    }

    final normalizedType = response.questionType
            .toLowerCase()
            .replaceAll('_', '')
            .replaceAll(' ', '')
            .trim() ??
        '';
    print('📋 Normalized Question Type: "$normalizedType"');

    switch (normalizedType) {
      case 'multiplechoice':
      case 'mcq':
        return _buildMultipleChoiceResponse(response);
      case 'truefalse':
        return _buildTrueFalseResponse(response);
      case 'file':
      case 'uploadfile':
        return _buildFileResponse(response, viewModel);
      default:
        return Center(
          child: Text(
            'Unknown question type: ${response.questionType}',
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  Widget _buildMultipleChoiceResponse(TestsStudentResponse response) {
    final selectedOption = response.selectedOption ?? -1;
    final correctOption = _correctAnswers[response.questionId] ?? -1;
    var isCorrect = response.isCorrect ?? false;
    final isGraded = response.score != null;

    // Get the options for this question
    final options = _optionsData[response.questionId] ?? [];

    // TEXT-BASED COMPARISON IMPROVEMENT
    // Get the text-based answers if available
    String? selectedAnswerText = response.selectedAnswerText;
    if (selectedAnswerText == null &&
        selectedOption >= 0 &&
        selectedOption < options.length) {
      selectedAnswerText = getOptionText(response.questionId, selectedOption);
    }

    String? correctAnswerText = response.correctAnswerText;
    if (correctAnswerText == null) {
      // Try to get correct answer from _questionData
      final questionData = _questionData[response.questionId];
      if (questionData != null && questionData['correct'] != null) {
        final correctStr = questionData['correct'].toString();
        try {
          // If correct answer is a number/index
          int correctIdx = int.parse(correctStr);
          if (correctIdx >= 0 && correctIdx < options.length) {
            correctAnswerText = options[correctIdx].toString();
          }
        } catch (e) {
          // If not a number, it might be direct text
          correctAnswerText = correctStr;
        }
      }
    }

    print(
        '🔍 MCQ Text Comparison: Selected="$selectedAnswerText", Correct="$correctAnswerText"');

    // Determine which option is correct based on text matching
    int actualCorrectOption = correctOption;
    if (correctAnswerText != null && options.isNotEmpty) {
      for (int i = 0; i < options.length; i++) {
        String optionText = getOptionText(response.questionId, i).toLowerCase();
        if (optionText == correctAnswerText.toLowerCase()) {
          actualCorrectOption = i;
          print('☑️ Found correct option "$correctAnswerText" at index $i');
          break;
        }
      }
    }

    // If the answer is marked correct but actual correct option doesn't match,
    // trust the isCorrect flag and update actualCorrectOption
    if (isCorrect &&
        selectedOption != -1 &&
        selectedOption != actualCorrectOption) {
      actualCorrectOption = selectedOption;
      print(
          '⚠️ Trusting isCorrect flag, setting correct option to selected option ($selectedOption)');
    }

    print(
        '🔍 MCQ Display: selected=$selectedOption, correct=$actualCorrectOption, isCorrect=$isCorrect');

    // Final debug output
    print(
        '🔍 MCQ Response: selected=$selectedOption, correct=$actualCorrectOption, isCorrect=$isCorrect');

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with question type and status badge
            Row(
              children: [
                Expanded(
                  child: const Text(
                  'Multiple Choice Question',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                    overflow: TextOverflow.ellipsis,
                ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question text from actual data
            Text(
              getQuestionText(response.questionId),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // Options with actual text
            ...List.generate(options.length, (index) {
              final isSelected = index == selectedOption ||
                  (selectedAnswerText != null &&
                      getOptionText(response.questionId, index).toLowerCase() ==
                          selectedAnswerText.toLowerCase());
              final isCorrectOption = index == actualCorrectOption;

              Color borderColor = Colors.grey.withOpacity(0.3);
              Color bgColor = Colors.white;
              Color textColor = Colors.black87;

              // تحديد الألوان بناءً على الحالة
              if (isGraded) {
                if (isSelected && isCorrect) {
                  // إجابة صحيحة تم اختيارها
                  borderColor = Colors.green;
                  bgColor = Colors.green.withOpacity(0.05);
                  textColor = Colors.green.shade700;
                } else if (isSelected && !isCorrect) {
                  // إجابة خاطئة تم اختيارها
                  borderColor = Colors.red;
                  bgColor = Colors.red.withOpacity(0.05);
                  textColor = Colors.red.shade700;
                } else if (isCorrectOption && !isSelected) {
                  // الإجابة الصحيحة (لما الطالب يختار إجابة خاطئة)
                  borderColor = Colors.green;
                  bgColor = Colors.green.withOpacity(0.05);
                  textColor = Colors.green.shade700;
                }
              } else if (isSelected) {
                // حالة غير مقيمة ومحددة
                borderColor = Colors.blue;
                bgColor = Colors.blue.withOpacity(0.05);
                textColor = Colors.blue.shade700;
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  color: bgColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Option letter
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected || isCorrectOption
                                ? borderColor
                                : Colors.grey.withOpacity(0.5),
                            width: 1.5,
                          ),
                          color: isSelected || isCorrectOption
                              ? borderColor
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected || isCorrectOption
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Option text from actual data
                      Expanded(
                        child: Text(
                          getOptionText(response.questionId, index),
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: isSelected || isCorrectOption
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      // إضافة الأيقونة حسب الحالة
                      if (isGraded) ...[
                        if (isSelected && isCorrect)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          )
                        else if (isSelected && !isCorrect)
                          const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                            size: 20,
                          )
                        else if (isCorrectOption && !isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Score - FIXED to always show correct points based on isCorrect
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCorrect ? Icons.star : Icons.star_border,
                    color: isCorrect ? Colors.amber : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Score: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCorrect
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  Text(
                    isCorrect ? "1 point" : "0 points",
                    style: TextStyle(
                      fontSize: 16,
                      color: isCorrect
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Teacher comment (if any)
            if (response.teacherComment != null &&
                response.teacherComment!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Teacher Comment:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  response.teacherComment!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrueFalseResponse(TestsStudentResponse response) {
    final selectedOption = response.selectedOption ?? -1;
    final correctOption = _correctAnswers[response.questionId] ?? -1;
    final isCorrect = response.isCorrect ?? false;
    final isGraded = response.score != null; // Check if the response is graded
    final options = ['True', 'False'];

    // Get text-based answers for display
    String selectedAnswerText =
        selectedOption >= 0 && selectedOption < options.length
            ? options[selectedOption]
            : (response.selectedAnswerText ?? '');
    String correctAnswerText =
        correctOption >= 0 && correctOption < options.length
            ? options[correctOption]
            : '';

    if (correctAnswerText.isEmpty) {
      final questionData = _questionData[response.questionId];
      if (questionData != null && questionData['correct'] != null) {
        final correctStr = questionData['correct'].toString().toLowerCase();
        correctAnswerText = (correctStr == 'true' ||
                correctStr == '0' ||
                correctStr.contains('true'))
            ? 'True'
            : 'False';
      }
    }

    print(
        '🔍 TF Text Comparison: Selected="$selectedAnswerText", Correct="$correctAnswerText"');

    // Determine correct option based on text if not set
    int actualCorrectOption = correctOption;
    if (correctAnswerText.isNotEmpty) {
      actualCorrectOption = correctAnswerText.toLowerCase() == 'true' ? 0 : 1;
    }

    // Trust isCorrect flag if it conflicts
    if (isCorrect &&
        selectedOption != -1 &&
        selectedOption != actualCorrectOption) {
      actualCorrectOption = selectedOption;
    }

    print(
        '🔍 TF Final display: selected=$selectedOption, correct=$actualCorrectOption, isCorrect=$isCorrect');

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 7,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: const Text(
                  'True/False Question',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              getQuestionText(response.questionId),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              final isSelected = index == selectedOption ||
                  (selectedAnswerText.isNotEmpty &&
                      selectedAnswerText.toLowerCase() == value.toLowerCase());
              final isCorrectOption = index == actualCorrectOption;

              Color borderColor = Colors.grey.withOpacity(0.3);
              Color bgColor = Colors.white;
              Color textColor = Colors.black87;
              Icon? trailingIcon;

              // تحديد الألوان بناءً على الحالة
              if (isGraded) {
                if (isSelected && isCorrect) {
                  // إجابة صحيحة تم اختيارها
                  borderColor = Colors.green;
                  bgColor = Colors.green.withOpacity(0.1);
                  textColor = Colors.green.shade700;
                  trailingIcon =
                      const Icon(Icons.check, color: Colors.green, size: 20);
                } else if (isSelected && !isCorrect) {
                  // إجابة خاطئة تم اختيارها
                  borderColor = Colors.red;
                  bgColor = Colors.red.withOpacity(0.1);
                  textColor = Colors.red.shade700;
                  trailingIcon =
                      const Icon(Icons.close, color: Colors.red, size: 20);
                } else if (isCorrectOption && !isSelected) {
                  // الإجابة الصحيحة (لما الطالب يختار إجابة خاطئة)
                  borderColor = Colors.green;
                  bgColor = Colors.green.withOpacity(0.1);
                  textColor = Colors.green.shade700;
                  trailingIcon =
                      const Icon(Icons.check, color: Colors.green, size: 20);
                }
              } else if (isSelected) {
                // حالة غير مقيمة ومحددة
                borderColor = Colors.blue;
                bgColor = Colors.blue.withOpacity(0.1);
                textColor = Colors.blue.shade700;
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  color: bgColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                          color: isSelected || isCorrectOption
                              ? borderColor
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            index == 0 ? 'T' : 'F',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected || isCorrectOption
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: isSelected || isCorrectOption
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) trailingIcon,
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCorrect ? Icons.star : Icons.star_border,
                    color: isCorrect ? Colors.amber : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Score: ${isCorrect ? "1" : "0"} point${isCorrect ? "" : "s"}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isCorrect
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileResponse(
      TestsStudentResponse response, TestsSubmissionsViewModel viewModel) {
    final fileUrl = response.fileUrl;
    final fileName = response.fileName ?? 'Uploaded File';
    final isGraded = response.score != null;
    final score = response.score ?? 0;

    return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: const Text(
                    'File Upload',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                      overflow: TextOverflow.ellipsis,
                  ),
                  ),
                  const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGraded
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isGraded
                                ? Colors.blue.withOpacity(0.5)
                                : Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          isGraded ? 'Graded' : 'Awaiting Grading',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isGraded ? Colors.blue : Colors.orange,
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                getQuestionText(response.questionId),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // عرض الإجابة النصية إذا وجدت
              if (response.textAnswer != null &&
                  response.textAnswer!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Text Answer:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        response.textAnswer!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (fileUrl != null && fileUrl.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFileIcon(fileName),
                        color: Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Click to view',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilePreviewView(
                                fileUrl: fileUrl,
                                firebaseFileName: fileName,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'No file uploaded',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (viewModel.isAdmin) ...[
                if (!isGraded) ...[
                  // Interfaz de calificación para administradores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón correcto (1 punto)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            setState(() {
                              response.score = 1;
                              response.isCorrect = true;
                            });
                            await viewModel.gradeFileResponse(
                              widget.submission.studentId,
                              response.questionId,
                              1,
                              null,
                            );
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Correct (1 point)',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón incorrecto (0 puntos)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            setState(() {
                              response.score = 0;
                              response.isCorrect = false;
                            });
                            await viewModel.gradeFileResponse(
                              widget.submission.studentId,
                              response.questionId,
                              0,
                              null,
                            );
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Incorrect (0 points)',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Mostrar puntuación y permitir volver a calificar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          score > 0 ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: score > 0
                              ? Colors.green.shade200
                              : Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              score > 0 ? Icons.check_circle : Icons.cancel,
                              color: score > 0 ? Colors.green : Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Score: $score point${score == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: score > 0
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Botón para volver a calificar
                        ElevatedButton(
                          onPressed: () {
                            // Cambiar la calificación al valor opuesto
                            setState(() {
                              response.score = (score ?? 0) > 0 ? 0 : 1;
                              response.isCorrect = (response.score ?? 0) > 0;
                            });
                            viewModel.gradeFileResponse(
                              widget.submission.studentId,
                              response.questionId,
                              response.score!,
                              null,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Change to ${score > 0 ? 'Incorrect' : 'Correct'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                // Interfaz para estudiantes
                if (!isGraded) ...[
                  // Mostrar mensaje de espera para estudiantes
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          color: Colors.orange.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Waiting for instructor to grade this submission',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Mostrar resultado para estudiantes
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          score > 0 ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: score > 0
                              ? Colors.green.shade200
                              : Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          score > 0 ? Icons.check_circle : Icons.cancel,
                          color: score > 0 ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Score: $score point${score == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: score > 0
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              if (response.teacherComment != null &&
                  response.teacherComment!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Teacher Comment:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    response.teacherComment!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ));
  }

// دالة جديدة لتحديد الأيقونة بناءً على نوع الملف
  IconData _getFileIcon(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return Icons.insert_drive_file_outlined;
    }

    // استخراج الامتداد من الـ URL
    final extension = fileName.split('.').last.toLowerCase();

    // التحقق من نوع الملف
    if (extension == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return Icons.image;
    } else {
      return Icons
          .insert_drive_file_outlined; // أيقونة افتراضية إذا كان نوع غير معروف
    }
  }

  Future<void> _updateSubmissionScore(TestsStudentResponse response) async {
    try {
      final submissionRef = FirebaseFirestore.instance
          .collection('Courses')
          .doc(widget.adminId)
          .collection('tests')
          .doc(widget.testId)
          .collection('studentSubmits')
          .doc(widget.submission.studentId);

      // Update the specific response in the questions array
      final snapshot = await submissionRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> questions =
            List<Map<String, dynamic>>.from(data['questions'] ?? []);

        // Obtener el score actual (1 si correcto, 0 si incorrecto)
        final int scoreValue = response.score ?? 0;
        final bool isCorrect = scoreValue > 0;

        // Actualizar la pregunta específica
        for (var i = 0; i < questions.length; i++) {
          if (questions[i]['questionId'] == response.questionId) {
            questions[i]['score'] = scoreValue;
            questions[i]['isCorrect'] = isCorrect;
            questions[i]['isGraded'] = true;
            break;
          }
        }

        // Recalcular puntuación total
        int totalScore = 0;
        for (var question in questions) {
          totalScore += question['score'] as int? ?? 0;
        }

        final int maxScore = questions.length;
        final int scorePercentage =
            maxScore > 0 ? ((totalScore / maxScore) * 100).round() : 0;

        await submissionRef.update({
          'questions': questions,
          'totalScore': totalScore,
          'maxScore': maxScore,
          'scorePercentage': scorePercentage,
          'status': 'graded',
          'lastGraded': FieldValue.serverTimestamp(),
        });

        print(
            '💾 Updated score for question ${response.questionId} to $scoreValue');
      }
    } catch (e) {
      print('❌ Error updating score: $e');
    }
  }

  String getOptionText(String questionId, int index) {
    // Get the options for this question
    final options = _optionsData[questionId] ?? [];

    // Check if index is valid
    if (index < 0 || index >= options.length) {
      return "Option not found";
    }

    // Extract text from option
    final option = options[index];
    if (option.containsKey('text')) {
      return option['text'].toString();
    } else {
      return option.toString();
    }
  }

  String getQuestionText(String questionId) {
    // Get the question data
    final questionData = _questionData[questionId];
    if (questionData == null) {
      return "Question not found";
    }

    // Extract question text
    if (questionData.containsKey('question')) {
      return questionData['question'].toString();
    } else if (questionData.containsKey('questionText')) {
      return questionData['questionText'].toString();
    } else {
      return "Question #$questionId";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'graded':
        return Colors.green;
      case 'partially_graded':
        return Colors.orange;
      case 'late':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';
      case 'graded':
        return 'Graded';
      case 'partially_graded':
        return 'Partially Graded';
      case 'late':
        return 'Late Submission';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy - h:mm a').format(date);
  }
}
