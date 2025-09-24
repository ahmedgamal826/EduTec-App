import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final int index;
  final bool isSelected;
  final bool isAnswered;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String role;

  const QuestionCard({super.key, 
    required this.index,
    required this.isSelected,
    this.isAnswered = false,
    required this.onTap,
    required this.onDelete,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد لون الكارت بناءً على حالته
    Color cardColor;
    if (isSelected) {
      cardColor = AppColors.primaryColor;
    } else if (isAnswered) {
      cardColor =
          Colors.green.shade100; // خلفية خضراء فاتحة للأسئلة المجاب عليها
    } else {
      cardColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              elevation: 5,
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: 100,
                alignment: Alignment.center,
                child: Text(
                  'Question ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // عرض أيقونة الحذف فقط إذا كان الدور هو 'Admin'
          if (role == 'Admin')
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                ),
              ),
            ),
          // إضافة علامة صح صغيرة للأسئلة المجاب عليها
          if (isAnswered && !isSelected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}
