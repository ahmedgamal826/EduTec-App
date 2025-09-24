import 'package:cloud_firestore/cloud_firestore.dart';

class TestsStudentResponse {
  final String questionId;
  final String questionType;
  final int? selectedOption;
  String? fileUrl;
  String? fileName;
  bool? isCorrect;
  int? score;
  final String? teacherComment;
  final String? selectedAnswerText;
  final String? correctAnswerText;
  final String? textAnswer;

  TestsStudentResponse({
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
    this.textAnswer,
  });

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
      'textAnswer': textAnswer,
    };
  }

  factory TestsStudentResponse.fromMap(Map<String, dynamic> map) {
    return TestsStudentResponse(
      questionId: map['questionId'] as String? ?? '',
      questionType: map['questionType'] as String? ?? '',
      selectedOption: map['selectedOption'] as int?,
      fileUrl: map['fileUrl'] as String?,
      fileName: map['fileName'] as String?,
      isCorrect: map['isCorrect'] as bool?,
      score: map['score'] as int?,
      teacherComment: map['teacherComment'] as String?,
      selectedAnswerText: map['selectedAnswerText'] as String?,
      correctAnswerText: map['correctAnswerText'] as String?,
      textAnswer: map['textAnswer'] as String?,
    );
  }
}

class TestsStudentSubmission {
  final String testId;
  final String studentId;
  final String studentName;
  final List<TestsStudentResponse> responses;
  final int? totalScore;
  final int maxScore;
  final int? scorePercentage;
  final String? scoreDisplay;
  final String status;
  final DateTime submittedAt;
  final DateTime? gradedAt;
  final String? teacherComment;

  TestsStudentSubmission({
    required this.testId,
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
      'testId': testId,
      'studentId': studentId,
      'studentName': studentName,
      'responses': responses.map((r) => r.toMap()).toList(),
      'totalScore': totalScore,
      'maxScore': maxScore,
      'scorePercentage': scorePercentage,
      'scoreDisplay': scoreDisplay ??
          (totalScore != null ? '$totalScore/$maxScore' : 'Not graded yet'),
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
      'teacherComment': teacherComment,
    };
  }

  factory TestsStudentSubmission.fromMap(Map<String, dynamic> map) {
    return TestsStudentSubmission(
      testId: map['testId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      responses: List<TestsStudentResponse>.from(
        (map['responses'] as List<dynamic>? ?? []).map(
            (x) => TestsStudentResponse.fromMap(x as Map<String, dynamic>)),
      ),
      totalScore: map['totalScore'] as int?,
      maxScore: map['maxScore'] as int? ?? 0,
      scorePercentage: map['scorePercentage'] as int?,
      scoreDisplay: map['scoreDisplay'] as String? ?? 'Not graded yet',
      status: map['status'] as String? ?? 'submitted',
      submittedAt:
          (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gradedAt: (map['gradedAt'] as Timestamp?)?.toDate(),
      teacherComment: map['teacherComment'] as String?,
    );
  }
}
