import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/data/models/assignment_model_student.dart';
import 'package:attendance_app/features/tests/data/models/tests_model_admin.dart';
import 'package:attendance_app/features/tests/data/models/tests_question_model_admin.dart';
import 'package:attendance_app/features/tests/presentation/viewmodels/home_tests_viewmodel.dart';
import 'package:attendance_app/features/tests/presentation/views/admin_tests_view.dart';
import 'package:attendance_app/features/tests/presentation/views/widgets/tests_list_item_admin.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeTestsView extends StatelessWidget {
  final String courseId;

  const HomeTestsView({super.key, required this.courseId});

  // Helper method to format time with AM/PM
  String _formatTimeWithAMPM(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    return DateFormat('hh:mm a').format(dateTime);
  }

  void _deleteTest(
      BuildContext context, TestsHomeViewModel viewModel, int index) {
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

  void _showAddTestDialog(BuildContext context, TestsHomeViewModel viewModel) {
    String newTestName = '';
    DateTime? selectedExamDate;
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;
    TextEditingController examDateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add New Test',
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
                    hintText: 'Enter test name',
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
                    newTestName = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: examDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select exam date',
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
                      initialDate: DateTime.now().add(const Duration(days: 1)),
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
                      selectedExamDate = pickedDate;
                      examDateController.text =
                          DateFormat('dd-MM-yyyy').format(selectedExamDate!);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select start time',
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
                    prefixIcon: const Icon(Icons.access_time,
                        color: AppColors.primaryColor),
                  ),
                  onTap: () async {
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
                      selectedStartTime = pickedTime;
                      startTimeController.text =
                          _formatTimeWithAMPM(pickedTime);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select end time',
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
                    prefixIcon: const Icon(Icons.access_time,
                        color: AppColors.primaryColor),
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedStartTime != null
                          ? TimeOfDay(
                              hour: (selectedStartTime!.hour + 1) % 24,
                              minute: selectedStartTime!.minute)
                          : TimeOfDay.now(),
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
                      selectedEndTime = pickedTime;
                      endTimeController.text = _formatTimeWithAMPM(pickedTime);
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
                if (newTestName.isNotEmpty) {
                  Navigator.pop(context);

                  String? formattedExamDate;
                  String? formattedStartTime;
                  String? formattedEndTime;

                  if (selectedExamDate != null) {
                    formattedExamDate =
                        DateFormat('dd-MM-yyyy').format(selectedExamDate!);
                  }

                  if (selectedStartTime != null) {
                    formattedStartTime =
                        '${selectedStartTime!.hour.toString().padLeft(2, '0')}:${selectedStartTime!.minute.toString().padLeft(2, '0')}';
                  }

                  if (selectedEndTime != null) {
                    formattedEndTime =
                        '${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}';
                  }

                  _addOrUpdateTest(context, viewModel,
                      name: newTestName,
                      examDate: formattedExamDate,
                      startTime: formattedStartTime,
                      endTime: formattedEndTime);
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

  Future<void> _addOrUpdateTest(
      BuildContext context, TestsHomeViewModel viewModel,
      {List<Map<String, dynamic>> initialQuestions = const [],
      String? testId,
      String? name,
      String? examDate,
      String? startTime,
      String? endTime}) async {
    final newQuestions = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminTestsView(
          courseId: courseId,
          initialTestsQuestions: initialQuestions,
        ),
      ),
    );

    if (newQuestions == null || newQuestions is! List || newQuestions.isEmpty) {
      return;
    }

    try {
      final questionsList = newQuestions
          .map((q) => TestsQuestionModel.fromMap(q as Map<String, dynamic>))
          .toList();

      if (testId == null) {
        await viewModel.addAssignment(name!, questionsList,
            examDate: examDate, startTime: startTime, endTime: endTime);
      } else {
        await viewModel.updateAssignment(testId, questionsList,
            examDate: examDate, startTime: startTime, endTime: endTime);
      }
    } catch (e) {
      print('Error in _addOrUpdateTest: $e');
    }
  }

  void _showEditTestDialog(BuildContext context, TestsHomeViewModel viewModel,
      TestsAssignmentModel test) {
    String newTestName = test.name;
    DateTime? selectedExamDate;
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;
    TextEditingController nameController =
        TextEditingController(text: test.name);
    TextEditingController examDateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    // Initialize the exam date controller if an exam date exists
    if (test.examDate != null) {
      try {
        final parsedDate = DateFormat('dd-MM-yyyy').parseStrict(test.examDate!);
        selectedExamDate = parsedDate;
        examDateController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
      } catch (e) {
        print('Error parsing date: ${test.examDate}, Error: $e');
      }
    }

    // Initialize the start time controller if a start time exists
    if (test.startTime != null) {
      try {
        final parts = test.startTime!.split(':');
        if (parts.length == 2) {
          selectedStartTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
          startTimeController.text =
              '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        print('Error parsing start time: ${test.startTime}, Error: $e');
      }
    }

    // Initialize the end time controller if an end time exists
    if (test.endTime != null) {
      try {
        final parts = test.endTime!.split(':');
        if (parts.length == 2) {
          selectedEndTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
          endTimeController.text =
              '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        print('Error parsing end time: ${test.endTime}, Error: $e');
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
            'Edit Test',
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
                    labelText: 'Test Name',
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
                    newTestName = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: examDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Exam Date',
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
                        examDateController.clear();
                        selectedExamDate = null;
                      },
                    ),
                  ),
                  onTap: () async {
                    final initialDate = selectedExamDate ??
                        DateTime.now().add(const Duration(days: 1));

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
                      selectedExamDate = pickedDate;
                      examDateController.text =
                          DateFormat('dd-MM-yyyy').format(selectedExamDate!);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Time',
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
                    prefixIcon: const Icon(Icons.access_time,
                        color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        startTimeController.clear();
                        selectedStartTime = null;
                      },
                    ),
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedStartTime ?? TimeOfDay.now(),
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
                      selectedStartTime = pickedTime;
                      startTimeController.text =
                          _formatTimeWithAMPM(pickedTime);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Time',
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
                    prefixIcon: const Icon(Icons.access_time,
                        color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        endTimeController.clear();
                        selectedEndTime = null;
                      },
                    ),
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedEndTime ??
                          (selectedStartTime != null
                              ? TimeOfDay(
                                  hour: (selectedStartTime!.hour + 1) % 24,
                                  minute: selectedStartTime!.minute)
                              : TimeOfDay.now()),
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
                      selectedEndTime = pickedTime;
                      endTimeController.text = _formatTimeWithAMPM(pickedTime);
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
                if (newTestName.isNotEmpty) {
                  Navigator.pop(context);

                  // Format values for storage
                  String? formattedExamDate;
                  String? formattedStartTime;
                  String? formattedEndTime;

                  if (selectedExamDate != null) {
                    formattedExamDate =
                        DateFormat('dd-MM-yyyy').format(selectedExamDate!);
                  }

                  if (selectedStartTime != null) {
                    formattedStartTime =
                        '${selectedStartTime!.hour.toString().padLeft(2, '0')}:${selectedStartTime!.minute.toString().padLeft(2, '0')}';
                  }

                  if (selectedEndTime != null) {
                    formattedEndTime =
                        '${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}';
                  }

                  // Update test with new details
                  _updateTestDetails(
                    context,
                    viewModel,
                    test,
                    newName: newTestName,
                    newExamDate: formattedExamDate,
                    newStartTime: formattedStartTime,
                    newEndTime: formattedEndTime,
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

  Future<void> _updateTestDetails(BuildContext context,
      TestsHomeViewModel viewModel, TestsAssignmentModel test,
      {required String newName,
      String? newExamDate,
      String? newStartTime,
      String? newEndTime}) async {
    try {
      await viewModel.updateAssignmentDetails(
        test.name,
        newName: newName,
        examDate: newExamDate,
        startTime: newStartTime,
        endTime: newEndTime,
      );
    } catch (e) {
      print('Error updating test details: $e');
    }
  }

  void _editTestQuestions(BuildContext context, TestsHomeViewModel viewModel,
      TestsAssignmentModel test) {
    _addOrUpdateTest(
      context,
      viewModel,
      initialQuestions: test.questions.map((q) => q.toMap()).toList(),
      testId: test.name,
      examDate: test.examDate,
      startTime: test.startTime,
      endTime: test.endTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => TestsHomeViewModel(courseId: courseId),
      child: Consumer<TestsHomeViewModel>(
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
              title: const Text('Tests',
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
                                Text('No Tests available',
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
                                final test = viewModel.assignments[index];
                                return TestsListItemAdmin(
                                  test: test,
                                  animation: const AlwaysStoppedAnimation(1.0),
                                  onDelete: () {
                                    viewModel.selectAssignment(index);
                                    _deleteTest(context, viewModel, index);
                                  },
                                  onTap: () {
                                    _showEditTestDialog(
                                      context,
                                      viewModel,
                                      test,
                                    );
                                  },
                                  onEditQuestions: () {
                                    _editTestQuestions(
                                      context,
                                      viewModel,
                                      test,
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
                _showAddTestDialog(context, viewModel);
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
