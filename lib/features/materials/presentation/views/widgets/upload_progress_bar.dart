import 'package:flutter/material.dart';

class UploadProgressBar extends StatelessWidget {
  final bool isUploading;
  final double uploadProgress;

  const UploadProgressBar({
    super.key,
    required this.isUploading,
    required this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isUploading)
            LinearProgressIndicator(
              value: uploadProgress / 100,
              color: const Color(0xFF1565C0),
              backgroundColor: Colors.grey[200],
            ),
          Center(
            child: Text(
              isUploading
                  ? 'Uploading... ${uploadProgress.toStringAsFixed(0)}%'
                  : 'Upload Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isUploading ? const Color(0xFF1565C0) : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
