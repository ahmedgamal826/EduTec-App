import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class TestsTestsQuestionCard extends StatelessWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String role;

  const TestsTestsQuestionCard({
    super.key,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                'Q${index + 1}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.primaryColor,
                ),
              ),
            ),
            if (role == 'Admin' && onDelete != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
