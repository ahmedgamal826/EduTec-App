import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/questionnaire/presentation/viewmodels/questionnaire_viewmodel.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/add_questions_view.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_card.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_content.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminQuestionnaireView extends StatelessWidget {
  final List<Map<String, dynamic>> initialQuestions;
  final String courseId;

  const AdminQuestionnaireView({
    super.key,
    this.initialQuestions = const [],
    required this.courseId,
  });

  void _showQuestionTypeDialog(
      BuildContext context, QuestionnaireViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Question Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuestionTypeButton(context, 'TrueFalse', viewModel),
            const SizedBox(height: 10),
            _buildQuestionTypeButton(context, 'MCQ', viewModel),
            const SizedBox(height: 10),
            _buildQuestionTypeButton(context, 'Essay', viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeButton(
      BuildContext context, String type, QuestionnaireViewModel viewModel) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddQuestionScreen(
              questionType: type,
              onQuestionAdded: (newQuestion) {
                viewModel.addQuestion(newQuestion);
              },
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text(
          type == 'TrueFalse' ? 'True/False' : type,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, int index, QuestionnaireViewModel viewModel) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Confirm Deletion',
      desc: 'Are you sure you want to delete Question ${index + 1}?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        viewModel.deleteQuestion(index);
      },
      btnOkText: 'Confirm',
      btnCancelText: 'Cancel',
      btnOkColor: Colors.red,
      btnCancelColor: Colors.grey,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = QuestionnaireViewModel();
        viewModel.initializeQuestions(initialQuestions);
        return viewModel;
      },
      child: Consumer<QuestionnaireViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Questions',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IconButton(
                    onPressed: () async {
                      if (viewModel.questions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please add at least one question!')),
                        );
                        return;
                      }
                      Navigator.pop(context,
                          viewModel.questions.map((q) => q.toMap()).toList());
                    },
                    icon:
                        const Icon(Icons.check, color: Colors.white, size: 30),
                    tooltip: 'Save Questionnaire',
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: QuestionContent(
                            question: viewModel.currentQuestion),
                      ),
                    ),
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: Colors.grey.shade200,
                      child: viewModel.questions.isEmpty
                          ? const Center(
                              child: Text('No questions yet',
                                  style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.questions.length,
                              itemBuilder: (context, index) {
                                return QuestionCard(
                                  role: 'Admin',
                                  index: index,
                                  isSelected:
                                      viewModel.currentQuestionIndex == index,
                                  onTap: () {
                                    viewModel.selectQuestion(index);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddQuestionScreen(
                                          questionType:
                                              viewModel.questions[index].type,
                                          existingQuestion:
                                              viewModel.questions[index],
                                          onQuestionAdded: (updatedQuestion) {
                                            viewModel.updateQuestion(
                                                index, updatedQuestion);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  onDelete: () => _showDeleteDialog(
                                      context, index, viewModel),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: "admin_questionnaire_screen",
                    onPressed: () {
                      _showQuestionTypeDialog(context, viewModel);
                    },
                    backgroundColor: AppColors.primaryColor,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
