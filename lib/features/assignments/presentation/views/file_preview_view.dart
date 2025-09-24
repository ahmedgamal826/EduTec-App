import 'package:flutter/material.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePreviewView extends StatefulWidget {
  final String fileUrl;
  final String? firebaseFileName;
  final int? fileSize;

  const FilePreviewView({
    super.key,
    required this.fileUrl,
    this.firebaseFileName,
    this.fileSize,
  });

  @override
  State<FilePreviewView> createState() => _FilePreviewViewState();
}

class _FilePreviewViewState extends State<FilePreviewView> {
  bool _isLoading = true;
  String? _localFilePath;
  String? _errorMessage;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isPdf = false;
  String _fileName = '';
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  PDFViewController? _pdfViewController;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _extractFileName();
    _checkPermissionsAndPrepareFile();
    _initializeNotifications();
  }

  // Check for storage permissions before preparing file
  Future<void> _checkPermissionsAndPrepareFile() async {
    // Request storage permissions
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    // Also request external storage permission on Android
    var externalStatus = await Permission.manageExternalStorage.status;
    if (!externalStatus.isGranted) {
      externalStatus = await Permission.manageExternalStorage.request();
    }
    
    if (status.isGranted || externalStatus.isGranted) {
      _prepareFile();
    } else {
      setState(() {
        _errorMessage = 'Storage permission denied. Cannot access files.';
        _isLoading = false;
      });
    }
  }

  void _extractFileName() {
    if (widget.firebaseFileName != null &&
        widget.firebaseFileName!.isNotEmpty) {
      _fileName = widget.firebaseFileName!;
      print('Using Firebase filename: $_fileName');
      return;
    }

    try {
      String url = widget.fileUrl;
      
      // Para URLs con patrón de marca de tiempo
      RegExp timestampFilenameRegex = RegExp(r'\/(\d+_[^?]+)');
      var timestampMatches = timestampFilenameRegex.firstMatch(url);
      if (timestampMatches != null && timestampMatches.group(1) != null) {
        String possibleFilename = timestampMatches.group(1)!;
        if (possibleFilename.contains('.')) {
          try {
            _fileName = Uri.decodeFull(possibleFilename);
          } catch (e) {
            _fileName = possibleFilename;
            print('Error decoding filename: $e');
          }
          print('Extracted filename from timestamp pattern: $_fileName');
          return;
        }
      }

      // Intentar encontrar el nombre en la ruta de assignment_files
      if (url.contains('assignment_files')) {
        RegExp assignmentFilesRegex =
            RegExp(r'assignment_files(?:%2F|\/)([^?&]+)');
        var assignmentMatches = assignmentFilesRegex.firstMatch(url);
        if (assignmentMatches != null && assignmentMatches.group(1) != null) {
          String possibleFilename = assignmentMatches.group(1)!;
          if (possibleFilename.contains('.')) {
            try {
              _fileName = Uri.decodeFull(possibleFilename);
            } catch (e) {
              _fileName = possibleFilename;
              print('Error decoding filename: $e');
            }
            print('Extracted filename from assignment_files: $_fileName');
            return;
          }
        }
      }

      // Intentar extraer de las partes de la URL
      final parts = url.split('?').first.split('/');
      if (parts.isNotEmpty) {
        String lastPart = parts.last;
        if (lastPart.contains('%')) {
          try {
            lastPart = Uri.decodeFull(lastPart);
          } catch (e) {
            print('Error decoding URL part: $e');
          }
        }
        if (lastPart.isNotEmpty && lastPart.contains('.')) {
          _fileName = lastPart;
          print('Extracted filename from URL path: $_fileName');
          return;
        }
      }

      // Intentar extraer de parámetros alt=media
      if (url.contains('alt=media')) {
        RegExp filenameRegex = RegExp(r'([^\/]+)(_[^_?]+\.\w+)');
        var matches = filenameRegex.firstMatch(url);
        if (matches != null && matches.groupCount >= 2) {
          String possibleFilename = matches.group(1)! + (matches.group(2) ?? '');
          if (possibleFilename.contains('.')) {
            _fileName = possibleFilename;
            print('Extracted filename from alt=media: $_fileName');
            return;
          }
        }
      }

      // Último recurso: extraer el nombre del archivo de la URL
      try {
        String basePath = url.split('?').first;
        _fileName = path.basename(basePath);
      } catch (e) {
        print('Error extracting filename from path: $e');
        _fileName = 'file';
      }

      // Si todavía no tenemos un nombre de archivo válido con extensión
      if (!_fileName.contains('.')) {
        if (url.toLowerCase().contains('.pdf')) {
          _fileName = 'document.pdf';
        } else if (url.toLowerCase().contains('.jpg') ||
            url.toLowerCase().contains('.jpeg')) {
          _fileName = 'image.jpg';
        } else if (url.toLowerCase().contains('.png')) {
          _fileName = 'image.png';
        } else if (url.toLowerCase().contains('.docx')) {
          _fileName = 'document.docx';
        } else {
          _fileName = 'file';
        }
      }
    } catch (e) {
      print('Error general extracting filename: $e');
      _fileName = 'file';
    }
    
    print('Final filename: $_fileName from URL: ${widget.fileUrl}');
  }

  String _generateConsistentFilename(String url) {
    var bytes = utf8.encode(url);
    var digest = sha256.convert(bytes);
    String hash = digest.toString().substring(0, 10);
    if (_fileName.contains('.')) {
      String ext = path.extension(_fileName);
      return 'file_$hash$ext';
    } else {
      if (url.toLowerCase().contains('.pdf')) {
        return 'file_$hash.pdf';
      } else if (url.toLowerCase().contains('.jpg') ||
          url.toLowerCase().contains('.jpeg')) {
        return 'file_$hash.jpg';
      } else if (url.toLowerCase().contains('.png')) {
        return 'file_$hash.png';
      } else {
        return 'file_$hash.dat';
      }
    }
  }

  Future<void> _prepareFile() async {
    final extension = path.extension(_fileName.toLowerCase());

    setState(() {
      _isLoading = true;
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
      _isPdf = extension == '.pdf';
    });

    try {
      if (widget.fileUrl.startsWith('file://') ||
          widget.fileUrl.startsWith('/')) {
        final file = File(widget.fileUrl.replaceFirst('file://', ''));
        if (await file.exists()) {
          setState(() {
            _localFilePath = file.path;
            _isLoading = false;
            _isDownloading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Local file not found';
            _isLoading = false;
            _isDownloading = false;
          });
        }
        return;
      }

      String safeFilename = _generateConsistentFilename(widget.fileUrl);
      
      // Try to use app's cache directory first (doesn't require special permissions)
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$safeFilename';
      final file = File(filePath);

      if (await file.exists()) {
        print('File already cached, using: $filePath');
        setState(() {
          _localFilePath = filePath;
          _isLoading = false;
          _isDownloading = false;
          _downloadProgress = 1.0;
        });
        return;
      }

      // Sanitize the URL before making HTTP request
      String sanitizedUrl = widget.fileUrl;
      http.StreamedResponse streamedResponse;
      
      // If URL contains potentially problematic characters, try to clean it
      if (widget.fileUrl.contains('%') && !widget.fileUrl.contains('%20') && !widget.fileUrl.contains('%2F')) {
        sanitizedUrl = widget.fileUrl.replaceAll('%', '%25');
      }
      
      try {
        final request = http.Request('GET', Uri.parse(sanitizedUrl));
        streamedResponse = await http.Client().send(request);
      } catch (e) {
        print('Error with sanitized URL, trying original: $e');
        final request = http.Request('GET', Uri.parse(widget.fileUrl));
        streamedResponse = await http.Client().send(request);
      }

      if (streamedResponse.statusCode == 200) {
        final contentLength = streamedResponse.contentLength ?? 0;
        int bytesReceived = 0;
        List<int> bytes = [];

        await for (var chunk in streamedResponse.stream) {
          bytes.addAll(chunk);
          bytesReceived += chunk.length;
          if (contentLength > 0 && mounted) {
            setState(() {
              _downloadProgress = bytesReceived / contentLength;
            });
            final progress = (bytesReceived / contentLength * 100).toInt();
            await _showProgressNotification(progress);
          }
        }

        await file.writeAsBytes(bytes);

        if (mounted) {
          setState(() {
            _localFilePath = filePath;
            _isLoading = false;
            _isDownloading = false;
            _downloadProgress = 1.0;
          });
          await _showDownloadCompleteNotification(filePath);
        }
      } else {
        print('HTTP Error: ${streamedResponse.statusCode}');
        if (mounted) {
          setState(() {
            _errorMessage =
                'Failed to download file (Status: ${streamedResponse.statusCode})';
            _isLoading = false;
            _isDownloading = false;
          });
        }
      }
    } catch (e) {
      print('Error preparing file: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading file: $e';
          _isLoading = false;
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showProgressNotification(int progress) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Shows download progress',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      onlyAlertOnce: true,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Downloading File',
      'Progress: $progress%',
      platformChannelSpecifics,
      payload: 'download',
    );
  }

  Future<void> _showDownloadCompleteNotification(String filePath) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Shows download progress',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Download Complete',
      'File saved to Downloads folder',
      platformChannelSpecifics,
      payload: 'download_complete',
    );
  }

  String _getFormattedFileSize() {
    if (widget.fileSize != null) {
      return _formatFileSize(widget.fileSize!);
    }
    return '';
  }

  String _formatFileSize(int bytes) {
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

  @override
  Widget build(BuildContext context) {
    final extension = path.extension(_fileName.toLowerCase());
    final isImage =
        ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);

    String displayFileName = _extractDisplayName();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayFileName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.fileSize != null)
              Text(
                _getFormattedFileSize(),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _openFileExternally(widget.fileUrl),
            tooltip: 'Open in external app',
          ),
          if (_localFilePath != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadFile(),
              tooltip: 'Save to device',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isPdf && _localFilePath != null && _totalPages > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: AppColors.primaryColor.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    if (_totalPages > 1)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_upward,
                              color: _currentPage > 0
                                  ? AppColors.primaryColor
                                  : Colors.grey.withOpacity(0.5),
                            ),
                            onPressed: _currentPage > 0
                                ? () => _goToFirstPage()
                                : null,
                            tooltip: 'Go to first page',
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_downward,
                              color: _currentPage < _totalPages - 1
                                  ? AppColors.primaryColor
                                  : Colors.grey.withOpacity(0.5),
                            ),
                            onPressed: _currentPage < _totalPages - 1
                                ? () => _goToLastPage()
                                : null,
                            tooltip: 'Go to last page',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            Expanded(
              child: _buildBody(isImage, extension),
            ),
          ],
        ),
      ),
    );
  }

  String _extractDisplayName() {
    try {
      if (widget.firebaseFileName != null &&
          widget.firebaseFileName!.isNotEmpty) {
        if (widget.firebaseFileName!.contains('assignment_files/') ||
            widget.firebaseFileName!.contains('assignment_files%2F')) {
          final RegExp regex = RegExp(r'assignment_files(?:%2F|\/)([^?&]+)');
          final match = regex.firstMatch(widget.firebaseFileName!);
          if (match != null && match.groupCount >= 1) {
            final extractedName = match.group(1) ?? '';
            if (extractedName.isNotEmpty) {
              try {
                return Uri.decodeFull(extractedName);
              } catch (e) {
                print('Error decoding extracted name: $e');
                return extractedName;
              }
            }
          }
          
          final RegExp timestampRegex = RegExp(r'\/(\d+_[^?]+)');
          final timestampMatch =
              timestampRegex.firstMatch(widget.firebaseFileName!);
          if (timestampMatch != null && timestampMatch.groupCount >= 1) {
            final extractedName = timestampMatch.group(1) ?? '';
            if (extractedName.isNotEmpty) {
              try {
                return Uri.decodeFull(extractedName);
              } catch (e) {
                print('Error decoding timestamp name: $e');
                return extractedName;
              }
            }
          }
        } else {
          return widget.firebaseFileName!;
        }
      }
    } catch (e) {
      print('Error extracting display name: $e');
    }
    
    return _fileName;
  }

  void _changePdfPage(int page) {
    if (_pdfViewController != null) {
      _pdfViewController!.setPage(page);
    }
  }

  void _goToFirstPage() {
    if (_pdfViewController != null) {
      _pdfViewController!.setPage(0);
    }
  }

  void _goToLastPage() {
    if (_pdfViewController != null && _totalPages > 0) {
      _pdfViewController!.setPage(_totalPages - 1);
    }
  }

  Widget _buildBody(bool isImage, String extension) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: _isDownloading && _downloadProgress > 0
                    ? _downloadProgress
                    : null,
                strokeWidth: 3,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isDownloading
                  ? 'Downloading file... ${(_downloadProgress * 100).toStringAsFixed(0)}%'
                  : 'Loading file...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _fileName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (_localFilePath == null) {
      return _buildErrorWidget('File not available');
    }

    if (isImage) {
      return _buildImagePreview();
    } else if (_isPdf) {
      return _buildPdfView(_localFilePath!);
    } else {
      return _buildGenericFileView(_fileName, extension);
    }
  }

  Widget _buildImagePreview() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(
            File(_localFilePath!),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return _buildErrorWidget('Could not load image: $error');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPdfView(String filePath) {
    return PDFView(
      filePath: filePath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.WIDTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        if (mounted) {
          setState(() {
            _totalPages = pages!;
          });
        }
      },
      onError: (error) {
        print('PDF View Error: $error');
        if (mounted) {
          setState(() {
            _errorMessage = error.toString();
          });
        }
      },
      onPageError: (page, error) {
        print('PDF Page Error: Page $page - $error');
        if (mounted) {
          setState(() {
            _errorMessage = 'Error on page $page: $error';
          });
        }
      },
      onViewCreated: (PDFViewController controller) {
        if (mounted) {
          setState(() {
            _pdfViewController = controller;
          });
        }
      },
      onPageChanged: (int? page, int? total) {
        if (page != null && mounted) {
          setState(() {
            _currentPage = page;
          });
        }
      },
    );
  }

  Widget _buildGenericFileView(String fileName, String extension) {
    IconData fileIcon = _getFileIcon(extension);
    String fileTypeDescription = _getFileTypeDescription(extension);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      fileIcon,
                      size: 70,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        extension.toUpperCase().replaceFirst('.', ''),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            fileName,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              fileTypeDescription,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          if (widget.fileSize != null) ...[
            const SizedBox(height: 8),
            Text(
              _getFormattedFileSize(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openFileExternally(widget.fileUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Externally'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed:
                    _localFilePath != null ? () => _downloadFile() : null,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
    } else if (['.mp3', '.wav', '.ogg'].contains(extension)) {
      return Icons.audio_file;
    } else if (['.mp4', '.avi', '.mov'].contains(extension)) {
      return Icons.video_file;
    }
    return Icons.insert_drive_file;
  }

  String _getFileTypeDescription(String extension) {
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension)) {
      return "Image File";
    } else if (extension == '.pdf') {
      return "PDF Document";
    } else if (['.doc', '.docx'].contains(extension)) {
      return "Word Document";
    } else if (['.xls', '.xlsx'].contains(extension)) {
      return "Excel Spreadsheet";
    } else if (['.ppt', '.pptx'].contains(extension)) {
      return "PowerPoint Presentation";
    } else if (['.txt'].contains(extension)) {
      return "Text File";
    } else if (['.rtf'].contains(extension)) {
      return "Rich Text Document";
    } else if (['.zip', '.rar', '.7z'].contains(extension)) {
      return "Compressed Archive";
    } else if (['.mp3', '.wav', '.ogg'].contains(extension)) {
      return "Audio File";
    } else if (['.mp4', '.avi', '.mov'].contains(extension)) {
      return "Video File";
    }
    return "Document";
  }

  Widget _buildErrorWidget(String message) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cannot Open File',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openFileExternally(widget.fileUrl),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in Browser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _prepareFile(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openFileExternally(String url) async {
    try {
      // Sanitize URL before opening
      String sanitizedUrl = url;
      
      // If URL contains potentially problematic characters, try to clean it
      if (url.contains('%') && !url.contains('%20') && !url.contains('%2F')) {
        sanitizedUrl = url.replaceAll('%', '%25');
      }
      
      final uri = Uri.parse(sanitizedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Try with original URL if sanitized version fails
        if (sanitizedUrl != url) {
          try {
            final originalUri = Uri.parse(url);
            if (await canLaunchUrl(originalUri)) {
              await launchUrl(originalUri, mode: LaunchMode.externalApplication);
              return;
            }
          } catch (e) {
            print('Error trying with original URL: $e');
          }
        }
        
        // If both attempts fail, try with LaunchMode.platformDefault
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          return;
        } catch (e) {
          print('Error with platformDefault launch mode: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Could not open file with external app')),
          );
        }
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error opening file externally: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error opening file: $e')),
        );
      }
    }
  }

  Future<void> _downloadFile() async {
    // Request storage permissions first
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    // Also request external storage permission on Android
    var externalStatus = await Permission.manageExternalStorage.status;
    if (!externalStatus.isGranted) {
      externalStatus = await Permission.manageExternalStorage.request();
    }
    
    if (!status.isGranted && !externalStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied. Cannot download file.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_localFilePath != null) {
      try {
        // Try to use Download directory
        final downloadsDir = await getExternalStorageDirectory();
        final downloadPath = downloadsDir?.path ?? '/storage/emulated/0/Download';
        
        Directory downloadsDirectory = Directory(downloadPath);
        if (!await downloadsDirectory.exists()) {
          await downloadsDirectory.create(recursive: true);
          print('Created Downloads directory at: $downloadPath');
        }

        final destinationFile = File('$downloadPath/$_fileName');
        if (await destinationFile.exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File already exists in Downloads'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        await destinationFile
            .writeAsBytes(await File(_localFilePath!).readAsBytes());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _showDownloadCompleteNotification(destinationFile.path);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
