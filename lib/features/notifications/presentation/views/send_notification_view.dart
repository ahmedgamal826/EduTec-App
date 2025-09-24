import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SendNotificationView extends StatefulWidget {
  const SendNotificationView({super.key});

  @override
  State<SendNotificationView> createState() => _SendNotificationViewState();
}

class _SendNotificationViewState extends State<SendNotificationView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  bool _canSendNotifications = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _checkPermissions() async {
    final canSend = await _notificationService.canSendNotifications();
    setState(() {
      _canSendNotifications = canSend;
    });
  }
  
  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a title');
      return;
    }
    
    if (_messageController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a message');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _notificationService.sendCustomNotification(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _titleController.clear();
          _messageController.clear();
        });
        
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to send notification: ${e.toString()}');
      }
    }
  }
  
  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }
  
  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Success',
      desc: 'Notification sent successfully to all students',
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Send Firebase Notification",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _canSendNotifications 
          ? _buildSendNotificationForm()
          : _buildPermissionDenied(),
    );
  }
  
  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Permission Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You do not have permission to send notifications. Only administrators and doctors can send notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSendNotificationForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Push Notifications with FCM',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Notification Title',
                hintText: 'Enter notification title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Notification Message',
                hintText: 'Enter notification message',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Send Notification',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 