import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;

  const AnimatedButton({super.key, 
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 50,
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.blueAccent.withOpacity(0.6)
                : Colors.blue.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
