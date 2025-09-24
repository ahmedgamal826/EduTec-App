import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/notifications/presentation/viewmodels/student_notifications_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsDetailsView extends StatelessWidget {
  final Map<String, String> notification;
  final String? notificationId;

  const NotificationsDetailsView({
    super.key,
    required this.notification,
    this.notificationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Notification Details",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: "icon-${notification['subject']}",
                    child: const Icon(
                      Icons.notifications_active,
                      color: AppColors.primaryColor,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  notification["subject"]!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildInfoItem(
                      icon: Icons.calendar_today,
                      text: "Date: ${notification["date"]!}",
                    ),
                    if (notification["time"] != null &&
                        notification["time"]!.isNotEmpty)
                      _buildInfoItem(
                        icon: Icons.access_time,
                        text: "Time: ${_formatTime12Hour(notification["time"]!)}",
                      ),
                  ],
                ),
                if (notification["createdByName"] != null &&
                    notification["createdByName"]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildInfoItem(
                      icon: Icons.person,
                      text: "Created by: ${notification["createdByName"]!}",
                    ),
                  ),
                if (notification["deadline"] != null &&
                    notification["deadline"]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildInfoItem(
                      icon: Icons.timer,
                      text: "Deadline: ${notification["deadline"]!}",
                      textColor: Colors.redAccent,
                      iconColor: Colors.redAccent,
                      isBold: true,
                    ),
                  ),
                const Divider(thickness: 1.5, height: 25),
                const Text(
                  "Description:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      notification["description"]!,
                      style:
                          const TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    Color iconColor = Colors.grey,
    Color textColor = Colors.grey,
    bool isBold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatTime12Hour(String time24) {
    // Parse the 24-hour time string (e.g., "21:26") to DateTime
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
}
