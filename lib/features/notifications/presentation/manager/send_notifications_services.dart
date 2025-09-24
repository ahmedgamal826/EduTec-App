// // import 'dart:convert';
// // import 'dart:developer';
// // import 'package:attendance_app/features/notifications/presentation/manager/product_details_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:googleapis_auth/auth_io.dart' as auth;

// // Future<String> getAccessToken() async {
// //   final jsonString = await rootBundle.loadString(
// //     'assets/notification_key/food-ordering-app-f89c6-300028c12964.json',
// //   );

// //   final accountCredentials =
// //       auth.ServiceAccountCredentials.fromJson(jsonString);

// //   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
// //   final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

// //   return client.credentials.accessToken.data;
// // }

// // // Future<void> sendNotification(
// // //     {required String token,
// // //     required String title,
// // //     required String body,
// // //     required Map<String, String> data}) async {
// // //   final String accessToken = await getAccessToken();
// // //   final String fcmUrl =
// // //       'https://fcm.googleapis.com/v1/projects/food-ordering-app-f89c6/messages:send';

// // //   final response = await http.post(
// // //     Uri.parse(fcmUrl),
// // //     headers: <String, String>{
// // //       'Content-Type': 'application/json',
// // //       'Authorization': 'Bearer $accessToken',
// // //     },
// // //     body: jsonEncode(<String, dynamic>{
// // //       'message': {
// // //         'token': token,
// // //         'notification': {
// // //           'title': title,
// // //           'body': body,
// // //         },
// // //         'data': data, // Add custom data here

// // //         'android': {
// // //           'notification': {
// // //             "sound": "custom_sound",
// // //             'click_action':
// // //                 'FLUTTER_NOTIFICATION_CLICK', // Required for tapping to trigger response
// // //             'channel_id': 'high_importance_channel'
// // //           },
// // //         },
// // //         'apns': {
// // //           'payload': {
// // //             'aps': {"sound": "custom_sound.caf", 'content-available': 1},
// // //           },
// // //         },
// // //       },
// // //     }),
// // //   );

// // //   if (response.statusCode == 200) {
// // //     print('Notification sent successfully');
// // //   } else {
// // //     print('Failed to send notification: ${response.body}');
// // //   }
// // // }

// // // Future<void> sendNotification({
// // //   required String token,
// // //   required String title,
// // //   required String body,
// // //   required Map<String, String> data,
// // // }) async {
// // //   final String accessToken = await getAccessToken();
// // //   final String fcmUrl =
// // //       'https://fcm.googleapis.com/v1/projects/food-ordering-app-f89c6/messages:send';

// // //   final response = await http.post(
// // //     Uri.parse(fcmUrl),
// // //     headers: <String, String>{
// // //       'Content-Type': 'application/json',
// // //       'Authorization': 'Bearer $accessToken',
// // //     },
// // //     body: jsonEncode(<String, dynamic>{
// // //       'message': {
// // //         'token': token,
// // //         'notification': {
// // //           'title': title,
// // //           'body': body,
// // //         },
// // //         'data': data,
// // //         'android': {
// // //           'notification': {
// // //             'sound': 'custom_sound',
// // //             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
// // //             'channel_id': 'high_importance_channel',
// // //             'priority': 'high',
// // //             'play_sound': true, // Explicitly enable sound
// // //           },
// // //         },
// // //         'apns': {
// // //           'payload': {
// // //             'aps': {
// // //               'sound': 'custom_sound.caf',
// // //               'content-available': 1,
// // //               'mutable-content': 1,
// // //               'badge': 1,
// // //               'alert': {
// // //                 'title': title,
// // //                 'body': body,
// // //               },
// // //             },
// // //           },
// // //         },
// // //       },
// // //     }),
// // //   );

// // //   if (response.statusCode == 200) {
// // //     log('Notification sent successfully');
// // //   } else {
// // //     log('Failed to send notification: ${response.body}');
// // //   }
// // // }

// // Future<void> sendNotification({
// //   required String token,
// //   required String title,
// //   required String body,
// //   required Map<String, String> data,
// // }) async {
// //   final String accessToken = await getAccessToken();
// //   final String fcmUrl =
// //       'https://fcm.googleapis.com/v1/projects/food-ordering-app-f89c6/messages:send';

// //   final response = await http.post(
// //     Uri.parse(fcmUrl),
// //     headers: <String, String>{
// //       'Content-Type': 'application/json',
// //       'Authorization': 'Bearer $accessToken',
// //     },
// //     body: jsonEncode(<String, dynamic>{
// //       'message': {
// //         'token': token,
// //         'notification': {
// //           'title': title,
// //           'body': body,
// //         },
// //         'data': data,
// //         'android': {
// //           'priority': 'high', // Moved to the correct level
// //           'notification': {
// //             'sound':
// //                 'custom_sound', // This matches the raw resource on the client
// //             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
// //             'channel_id': 'high_importance_channel',
// //           },
// //         },
// //         'apns': {
// //           'payload': {
// //             'aps': {
// //               'sound': 'custom_sound.caf',
// //               'content-available': 1,
// //               'mutable-content': 1,
// //               'badge': 1,
// //               'alert': {
// //                 'title': title,
// //                 'body': body,
// //               },
// //             },
// //           },
// //         },
// //       },
// //     }),
// //   );

// //   if (response.statusCode == 200) {
// //     log('Notification sent successfully');
// //   } else {
// //     log('Failed to send notification: ${response.body}');
// //   }
// // }

// // void handleNotification(BuildContext context, Map<String, dynamic> data) {
// //   String route = data['route'];
// //   String id = data['id'];

// //   if (route == '/product_detials') {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //           builder: (context) => ProductDetailsScreen(productId: id)),
// //     );
// //   }
// // }

// import 'dart:convert';
// import 'dart:developer';
// import 'package:attendance_app/features/chats/data/models/chat_model.dart';
// import 'package:attendance_app/features/chats/presentation/views/chat_view.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;

// Future<String> getAccessToken() async {
//   final jsonString = await rootBundle.loadString(
//     'assets/notification_key/food-ordering-app-f89c6-300028c12964.json',
//   );

//   final accountCredentials =
//       auth.ServiceAccountCredentials.fromJson(jsonString);

//   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
//   final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

//   return client.credentials.accessToken.data;
// }

// Future<void> sendNotification({
//   required String token,
//   required String title,
//   required String body,
//   required Map<String, String> data,
// }) async {
//   final String accessToken = await getAccessToken();
//   final String fcmUrl =
//       'https://fcm.googleapis.com/v1/projects/food-ordering-app-f89c6/messages:send';

//   final response = await http.post(
//     Uri.parse(fcmUrl),
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $accessToken',
//     },
//     body: jsonEncode(<String, dynamic>{
//       'message': {
//         'token': token,
//         'notification': {
//           'title': title,
//           'body': body,
//         },
//         'data': data,
//         'android': {
//           'priority': 'high',
//           'notification': {
//             'sound': 'custom_sound',
//             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//             'channel_id': 'high_importance_channel',
//           },
//         },
//         'apns': {
//           'payload': {
//             'aps': {
//               'sound': 'custom_sound.caf',
//               'content-available': 1,
//               'mutable-content': 1,
//               'badge': 1,
//               'alert': {
//                 'title': title,
//                 'body': body,
//               },
//             },
//           },
//         },
//       },
//     }),
//   );

//   if (response.statusCode == 200) {
//     log('Notification sent successfully');
//   } else {
//     log('Failed to send notification: ${response.body}');
//   }
// }

// void handleNotification(BuildContext context, Map<String, dynamic> data) {
//   String? route = data['route'];
//   String? chatId = data['chatId'];

//   if (route == '/chat' && chatId != null) {
//     FirebaseFirestore.instance
//         .collection('users_chats')
//         .doc(chatId)
//         .get()
//         .then((doc) {
//       if (doc.exists) {
//         final chat = ChatModel.fromFirestore(doc);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatView(chat: chat),
//           ),
//         );
//       } else {
//         log('Chat not found for chatId: $chatId');
//       }
//     });
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:attendance_app/features/chats/data/models/chat_model.dart';
import 'package:attendance_app/features/chats/data/repositories/chat_repository.dart';
import 'package:attendance_app/features/chats/presentation/manager/chat_view_model_provider.dart';
import 'package:attendance_app/features/chats/presentation/views/chat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

Future<String> getAccessToken() async {
  final jsonString = await rootBundle.loadString(
    'assets/notification_key/food-ordering-app-f89c6-300028c12964.json',
  );

  final accountCredentials =
      auth.ServiceAccountCredentials.fromJson(jsonString);

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

  return client.credentials.accessToken.data;
}

Future<void> sendNotification({
  required String token,
  required String title,
  required String body,
  required Map<String, String> data,
}) async {
  try {
    final String accessToken = await getAccessToken();
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/food-ordering-app-f89c6/messages:send';

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data,
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'custom_sound',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'channel_id': 'high_importance_channel',
              'icon': '@mipmap/ic_launcher',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'sound': 'custom_sound.caf',
                'content-available': 1,
                'mutable-content': 1,
                'badge': 1,
                'alert': {
                  'title': title,
                  'body': body,
                },
              },
            },
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      log('Notification sent successfully to token: $token');
    } else {
      log('Failed to send notification: ${response.body}');
      throw Exception('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    log('Error sending notification: $e');
    rethrow;
  }
}

void handleNotification(BuildContext context, Map<String, dynamic> data) {
  String? route = data['route'];
  String? chatId = data['chatId'];

  if (route == '/chat' && chatId != null) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      log('No user logged in, cannot navigate to chat: $chatId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view the chat')),
      );
      Navigator.pushNamed(context, 'loginScreen');
      return;
    }

    FirebaseFirestore.instance
        .collection('users_chats')
        .doc(chatId)
        .get()
        .then((doc) {
      if (doc.exists) {
        try {
          final chat = ChatModel.fromFirestore(doc, currentUserId);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => ChatViewModel(ChatRepository()),
                child: ChatView(chat: chat),
              ),
            ),
          );
        } catch (e) {
          log('Error creating ChatModel: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open chat: $e')),
          );
        }
      } else {
        log('Chat not found for chatId: $chatId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat not found')),
        );
      }
    }).catchError((e) {
      log('Error fetching chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chat: $e')),
      );
    });
  }
}
