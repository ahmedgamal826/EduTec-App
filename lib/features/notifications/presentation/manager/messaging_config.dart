import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:attendance_app/core/provider/app_provider.dart';
import 'package:attendance_app/features/chats/data/models/chat_model.dart';
import 'package:attendance_app/features/chats/data/repositories/chat_repository.dart';
import 'package:attendance_app/features/chats/presentation/manager/chat_view_model_provider.dart';
import 'package:attendance_app/features/chats/presentation/views/chat_view.dart';
import 'package:attendance_app/features/notifications/data/models/notification_model.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:attendance_app/features/notifications/presentation/views/student_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

// معالج الإشعارات الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تأكد من تهيئة Firebase إذا لم تكن مهيأة بالفعل
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  
  print("تم استلام إشعار في الخلفية: ${message.notification?.title}");
  print("بيانات الإشعار: ${message.data}");
  
  // إنشاء مكون الإشعارات المحلية للخلفية
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
      
  // تهيئة قناة الإشعارات للخلفية
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('custom_sound'),
    enableVibration: true,
    enableLights: true,
    showBadge: true,
  );
  
  // إنشاء قناة الإشعارات
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  
  // تهيئة الإشعارات المحلية
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      ),
    ),
  );
  
  // عرض الإشعار المحلي
  if (message.notification != null) {
    await _showBackgroundNotification(
      flutterLocalNotificationsPlugin,
      message.notification!.title ?? 'إشعار جديد',
      message.notification!.body ?? '',
      message.data,
    );
  } else if (message.data.isNotEmpty) {
    // إذا كان الإشعار يحتوي على بيانات فقط بدون كائن notification
    final title = message.data['title'] ?? 'إشعار جديد';
    final body = message.data['body'] ?? '';
    
    await _showBackgroundNotification(
      flutterLocalNotificationsPlugin,
      title,
      body,
      message.data,
    );
  }
}

// دالة لعرض إشعار في الخلفية
Future<void> _showBackgroundNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  String title,
  String body,
  Map<String, dynamic> data,
) async {
  try {
    // تكوين تفاصيل الإشعار لنظام Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      enableVibration: true,
      enableLights: true,
      color: Color.fromARGB(255, 0, 102, 204),
      ledColor: Color.fromARGB(255, 0, 102, 204),
      ledOnMs: 1000,
      ledOffMs: 500,
      ticker: 'إشعار جديد',
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );

    // تكوين تفاصيل الإشعار لنظام iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'custom_sound.caf',
      interruptionLevel: InterruptionLevel.timeSensitive,
      threadIdentifier: 'attendance_app',
    );

    // تكوين تفاصيل الإشعار لجميع الأنظمة
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // عرض الإشعار
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // معرف فريد للإشعار
      title,
      body,
      notificationDetails,
      payload: jsonEncode(data),
    );
    
    print('تم عرض إشعار في الخلفية: $title');
  } catch (e) {
    print('خطأ في عرض الإشعار في الخلفية: $e');
  }
}

class MessagingConfig {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> createNotificationChannel() async {
    // إعداد قناة الإشعارات لنظام Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    
    // إنشاء قناة ثانية للإشعارات في الواجهة الأمامية
    const AndroidNotificationChannel foregroundChannel = AndroidNotificationChannel(
      'foreground_channel',
      'Foreground Notifications',
      description: 'This channel is used for notifications when app is in foreground.',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );
    
    await androidPlugin?.createNotificationChannel(foregroundChannel);
  }

  static Future<void> initFirebaseMessaging() async {
    await createNotificationChannel();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // طلب أذونات الإشعارات
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // الحصول على رمز FCM وتخزينه في Firestore
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null && FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(
        {'fcmToken': fcmToken},
        SetOptions(merge: true),
      );
      log('تم تخزين رمز FCM للمستخدم: ${FirebaseAuth.instance.currentUser!.uid}');
    }

    // التعامل مع تحديث الرمز
    messaging.onTokenRefresh.listen((newToken) async {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set(
          {'fcmToken': newToken},
          SetOptions(merge: true),
        );
        log('تم تحديث رمز FCM: $newToken');
      }
    });

    // إعداد الإشعارات المحلية
    final AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentSound: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // تهيئة مكون الإشعارات المحلية
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          final context = navigatorKey.currentContext;
          if (context != null) {
            handleNotification(context, data);
          }
        }
      },
    );

    // ضبط خيارات عرض الإشعارات في الواجهة الأمامية لنظام iOS
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('المستخدم منح الإذن');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('المستخدم منح إذنًا مؤقتًا');
    } else {
      log('المستخدم رفض الإذن');
    }

    // تسجيل معالج الإشعارات في الخلفية
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // التعامل مع الإشعارات في الواجهة الأمامية
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      log("تم استلام إشعار في الواجهة الأمامية: ${event.notification?.title}");
      try {
        final notification = event.notification;

        if (notification != null) {
          // إضافة الإشعار إلى قاعدة البيانات
          if (event.data['type'] == 'assignment' ||
              event.data['type'] == 'test' ||
              event.data['type'] == 'attendance' ||
              event.data['type'] == 'material' ||
              event.data['type'] == 'questionnaire' ||
              event.data['type'] == 'custom') {
            await _saveNotificationToFirestore(
              notification.title ?? 'New Notification',
              notification.body ?? '',
              event.data['courseId'],
              event.data['type'],
              event.data['deadline'],
              event.data['recipients'] != null
                  ? (event.data['recipients'] as String).split(',')
                  : null,
            );
          }

          // عرض الإشعار في الواجهة الأمامية
          await flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'foreground_channel',
                'Foreground Notifications',
                channelDescription:
                    'This channel is used for notifications when app is in foreground.',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                sound:
                    RawResourceAndroidNotificationSound('custom_sound'),
                icon: '@mipmap/ic_launcher',
                enableVibration: true,
                fullScreenIntent: true,
                visibility: NotificationVisibility.public,
                ticker: 'New notification',
                category: AndroidNotificationCategory.message,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'custom_sound.caf',
                interruptionLevel: InterruptionLevel.timeSensitive,
              ),
            ),
            payload: event.data.isNotEmpty ? jsonEncode(event.data) : null,
          );

          // التعامل مع الإشعار في السياق الحالي
          final context = navigatorKey.currentContext;
          if (context != null) {
            handleNotification(context, event.data);
          } else {
            log('سياق navigator هو null');
          }
        }
      } catch (e) {
        log('خطأ في عرض الإشعار: $e');
      }
    });

    // التعامل مع النقر على الإشعار عندما يكون التطبيق مغلقًا
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        log('تم فتح التطبيق من حالة مغلقة بواسطة إشعار');
        // انتظار تهيئة التطبيق بالكامل قبل التعامل مع التنقل
        Future.delayed(const Duration(seconds: 2), () {
          final context = navigatorKey.currentContext;
          if (context != null) {
            handleNotification(context, message.data);
          }
        });
      }
    });

    // التعامل مع النقر على الإشعار عندما يكون التطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('تم فتح التطبيق من حالة الخلفية بواسطة إشعار');
      final context = navigatorKey.currentContext;
      if (context != null) {
        handleNotification(context, message.data);
      }
    });
    
    // إذا كان التطبيق على نظام iOS، نطلب أذونات إضافية
    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    
    // تمكين الإشعارات عندما يكون التطبيق في الخلفية
    await messaging.setAutoInitEnabled(true);
  }

  // دالة مساعدة لحفظ الإشعار في Firestore
  static Future<void> _saveNotificationToFirestore(
      String title, String body, String? courseId,
      [String? type = 'custom',
      String? deadline,
      List<String>? recipients]) async {
    try {
      final notificationService = NotificationService();
      await notificationService.createNotification(
        subject: title,
        description: body,
        courseId: courseId,
        type: type,
        deadline: deadline,
        recipients: recipients,
        isRead: false,
      );
    } catch (e) {
      log('خطأ في حفظ الإشعار في Firestore: $e');
    }
  }

  // التعامل مع الإشعارات
  static void handleNotification(
      BuildContext context, Map<String, dynamic> data) {
    // معالجة النقر على الإشعار حسب نوعه
    if (data['route'] == '/chat' && data['chatId'] != null) {
      // إشعار محادثة
      final chatId = data['chatId'];
      final senderId = data['senderId'];

      log('فتح محادثة عن طريق إشعار. chatId: $chatId، المرسل: $senderId');

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        log('لا يوجد مستخدم مسجل دخول، لا يمكن فتح المحادثة: $chatId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
        );
        return;
      }

      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get()
          .then((doc) {
        if (doc.exists) {
          try {
            // إنشاء نموذج ChatModel من مستند Firestore
            final chat = ChatModel.fromFirestore(doc, currentUserId);

            // فتح صفحة المحادثة مع تضمين Provider
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
            log('خطأ في إنشاء نموذج المحادثة: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل في فتح المحادثة: $e')),
            );
          }
        } else {
          log('لم يتم العثور على المحادثة برقم: $chatId');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على المحادثة')),
          );
        }
      }).catchError((e) {
        log('خطأ في جلب المحادثة: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب المحادثة: $e')),
        );
      });
    } else if (data['type'] == 'assignment' ||
        data['type'] == 'test' ||
        data['type'] == 'attendance' ||
        data['type'] == 'material' ||
        data['type'] == 'questionnaire' ||
        data['type'] == 'custom') {
      // فتح صفحة الإشعارات للأنواع الأخرى
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudentNotifications()),
      );
    }
  }

  // معالجة النقر على الإشعار
  static void _handleNotificationTap(RemoteMessage message) {
    // يمكن هنا التنقل إلى الشاشة المناسبة بناءً على بيانات الإشعار
    final data = message.data;
    
    if (data.containsKey('screen')) {
      final screen = data['screen'];
      
      // التنقل إلى الشاشة المطلوبة
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushNamed(screen);
      }
    }
  }

  // عرض إشعار في الواجهة الأمامية
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      // تكوين تفاصيل الإشعار لنظام Android
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'foreground_channel',
        'Foreground Notifications',
        channelDescription: 'This channel is used for notifications when app is in foreground.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('custom_sound'),
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        enableVibration: true,
        enableLights: true,
        color: Color.fromARGB(255, 0, 102, 204),
        ledColor: Color.fromARGB(255, 0, 102, 204),
        ledOnMs: 1000,
        ledOffMs: 500,
        ticker: 'إشعار جديد',
        visibility: NotificationVisibility.public,
      );

      // تكوين تفاصيل الإشعار لنظام iOS
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'custom_sound.caf',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      // تكوين تفاصيل الإشعار لجميع الأنظمة
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // عرض الإشعار
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond, // معرف فريد للإشعار
        message.notification?.title ?? message.data['title'] ?? 'إشعار جديد',
        message.notification?.body ?? message.data['body'] ?? '',
        notificationDetails,
        payload: jsonEncode(message.data),
      );
      
      print('تم عرض إشعار في الواجهة الأمامية');
    } catch (e) {
      print('خطأ في عرض الإشعار في الواجهة الأمامية: $e');
    }
  }

  // إرسال إشعار اختباري
  static Future<void> sendTestNotification() async {
    try {
      // تكوين تفاصيل الإشعار لنظام Android
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('custom_sound'),
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        enableVibration: true,
        enableLights: true,
        color: Color.fromARGB(255, 0, 102, 204),
        ledColor: Color.fromARGB(255, 0, 102, 204),
        ledOnMs: 1000,
        ledOffMs: 500,
        ticker: 'إشعار اختباري',
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
      );

      // تكوين تفاصيل الإشعار لنظام iOS
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'custom_sound.caf',
        interruptionLevel: InterruptionLevel.timeSensitive,
        threadIdentifier: 'attendance_app',
      );

      // تكوين تفاصيل الإشعار لجميع الأنظمة
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // عرض الإشعار
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond, // معرف فريد للإشعار
        'إشعار اختباري',
        'هذا إشعار اختباري من MessagingConfig',
        notificationDetails,
        payload: 'test_notification',
      );
      
      print('تم إرسال إشعار اختباري من MessagingConfig');
    } catch (e) {
      print('خطأ في إرسال الإشعار الاختباري من MessagingConfig: $e');
    }
  }
}
