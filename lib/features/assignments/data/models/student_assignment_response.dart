// import 'package:cloud_firestore/cloud_firestore.dart';

// class StudentResponse {
//   final String questionId;
//   final String questionType; // "multiple_choice", "true_false", "file"
//   final int? selectedOption; // Índice de la opción seleccionada
//   final String? fileUrl; // URL del archivo subido por el estudiante
//   final String? fileName; // Nombre del archivo
//   final bool?
//       isCorrect; // Si la respuesta es correcta (calculado automáticamente)
//   final int?
//       score; // Puntaje asignado (calculado automáticamente o asignado por el docente)
//   final String? teacherComment; // Comentario del docente (opcional)

//   StudentResponse({
//     required this.questionId,
//     required this.questionType,
//     this.selectedOption,
//     this.fileUrl,
//     this.fileName,
//     this.isCorrect,
//     this.score,
//     this.teacherComment,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'questionId': questionId,
//       'questionType': questionType,
//       'selectedOption': selectedOption,
//       'fileUrl': fileUrl,
//       'fileName': fileName,
//       'isCorrect': isCorrect,
//       'score': score,
//       'teacherComment': teacherComment,
//     };
//   }

//   factory StudentResponse.fromMap(Map<String, dynamic> map) {
//     return StudentResponse(
//       questionId: map['questionId'] ?? '',
//       questionType: map['questionType'] ?? '',
//       selectedOption: map['selectedOption'],
//       fileUrl: map['fileUrl'],
//       fileName: map['fileName'],
//       isCorrect: map['isCorrect'],
//       score: map['score'],
//       teacherComment: map['teacherComment'],
//     );
//   }
// }

// class StudentAssignmentSubmission {
//   final String assignmentId;
//   final String studentId;
//   final String studentName;
//   final List<StudentResponse> responses;
//   final int totalScore;
//   final int maxScore;
//   final int scorePercentage;
//   final String scoreDisplay;
//   final String status; // "submitted", "graded", "partially_graded"
//   final DateTime submittedAt;
//   final DateTime? gradedAt;

//   StudentAssignmentSubmission({
//     required this.assignmentId,
//     required this.studentId,
//     required this.studentName,
//     required this.responses,
//     required this.totalScore,
//     required this.maxScore,
//     required this.scorePercentage,
//     required this.scoreDisplay,
//     required this.status,
//     required this.submittedAt,
//     this.gradedAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'assignmentId': assignmentId,
//       'studentId': studentId,
//       'studentName': studentName,
//       'responses': responses.map((r) => r.toMap()).toList(),
//       'totalScore': totalScore,
//       'maxScore': maxScore,
//       'scorePercentage': scorePercentage,
//       'scoreDisplay': scoreDisplay,
//       'status': status,
//       'submittedAt': Timestamp.fromDate(submittedAt),
//       'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
//     };
//   }

//   factory StudentAssignmentSubmission.fromMap(Map<String, dynamic> map) {
//     return StudentAssignmentSubmission(
//       assignmentId: map['assignmentId'] ?? '',
//       studentId: map['studentId'] ?? '',
//       studentName: map['studentName'] ?? '',
//       responses: List<StudentResponse>.from(
//         (map['responses'] ?? []).map((x) => StudentResponse.fromMap(x)),
//       ),
//       totalScore: map['totalScore'] ?? 0,
//       maxScore: map['maxScore'] ?? 0,
//       scorePercentage: map['scorePercentage'] ?? 0,
//       scoreDisplay: map['scoreDisplay'] ?? '0%',
//       status: map['status'] ?? 'submitted',
//       submittedAt:
//           (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       gradedAt: (map['gradedAt'] as Timestamp?)?.toDate(),
//     );
//   }
// }

import 'package:intl/intl.dart';

class StudentResponse {
  final String questionId;
  final String questionType; // "multiple_choice", "true_false", "file"
  final int? selectedOption; // Índice de la opción seleccionada
  String? fileUrl; // URL del archivo subido por el estudiante
  String? fileName; // Nombre del archivo
  bool? isCorrect; // Si la respuesta es correcta
  int? score; // Puntaje asignado
  final String? teacherComment; // Comentario del docente (opcional)
  final String? selectedAnswerText;
  final String? correctAnswerText;
  final String? textAnswer; // إجابة نصية للسؤال

  StudentResponse({
    required this.questionId,
    required this.questionType,
    this.selectedOption,
    this.fileUrl,
    this.fileName,
    this.isCorrect,
    this.score,
    this.teacherComment,
    this.selectedAnswerText,
    this.correctAnswerText,
    this.textAnswer, // إضافة حقل للإجابة النصية
  });

  // Add method to update isCorrect field
  void updateIsCorrect(bool value) {
    isCorrect = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionType': questionType,
      'selectedOption': selectedOption,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'isCorrect': isCorrect,
      'score': score,
      'teacherComment': teacherComment,
      'selectedAnswerText': selectedAnswerText,
      'correctAnswerText': correctAnswerText,
      'textAnswer': textAnswer, // إضافة حقل للإجابة النصية
    };
  }

  factory StudentResponse.fromMap(Map<String, dynamic> map) {
    return StudentResponse(
      questionId: map['questionId'] ?? '',
      questionType: map['questionType'] ?? '',
      selectedOption: map['selectedOption'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      isCorrect: map['isCorrect'],
      score: map['score'],
      teacherComment: map['teacherComment'],
      selectedAnswerText: map['selectedAnswerText'],
      correctAnswerText: map['correctAnswerText'],
      textAnswer: map['textAnswer'], // إضافة حقل للإجابة النصية
    );
  }
}

class StudentAssignmentSubmission {
  final String assignmentId;
  final String studentId;
  final String studentName;
  final List<StudentResponse> responses;
  final int? totalScore; // Nullable للتعامل مع الحالات غير المقيمة
  final int maxScore;
  final int? scorePercentage; // Nullable
  final String? scoreDisplay; // Nullable
  final String status; // "submitted", "graded", "partially_graded"
  final DateTime submittedAt;
  final DateTime? gradedAt;
  final String? teacherComment; // تعليق عام على الـ submission

  StudentAssignmentSubmission({
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.responses,
    this.totalScore,
    required this.maxScore,
    this.scorePercentage,
    this.scoreDisplay,
    required this.status,
    required this.submittedAt,
    this.gradedAt,
    this.teacherComment,
  });

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'responses': responses.map((r) => r.toMap()).toList(),
      'totalScore': totalScore,
      'maxScore': maxScore,
      'scorePercentage': scorePercentage,
      'scoreDisplay': scoreDisplay,
      'status': status,
      'date': DateFormat('dd-MM-yyyy HH:mm')
          .format(submittedAt), // Changed to string
      'gradedAt': gradedAt != null
          ? DateFormat('dd-MM-yyyy HH:mm').format(gradedAt!)
          : null,
      'teacherComment': teacherComment,
    };
  }

  factory StudentAssignmentSubmission.fromMap(Map<String, dynamic> map) {
    final submissionDateStr = map['date'] as String? ??
        DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    final gradedDateStr = map['gradedAt'] as String?;

    return StudentAssignmentSubmission(
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      responses: List<StudentResponse>.from(
        (map['responses'] ?? []).map((x) => StudentResponse.fromMap(x)),
      ),
      totalScore: map['totalScore'],
      maxScore: map['maxScore'] ?? 0,
      scorePercentage: map['scorePercentage'],
      scoreDisplay: map['scoreDisplay'] ?? 'Not graded yet',
      status: map['status'] ?? 'submitted',
      submittedAt: DateFormat('dd-MM-yyyy HH:mm').parse(submissionDateStr),
      gradedAt: gradedDateStr != null
          ? DateFormat('dd-MM-yyyy HH:mm').parse(gradedDateStr)
          : null,
      teacherComment: map['teacherComment'],
    );
  }
}
