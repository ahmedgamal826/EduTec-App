// import 'package:attendance_app/features/tests/data/models/tests_question_model_admin.dart';

// enum TestsQuestionType {
//   trueOrFalse,
//   multipleChoice,
//   essayWithImage,
// }

// class TestsStudentQuestion {
//   final String id;
//   final String type;
//   final String question;
//   final List<String> options;
//   final String? correct;
//   final String? fileUrl;
//   final String? fileName;
//   final String? fileType;
//   final int? fileSize;
//   int? selectedOption;
//   String? uploadedFileUrl;
//   String? uploadedFileName;
//   bool? isAnswered;
//   bool? isCorrect;

//   TestsStudentQuestion({
//     required this.id,
//     required this.type,
//     required this.question,
//     this.options = const [],
//     this.correct,
//     this.fileUrl,
//     this.fileName,
//     this.fileType,
//     this.fileSize,
//     this.selectedOption,
//     this.uploadedFileUrl,
//     this.uploadedFileName,
//     this.isAnswered = false,
//     this.isCorrect,
//   });

//   bool isQuestionAnswered() {
//     if (type == 'multiple_choice' ||
//         type == 'MCQ' ||
//         type == 'true_false' ||
//         type == 'TrueFalse') {
//       return selectedOption != null;
//     } else if (type == 'file' || type == 'Upload File') {
//       return uploadedFileUrl != null && uploadedFileUrl!.isNotEmpty;
//     }
//     return false;
//   }

//   factory TestsStudentQuestion.fromAdminModel(
//       TestsQuestionModel adminQuestion, int questionIndex) {
//     String questionId = questionIndex.toString();
//     String? correctAnswer = adminQuestion.correct;

//     return TestsStudentQuestion(
//       id: questionId,
//       type: adminQuestion.type,
//       question: adminQuestion.question,
//       options: adminQuestion.options,
//       correct: correctAnswer,
//       fileUrl: adminQuestion.fileUrl,
//       fileName: adminQuestion.fileName,
//       fileType: adminQuestion.fileType,
//       fileSize: adminQuestion.fileSize,
//     );
//   }

//   bool checkAnswer() {
//     if (type == 'multiple_choice' || type == 'MCQ') {
//       if (selectedOption == null || correct == null) {
//         return false;
//       }

//       if (selectedOption! < options.length) {
//         String selectedText = options[selectedOption!].trim().toLowerCase();
//         String correctText = correct!.trim().toLowerCase();
//         bool isCorrect = selectedText == correctText;
//         print(
//             "TEXT COMPARISON: Selected='$selectedText', Correct='$correctText', isCorrect=$isCorrect");
//         return isCorrect;
//       }
//       return false;
//     } else if (type == 'true_false' || type == 'TrueFalse') {
//       if (selectedOption == null || correct == null) {
//         return false;
//       }

//       String selectedAnswer = selectedOption == 0 ? "true" : "false";
//       String correctStr = correct!.toLowerCase().trim();

//       if (correctStr == "0" ||
//           correctStr == "true" ||
//           correctStr == "\"true\"" ||
//           correctStr == "'true'") {
//         return selectedOption == 0;
//       } else if (correctStr == "1" ||
//           correctStr == "false" ||
//           correctStr == "\"false\"" ||
//           correctStr == "'false'") {
//         return selectedOption == 1;
//       }

//       return selectedAnswer == correctStr;
//     }

//     return false;
//   }
// }

// enum TestsAssignmentQuestionType {
//   trueOrFalse,
//   multipleChoice,
// }

// class TestsAssignmentQuestion {
//   final String questionText;
//   final TestsAssignmentQuestionType questionType;
//   final int correctAnswer;
//   final List<String> options;
//   final bool hasImage;
//   final String? imagePath;

//   TestsAssignmentQuestion({
//     required this.questionText,
//     required this.questionType,
//     required this.correctAnswer,
//     required this.options,
//     this.hasImage = false,
//     this.imagePath,
//   });
// }
import 'package:attendance_app/features/tests/data/models/tests_question_model_admin.dart';

// Define the enum to match the string types used in TestsStudentQuestion
enum TestsStudentQuestionType {
  trueOrFalse,
  multipleChoice,
  essayWithImage,
}

class TestsStudentQuestion {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String? correct;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final int? fileSize;
  int? selectedOption;
  String? uploadedFileUrl;
  String? uploadedFileName;
  String? textAnswer;
  bool? isAnswered;
  bool? isCorrect;
  // Add properties to match TestsAssignmentQuestion
  final bool hasImage;
  final String? imagePath;

  TestsStudentQuestion({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
    this.correct,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.selectedOption,
    this.uploadedFileUrl,
    this.uploadedFileName,
    this.textAnswer,
    this.isAnswered = false,
    this.isCorrect,
    this.hasImage = false,
    this.imagePath,
  });

  // Getter to compute the correct answer index
  int? get correctAnswerIndex {
    if (correct == null) return null;
    if (type == 'TrueFalse' || type == 'true_false') {
      String correctStr = correct!.toLowerCase().trim();
      if (correctStr == 'true' ||
          correctStr == '0' ||
          correctStr == '"true"' ||
          correctStr == "'true'") {
        return 0;
      } else if (correctStr == 'false' ||
          correctStr == '1' ||
          correctStr == '"false"' ||
          correctStr == "'false'") {
        return 1;
      }
      return null;
    } else if (type == 'MCQ' || type == 'multiple_choice') {
      return options.indexWhere((option) =>
          option.trim().toLowerCase() == correct!.trim().toLowerCase());
    }
    return null;
  }

  bool isQuestionAnswered() {
    if (type == 'multiple_choice' ||
        type == 'MCQ' ||
        type == 'true_false' ||
        type == 'TrueFalse') {
      return selectedOption != null;
    } else if (type == 'file' || type == 'Upload File') {
      return (uploadedFileUrl != null && uploadedFileUrl!.isNotEmpty) || 
             (textAnswer != null && textAnswer!.isNotEmpty);
    }
    return false;
  }

  factory TestsStudentQuestion.fromAdminModel(
      TestsQuestionModel adminQuestion, int questionIndex) {
    String questionId = questionIndex.toString();
    String? correctAnswer = adminQuestion.correct;

    return TestsStudentQuestion(
      id: questionId,
      type: adminQuestion.type,
      question: adminQuestion.question,
      options: adminQuestion.options,
      correct: correctAnswer,
      fileUrl: adminQuestion.fileUrl,
      fileName: adminQuestion.fileName,
      fileType: adminQuestion.fileType,
      fileSize: adminQuestion.fileSize,
      hasImage: adminQuestion.type ==
          'essayWithImage', // Infer hasImage based on type
      imagePath:
          adminQuestion.fileUrl, // Use fileUrl as imagePath if applicable
    );
  }

  bool checkAnswer() {
    if (type == 'multiple_choice' || type == 'MCQ') {
      if (selectedOption == null || correct == null) {
        return false;
      }

      if (selectedOption! < options.length) {
        String selectedText = options[selectedOption!].trim().toLowerCase();
        String correctText = correct!.trim().toLowerCase();
        bool isCorrect = selectedText == correctText;
        print(
            "TEXT COMPARISON: Selected='$selectedText', Correct='$correctText', isCorrect=$isCorrect");
        return isCorrect;
      }
      return false;
    } else if (type == 'true_false' || type == 'TrueFalse') {
      if (selectedOption == null || correct == null) {
        return false;
      }

      String selectedAnswer = selectedOption == 0 ? "true" : "false";
      String correctStr = correct!.toLowerCase().trim();

      if (correctStr == "0" ||
          correctStr == "true" ||
          correctStr == "\"true\"" ||
          correctStr == "'true'") {
        return selectedOption == 0;
      } else if (correctStr == "1" ||
          correctStr == "false" ||
          correctStr == "\"false\"" ||
          correctStr == "'false'") {
        return selectedOption == 1;
      }

      return selectedAnswer == correctStr;
    }

    return false;
  }
}

enum TestsAssignmentQuestionType {
  trueOrFalse,
  multipleChoice,
}

class TestsAssignmentQuestion {
  final String questionText;
  final TestsAssignmentQuestionType questionType;
  final int correctAnswer;
  final List<String> options;
  final bool hasImage;
  final String? imagePath;

  TestsAssignmentQuestion({
    required this.questionText,
    required this.questionType,
    required this.correctAnswer,
    required this.options,
    this.hasImage = false,
    this.imagePath,
  });
}
