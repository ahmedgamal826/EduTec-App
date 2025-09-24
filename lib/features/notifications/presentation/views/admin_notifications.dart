import 'package:attendance_app/core/provider/app_provider.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/notifications/data/models/notification_model.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:attendance_app/features/notifications/presentation/views/add_notifications_view.dart';
import 'package:attendance_app/features/notifications/presentation/views/notifications_details_view.dart';
import 'package:attendance_app/features/notifications/presentation/views/send_notification_view.dart';
import 'package:attendance_app/features/notifications/presentation/views/update_notifications_view.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({super.key});

  @override
  _AdminNotificationsState createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  final NotificationService _notificationService = NotificationService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Just set loading to false, admins don't see notifications
      setState(() {
        isLoading = false;
      });
      
      // Update app provider unread count (should be 0 for admins)
      Provider.of<AppProvider>(context, listen: false).fetchUnreadNotificationsCount();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading notifications: $e');
    }
  }

  void _navigateToSendNotificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SendNotificationView(),
      ),
    ).then((value) {
      // Reload notifications when returning from send notification screen
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _navigateToSendNotificationScreen,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAdminNotificationsBody(),
    );
  }

  Widget _buildAdminNotificationsBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 70,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'As an admin, you can only send notifications to students but not receive them.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToSendNotificationScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Send Notification'),
          ),
        ],
      ),
    );
  }
  
  // Determine notification icon based on type
  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment;
      case 'test':
        return Icons.quiz;
      case 'attendance':
        return Icons.how_to_reg;
      case 'material':
        return Icons.folder_open;
      case 'questionnaire':
        return Icons.fact_check;
      case 'custom':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }
  
  // Determine notification icon color based on type
  Color _getNotificationIconColor(String? type) {
    switch (type) {
      case 'assignment':
        return Colors.blue;
      case 'test':
        return Colors.orange;
      case 'attendance':
        return Colors.green;
      case 'material':
        return Colors.purple;
      case 'questionnaire':
        return Colors.teal;
      case 'custom':
        return Colors.indigo;
      default:
        return AppColors.primaryColor;
    }
  }
}
