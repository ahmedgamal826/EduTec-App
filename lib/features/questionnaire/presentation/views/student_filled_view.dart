import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'student_answers_view.dart';

class StudentsFilledView extends StatelessWidget {
  final String courseId;

  const StudentsFilledView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Students Who Filled',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Courses')
            .doc(courseId)
            .collection('questionnaires')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(context, 'Error loading data');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context, 'No questionnaires available');
          }

          final questionnaires = snapshot.data!.docs;

          return FutureBuilder<List<bool>>(
            future: _checkIfAnyStudentsFilled(questionnaires, courseId),
            builder: (context, filledSnapshot) {
              if (filledSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              if (filledSnapshot.hasError) {
                return _buildErrorState(context, 'Error loading filled data');
              }

              final hasAnyStudentsFilled =
                  filledSnapshot.data?.any((filled) => filled) ?? false;

              if (!hasAnyStudentsFilled) {
                return _buildEmptyState(
                    context, 'No students have filled out questionnaires yet');
              }

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: ListView.builder(
                  itemCount: questionnaires.length,
                  itemBuilder: (context, index) {
                    final questionnaire = questionnaires[index];
                    final questionnaireId = questionnaire.id;
                    final questionnaireName = 'Questionnaire ${index + 1}';

                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: Duration(milliseconds: index * 500),
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
                            questionnaireName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Tap to view students',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          children: [
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('Courses')
                                  .doc(courseId)
                                  .collection('questionnaires')
                                  .doc(questionnaireId)
                                  .collection('filledBy')
                                  .get(),
                              builder: (context, filledSnapshot) {
                                if (filledSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                    ),
                                  );
                                }
                                if (filledSnapshot.hasError) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Error loading filled data',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                }
                                final filledDocs =
                                    filledSnapshot.data?.docs ?? [];
                                final studentUids = filledDocs
                                    .map((doc) => doc['uid'] as String)
                                    .toList();

                                if (studentUids.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'No students have filled this questionnaire yet.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                return FutureBuilder<
                                    List<Map<String, dynamic>>>(
                                  future: _getStudentNames(studentUids),
                                  builder: (context, studentNamesSnapshot) {
                                    if (studentNamesSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                        ),
                                      );
                                    }
                                    final studentNames =
                                        studentNamesSnapshot.data ?? [];

                                    return Column(
                                      children: studentNames
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final studentIndex = entry.key;
                                        final studentName =
                                            entry.value['name'] ?? 'Unknown';

                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.04,
                                            vertical: screenHeight * 0.005,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StudentAnswersView(
                                                    courseId: courseId,
                                                    questionnaireId:
                                                        questionnaireId,
                                                    studentUid: studentUids[
                                                        studentIndex],
                                                    studentName: studentName,
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: screenHeight * 0.015,
                                                horizontal: screenWidth * 0.04,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    color:
                                                        AppColors.primaryColor,
                                                    size: 24,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.03),
                                                  Expanded(
                                                    child: Text(
                                                      studentName,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.grey[400],
                                                    size: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                );
                              },
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

  Future<List<bool>> _checkIfAnyStudentsFilled(
      List<QueryDocumentSnapshot> questionnaires, String courseId) async {
    final List<bool> results = [];
    for (final questionnaire in questionnaires) {
      final questionnaireId = questionnaire.id;
      final snapshot = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('questionnaires')
          .doc(questionnaireId)
          .collection('filledBy')
          .get();
      final filledDocs = snapshot.docs;
      results.add(filledDocs.isNotEmpty);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> _getStudentNames(List<String> uids) async {
    final List<Map<String, dynamic>> names = [];
    for (final uid in uids) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        names.add({'name': doc.data()?['name'] ?? 'Unknown'});
      }
    }
    return names;
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
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
