import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class UserTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;

  const UserTextField({super.key, 
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: TextField(
          cursorColor: AppColors.primaryColor,
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.primaryColor,
            ),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black),
            border: InputBorder.none,
            fillColor: Colors.black12,
          ),
          readOnly: !enabled,
        ),
      ),
    );
  }
}
