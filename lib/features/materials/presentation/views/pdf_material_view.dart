import 'dart:io';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfMaterialViewer extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const PdfMaterialViewer({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  _PdfMaterialViewerState createState() => _PdfMaterialViewerState();
}

class _PdfMaterialViewerState extends State<PdfMaterialViewer> {
  String? localFilePath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadAndSaveFile();
  }

  Future<void> _downloadAndSaveFile() async {
    try {
      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to download file: HTTP ${response.statusCode}';
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${widget.fileName}';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (await file.exists()) {
        setState(() {
          localFilePath = filePath;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to save file to device.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error downloading file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ))
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : localFilePath != null
                  ? PDFView(
                      filePath: localFilePath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error loading PDF: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('Failed to load PDF')),
    );
  }
}
