import 'dart:async';
import 'package:attendance_app/core/provider/app_provider.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/chat_gpt_home_view.dart';
import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/dark_mode_toggle.dart';
import 'package:attendance_app/features/notifications/presentation/views/student_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/features/chat_gpt/presentation/manager/Providers/profile_provider.dart';
import 'package:attendance_app/core/provider/chat_provider.dart';

class StudentDrawer extends StatefulWidget {
  const StudentDrawer({super.key});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> with WidgetsBindingObserver {
  bool isDarkMode = false;
  Timer? _notificationTimer;
  bool _isDrawerOpen = false;
  int _lastNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // التحقق من الإشعارات عند فتح الدرج
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isDrawerOpen = true;
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      _lastNotificationCount = appProvider.unreadNotificationsCount;
      appProvider.fetchNotifications();
      
      // بدء مؤقت لتحديث الإشعارات بشكل دوري أثناء فتح الدرج
      _startNotificationTimer();
    });
  }
  
  // بدء مؤقت لتحديث الإشعارات بشكل دوري
  void _startNotificationTimer() {
    // إلغاء المؤقت القديم إذا كان موجوداً
    _notificationTimer?.cancel();
    
    // إنشاء مؤقت جديد للتحقق من الإشعارات كل 3 ثوانٍ
    _notificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isDrawerOpen && mounted) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        appProvider.fetchNotifications(silent: true);
      }
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // عند استئناف التطبيق وكان الدرج مفتوحًا، نقوم بتحديث الإشعارات
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isDrawerOpen && mounted) {
      Provider.of<AppProvider>(context, listen: false).fetchNotifications();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationTimer?.cancel();
    _isDrawerOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Drawer(
        child: Center(child: Text("No user logged in.")),
      );
    }

    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final appProvider = Provider.of<AppProvider>(context);

    return Drawer(
      backgroundColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.blackColor
                          : AppColors.primaryColor,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode
                            ? AppColors.whiteColor
                            : AppColors.primaryColor,
                      ),
                    ),
                  );
                }
                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                String name = userData["name"] ?? "Student";
                String? imageUrl =
                    userData["image"]; // Get profile image from Firestore

                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.blackColor
                        : AppColors.primaryColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45, // تقليل حجم الصورة
                        backgroundColor: Colors.white,
                        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                            ? NetworkImage(imageUrl)
                            : null,
                        child: (imageUrl == null || imageUrl.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 45, // تقليل حجم الأيقونة
                                color: Color(0xff70ACF4),
                              )
                            : null,
                      ),
                      const SizedBox(height: 5), // تقليل المسافة
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20, // تقليل حجم الخط
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildListTile(
              icon: Icons.home,
              title: "Home",
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildListTile(
              icon: Icons.psychology,
              title: "ChatGPT",
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                            create: (context) => ProfileProvider()),
                        ChangeNotifierProvider(
                            create: (context) => ChatProvider()),
                      ],
                      child: const ChatGPTHomeView(),
                    ),
                  ),
                );
              },
            ),
            _buildNotificationTile(
              appProvider: appProvider,
              isDarkMode: isDarkMode,
              context: context,
            ),
            const DarkModeToggle(),
            const Divider(height: 1), // تقليل ارتفاع الخط الفاصل
            _buildListTile(
              icon: Icons.logout,
              title: "Log Out",
              isDarkMode: isDarkMode,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "loginScreen");
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // استخراج ListTile إلى دالة منفصلة لتحسين إعادة الاستخدام
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -1), // تقليل المساحة الرأسية
      leading: Icon(
        icon,
        size: 25, // تقليل حجم الأيقونة
        color: isDarkMode ? AppColors.whiteColor : AppColors.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16, // تقليل حجم الخط
          color: isDarkMode ? AppColors.whiteColor : AppColors.blackColor,
        ),
      ),
      onTap: onTap,
    );
  }
  
  // استخراج ListTile الإشعارات إلى دالة منفصلة
  Widget _buildNotificationTile({
    required AppProvider appProvider,
    required bool isDarkMode,
    required BuildContext context,
  }) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -1), // تقليل المساحة الرأسية
      leading: Stack(
        children: [
          Icon(
            Icons.notifications_active,
            size: 25, // تقليل حجم الأيقونة
            color: isDarkMode ? AppColors.whiteColor : AppColors.primaryColor,
          ),
          if (appProvider.unreadNotificationsCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8, // تقليل حجم النقطة الخضراء
                height: 8, // تقليل حجم النقطة الخضراء
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Text(
            "Notifications",
            style: TextStyle(
              fontSize: 16, // تقليل حجم الخط
              color: isDarkMode ? AppColors.whiteColor : AppColors.blackColor,
            ),
          ),
          const SizedBox(width: 5), // تقليل المسافة
          if (appProvider.unreadNotificationsCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), // تقليل الحشو
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8), // تقليل نصف القطر
              ),
              child: Text(
                appProvider.unreadNotificationsCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10, // تقليل حجم الخط
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        // Force refresh notifications count before navigating
        Provider.of<AppProvider>(context, listen: false)
            .fetchUnreadNotificationsCount();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentNotifications(),
          ),
        ).then((_) {
          // Update unread notifications count after returning from notifications page
          Provider.of<AppProvider>(context, listen: false)
              .fetchUnreadNotificationsCount();
        });
      },
    );
  }
}
