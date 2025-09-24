import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuestionnaireCard extends StatelessWidget {
  final int index;
  final double screenHeight;
  final double screenWidth;
  final String date;
  final String doctor;
  final List<Map<String, dynamic>> questions;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const QuestionnaireCard({
    super.key,
    required this.index,
    required this.screenHeight,
    required this.screenWidth,
    required this.date,
    required this.doctor,
    required this.questions,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    late String formattedDate;
    try {
      formattedDate = DateFormat('dd-MM-yyyy h:mm a')
          .format(DateFormat('dd-MM-yyyy HH:mm').parseStrict(date));
    } catch (e) {
      formattedDate = 'Invalid date';
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: screenWidth * 0.02,
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primaryColor.withOpacity(0.2),
        highlightColor: AppColors.primaryColor.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.04,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questionnaire ${index + 1}',
                      style: TextStyle(
                        fontSize: screenHeight * 0.028,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Text(
                      'Date: $formattedDate',
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      'By: Dr/ $doctor',
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
    );
  }
}
