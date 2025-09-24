import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/presentation/views/file_preview_view.dart';
import 'package:attendance_app/features/tests/presentation/viewmodels/add_tests_question_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/tests_question_model_admin.dart';
import 'package:path/path.dart' as path;

class AddTestsQuestionScreen extends StatelessWidget {
  final String questionType;
  final TestsQuestionModel? existingQuestion;
  final Function(TestsQuestionModel) onQuestionAdded;

  const AddTestsQuestionScreen({
    super.key,
    required this.questionType,
    this.existingQuestion,
    required this.onQuestionAdded,
  });

  void _saveQuestion(
      BuildContext context, TestsAddQuestionViewModel viewModel) {
    final question = viewModel.saveQuestion();
    if (question == null) {
      debugPrint('Save failed: Invalid question');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    debugPrint('Saving question: ${question.toMap()}');
    onQuestionAdded(question);
    Navigator.pop(context);
  }

  Widget _buildFileInfoCard(BuildContext context, String fileUrl,
      {bool isUploaded = true,
      String? fileType,
      String? fileSize,
      required TestsAddQuestionViewModel viewModel}) {
    String fileName;
    try {
      if (fileUrl.contains('firebasestorage.googleapis.com')) {
        try {
          // Para URLs con patrón de marca de tiempo
          RegExp timestampFilenameRegex = RegExp(r'\/(\d+_[^?]+)');
          var timestampMatches = timestampFilenameRegex.firstMatch(fileUrl);
          if (timestampMatches != null && timestampMatches.group(1) != null) {
            String extracted = timestampMatches.group(1)!;
            // Manejar la decodificación de manera segura
            try {
              fileName = Uri.decodeFull(extracted);
            } catch (e) {
              // Si falla la decodificación, usar el valor sin decodificar
              fileName = extracted;
              print('Error al decodificar nombre de archivo: $e');
            }
          } else {
            // Intentar extracción básica de nombre de archivo
            String basePath = fileUrl.split('?').first;
            fileName = path.basename(basePath);
          }
        } catch (e) {
          // En caso de error, usar un nombre genérico
          fileName = 'uploaded_file';
          print('Error extrayendo nombre del archivo desde URL: $e');
        }
      } else {
        try {
          fileName = path.basename(fileUrl);
        } catch (e) {
          fileName = 'file';
          print('Error extrayendo nombre de archivo local: $e');
        }
      }
    } catch (e) {
      fileName = 'file';
      print('Error general procesando nombre de archivo: $e');
    }

    final extension = path.extension(fileName).toLowerCase();
    final isImage =
        ['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(extension);

    IconData fileIcon = Icons.insert_drive_file;
    if (isImage) {
      fileIcon = Icons.image;
    } else if (extension == '.pdf') {
      fileIcon = Icons.picture_as_pdf;
    } else if (['.doc', '.docx'].contains(extension)) {
      fileIcon = Icons.description;
    } else if (['.xls', '.xlsx'].contains(extension)) {
      fileIcon = Icons.table_chart;
    } else if (['.ppt', '.pptx'].contains(extension)) {
      fileIcon = Icons.slideshow;
    } else if (['.txt', '.rtf'].contains(extension)) {
      fileIcon = Icons.text_snippet;
    }

    int? fileSizeBytes;
    if (fileSize != null) {
      try {
        fileSizeBytes = int.tryParse(fileSize);
      } catch (e) {
        debugPrint('Error parsing file size: $e');
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: AppColors.primaryColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {
          if (isUploaded) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilePreviewView(
                  fileUrl: fileUrl,
                  firebaseFileName: fileName,
                  fileSize: fileSizeBytes,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      fileIcon,
                      color: AppColors.primaryColor,
                      size: 32,
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                extension.toUpperCase().replaceFirst('.', ''),
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (fileType != null)
                              Text(
                                fileType,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            if (fileSizeBytes != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('•',
                                      style: TextStyle(color: Colors.grey)),
                                  const SizedBox(width: 8),
                                  Text(
                                    viewModel
                                        .getReadableFileSize(fileSizeBytes),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isUploaded)
                    const Icon(
                      Icons.visibility,
                      color: AppColors.primaryColor,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isUploaded ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUploaded
                        ? Colors.green.shade300
                        : Colors.amber.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUploaded ? Icons.check_circle : Icons.hourglass_top,
                      color: isUploaded ? Colors.green : Colors.amber[700],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUploaded
                          ? 'File is ready to be used'
                          : 'File selected (not uploaded yet)',
                      style: TextStyle(
                        color:
                            isUploaded ? Colors.green[800] : Colors.amber[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TestsAddQuestionViewModel(
          questionType: questionType, existingQuestion: existingQuestion),
      child: Consumer<TestsAddQuestionViewModel>(
        builder: (context, viewModel, child) {
          debugPrint('Building AddTestsQuestionScreen for $questionType');
          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                existingQuestion != null
                    ? 'Edit $questionType Tests Question'
                    : 'Add $questionType Tests Question',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryColor,
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          cursorColor: AppColors.primaryColor,
                          controller: viewModel.questionController,
                          decoration: const InputDecoration(
                            labelText: 'Enter your question',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primaryColor, width: 2)),
                          ),
                          maxLines: 3,
                          onChanged: (value) =>
                              debugPrint('Question text changed: $value'),
                        ),
                        const SizedBox(height: 20),
                        if (questionType == 'TrueFalse') ...[
                          const Text('Select the correct answer:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Card(
                            elevation: 8,
                            child: RadioListTile<String>(
                              title: const Text('True'),
                              value: 'True',
                              activeColor: AppColors.primaryColor,
                              groupValue: viewModel.correctAnswerTrueFalse,
                              onChanged: (value) {
                                debugPrint('Selected True');
                                viewModel.setCorrectAnswerTrueFalse(value);
                              },
                            ),
                          ),
                          Card(
                            elevation: 8,
                            child: RadioListTile<String>(
                              title: const Text('False'),
                              value: 'False',
                              activeColor: AppColors.primaryColor,
                              groupValue: viewModel.correctAnswerTrueFalse,
                              onChanged: (value) {
                                debugPrint('Selected False');
                                viewModel.setCorrectAnswerTrueFalse(value);
                              },
                            ),
                          ),
                        ] else if (questionType == 'MCQ') ...[
                          const Text(
                              'Enter the options and select the correct answer:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          ...viewModel.mcqOptionControllers
                              .asMap()
                              .entries
                              .map((entry) {
                            int idx = entry.key;
                            TextEditingController controller = entry.value;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      cursorColor: AppColors.primaryColor,
                                      controller: controller,
                                      decoration: InputDecoration(
                                        labelText: 'Option ${idx + 1}',
                                        labelStyle:
                                            const TextStyle(color: Colors.grey),
                                        border: const OutlineInputBorder(),
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey)),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.primaryColor,
                                                width: 2)),
                                      ),
                                      onChanged: (value) => debugPrint(
                                          'Option $idx changed: $value'),
                                    ),
                                  ),
                                  Radio<int>(
                                    value: idx,
                                    groupValue: viewModel.correctAnswerMcq,
                                    activeColor: AppColors.primaryColor,
                                    onChanged: (value) {
                                      debugPrint('Selected MCQ option $idx');
                                      viewModel.setCorrectAnswerMcq(value);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ] else if (questionType == 'Upload File') ...[
                          const Text('Reference File for Tests:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),

                          // Display uploaded file
                          if (viewModel.uploadedFileUrl != null) ...[
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: Colors.blue.shade100, width: 1),
                              ),
                              color: Colors.blue.shade50,
                              child: InkWell(
                                onTap: () {
                                  if (viewModel.uploadedFileUrl != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FilePreviewView(
                                          fileUrl: viewModel.uploadedFileUrl!,
                                          firebaseFileName:
                                              viewModel.selectedFileName,
                                          fileSize: viewModel.selectedFileSize,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 3,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: _getFileIcon(
                                                viewModel.selectedFileName ??
                                                    ''),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _getDisplayFileName(viewModel
                                                      .selectedFileName),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                if (viewModel
                                                        .selectedFileSize !=
                                                    null)
                                                  Text(
                                                    viewModel.getReadableFileSize(
                                                        viewModel
                                                            .selectedFileSize!),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.green.shade300),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.visibility,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Tap to view file',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Display selected file
                          if (viewModel.selectedFile != null &&
                              viewModel.uploadedFileUrl == null) ...[
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: Colors.orange.shade100, width: 1),
                              ),
                              color: Colors.orange.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: _getFileIcon(
                                          viewModel.selectedFileName ?? ''),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            viewModel.selectedFileName ??
                                                'Selected file',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          if (viewModel.selectedFileSize !=
                                              null)
                                            Text(
                                              viewModel.getReadableFileSize(
                                                  viewModel.selectedFileSize!),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Not uploaded yet',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.orange.shade800,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: !viewModel.isUploading
                                          ? () => viewModel.uploadFile()
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade500,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Upload'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Upload progress
                          if (viewModel.isUploading) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.upload_file,
                                        color: AppColors.primaryColor,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Uploading: ${(viewModel.uploadProgress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: viewModel.uploadProgress,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryColor),
                                    minHeight: 10,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ],

                          // Upload status
                          if (viewModel.uploadStatus.isNotEmpty &&
                              !viewModel.uploadStatus
                                  .contains('Selected file:') &&
                              !viewModel.isUploading &&
                              viewModel.uploadedFileUrl == null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: viewModel.uploadStatus.contains('Error')
                                    ? Colors.red.shade50
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        viewModel.uploadStatus.contains('Error')
                                            ? Colors.red.shade300
                                            : Colors.blue.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    viewModel.uploadStatus.contains('Error')
                                        ? Icons.error_outline
                                        : Icons.info_outline,
                                    color:
                                        viewModel.uploadStatus.contains('Error')
                                            ? Colors.red
                                            : Colors.blue,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      viewModel.uploadStatus,
                                      style: TextStyle(
                                        color: viewModel.uploadStatus
                                                .contains('Error')
                                            ? Colors.red.shade800
                                            : Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // File selection and upload buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => viewModel.pickFile(),
                                  icon: const Icon(Icons.attach_file),
                                  label: const Text('Select File'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: viewModel.selectedFile != null &&
                                          !viewModel.isUploading
                                      ? () => viewModel.uploadFile()
                                      : null,
                                  icon: const Icon(Icons.cloud_upload),
                                  label: const Text('Upload'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
                                    disabledForegroundColor:
                                        Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            debugPrint('Save Question pressed');
                            _saveQuestion(context, viewModel);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            existingQuestion != null
                                ? 'Update Tests Question'
                                : 'Save Tests Question',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (viewModel.isUploading && viewModel.uploadProgress == 0)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Preparing upload...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = path.extension(fileName.toLowerCase());
    IconData fileIcon = Icons.insert_drive_file;

    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension)) {
      fileIcon = Icons.image;
    } else if (extension == '.pdf') {
      fileIcon = Icons.picture_as_pdf;
    } else if (['.doc', '.docx'].contains(extension)) {
      fileIcon = Icons.description;
    } else if (['.xls', '.xlsx'].contains(extension)) {
      fileIcon = Icons.table_chart;
    } else if (['.ppt', '.pptx'].contains(extension)) {
      fileIcon = Icons.slideshow;
    } else if (['.zip', '.rar', '.7z'].contains(extension)) {
      fileIcon = Icons.folder_zip;
    } else if (['.txt', '.rtf'].contains(extension)) {
      fileIcon = Icons.text_snippet;
    }

    return Icon(
      fileIcon,
      color: AppColors.primaryColor,
      size: 28,
    );
  }

  String _extractDisplayName(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'Uploaded file';
    }

    try {
      // Si el nombre de archivo es una ruta completa que incluye test_files/
      if (filename.contains('test_files/') ||
          filename.contains('test_files%2F')) {
        // Extraer la última parte después de test_files/
        final RegExp regex = RegExp(r'test_files(?:%2F|\/)([^?&]+)');
        final match = regex.firstMatch(filename);
        if (match != null && match.groupCount >= 1) {
          final extractedName = match.group(1) ?? '';
          if (extractedName.isNotEmpty) {
            try {
              return Uri.decodeFull(extractedName);
            } catch (e) {
              print('Error decodificando nombre: $e');
              return extractedName;
            }
          }
        }

        // Intentar extraer el patrón de nombre de archivo con marca de tiempo
        final RegExp timestampRegex = RegExp(r'\/(\d+_[^?]+)');
        final timestampMatch = timestampRegex.firstMatch(filename);
        if (timestampMatch != null && timestampMatch.groupCount >= 1) {
          final extractedName = timestampMatch.group(1) ?? '';
          if (extractedName.isNotEmpty) {
            try {
              return Uri.decodeFull(extractedName);
            } catch (e) {
              print('Error decodificando nombre de timestamp: $e');
              return extractedName;
            }
          }
        }
      }

      // Si llegamos aquí, simplemente usa el nombre de archivo tal como está
      if (filename.contains('?')) {
        filename = filename.split('?').first;
      }

      // Obtener solo el nombre de archivo de la ruta
      try {
        final name = path.basename(filename);
        return name;
      } catch (e) {
        // En caso de error, simplemente devuelve la cadena original
        return filename;
      }
    } catch (e) {
      print('Error procesando nombre de archivo: $e');
      return 'file';
    }
  }

  String _getDisplayFileName(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'Uploaded file';
    }

    try {
      // Verificar si contiene test_files (nota: se usaba tests_files que puede ser incorrecto)
      if (filename.contains('test_files/') ||
          filename.contains('test_files%2F') ||
          filename.contains('tests_files/') ||
          filename.contains('tests_files%2F')) {
        // Probar primero con test_files
        final RegExp regex = RegExp(r'test_files(?:%2F|\/)([^?&]+)');
        final match = regex.firstMatch(filename);
        if (match != null && match.groupCount >= 1) {
          final extractedName = match.group(1) ?? '';
          if (extractedName.isNotEmpty) {
            try {
              return Uri.decodeFull(extractedName);
            } catch (e) {
              print('Error decodificando nombre: $e');
              return extractedName;
            }
          }
        }

        // Probar con tests_files (plural)
        final RegExp regexPlural = RegExp(r'tests_files(?:%2F|\/)([^?&]+)');
        final matchPlural = regexPlural.firstMatch(filename);
        if (matchPlural != null && matchPlural.groupCount >= 1) {
          final extractedName = matchPlural.group(1) ?? '';
          if (extractedName.isNotEmpty) {
            try {
              return Uri.decodeFull(extractedName);
            } catch (e) {
              print('Error decodificando nombre (plural): $e');
              return extractedName;
            }
          }
        }

        // Intentar extraer el patrón de nombre de archivo con marca de tiempo
        final RegExp timestampRegex = RegExp(r'\/(\d+_[^?]+)');
        final timestampMatch = timestampRegex.firstMatch(filename);
        if (timestampMatch != null && timestampMatch.groupCount >= 1) {
          final extractedName = timestampMatch.group(1) ?? '';
          if (extractedName.isNotEmpty) {
            try {
              return Uri.decodeFull(extractedName);
            } catch (e) {
              print('Error decodificando nombre de timestamp: $e');
              return extractedName;
            }
          }
        }
      }

      // Si llegamos aquí, simplemente usa el nombre de archivo tal como está
      if (filename.contains('?')) {
        filename = filename.split('?').first;
      }

      // Obtener solo el nombre de archivo de la ruta
      try {
        final name = path.basename(filename);
        return name;
      } catch (e) {
        print('Error obteniendo basename: $e');
        return filename;
      }
    } catch (e) {
      print('Error procesando nombre de archivo: $e');
      return 'file';
    }
  }
}
