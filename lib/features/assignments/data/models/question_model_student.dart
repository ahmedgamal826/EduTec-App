// // Question Models
// enum QuestionType {
//   trueOrFalse,
//   multipleChoice,
// }
//
// class Question {
//   final String questionText;
//   final QuestionType questionType;
//   final int correctAnswer; // 0-based index of correct answer in options
//   final List<String> options;
//   final bool hasImage;
//   final String? imagePath;
//
//   Question({
//     required this.questionText,
//     required this.questionType,
//     required this.correctAnswer,
//     required this.options,
//     this.hasImage = false,
//     this.imagePath,
//   });
// }

// Student Question Models compatible with Admin models
enum QuestionType {
  trueOrFalse,
  multipleChoice,
  essayWithImage,
}

class StudentQuestion {
  final String id; // ID única para identificar la pregunta
  final String type; // "multiple_choice", "true_false", "file"
  final String question;
  final List<String> options;
  final String?
      correct; // La respuesta correcta (índice como string o true/false)
  final String? fileUrl; // URL del archivo adjunto a la pregunta (si hay)
  final String? fileName;
  final String? fileType;
  final int? fileSize;

  // Campos para tracking de la respuesta del estudiante
  int? selectedOption;
  String? uploadedFileUrl;
  String? uploadedFileName;
  String? textAnswer; // إضافة حقل للإجابة النصية
  bool? isAnswered;
  bool? isCorrect;

  StudentQuestion({
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
    this.textAnswer, // إضافة حقل للإجابة النصية
    this.isAnswered = false,
    this.isCorrect,
  });

  // Check if the question has been answered based on its type
  // bool isQuestionAnswered() {
  //   if (type == 'multiple_choice' ||
  //       type == 'MCQ' ||
  //       type == 'true_false' ||
  //       type == 'TrueFalse') {
  //     return selectedOption != null;
  //   } else if (type == 'file') {
  //     return uploadedFileUrl != null && uploadedFileUrl!.isNotEmpty;
  //   }
  //   return false;
  // }

  bool isQuestionAnswered() {
    if (type == 'multiple_choice' ||
        type == 'MCQ' ||
        type == 'true_false' ||
        type == 'TrueFalse') {
      return selectedOption != null;
    } else if (type == 'file' || type == 'Upload File') {
      // اعتبار السؤال مجاب عليه إذا تم رفع ملف أو إدخال نص
      return (uploadedFileUrl != null && uploadedFileUrl!.isNotEmpty) || 
             (textAnswer != null && textAnswer!.isNotEmpty);
    }
    return false;
  }

  // // Crear una pregunta estudiante a partir del modelo del administrador
  // factory StudentQuestion.fromAdminModel(
  //     QuestionModel adminQuestion, int questionIndex) {
  //   // Ensure that the question ID is always a string
  //   String questionId = questionIndex.toString();

  //   // Handle correct answer format correctly
  //   String? correctAnswer = adminQuestion.correct;

  //   // If it's null, make sure that we handle it properly
  //   if (correctAnswer == null && adminQuestion.type == 'multiple_choice' ||
  //       adminQuestion.type == 'MCQ' ||
  //       adminQuestion.type == 'true_false' ||
  //       adminQuestion.type == 'TrueFalse') {
  //     // Default to first option (0) if not specified
  //     correctAnswer = "0";
  //   }

  //   return StudentQuestion(
  //     id: questionId,
  //     type: adminQuestion.type,
  //     question: adminQuestion.question,
  //     options: adminQuestion.options,
  //     correct: correctAnswer,
  //     fileUrl: adminQuestion.fileUrl,
  //     fileName: adminQuestion.fileName,
  //     fileType: adminQuestion.fileType,
  //     fileSize: adminQuestion.fileSize,
  //   );
  // }

  factory StudentQuestion.fromAdminModel(
      QuestionModel adminQuestion, int questionIndex) {
    // Ensure that the question ID is always a string
    String questionId = questionIndex.toString();

    // Handle correct answer format correctly
    String? correctAnswer = adminQuestion.correct;

    // Do not default to "0" if correct is null, keep it null or use the raw value
    return StudentQuestion(
      id: questionId,
      type: adminQuestion.type,
      question: adminQuestion.question,
      options: adminQuestion.options,
      correct: correctAnswer, // Use raw value without defaulting to "0"
      fileUrl: adminQuestion.fileUrl,
      fileName: adminQuestion.fileName,
      fileType: adminQuestion.fileType,
      fileSize: adminQuestion.fileSize,
    );
  }

  // // Verificar si la respuesta es correcta
  // bool checkAnswer() {
  //   if (type == 'multiple_choice' || type == 'MCQ') {
  //     if (selectedOption == null || correct == null) {
  //       return false;
  //     }

  //     // First, try direct text comparison (text of selected option vs correct text)
  //     String correctStr = correct!.trim().toLowerCase();
  //     if (selectedOption! < options.length) {
  //       String selectedText = options[selectedOption!].toLowerCase();

  //       // If the text of the selected option matches the correct answer text
  //       if (selectedText == correctStr) {
  //         print(
  //             "CORRECT: Selected option text '$selectedText' matches correct answer text '$correctStr'");
  //         return true;
  //       }

  //       // Try to find the correct option by comparing text content
  //       for (int i = 0; i < options.length; i++) {
  //         String optionText = options[i].toLowerCase();
  //         if (optionText == correctStr) {
  //           print(
  //               "FOUND CORRECT OPTION: Option $i text '$optionText' matches correct answer text '$correctStr'");
  //           return selectedOption == i;
  //         }
  //       }
  //     }

  //     // If no text match found, try numeric comparison
  //     try {
  //       int correctIndex = int.parse(correctStr);
  //       bool isCorrect = selectedOption == correctIndex;
  //       print(
  //           "NUMERIC COMPARISON: Selected=$selectedOption, Correct=$correctIndex, isCorrect=$isCorrect");
  //       return isCorrect;
  //     } catch (e) {
  //       print("Error parsing correct option as number: $e");
  //     }

  //     // If all else fails, compare string representations
  //     bool fallbackResult = selectedOption.toString() == correctStr;
  //     print(
  //         "FALLBACK COMPARISON: Selected=${selectedOption.toString()}, Correct=$correctStr, isCorrect=$fallbackResult");
  //     return fallbackResult;
  //   } else if (type == 'true_false' || type == 'TrueFalse') {
  //     if (selectedOption == null || correct == null) {
  //       return false;
  //     }

  //     // For true/false questions, "true" = 0 and "false" = 1 in the UI
  //     String selectedAnswer = selectedOption == 0 ? "true" : "false";
  //     String correctStr = correct!.toLowerCase().trim();

  //     // Handle various formats of correct answer
  //     if (correctStr == "0" ||
  //         correctStr == "true" ||
  //         correctStr == "\"true\"" ||
  //         correctStr == "'true'") {
  //       return selectedOption == 0;
  //     } else if (correctStr == "1" ||
  //         correctStr == "false" ||
  //         correctStr == "\"false\"" ||
  //         correctStr == "'false'") {
  //       return selectedOption == 1;
  //     }

  //     // Default string comparison
  //     return selectedAnswer == correctStr;
  //   }

  //   // For file questions or unknown types
  //   return false;
  // }

  bool checkAnswer() {
    if (type == 'multiple_choice' || type == 'MCQ') {
      if (selectedOption == null || correct == null) {
        return false;
      }

      // Direct text comparison between selected option text and correct text
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

// Para mantener compatibilidad con el código existente
class QuestionModel {
  final String type;
  final String question;
  final List<String> options;
  final String? correct;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final int? fileSize;

  QuestionModel({
    required this.type,
    required this.question,
    this.options = const [],
    this.correct,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'question': question,
      'options': options,
      'correct': correct,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      type: map['type'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correct: map['correct'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      fileType: map['fileType'],
      fileSize: map['fileSize'],
    );
  }
}

// Assignment page specific model to avoid conflicts
enum AssignmentQuestionType {
  trueOrFalse,
  multipleChoice,
}

class AssignmentQuestion {
  final String questionText;
  final AssignmentQuestionType questionType;
  final int correctAnswer; // 0-based index of correct answer in options
  final List<String> options;
  final bool hasImage;
  final String? imagePath;

  AssignmentQuestion({
    required this.questionText,
    required this.questionType,
    required this.correctAnswer,
    required this.options,
    this.hasImage = false,
    this.imagePath,
  });
}
