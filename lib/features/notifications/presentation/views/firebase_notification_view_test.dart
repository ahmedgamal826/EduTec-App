import 'package:attendance_app/features/notifications/presentation/manager/send_notifications_services.dart';
import 'package:flutter/material.dart';

class FirebaseNotificationViewTest extends StatelessWidget {
  const FirebaseNotificationViewTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Send Firebase Notifications',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text('Push Notifications with FCM'),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                sendNotification(
                    token:
                        'dEDNyYmITnuF2sgAKjVRs3:APA91bGY3XrI7RrFCWcoiwoKVyl5kXrJ6ypmRUpxE_3JuhPLr6PHnRkwGM_UtUiQrRvbYs9WYzUM1O6sy2UqtUdJ_uWT1Vi80kqfP-aj5GvkOksfA47Rthw',
                    title: 'Hello Ahmed Elnemr!',
                    body: 'This is a new test notification.',
                    data: {
                      "route": "/product_detials",
                      "id": "120",
                    });
              },
              child: const Text('Send Notification'),
            ),
          )
        ],
      ),
    );
  }
}
