import 'dart:async';
import 'package:attendance_app/core/provider/app_provider.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/chats/presentation/views/home_chats__view.dart';
import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
import 'package:attendance_app/features/home/presentation/views/home_screen.dart';
import 'package:attendance_app/features/profile/presentations/views/user_profile_view.dart';
import 'package:attendance_app/features/chats/presentation/manager/chat_view_model_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> with WidgetsBindingObserver {
  int selectedIndex = 1;
  bool isAdminUser = false;
  bool isLoading = true;
  Timer? _notificationTimer;

  // كل صفحة يتم تحميلها مرة واحدة فقط والاحتفاظ بها
  late final List<Widget> _pageWidgets;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // تهيئة الصفحات مرة واحدة لتجنب إعادة البناء
    _pageWidgets = [
      const HomeChatsView(),
      const HomeScreen(),
      const UserProfileView(),
    ];

    _checkUserRole();
    _startNotificationTimer();
    
    // تعيين معرف المستخدم الحالي في AppProvider
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Provider.of<AppProvider>(context, listen: false).setCurrentUserId(currentUser.uid);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // تحديث الإشعارات عندما يعود التطبيق للواجهة
      _refreshNotifications();
    }
  }

  // بدء مؤقت لتحديث الإشعارات بشكل دوري
  void _startNotificationTimer() {
    // إلغاء المؤقت القديم إذا كان موجوداً
    _notificationTimer?.cancel();
    
    // إنشاء مؤقت جديد للتحقق من الإشعارات كل 3 ثوانٍ
    _notificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshNotifications();
    });
  }

  // تحديث الإشعارات
  void _refreshNotifications() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.fetchNotifications(silent: true);
  }

  Future<void> _checkUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            isAdminUser = userDoc["role"]?.toString().toLowerCase() == "admin";
            isLoading = false;
          });
        } else {
          setState(() {
            isAdminUser = false;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isAdminUser = false;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error in checking role: $e");
      setState(() {
        isAdminUser = false;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام listen: false لمنع إعادة البناء غير الضرورية
    final isDarkMode = Provider.of<DarkModeProvider>(context, listen: false).isDarkMode;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _pageWidgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? const Color(0xff212121) : Colors.white,
        enableFeedback: false,
        items: [
          _buildNavItem(Icons.chat, "Chats", 0, isDarkMode),
          _buildNavItem(Icons.home, "Home", 1, isDarkMode),
          _buildNavItem(Icons.person, "Profile", 2, isDarkMode),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: isDarkMode ? Colors.white : AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        elevation: 15,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index, bool isDarkMode) {
    // إضافة نقطة خضراء للشات عندما تكون هناك رسائل غير مقروءة
    if (index == 0) {  // الشاتات
      // التحقق من وجود رسائل غير مقروءة في الشاتات
      final chatViewModel = Provider.of<ChatViewModel>(context, listen: true);
      bool hasUnreadMessages = chatViewModel.chats.any((chat) => chat.unreadCount > 0);
      
      return BottomNavigationBarItem(
        icon: Stack(
          children: [
            Icon(
              icon,
              size: selectedIndex == index ? 32 : 24,
              color: selectedIndex == index
                  ? (isDarkMode ? Colors.white : AppColors.primaryColor)
                  : Colors.grey.shade600,
            ),
            if (hasUnreadMessages)
              Positioned(
                top: 0,
                right: 0,
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
        label: label,
      );
    }
    
    // بقية الأيقونات بدون نقطة خضراء
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        size: selectedIndex == index ? 32 : 24,
        color: selectedIndex == index
            ? (isDarkMode ? Colors.white : AppColors.primaryColor)
            : Colors.grey.shade600,
      ),
      label: label,
    );
  }
}
