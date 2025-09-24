import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class StudentAnswersView extends StatelessWidget {
  final String courseId;
  final String questionnaireId;
  final String studentUid;
  final String studentName;

  const StudentAnswersView({
    super.key,
    required this.courseId,
    required this.questionnaireId,
    required this.studentUid,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '$studentName\'s Answers',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Courses')
            .doc(courseId)
            .collection('questionnaires')
            .doc(questionnaireId)
            .collection('filledBy')
            .doc(studentUid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(context, 'Error loading answers');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildEmptyState(
                context, 'No answers found for this student');
          }

          final answers = snapshot.data!.data() as Map<String, dynamic>;
          final answersMap = answers['answers'] as Map<String, dynamic>? ?? {};

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Courses')
                .doc(courseId)
                .collection('questionnaires')
                .doc(questionnaireId)
                .get(),
            builder: (context, questionnaireSnapshot) {
              if (questionnaireSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              if (questionnaireSnapshot.hasError) {
                return _buildErrorState(context, 'Error loading questionnaire');
              }
              if (!questionnaireSnapshot.hasData ||
                  !questionnaireSnapshot.data!.exists) {
                return _buildEmptyState(context, 'Questionnaire not found');
              }

              final questionnaireData =
                  questionnaireSnapshot.data!.data() as Map<String, dynamic>;
              final questions = (questionnaireData['questions'] as List)
                  .map((q) => QuestionModel.fromMap(q))
                  .toList();

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final answer = answersMap[index.toString()]?.toString() ??
                        'No answer provided';
                    final isCorrect =
                        question.type != 'Essay' && question.correct != null
                            ? answer == question.correct
                            : null;

                    return FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      delay: Duration(milliseconds: index * 100),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        margin:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.1),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            question.question,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Type: ${question.type}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.02,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.reply,
                                        size: 18,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Answer: $answer',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (question.type != 'Essay' &&
                                      question.correct != null) ...[
                                    const Divider(height: 20),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 18,
                                          color: isCorrect == true
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Correct Answer: ${question.correct}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isCorrect == true
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (isCorrect != null)
                                          Icon(
                                            isCorrect
                                                ? Icons.check
                                                : Icons.close,
                                            color: isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
