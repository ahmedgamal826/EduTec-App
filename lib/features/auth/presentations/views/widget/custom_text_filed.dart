import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextFiled extends StatefulWidget {
  const CustomTextFiled({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validatorMessage,
  });

  final String hintText;
  final TextEditingController controller;
  final String validatorMessage;

  @override
  State<CustomTextFiled> createState() => _CustomTextFiledState();
}

class _CustomTextFiledState extends State<CustomTextFiled> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    bool isPasswordField = (widget.hintText == 'Enter your Password' ||
        widget.hintText == 'Enter Confirm Password');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: TextFormField(
          cursorColor: AppColors.primaryColor,
          controller: widget.controller,
          validator: (value) {
            if (value!.isEmpty) {
              return widget.validatorMessage;
            }
            return null;
          },
          obscureText: isPasswordField ? obscureText : false,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[400]!, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: isPasswordField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.primaryColor,
                    ),
                  )
                : null,
            prefixIcon: widget.hintText == 'Enter your Email'
                ? Icon(
                    Icons.mail,
                    color: AppColors.primaryColor,
                  )
                : widget.hintText == 'Enter your Name'
                    ? Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      )
                    : Icon(
                        Icons.lock,
                        color: AppColors.primaryColor,
                      ),
          ),
        ),
      ),
    );
  }
}
