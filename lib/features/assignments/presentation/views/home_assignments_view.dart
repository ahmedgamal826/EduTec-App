import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/data/models/assignment_model_admin.dart';
import 'package:attendance_app/features/assignments/data/models/question_model_admin.dart';
import 'package:attendance_app/features/assignments/presentation/viewmodels/home_assignments_viewmodel.dart';
import 'package:attendance_app/features/assignments/presentation/views/admin_assignment_view.dart';
import 'package:attendance_app/features/assignments/presentation/views/widgets/assignment_list_item.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeAssignmentsView extends StatelessWidget {
  final String courseId;

  const HomeAssignmentsView({super.key, required this.courseId});

  void _deleteAssignment(
      BuildContext context, HomeAssignmentsViewModel viewModel, int index) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Confirm Deletion',
      desc:
          'Are you sure you want to delete ${viewModel.assignments[index].name}?',
      btnCancelOnPress: () => viewModel.selectAssignment(-1),
      btnOkOnPress: () => viewModel.deleteAssignment(index),
      btnOkText: 'Confirm',
      btnCancelText: 'Cancel',
      btnOkColor: Colors.red,
      btnCancelColor: Colors.grey,
    ).show();
  }

  void _showAddAssignmentDialog(
      BuildContext context, HomeAssignmentsViewModel viewModel) {
    String newAssignmentName = '';
    DateTime? selectedDeadline;
    TextEditingController deadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add New Assignment',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  cursorColor: AppColors.primaryColor,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter assignment name',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    newAssignmentName = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: deadlineController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select deadline (optional)',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: AppColors.primaryColor),
                  ),
                  onTap: () async {
                    // Show date picker
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      // Show time picker
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primaryColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedTime != null) {
                        // Combine date and time
                        selectedDeadline = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        // Format the deadline for display
                        deadlineController.text =
                            DateFormat('dd-MM-yyyy h:mm a')
                                .format(selectedDeadline!);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (newAssignmentName.isNotEmpty) {
                  Navigator.pop(context);
                  String? formattedDeadline;
                  if (selectedDeadline != null) {
                    formattedDeadline = DateFormat('dd-MM-yyyy HH:mm')
                        .format(selectedDeadline!);
                  }
                  _addOrUpdateAssignment(context, viewModel,
                      name: newAssignmentName, deadline: formattedDeadline);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _addOrUpdateAssignment(
  //     BuildContext context, HomeAssignmentsViewModel viewModel,
  //     {List<Map<String, dynamic>> initialQuestions = const [],
  //     String? assignmentId,
  //     String? name,
  //     String? deadline}) async {
  //   final newQuestions = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AdminAssignmentView(
  //         courseId: courseId,
  //         initialQuestions: initialQuestions,
  //       ),
  //     ),
  //   );

  //   if (newQuestions == null || newQuestions is! List || newQuestions.isEmpty) {
  //     return;
  //   }

  //   try {
  //     final questionsList = newQuestions
  //         .map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
  //         .toList();

  //     if (assignmentId == null) {
  //       // Add new assignment with deadline
  //       await viewModel.addAssignment(name!, questionsList, deadline: deadline);
  //     } else {
  //       // Update existing assignment, keeping the deadline the same
  //       await viewModel.updateAssignment(assignmentId, questionsList);
  //     }
  //   } catch (e) {
  //     print('Error in _addOrUpdateAssignment: $e');
  //   }
  // }

  Future<void> _addOrUpdateAssignment(
      BuildContext context, HomeAssignmentsViewModel viewModel,
      {List<Map<String, dynamic>> initialQuestions = const [],
      String? assignmentId,
      String? name,
      String? deadline}) async {
    final newQuestions = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAssignmentView(
          courseId: courseId,
          initialQuestions: initialQuestions,
        ),
      ),
    );

    if (newQuestions == null || newQuestions is! List || newQuestions.isEmpty) {
      return;
    }

    try {
      final questionsList = newQuestions
          .map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
          .toList();

      if (assignmentId == null) {
        await viewModel.addAssignment(name!, questionsList, deadline: deadline);
      } else {
        await viewModel.updateAssignment(assignmentId, questionsList,
            deadline: deadline);
      }
    } catch (e) {
      print('Error in _addOrUpdateAssignment: $e');
    }
  }

  void _showEditAssignmentDialog(BuildContext context,
      HomeAssignmentsViewModel viewModel, AssignmentModel assignment) {
    String newAssignmentName = assignment.name;
    DateTime? selectedDeadline;
    TextEditingController nameController =
        TextEditingController(text: assignment.name);
    TextEditingController deadlineController = TextEditingController();

    // Initialize the deadline controller if a deadline exists
    if (assignment.deadline != null) {
      try {
        final parsedDate =
            DateFormat('dd-MM-yyyy HH:mm').parseStrict(assignment.deadline!);
        selectedDeadline = parsedDate;
        deadlineController.text =
            DateFormat('dd-MM-yyyy h:mm a').format(parsedDate);
      } catch (e) {
        print('Error parsing date: ${assignment.deadline}, Error: $e');
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Assignment',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  cursorColor: AppColors.primaryColor,
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Assignment Name',
                    labelStyle: const TextStyle(
                      color: AppColors.primaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    newAssignmentName = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: deadlineController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Deadline',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        deadlineController.clear();
                        selectedDeadline = null;
                      },
                    ),
                  ),
                  onTap: () async {
                    // Show date picker
                    final initialDate = selectedDeadline ??
                        DateTime.now().add(const Duration(days: 7));

                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      // Show time picker
                      final initialTime = selectedDeadline != null
                          ? TimeOfDay(
                              hour: selectedDeadline!.hour,
                              minute: selectedDeadline!.minute)
                          : TimeOfDay.now();

                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primaryColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedTime != null) {
                        // Combine date and time
                        selectedDeadline = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        // Format the deadline for display
                        deadlineController.text =
                            DateFormat('dd-MM-yyyy h:mm a')
                                .format(selectedDeadline!);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                if (newAssignmentName.isNotEmpty) {
                  Navigator.pop(context);

                  // Format deadline for storage
                  String? formattedDeadline;
                  if (selectedDeadline != null) {
                    formattedDeadline = DateFormat('dd-MM-yyyy HH:mm')
                        .format(selectedDeadline!);
                  }

                  // Update assignment with new name and deadline
                  _updateAssignmentDetails(
                    context,
                    viewModel,
                    assignment,
                    newName: newAssignmentName,
                    newDeadline: formattedDeadline,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAssignmentDetails(BuildContext context,
      HomeAssignmentsViewModel viewModel, AssignmentModel assignment,
      {required String newName, String? newDeadline}) async {
    try {
      await viewModel.updateAssignmentDetails(
        assignment.name,
        newName: newName,
        deadline: newDeadline,
      );
    } catch (e) {
      print('Error updating assignment details: $e');
    }
  }

  void _editAssignmentQuestions(BuildContext context,
      HomeAssignmentsViewModel viewModel, AssignmentModel assignment) {
    _addOrUpdateAssignment(
      context,
      viewModel,
      initialQuestions: assignment.questions.map((q) => q.toMap()).toList(),
      assignmentId: assignment.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => HomeAssignmentsViewModel(courseId: courseId),
      child: Consumer<HomeAssignmentsViewModel>(
        builder: (context, viewModel, child) {
          // إظهار رسائل النجاح
          if (viewModel.successMessage.isNotEmpty) {
            // جدولة رسالة النجاح لتظهر بعد بناء الواجهة
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.successMessage),
                  backgroundColor: Colors.green,
                ),
              );
              // مسح الرسالة بعد عرضها
              viewModel.clearMessages();
            });
          }

          // إظهار رسائل الخطأ
          if (viewModel.errorMessage.isNotEmpty) {
            // جدولة رسالة الخطأ لتظهر بعد بناء الواجهة
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
              // مسح الرسالة بعد عرضها
              viewModel.clearMessages();
            });
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Assignments',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.primaryColor,
            ),
            // عرض مؤشر التحميل الرئيسي
            body: Stack(
              children: [
                // محتوى الصفحة الرئيسي
                viewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ))
                    : viewModel.assignments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.assignment,
                                    size: 80, color: Colors.grey),
                                SizedBox(height: screenHeight * 0.03),
                                Text('No Assignments available',
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
                              itemCount: viewModel.assignments.length,
                              itemBuilder: (context, index) {
                                final assignment = viewModel.assignments[index];
                                return AssignmentListItem(
                                  assignment: assignment,
                                  animation: const AlwaysStoppedAnimation(1.0),
                                  onDelete: () {
                                    viewModel.selectAssignment(index);
                                    _deleteAssignment(
                                        context, viewModel, index);
                                  },
                                  onTap: () {
                                    _showEditAssignmentDialog(
                                      context,
                                      viewModel,
                                      assignment,
                                    );
                                  },
                                  onEditQuestions: () {
                                    _editAssignmentQuestions(
                                      context,
                                      viewModel,
                                      assignment,
                                    );
                                  },
                                  courseName: viewModel.courseName,
                                ).animate().flipV(duration: 400.ms);
                              },
                            ),
                          ),

                // طبقة مؤشر التحميل أثناء المعالجة
                if (viewModel.isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showAddAssignmentDialog(context, viewModel);
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
