import 'package:flutter/material.dart';

class FilePickerCard extends StatelessWidget {
  final String? fileName;
  final String fileSizeText;
  final VoidCallback onTap;
  final IconData Function(String fileName) getFileIcon;

  const FilePickerCard({
    super.key,
    required this.fileName,
    required this.fileSizeText,
    required this.onTap,
    required this.getFileIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: fileName != null ? const Color(0xFF1565C0) : Colors.grey,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                fileName != null
                    ? getFileIcon(fileName!)
                    : Icons.add_circle_outline,
                size: 50,
                color: fileName != null ? const Color(0xFF1565C0) : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                fileName ?? 'Tap to Select a File',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: fileName != null ? Colors.black : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (fileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    fileSizeText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
