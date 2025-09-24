import 'package:attendance_app/app_home.dart';
import 'package:attendance_app/core/provider/app_provider.dart';
import 'package:attendance_app/core/provider/chat_provider.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/chat_gpt/data/services/sound_services.dart';
import 'package:attendance_app/features/chat_gpt/presentation/manager/Providers/profile_provider.dart';
import 'package:attendance_app/features/chats/data/repositories/chat_repository.dart';
import 'package:attendance_app/features/chats/presentation/manager/chat_view_model_provider.dart';
import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:attendance_app/features/notifications/presentation/manager/messaging_config.dart';
import 'package:attendance_app/features/notifications/presentation/views/send_notification_view.dart';
import 'package:attendance_app/features/splash/presentation/views/splash_view.dart';
import 'package:attendance_app/features/auth/presentations/views/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'firebase_options.dart';

// استخدام معالج الإشعارات الخلفية من MessagingConfig
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تمرير الإشعار إلى المعالج الرئيسي
  await firebaseMessagingBackgroundHandler(message);
}

// إنشاء مكون الإشعارات المحلية كمتغير عام
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة Hive للتخزين المحلي
  await ChatProvider.initHive();

  // تسجيل معالج الإشعارات الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // إعداد قنوات الإشعارات لنظام Android
  if (Platform.isAndroid) {
    // قناة للإشعارات ذات الأهمية العالية
    const AndroidNotificationChannel highImportanceChannel = AndroidNotificationChannel(
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

    // قناة للإشعارات في الواجهة الأمامية
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

    // إنشاء قنوات الإشعارات
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.createNotificationChannel(highImportanceChannel);
    await androidPlugin?.createNotificationChannel(foregroundChannel);
    
    // طلب أذونات الإشعارات
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // إعدادات تهيئة الإشعارات المحلية
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    defaultPresentSound: true,
    defaultPresentAlert: true,
    defaultPresentBadge: true,
    notificationCategories: [
      DarwinNotificationCategory(
        'attendance_app_category',
        actions: [
          DarwinNotificationAction.plain(
            'open',
            'فتح',
            options: {DarwinNotificationActionOption.foreground},
          ),
        ],
        options: {
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ],
  );

  // تهيئة إعدادات الإشعارات
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // تهيئة مكون الإشعارات المحلية
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // معالجة النقر على الإشعار
      if (response.payload != null) {
        print('تم النقر على الإشعار: ${response.payload}');
        // يمكن إضافة المزيد من المنطق هنا للتعامل مع النقر على الإشعار
      }
    },
  );

  // تكوين خيارات عرض الإشعارات في الواجهة الأمامية لنظام iOS
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // طلب أذونات الإشعارات من Firebase Messaging
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );

  print('إعدادات أذونات الإشعارات: ${settings.authorizationStatus}');

  // إجراء اختبار للإشعارات المحلية
  await _showTestNotification();

  // تشغيل التطبيق
  runApp(
    MultiProvider(
      providers: [
        // Providers
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SoundService()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DarkModeProvider()),
        // ChangeNotifierProvider(create: (_) => QuestionnaireViewModel()),
        //ChangeNotifierProvider(create: (_) => HomeQuestionnairesViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel(ChatRepository())),
        // Cubits
        // BlocProvider(create: (_) => LectureCubit()),
        ChangeNotifierProvider(create: (_) => DarkModeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const AttendanceApp(),
    ),
  );
}

// دالة لعرض إشعار اختباري للتأكد من عمل الإشعارات
Future<void> _showTestNotification() async {
  try {
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

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'custom_sound.caf',
      interruptionLevel: InterruptionLevel.timeSensitive,
      threadIdentifier: 'attendance_app',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'إشعار اختباري',
      'هذا إشعار اختباري للتأكد من عمل الإشعارات',
      notificationDetails,
      payload: 'test_notification',
    );
    
    print('تم إرسال إشعار اختباري');
  } catch (e) {
    print('خطأ في إرسال الإشعار الاختباري: $e');
  }
}

class AttendanceApp extends StatefulWidget {
  const AttendanceApp({super.key});

  @override
  State<AttendanceApp> createState() => _AttendanceAppState();
}

class _AttendanceAppState extends State<AttendanceApp> {
  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    await MessagingConfig.initFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    return MaterialApp(
      navigatorKey: MessagingConfig.navigatorKey,
      title: 'Attendance App',
      themeMode: darkModeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primaryColor: AppColors.primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashView(),
        'loginScreen': (context) => const LoginScreen(),
        'appHome': (context) => const AppHome(),
        'splashScreen': (context) => const SplashView(),
        'sendNotificationScreen': (context) => const SendNotificationView(),
      },
      initialRoute: 'splashScreen',
    );
  }
}
