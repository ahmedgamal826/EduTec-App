// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:attendance_app/core/utils/app_colors.dart';

// class DatePickerTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final Function(String) onDateSelected;

//   const DatePickerTextField({
//     Key? key,
//     required this.controller,
//     required this.onDateSelected,
//   }) : super(key: key);

//   @override
//   _DatePickerTextFieldState createState() => _DatePickerTextFieldState();
// }

// class _DatePickerTextFieldState extends State<DatePickerTextField> {
//   Future<void> _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2023),
//       lastDate: DateTime(2030),
//     );

//     if (picked != null) {
//       String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
//       setState(() {
//         widget.controller.text = formattedDate;
//       });
//       widget.onDateSelected(formattedDate);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: widget.controller,
//       readOnly: true,
//       onTap: () => _selectDate(context),
//       decoration: InputDecoration(
//         labelText: 'Select Date',
//         labelStyle: const TextStyle(color: Colors.black),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.grey, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//         suffixIcon: const Icon(Icons.calendar_today),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:attendance_app/core/utils/app_colors.dart';

class DatePickerTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onDateSelected;

  const DatePickerTextField({
    super.key,
    required this.controller,
    required this.onDateSelected,
  });

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.text = formattedDate;
      onDateSelected(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: 'Select Date',
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Date is required";
        }
        return null;
      },
    );
  }
}
