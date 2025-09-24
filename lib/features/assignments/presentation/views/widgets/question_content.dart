import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/data/models/question_model_admin.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../file_preview_view.dart';

class QuestionContent extends StatelessWidget {
  final QuestionModel? question;

  const QuestionContent({super.key, this.question});

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return const Center(
        child:
            Text('No question selected', style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Question:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              question!.question,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Type: ${question!.type}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (question!.type == 'TrueFalse' || question!.type == 'MCQ') ...[
            const Text(
              'Options:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            ...question!.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isCorrect = option == question!.correct;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? Colors.green : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D...
                          style: TextStyle(
                            color: isCorrect ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              );
            }),
          ] else if (question!.type == 'Upload File') ...[
            _buildFileDisplay(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFileDisplay(BuildContext context) {
    // If we have a fileUrl, we can display file info
    if (question!.fileUrl != null) {
      final String fileUrl = question!.fileUrl!;
      final String fileName = _getDisplayFileName(question!.fileName, fileUrl);
      final String extension = _getFileExtension(fileName, fileUrl);
      final int? fileSize = question!.fileSize;

      // Determine file type icon
      IconData fileIcon = _getFileIcon(extension);

      return Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue.shade100, width: 1),
        ),
        color: Colors.blue.shade50,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilePreviewView(
                  fileUrl: fileUrl,
                  firebaseFileName: question!.fileName,
                  fileSize: fileSize,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Using Wrap instead of Row to prevent overflow
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        fileIcon,
                        color: AppColors.primaryColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (question!.fileSize != null)
                            Text(
                              _getReadableFileSize(question!.fileSize!),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilePreviewView(
                            fileUrl: fileUrl,
                            firebaseFileName: question!.fileName,
                            fileSize: fileSize,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Fallback if no file information is available
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: Colors.blue.shade700, size: 24),
            const SizedBox(width: 12),
            Text(
              'File Upload Question',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  // Helper methods for file display
  String _getDisplayFileName(String? fileName, String? fileUrl) {
    if (fileName != null &&
        fileName.isNotEmpty &&
        !fileName.startsWith('http')) {
      return fileName;
    }

    if (fileUrl == null || fileUrl.isEmpty) {
      return 'Uploaded file';
    }

    // Try to extract filename from URL
    String url = fileUrl;

    // For Firebase Storage URLs with timestamp in filename pattern
    RegExp timestampFilenameRegex = RegExp(r'\/(\d+_[^?]+)');
    var timestampMatches = timestampFilenameRegex.firstMatch(url);
    if (timestampMatches != null && timestampMatches.group(1) != null) {
      String possibleFilename = timestampMatches.group(1)!;
      if (possibleFilename.contains('.')) {
        return Uri.decodeFull(possibleFilename);
      }
    }

    // First check for simple paths
    if (!url.contains('?')) {
      return path.basename(url);
    }

    // Try to extract from Firebase URL
    final parts = url.split('?').first.split('/');
    if (parts.isNotEmpty) {
      final lastPart = parts.last;
      if (lastPart.isNotEmpty && lastPart.contains('.')) {
        return Uri.decodeFull(lastPart);
      }
    }

    // Try to match a filename pattern in the URL
    if (url.contains('alt=media')) {
      RegExp filenameRegex = RegExp(r'([^\/]+)(_[^_?]+\.\w+)');
      var matches = filenameRegex.firstMatch(url);
      if (matches != null && matches.groupCount >= 2) {
        String possibleFilename = matches.group(1)! + (matches.group(2) ?? '');
        if (possibleFilename.contains('.')) {
          return possibleFilename;
        }
      }
    }

    // Fallback to generic name
    return 'Uploaded file';
  }

  String _getFileExtension(String fileName, String fileUrl) {
    // First try to get extension from filename
    String ext = path.extension(fileName.toLowerCase());
    if (ext.isNotEmpty) {
      return ext;
    }

    // Try to extract from URL
    if (fileUrl.toLowerCase().contains('.pdf')) {
      return '.pdf';
    } else if (fileUrl.toLowerCase().contains('.jpg') ||
        fileUrl.toLowerCase().contains('.jpeg')) {
      return '.jpg';
    } else if (fileUrl.toLowerCase().contains('.png')) {
      return '.png';
    } else if (fileUrl.toLowerCase().contains('.doc') ||
        fileUrl.toLowerCase().contains('.docx')) {
      return '.docx';
    }

    return '';
  }

  IconData _getFileIcon(String extension) {
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension)) {
      return Icons.image;
    } else if (extension == '.pdf') {
      return Icons.picture_as_pdf;
    } else if (['.doc', '.docx'].contains(extension)) {
      return Icons.description;
    } else if (['.xls', '.xlsx'].contains(extension)) {
      return Icons.table_chart;
    } else if (['.ppt', '.pptx'].contains(extension)) {
      return Icons.slideshow;
    } else if (['.txt', '.rtf'].contains(extension)) {
      return Icons.text_snippet;
    } else if (['.zip', '.rar', '.7z'].contains(extension)) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }

  String _getReadableFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return i == 0
        ? '$bytes ${suffixes[i]}'
        : '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
