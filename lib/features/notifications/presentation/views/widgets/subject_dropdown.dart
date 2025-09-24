import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class SubjectDropdown extends StatefulWidget {
  final List<String> subjects;
  final String? selectedSubject;
  final Function(String?) onChanged;

  const SubjectDropdown({
    super.key,
    required this.subjects,
    this.selectedSubject,
    required this.onChanged,
  });

  @override
  _SubjectDropdownState createState() => _SubjectDropdownState();
}

class _SubjectDropdownState extends State<SubjectDropdown> {
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.selectedSubject;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSubject,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Subject is required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Select Subject',
          labelStyle: const TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
        ),
        isDense: true,
        items: widget.subjects
            .map((subject) => DropdownMenuItem(
                  value: subject,
                  child: SizedBox(
                    width: 100,
                    child: Text(subject, textAlign: TextAlign.center),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedSubject = value;
          });
          widget.onChanged(value);
        },
        menuMaxHeight: 200, // تحديد أقصى ارتفاع للقائمة المنسدلة
      ),
    );
  }
}
