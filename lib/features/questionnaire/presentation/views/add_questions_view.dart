import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_question_viewmodel.dart';
import '../../data/models/question_model.dart';

class AddQuestionScreen extends StatelessWidget {
  final String questionType;
  final QuestionModel? existingQuestion;
  final Function(QuestionModel) onQuestionAdded;

  const AddQuestionScreen({
    super.key,
    required this.questionType,
    this.existingQuestion,
    required this.onQuestionAdded,
  });

  void _saveQuestion(BuildContext context, AddQuestionViewModel viewModel) {
    final question = viewModel.saveQuestion();
    if (question == null) {
      print('Save failed: Invalid question');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    print('Saving question: ${question.toMap()}');
    onQuestionAdded(question);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddQuestionViewModel(
          questionType: questionType, existingQuestion: existingQuestion),
      child: Consumer<AddQuestionViewModel>(
        builder: (context, viewModel, child) {
          print('Building AddQuestionScreen for $questionType');
          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                existingQuestion != null
                    ? 'Edit $questionType Question'
                    : 'Add $questionType Question',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      cursorColor: AppColors.primaryColor,
                      controller: viewModel.questionController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your question',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 2)),
                      ),
                      maxLines: 3,
                      onChanged: (value) =>
                          print('Question text changed: $value'),
                    ),
                    const SizedBox(height: 20),
                    if (questionType == 'TrueFalse') ...[
                      const Text('Select the correct answer:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 8,
                        child: RadioListTile<String>(
                          title: const Text('True'),
                          value: 'True',
                          activeColor: AppColors.primaryColor,
                          groupValue: viewModel.correctAnswerTrueFalse,
                          onChanged: (value) {
                            print('Selected True');
                            viewModel.setCorrectAnswerTrueFalse(value);
                          },
                        ),
                      ),
                      Card(
                        elevation: 8,
                        child: RadioListTile<String>(
                          title: const Text('False'),
                          value: 'False',
                          activeColor: AppColors.primaryColor,
                          groupValue: viewModel.correctAnswerTrueFalse,
                          onChanged: (value) {
                            print('Selected False');
                            viewModel.setCorrectAnswerTrueFalse(value);
                          },
                        ),
                      ),
                    ] else if (questionType == 'MCQ') ...[
                      const Text(
                          'Enter the options and select the correct answer:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ...viewModel.mcqOptionControllers
                          .asMap()
                          .entries
                          .map((entry) {
                        int idx = entry.key;
                        TextEditingController controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  cursorColor: AppColors.primaryColor,
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: 'Option ${idx + 1}',
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey)),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2)),
                                  ),
                                  onChanged: (value) =>
                                      print('Option $idx changed: $value'),
                                ),
                              ),
                              Radio<int>(
                                value: idx,
                                groupValue: viewModel.correctAnswerMcq,
                                activeColor: AppColors.primaryColor,
                                onChanged: (value) {
                                  print('Selected MCQ option $idx');
                                  viewModel.setCorrectAnswerMcq(value);
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        print('Save Question pressed');
                        _saveQuestion(context, viewModel);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        existingQuestion != null
                            ? 'Update Question'
                            : 'Save Question',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
