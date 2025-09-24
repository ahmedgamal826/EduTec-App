import 'package:attendance_app/features/notifications/data/models/notification_model.dart';
import 'package:attendance_app/features/notifications/data/services/notification_service.dart';
import 'package:flutter/material.dart';

class StudentNotificationsViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _unreadCount = 0;
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  
  StudentNotificationsViewModel() {
    _initNotifications();
    _fetchUnreadCount();
  }
  
  Future<void> _initNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Try to clean up old notifications
      await _notificationService.cleanupOldNotifications();
      
      // Get all notifications for the current user
      _notifications = await _notificationService.getAllUserNotifications();
      
      _isLoading = false;
      _errorMessage = '';
      notifyListeners();
      
      print('Loaded ${_notifications.length} notifications');
    } catch (e) {
      _errorMessage = 'Error loading notifications: $e';
      _isLoading = false;
      notifyListeners();
      print('Error in _initNotifications: $e');
    }
  }
  
  Future<void> _fetchUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadNotificationsCount();
      notifyListeners();
      print('Unread notifications count: $_unreadCount');
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }
  
  Future<void> refreshNotifications() async {
    await _initNotifications();
    await _fetchUnreadCount();
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // Update local list
      final index = _notifications.indexWhere((notification) => notification.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
      
      // Update unread count
      await _fetchUnreadCount();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((notification) => notification.id == notificationId);
      await _fetchUnreadCount();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting notification: $e';
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = '';
    _initNotifications();
    notifyListeners();
  }
} 