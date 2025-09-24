import 'dart:async';
import 'package:attendance_app/features/notifications/data/models/notification_model.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:attendance_app/features/notifications/presentation/manager/messaging_config.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  int _unreadNotificationsCount = 0;
  int get unreadNotificationsCount => _unreadNotificationsCount;
  Timer? _notificationTimer;
  bool _isLoadingNotifications = false;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool _hasNewNotifications = false;
  bool get hasNewNotifications => _hasNewNotifications;
  String _currentUserId = '';
  String get currentUserId => _currentUserId;
  
  // تعيين معرف المستخدم الحالي
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    fetchNotifications();
    _startNotificationTimer();
  }

  // بدء مؤقت لتحديث الإشعارات دوريًا
  void _startNotificationTimer() {
    // إلغاء المؤقت القديم إذا كان موجودًا
    _notificationTimer?.cancel();
    
    // إنشاء مؤقت جديد للتحقق من الإشعارات كل 5 ثوانٍ
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchNotifications(silent: true);
    });
  }

  // جلب الإشعارات من الخادم
  Future<void> fetchNotifications({bool silent = false}) async {
    // تجاهل إذا كان المستخدم غير مسجل الدخول
    if (_currentUserId.isEmpty) {
      return;
    }
    
    // تعيين علم التحميل إذا لم يكن صامتًا
    if (!silent) {
      _isLoadingNotifications = true;
      notifyListeners();
    }
    
    try {
      // جلب الإشعارات من الخادم
      final notifications = await _notificationService.getAllUserNotifications();
      
      // فحص إذا كانت هناك إشعارات جديدة
      final hasNewNotifications = _checkForNewNotifications(_notifications, notifications);
      
      // تحديث القائمة والعداد
      _notifications = notifications;
      _updateUnreadCount();
      
      // تعيين علم الإشعارات الجديدة
      if (hasNewNotifications) {
        _hasNewNotifications = true;
        // إذا كانت هناك إشعارات جديدة، قم بتشغيل إشعار محلي
        if (notifications.isNotEmpty && notifications.any((n) => !n.isRead)) {
          _sendLocalTestNotification();
        }
      }
      
      // تحديث واجهة المستخدم إذا كانت هناك إشعارات جديدة أو لم يكن صامتًا
      if (hasNewNotifications || !silent) {
        _isLoadingNotifications = false;
        notifyListeners();
      }
    } catch (e) {
      print('خطأ في جلب الإشعارات: $e');
      if (!silent) {
        _isLoadingNotifications = false;
        notifyListeners();
      }
    }
  }
  
  // فحص إذا كانت هناك إشعارات جديدة
  bool _checkForNewNotifications(List<NotificationModel> oldList, List<NotificationModel> newList) {
    if (oldList.isEmpty && newList.isNotEmpty) {
      return true;
    }
    
    if (newList.length > oldList.length) {
      return true;
    }
    
    // فحص إذا كانت هناك إشعارات جديدة غير موجودة في القائمة القديمة
    for (final notification in newList) {
      if (!oldList.any((old) => old.id == notification.id)) {
        return true;
      }
    }
    
    return false;
  }
  
  // تحديث عداد الإشعارات غير المقروءة
  void _updateUnreadCount() {
    _unreadNotificationsCount = _notifications.where((notification) => !notification.isRead).length;
  }

  // تعليم جميع الإشعارات كمقروءة
  Future<void> markAllNotificationsAsRead() async {
    try {
      // تعليم كل إشعار كمقروء في قاعدة البيانات
      for (final notification in _notifications) {
        if (!notification.isRead) {
          await _notificationService.markNotificationAsRead(notification.id);
        }
      }
      
      // تحديث حالة الإشعارات محليًا
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      
      // إعادة تعيين علامات الإشعارات الجديدة
      _hasNewNotifications = false;
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      print('خطأ في تعليم جميع الإشعارات كمقروءة: $e');
    }
  }

  // تعليم إشعار محدد كمقروء
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // تحديث حالة الإشعار محليًا
      final index = _notifications.indexWhere((notification) => notification.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print('خطأ في تعليم الإشعار كمقروء: $e');
    }
  }

  // إضافة إشعار جديد إلى القائمة (يستخدم عند استلام إشعار من Firebase)
  void addNotification(NotificationModel notification) {
    // التحقق من عدم وجود الإشعار مسبقًا
    if (!_notifications.any((n) => n.id == notification.id)) {
      _notifications.insert(0, notification);
      _hasNewNotifications = true;
      _updateUnreadCount();
      notifyListeners();
      
      // تشغيل إشعار محلي
      _sendLocalTestNotification();
    }
  }

  // إرسال إشعار محلي اختباري
  Future<void> _sendLocalTestNotification() async {
    try {
      // استخدام MessagingConfig لإرسال إشعار اختباري
      await MessagingConfig.sendTestNotification();
    } catch (e) {
      print('خطأ في إرسال الإشعار الاختباري: $e');
    }
  }

  // إعادة تعيين علامة الإشعارات الجديدة
  void resetNewNotificationsFlag() {
    _hasNewNotifications = false;
    notifyListeners();
  }

  // طريقة للتوافق مع الكود القديم - تحديث عدد الإشعارات غير المقروءة
  Future<void> fetchUnreadNotificationsCount() async {
    try {
      // جلب عدد الإشعارات غير المقروءة من الخادم
      final count = await _notificationService.getUnreadNotificationsCount();
      _unreadNotificationsCount = count;
      notifyListeners();
    } catch (e) {
      print('خطأ في جلب عدد الإشعارات غير المقروءة: $e');
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }
} 