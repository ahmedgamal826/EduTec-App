import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/models/question_model_admin.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class AddQuestionViewModel extends ChangeNotifier {
  final TextEditingController questionController = TextEditingController();
  String? correctAnswerTrueFalse;
  int? correctAnswerMcq;
  List<TextEditingController> mcqOptionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // File upload properties
  File? _selectedFile;
  String? _selectedFileName;
  String? _selectedFileType;
  int? _selectedFileSize;
  String? _uploadedFileUrl;
  bool _isUploading = false;
  String _uploadStatus = '';
  double _uploadProgress = 0.0;

  // Getters
  File? get selectedFile => _selectedFile;
  String? get selectedFileName => _selectedFileName;
  String? get selectedFileType => _selectedFileType;
  int? get selectedFileSize => _selectedFileSize;
  String? get uploadedFileUrl => _uploadedFileUrl;
  bool get isUploading => _isUploading;
  String get uploadStatus => _uploadStatus;
  double get uploadProgress => _uploadProgress;

  final String questionType;
  QuestionModel? existingQuestion;

  AddQuestionViewModel({
    required this.questionType,
    this.existingQuestion,
  }) {
    if (existingQuestion != null) {
      questionController.text = existingQuestion!.question;

      if (questionType == 'TrueFalse') {
        correctAnswerTrueFalse = existingQuestion!.correct;
      } else if (questionType == 'MCQ') {
        final existingOptions = existingQuestion!.options;
        final correct = existingQuestion!.correct;

        for (int i = 0;
            i < existingOptions.length && i < mcqOptionControllers.length;
            i++) {
          mcqOptionControllers[i].text = existingOptions[i];
        }

        if (correct != null) {
          correctAnswerMcq = existingOptions.indexOf(correct);
          if (correctAnswerMcq == -1) correctAnswerMcq = 0;
        }
      } else if (questionType == 'Upload File') {
        _uploadedFileUrl = existingQuestion!.fileUrl;
        _selectedFileName = existingQuestion!.fileName;
        _selectedFileSize = existingQuestion!.fileSize;
        _selectedFileType = existingQuestion!.fileType;
      }
    }
  }

  void setCorrectAnswerTrueFalse(String? value) {
    correctAnswerTrueFalse = value;
    notifyListeners();
  }

  void setCorrectAnswerMcq(int? value) {
    correctAnswerMcq = value;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'txt',
          'xls',
          'xlsx',
          'ppt',
          'pptx'
        ],
      );

      if (result != null) {
        // Manejar la ruta del archivo correctamente para evitar problemas de codificación
        String filePath = result.files.single.path!;
        
        // Convertir ruta a formato compatible con URI
        if (Platform.isWindows) {
          // En Windows, reemplazar barras invertidas con barras normales
          filePath = filePath.replaceAll('\\', '/');
        }
        
        _selectedFile = File(filePath);
        _selectedFileName = path.basename(filePath);
        _selectedFileSize = await _selectedFile!.length();
        _selectedFileType =
            lookupMimeType(filePath) ?? 'application/octet-stream';

        _uploadStatus = 'File selected successfully';
        notifyListeners();
      }
    } catch (e) {
      _uploadStatus = 'Error picking file: $e';
      notifyListeners();
    }
  }

  Future<void> uploadFile() async {
    if (_selectedFile == null) {
      _uploadStatus = 'Please select a file first';
      notifyListeners();
      return;
    }

    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Uploading...';
      notifyListeners();

      // Sanitizar el nombre del archivo para evitar problemas de codificación
      String originalFileName = path.basename(_selectedFile!.path);
      
      // Reemplazar caracteres problemáticos en el nombre del archivo
      String sanitizedFileName = originalFileName
          .replaceAll('%', '_percent_')
          .replaceAll('&', '_and_')
          .replaceAll('+', '_plus_')
          .replaceAll(' ', '_')
          .replaceAll('#', '_hash_');
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';
      final destination = 'assignment_files/$fileName';

      final ref = FirebaseStorage.instance.ref(destination);
      final uploadTask = ref.putFile(
        _selectedFile!,
        SettableMetadata(
          contentType: _selectedFileType,
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      });

      final snapshot = await uploadTask.whenComplete(() {});
      _uploadedFileUrl = await snapshot.ref.getDownloadURL();

      _uploadStatus = 'File uploaded successfully';
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
    } catch (e) {
      _uploadStatus = 'Error uploading file: $e';
      _isUploading = false;
      notifyListeners();
      print('Error detallado al subir archivo: $e');
    }
  }

  String getReadableFileSize(int? bytes) {
    if (bytes == null) return "Unknown size";

    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    int i = 0;
    double len = bytes.toDouble();
    while (len >= 1024 && i < sizes.length - 1) {
      len /= 1024;
      i++;
    }
    return '${len.toStringAsFixed(1)} ${sizes[i]}';
  }

  String getFileTypeDisplay(String? mimeType) {
    if (mimeType == null) return "Unknown type";

    if (mimeType.startsWith('image/')) {
      return 'Image';
    } else if (mimeType == 'application/pdf') {
      return 'PDF Document';
    } else if (mimeType.contains('word') || mimeType.contains('document')) {
      return 'Word Document';
    } else if (mimeType.contains('excel') || mimeType.contains('sheet')) {
      return 'Excel Spreadsheet';
    } else if (mimeType.contains('powerpoint') ||
        mimeType.contains('presentation')) {
      return 'PowerPoint Presentation';
    } else if (mimeType.contains('text/')) {
      return 'Text File';
    }

    return 'Document';
  }

  // QuestionModel? saveQuestion() {
  //   final questionText = questionController.text.trim();
  //   if (questionText.isEmpty) return null;

  //   if (questionType == 'TrueFalse') {
  //     if (correctAnswerTrueFalse == null) return null;

  //     return QuestionModel(
  //       type: 'TrueFalse',
  //       question: questionText,
  //       options: ['True', 'False'],
  //       correct: correctAnswerTrueFalse,
  //     );
  //   } else if (questionType == 'MCQ') {
  //     final options = mcqOptionControllers
  //         .map((controller) => controller.text.trim())
  //         .where((text) => text.isNotEmpty)
  //         .toList();

  //     if (options.length < 2 || correctAnswerMcq == null) return null;

  //     return QuestionModel(
  //       type: 'MCQ',
  //       question: questionText,
  //       options: options,
  //       correct: options[correctAnswerMcq!],
  //     );
  //   } else if (questionType == 'Upload File') {
  //     if (_uploadedFileUrl == null) return null; // Ensure file is uploaded

  //     // Extract clean filename from either selected filename or URL
  //     String cleanFileName = _selectedFileName ?? '';

  //     // If we don't have a filename or it starts with http (meaning it's a URL), try to extract from the URL
  //     if (cleanFileName.isEmpty || cleanFileName.startsWith('http')) {
  //       if (_uploadedFileUrl != null) {
  //         final String url = _uploadedFileUrl!;

  //         // Try to get filename using timestamp pattern (common in Firebase Storage)
  //         RegExp timestampFilenameRegex = RegExp(r'\/(\d+_[^?]+)');
  //         var timestampMatches = timestampFilenameRegex.firstMatch(url);
  //         if (timestampMatches != null && timestampMatches.group(1) != null) {
  //           cleanFileName = Uri.decodeFull(timestampMatches.group(1)!);
  //         } else {
  //           // Try to get filename from the URL
  //           if (!url.contains('?')) {
  //             cleanFileName = path.basename(url);
  //           } else {
  //             // For URLs with query parameters, extract the path part
  //             final parts = url.split('?').first.split('/');
  //             if (parts.isNotEmpty) {
  //               final lastPart = parts.last;
  //               if (lastPart.isNotEmpty && lastPart.contains('.')) {
  //                 cleanFileName = Uri.decodeFull(lastPart);
  //               }
  //             }
  //           }
  //         }
  //       }

  //       // If still no filename, use a default
  //       if (cleanFileName.isEmpty) {
  //         cleanFileName = 'uploaded_file';

  //         // Try to detect extension from URL
  //         if (_uploadedFileUrl != null) {
  //           final url = _uploadedFileUrl!.toLowerCase();
  //           if (url.contains('.pdf')) {
  //             cleanFileName += '.pdf';
  //           } else if (url.contains('.doc')) {
  //             cleanFileName += '.doc';
  //           } else if (url.contains('.jpg') || url.contains('.jpeg')) {
  //             cleanFileName += '.jpg';
  //           } else if (url.contains('.png')) {
  //             cleanFileName += '.png';
  //           }
  //         }
  //       }
  //     }

  //     return QuestionModel(
  //       type: 'Upload File',
  //       question: questionText,
  //       fileUrl: _uploadedFileUrl,
  //       fileName: cleanFileName,
  //       fileType: _selectedFileType,
  //       fileSize: _selectedFileSize,
  //       options: [cleanFileName], // Using the clean filename for options too
  //     );
  //   }
  //   return null;
  // }

  QuestionModel? saveQuestion() {
    final questionText = questionController.text.trim();
    if (questionText.isEmpty) return null;

    if (questionType == 'TrueFalse') {
      if (correctAnswerTrueFalse == null) return null;
      return QuestionModel(
        type: 'TrueFalse',
        question: questionText,
        options: ['True', 'False'],
        correct: correctAnswerTrueFalse,
      );
    } else if (questionType == 'MCQ') {
      final options = mcqOptionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (options.length < 2 || correctAnswerMcq == null) return null;

      String correctValue = options[correctAnswerMcq!]; // Use the text directly
      return QuestionModel(
        type: 'MCQ',
        question: questionText,
        options: options,
        correct: correctValue, // Save the correct text, not index
      );
    } else if (questionType == 'Upload File') {
      if (_uploadedFileUrl == null) return null;

      String cleanFileName = _selectedFileName ?? '';
      if (cleanFileName.isEmpty || cleanFileName.startsWith('http')) {
        if (_uploadedFileUrl != null) {
          final url = _uploadedFileUrl!;
          try {
            RegExp timestampFilenameRegex = RegExp(r'\/(\d+_[^?]+)');
            var timestampMatches = timestampFilenameRegex.firstMatch(url);
            if (timestampMatches != null && timestampMatches.group(1) != null) {
              String extracted = timestampMatches.group(1)!;
              try {
                cleanFileName = Uri.decodeFull(extracted);
              } catch (e) {
                cleanFileName = extracted;
              }
            } else {
              String basePath = url.split('?').first;
              cleanFileName = path.basename(basePath);
            }
          } catch (e) {
            print('Error extracting filename from URL: $e');
            cleanFileName = 'uploaded_file';
          }
        }
        if (cleanFileName.isEmpty) cleanFileName = 'uploaded_file';
      }

      // Sanitizar el nombre del archivo para evitar problemas
      cleanFileName = cleanFileName
          .replaceAll('%', '_percent_')
          .replaceAll('&', '_and_')
          .replaceAll('+', '_plus_')
          .replaceAll('#', '_hash_');

      return QuestionModel(
        type: 'Upload File',
        question: questionText,
        fileUrl: _uploadedFileUrl,
        fileName: cleanFileName,
        fileType: _selectedFileType,
        fileSize: _selectedFileSize,
        options: [cleanFileName],
      );
    }
    return null;
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in mcqOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
