import 'package:attendance_app/core/provider/app_provider.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/notifications/data/models/notification_model.dart';
import 'package:attendance_app/features/notifications/presentation/viewmodels/student_notifications_viewmodel.dart';
import 'package:attendance_app/features/notifications/presentation/views/notifications_details_view.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentNotifications extends StatelessWidget {
  const StudentNotifications({super.key});

  void _showDeleteDialog(BuildContext context, String notificationId) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Delete Notification',
      desc: 'Are you sure you want to delete this notification?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        Provider.of<StudentNotificationsViewModel>(context, listen: false)
            .deleteNotification(notificationId);
      },
    ).show();
  }

  void _showMarkAllReadDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      title: 'Mark All as Read',
      desc: 'Are you sure you want to mark all notifications as read?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        // Update AppProvider to mark all as read
        Provider.of<AppProvider>(context, listen: false)
            .markAllNotificationsAsRead();
        // Also refresh the notifications viewmodel
        Provider.of<StudentNotificationsViewModel>(context, listen: false)
            .refreshNotifications();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentNotificationsViewModel(),
      child: Consumer<StudentNotificationsViewModel>(
        builder: (context, viewModel, _) {
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
                if (viewModel.unreadCount > 0)
                  IconButton(
                    icon: const Icon(Icons.done_all, color: Colors.white),
                    tooltip: 'Mark all as read',
                    onPressed: () => _showMarkAllReadDialog(context),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh',
                  onPressed: () => viewModel.refreshNotifications(),
                ),
              ],
            ),
            body: _buildNotificationsBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsBody(
      BuildContext context, StudentNotificationsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.clearError(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (viewModel.notifications.isEmpty) {
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
            const Text(
              'No notifications available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.refreshNotifications(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshNotifications(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: viewModel.notifications.length,
          itemBuilder: (context, index) {
            final notification = viewModel.notifications[index];
            return _buildNotificationItem(context, notification, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context,
      NotificationModel notification, StudentNotificationsViewModel viewModel) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        _showDeleteDialog(context, notification.id);
        return false;
      },
      child: GestureDetector(
        onTap: () {
          // تحديث حالة القراءة عند النقر على الإشعار
          if (!notification.isRead) {
            viewModel.markAsRead(notification.id);
            // Update app provider unread count as well
            Provider.of<AppProvider>(context, listen: false)
                .fetchUnreadNotificationsCount();
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsDetailsView(
                notification: {
                  'subject': notification.subject,
                  'description': notification.description,
                  'date': notification.date,
                  'time': notification.time ?? '',
                  'createdByName': notification.createdByName ?? '',
                  'deadline': notification.deadline ?? '',
                },
                notificationId: notification.id,
              ),
            ),
          );
        },
        child: Card(
          elevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // اختيار الأيقونة المناسبة حسب نوع الإشعار
                        Icon(
                          _getNotificationIcon(notification.type),
                          color: _getNotificationIconColor(notification.type),
                          size: 30,
                        ),
                        // عرض النقطة الخضراء للإشعارات غير المقروءة
                        if (!notification.isRead)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.subject,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            notification.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (notification.createdByName != null &&
                              notification.createdByName!.isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "By: ${notification.createdByName}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          if (notification.deadline != null &&
                              notification.deadline!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Deadline: ${notification.deadline}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          notification.date,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (notification.time != null &&
                            notification.time!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              _formatTime12Hour(notification.time!),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime12Hour(String time24) {
    // Parse the 24-hour time string (e.g., "20:03") to DateTime
    final timeParts = time24.split(':');
    if (timeParts.length == 2) {
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final dateTime =
          DateTime(2025, 1, 1, hour, minute); // Using an arbitrary date
      return DateFormat('h:mm a')
          .format(dateTime); // Formats to 12-hour with AM/PM
    }
    return time24; // Return original if parsing fails
  }

  // تحديد أيقونة الإشعار بناءً على نوعه
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
        return Icons.fact_check; // Icon for questionnaire
      default:
        return Icons.notifications;
    }
  }

  // تحديد لون أيقونة الإشعار بناءً على نوعه
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
        return Colors.teal; // Teal color for questionnaire
      default:
        return AppColors.primaryColor;
    }
  }
}
