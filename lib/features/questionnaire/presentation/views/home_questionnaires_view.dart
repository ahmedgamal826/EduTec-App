import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/questionnaire/presentation/viewmodels/home_questionnaires_viewmodel.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/admin_questionnaire_view.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/student_filled_view.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/question_model.dart';

class HomeQuestionnairesView extends StatelessWidget {
  final String courseId;

  const HomeQuestionnairesView({super.key, required this.courseId});

  void _deleteQuestionnaire(
      BuildContext context, HomeQuestionnairesViewModel viewModel, int index) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Confirm Deletion',
      desc:
          'Are you sure you want to delete ${viewModel.questionnaires[index].name}?',
      btnCancelOnPress: () => viewModel.selectQuestionnaire(-1),
      btnOkOnPress: () => viewModel.deleteQuestionnaire(index),
      btnOkText: 'Confirm',
      btnCancelText: 'Cancel',
      btnOkColor: Colors.red,
      btnCancelColor: Colors.grey,
    ).show();
  }

  Future<void> _addOrUpdateQuestionnaire(
      BuildContext context, HomeQuestionnairesViewModel viewModel,
      {List<Map<String, dynamic>> initialQuestions = const [],
      String? questionnaireId}) async {
    final newQuestions = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminQuestionnaireView(
          courseId: courseId,
          initialQuestions: initialQuestions,
        ),
      ),
    );

    if (newQuestions != null &&
        newQuestions is List &&
        newQuestions.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final questionsList = newQuestions
            .map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
            .toList();
        if (questionnaireId == null) {
          // إضافة استبيان جديد
          viewModel.addQuestionnaire(questionsList);
        } else {
          // تحديث استبيان موجود
          viewModel.updateQuestionnaire(questionnaireId, questionsList);
        }
      } catch (e) {
        print('Error adding/updating questionnaire: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding/updating questionnaire: $e')),
        );
      } finally {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => HomeQuestionnairesViewModel(courseId: courseId),
      child: Consumer<HomeQuestionnairesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Home Questionnaires',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.primaryColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.people, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StudentsFilledView(courseId: courseId)));
                  },
                  tooltip: 'View Students Who Filled',
                ),
              ],
            ),
            body: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ))
                : viewModel.questionnaires.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.library_books,
                                size: 80, color: Colors.grey),
                            SizedBox(height: screenHeight * 0.03),
                            Text('No Questionnaire available',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: screenHeight * 0.03,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500)),
                            SizedBox(height: screenHeight * 0.01),
                            Text('Click the "+" button to add a new one!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: screenHeight * 0.02,
                                    color: Colors.grey)),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: ListView.builder(
                          itemCount: viewModel.questionnaires.length,
                          itemBuilder: (context, index) {
                            final questionnaire =
                                viewModel.questionnaires[index];
                            String formattedDate;
                            try {
                              final parsedDate = DateFormat('dd-MM-yyyy HH:mm')
                                  .parseStrict(questionnaire.date);
                              formattedDate = DateFormat('dd-MM-yyyy h:mm a')
                                  .format(parsedDate);
                            } catch (e) {
                              print(
                                  'Error parsing date: ${questionnaire.date}, Error: $e');
                              formattedDate = DateFormat('dd-MM-yyyy h:mm a')
                                  .format(DateTime.now());
                            }
                            return FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              delay: Duration(milliseconds: index * 500),
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.012,
                                  horizontal: screenWidth * 0.010,
                                ),
                                color: Colors.white,
                                child: InkWell(
                                  onTap: () {
                                    _addOrUpdateQuestionnaire(
                                      context,
                                      viewModel,
                                      initialQuestions: questionnaire.questions
                                          .map((q) => q.toMap())
                                          .toList(),
                                      questionnaireId: questionnaire.name,
                                    );
                                  },
                                  onLongPress: () {
                                    viewModel.selectQuestionnaire(index);
                                    _deleteQuestionnaire(
                                        context, viewModel, index);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  splashColor:
                                      AppColors.primaryColor.withOpacity(0.2),
                                  highlightColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.02,
                                        horizontal: screenWidth * 0.04),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Questionnaire ${index + 1}',
                                                style: TextStyle(
                                                  fontSize:
                                                      screenHeight * 0.028,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.008),
                                              Text(
                                                'Date: $formattedDate',
                                                style: TextStyle(
                                                  fontSize: screenHeight * 0.02,
                                                  color: Colors.grey[600],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.005),
                                              Text(
                                                'By: Dr/ ${questionnaire.doctor}',
                                                style: TextStyle(
                                                  fontSize: screenHeight * 0.02,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppColors.primaryColor,
                                          size: screenHeight * 0.03,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            floatingActionButton: FloatingActionButton(
              heroTag: "admin_home_questionnaire_screen",
              onPressed: () async {
                await _addOrUpdateQuestionnaire(context, viewModel);
              },
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
