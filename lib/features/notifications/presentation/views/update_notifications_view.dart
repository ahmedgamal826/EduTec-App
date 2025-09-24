import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/notifications/presentation/views/widgets/date_picker_text_field.dart';
import 'package:attendance_app/features/notifications/presentation/views/widgets/description_text_field.dart';
import 'package:attendance_app/features/notifications/presentation/views/widgets/save_button.dart';
import 'package:attendance_app/features/notifications/presentation/views/widgets/subject_dropdown.dart';
import 'package:flutter/material.dart';

class UpdateNotificationsView extends StatefulWidget {
  final Map<String, String> notification;
  final int index;

  const UpdateNotificationsView({super.key, 
    required this.notification,
    required this.index,
  });

  @override
  _UpdateNotificationsViewState createState() =>
      _UpdateNotificationsViewState();
}

class _UpdateNotificationsViewState extends State<UpdateNotificationsView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? selectedSubject;
  DateTime? selectedDate;

  final List<String> subjects = ["Math", "Physics", "History", "Chemistry"];

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.notification["subject"];
    _descriptionController.text = widget.notification["description"]!;
    _dateController.text = widget.notification["date"]!;
  }

  void _updateNotification() {
    if (_formKey.currentState!.validate()) {
      if (selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a subject"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      Navigator.pop(context, {
        "subject": selectedSubject!,
        "description": _descriptionController.text,
        "date": _dateController.text,
        "index": widget.index,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Update Notification",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SubjectDropdown(
                  selectedSubject: selectedSubject,
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  },
                  subjects: subjects,
                ),
                const SizedBox(height: 10),
                DescriptionTextField(controller: _descriptionController),
                const SizedBox(height: 10),
                DatePickerTextField(
                  controller: _dateController,
                  onDateSelected: (selectedDate) {
                    setState(() {
                      this.selectedDate = DateTime.parse(selectedDate);
                    });
                  },
                ),
                const SizedBox(height: 30),
                SaveButton(onPressed: _updateNotification),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
