import 'package:attendance_app/features/notifications/data/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // إنشاء إشعار جديد
  Future<NotificationModel> createNotification({
    required String subject,
    required String description,
    String? courseId,
    String? type,
    String? deadline,
    List<String>? recipients,
    bool isRead = false,
  }) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final formattedTime = DateFormat('HH:mm').format(now);
      final uuid = const Uuid().v4();
      
      final user = _auth.currentUser;
      String? createdBy = user?.uid;
      String? createdByName;
      
      // الحصول على اسم منشئ الإشعار إذا كان متاحًا
      if (createdBy != null) {
        final userDoc = await _firestore.collection('users').doc(createdBy).get();
        if (userDoc.exists) {
          createdByName = userDoc.data()?['name'];
        }
      }

      final notificationData = {
        'subject': subject,
        'description': description,
        'date': formattedDate,
        'time': formattedTime,
        'courseId': courseId,
        'type': type,
        'createdBy': createdBy,
        'createdByName': createdByName,
        'deadline': deadline,
        'recipients': recipients,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': isRead,
      };

      await _firestore.collection('notifications').doc(uuid).set(notificationData);
      
      return NotificationModel.fromMap(notificationData, uuid);
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  // إنشاء إشعار للواجبات
  Future<NotificationModel> createAssignmentNotification({
    required String courseName,
    required String assignmentName,
    String? courseId,
    String? deadline,
  }) async {
    return createNotification(
      subject: courseName,
      description: 'New assignment added: $assignmentName',
      courseId: courseId,
      type: 'assignment',
      deadline: deadline,
      isRead: false,
    );
  }
  
  // إنشاء إشعار للاختبارات
  Future<NotificationModel> createTestNotification({
    required String courseName,
    required String testName,
    String? courseId,
    String? examDate,
    String? startTime,
  }) async {
    String description = 'New test added: $testName';
    if (examDate != null) {
      description += ' (Date: $examDate';
      if (startTime != null) {
        description += ', Start time: $startTime';
      }
      description += ')';
    }
    
    return createNotification(
      subject: courseName,
      description: description,
      courseId: courseId,
      type: 'test',
      deadline: examDate,
      isRead: false,
    );
  }
  
  // إنشاء إشعار للحضور
  Future<NotificationModel> createAttendanceNotification({
    required String courseName,
    required String studentName,
    required String lectureName,
    required String date,
    required String time,
    String? courseId,
    String? studentId,
  }) async {
    return createNotification(
      subject: 'Attendance Recorded',
      description: 'Your attendance was recorded for $lectureName in $courseName on $date at $time',
      courseId: courseId,
      type: 'attendance',
      recipients: studentId != null ? [studentId] : null,
      isRead: false,
    );
  }
  
  // إنشاء إشعار للمواد الدراسية الجديدة
  Future<NotificationModel> createMaterialNotification({
    required String courseName,
    required String materialName,
    required String lectureName,
    required String date,
    required String time,
    String? courseId,
    List<String>? recipients,
  }) async {
    return createNotification(
      subject: 'New Material Added',
      description: 'New material "$materialName" has been added to $lectureName in $courseName on $date at $time',
      courseId: courseId,
      type: 'material',
      recipients: recipients,
      isRead: false,
    );
  }
  
  // إنشاء إشعار للاستبيانات
  Future<NotificationModel> createQuestionnaireNotification({
    required String courseName,
    required String questionnaireName,
    required String date,
    required String time,
    String? courseId,
    List<String>? recipients,
  }) async {
    return createNotification(
      subject: 'New Questionnaire Added',
      description: 'New questionnaire "$questionnaireName" has been added to $courseName on $date at $time',
      courseId: courseId,
      type: 'questionnaire',
      recipients: recipients,
      isRead: false,
    );
  }
  
  // إرسال إشعار مخصص من الدكتور
  Future<NotificationModel> sendCustomNotification({
    required String title,
    required String message,
    String? courseId,
  }) async {
    try {
      // التحقق من أن المستخدم الحالي هو دكتور
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // التحقق من دور المستخدم
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = userData['role'];
      
      if (userRole != 'Admin' && userRole != 'Doctor' && userRole != 'admin' && userRole != 'doctor') {
        throw Exception('Only administrators and doctors can send notifications');
      }
      
      // الحصول على جميع معرفات الطلاب
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toList();
      
      // إنشاء إشعار مخصص لجميع الطلاب
      final notification = await createNotification(
        subject: title,
        description: message,
        courseId: courseId,
        type: 'custom',
        recipients: studentIds,
        isRead: false,
      );
      
      // إرسال إشعار FCM
      await _sendPushNotificationToStudents(
        title: title,
        body: message,
        courseId: courseId,
        senderName: userData['name'] ?? 'Doctor',
      );
      
      return notification;
    } catch (e) {
      print('Error sending custom notification: $e');
      rethrow;
    }
  }
  
  // إرسال إشعار FCM للطلاب
  Future<void> _sendPushNotificationToStudents({
    required String title,
    required String body,
    String? courseId,
    String? senderName,
  }) async {
    try {
      // الحصول على tokens FCM لجميع الطلاب
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      // استخراج الـ FCM tokens
      final List<String> fcmTokens = [];
      for (var doc in studentsSnapshot.docs) {
        final userData = doc.data();
        if (userData.containsKey('fcmToken') && userData['fcmToken'] != null) {
          fcmTokens.add(userData['fcmToken']);
        }
      }
      
      if (fcmTokens.isEmpty) {
        print('No FCM tokens found for students');
        return;
      }
      
      // إرسال الإشعار لكل token
      for (String token in fcmTokens) {
        await _sendFCMNotification(
          token: token,
          title: title,
          body: body,
          type: 'custom',
          courseId: courseId,
          senderName: senderName,
        );
      }
    } catch (e) {
      print('Error sending FCM notification to students: $e');
    }
  }
  
  // إرسال إشعار FCM
  Future<void> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    required String type,
    String? courseId,
    String? senderName,
  }) async {
    try {
      // استخدام Firebase Cloud Messaging API
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
      
      // استخدام مفتاح خادم FCM (يجب استبداله بمفتاح الخادم الخاص بك)
      const String serverKey = 'AAAAfPZjuO0:APA91bGeGvDVdh9NQsMUd9Nq4LlCgmg_U-P4QmKFBGGf5SQUkdAo3XBX1xEcLLYWy2bSvGEGPj-OspZPvbDUTnvE77fLHv1w_YKG3UdF5aeMwrUhEijgFEVCbFiNd7RVIz8VUt1Yei32';
      
      final now = DateTime.now();
      final formattedTime = DateFormat('HH:mm').format(now);
      
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(<String, dynamic>{
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'android_channel_id': 'high_importance_channel',
            'badge': '1',
            'tag': 'attendance_app_notification',
            'icon': '@mipmap/ic_launcher',
            'color': '#4CAF50',
            'default_sound': true,
            'default_vibrate_timings': true,
            'default_light_settings': true,
          },
          'data': {
            'type': type,
            'courseId': courseId,
            'senderName': senderName,
            'time': formattedTime,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'title': title,
            'body': body,
          },
          'android': {
            'priority': 'high',
            'notification': {
              'notification_priority': 'PRIORITY_MAX',
              'default_sound': true,
              'default_vibrate_timings': true,
              'default_light_settings': true,
              'visibility': 'PUBLIC',
              'channel_id': 'high_importance_channel',
              'tag': 'attendance_app_notification',
              'icon': '@mipmap/ic_launcher',
              'color': '#4CAF50',
            },
          },
          'apns': {
            'headers': {
              'apns-priority': '10',
            },
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
                'content-available': 1,
                'mutable-content': 1,
                'category': 'attendance_app_notification',
                'alert': {
                  'title': title,
                  'body': body,
                },
              }
            }
          },
          'webpush': {
            'headers': {
              'Urgency': 'high',
            },
          },
          'priority': 'high',
          'content_available': true,
        }),
      );
      
      if (response.statusCode == 200) {
        print('Successfully sent FCM notification');
        
        // تحليل الاستجابة
        final responseData = json.decode(response.body);
        final String messageId = responseData['message_id'] ?? '';
        final int success = responseData['success'] ?? 0;
        final int failure = responseData['failure'] ?? 0;
        
        print('FCM Response - Message ID: $messageId, Success: $success, Failure: $failure');
        
        if (failure > 0) {
          // طباعة معلومات الأخطاء إذا كانت موجودة
          final results = responseData['results'];
          if (results != null && results is List) {
            for (var i = 0; i < results.length; i++) {
              if (results[i]['error'] != null) {
                print('FCM Error for token at index $i: ${results[i]['error']}');
              }
            }
          }
        }
      } else {
        print('Failed to send FCM notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  // الحصول على إشعارات المستخدم الحالي
  Stream<List<NotificationModel>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // First check if the user is admin/doctor
    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .asyncMap((userDoc) async {
          if (!userDoc.exists) {
            return <NotificationModel>[];
          }
          
          final userData = userDoc.data() as Map<String, dynamic>;
          final userRole = userData['role']?.toString().toLowerCase() ?? '';
          final isAdminOrDoctor = userRole == 'admin' || userRole == 'doctor';
          
          // If user is admin/doctor, return empty list - admins don't see notifications
          if (isAdminOrDoctor) {
            return <NotificationModel>[];
          }
          
          // Get all notifications for students
          final snapshot = await _firestore.collection('notifications').get();
          final List<NotificationModel> notifications = [];
          
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final List<dynamic>? recipients = data['recipients'] as List<dynamic>?;
            
            // For students, show notifications meant for them
            if ((recipients == null) || (recipients.contains(user.uid))) {
              notifications.add(NotificationModel.fromMap(data, doc.id));
            }
          }
          
          // Sort notifications by date (newest first)
          notifications.sort((a, b) {
            DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.date);
            DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.date);
            int dateComparison = dateB.compareTo(dateA);
            
            // If dates are equal, compare by time
            if (dateComparison == 0 && a.time != null && b.time != null) {
              return b.time!.compareTo(a.time!);
            }
            
            return dateComparison;
          });
          
          return notifications;
        });
  }

  // الحصول على جميع الإشعارات للمستخدم الحالي
  Future<List<NotificationModel>> getAllUserNotifications() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      // Check user role first
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return [];
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = userData['role']?.toString().toLowerCase() ?? '';
      final isAdminOrDoctor = userRole == 'admin' || userRole == 'doctor';
      
      // If user is admin/doctor, return empty list - admins don't see notifications
      if (isAdminOrDoctor) {
        return [];
      }
      
      // Get all notifications for students
      final QuerySnapshot allNotificationsSnapshot = await _firestore
          .collection('notifications')
          .get();

      final List<NotificationModel> notifications = [];
      
      // Filter notifications for students
      for (var doc in allNotificationsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic>? recipients = data['recipients'] as List<dynamic>?;
        
        // For students, show notifications meant for them
        if ((recipients == null) || (recipients.contains(user.uid))) {
          notifications.add(NotificationModel.fromMap(data, doc.id));
        }
      }

      // Sort notifications by date (newest first)
      notifications.sort((a, b) {
        DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.date);
        DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.date);
        int dateComparison = dateB.compareTo(dateA);
        
        // If dates are equal, compare by time
        if (dateComparison == 0 && a.time != null && b.time != null) {
          return b.time!.compareTo(a.time!);
        }
        
        return dateComparison;
      });

      return notifications;
    } catch (e) {
      print('Error getting all user notifications: $e');
      return [];
    }
  }

  // تحديث حالة قراءة الإشعار
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // الحصول على عدد الإشعارات غير المقروءة
  Future<int> getUnreadNotificationsCount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return 0;
    }

    try {
      // Check user role first
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return 0;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = userData['role']?.toString().toLowerCase() ?? '';
      final isAdminOrDoctor = userRole == 'admin' || userRole == 'doctor';
      
      // If user is admin/doctor, return 0 - admins don't have notifications
      if (isAdminOrDoctor) {
        return 0;
      }
      
      // الحصول على جميع الإشعارات
      final QuerySnapshot allNotificationsSnapshot = await _firestore
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      int count = 0;
      
      // تصفية الإشعارات للمستخدم الحالي
      for (var doc in allNotificationsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic>? recipients = data['recipients'] as List<dynamic>?;
        
        // إضافة الإشعارات المخصصة للمستخدم أو الإشعارات العامة
        if ((recipients == null) || 
            (recipients.contains(user.uid))) {
          count++;
        }
      }

      return count;
    } catch (e) {
      print('Error getting unread notifications count: $e');
      return 0;
    }
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // إرسال إشعار لجميع الطلاب
  Future<NotificationModel> sendNotificationToAllStudents({
    required String subject,
    required String description,
    String? courseId,
    String? type,
    String? deadline,
  }) async {
    try {
      // الحصول على جميع معرفات الطلاب
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toList();
      
      // إنشاء إشعار لجميع الطلاب
      return await createNotification(
        subject: subject,
        description: description,
        courseId: courseId,
        type: type,
        deadline: deadline,
        recipients: studentIds,
        isRead: false,
      );
    } catch (e) {
      print('Error sending notification to all students: $e');
      rethrow;
    }
  }
  
  // تنظيف الإشعارات القديمة (أكثر من 30 يومًا)
  Future<void> cleanupOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final formattedDate = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);
      
      final oldNotificationsSnapshot = await _firestore
          .collection('notifications')
          .get();
          
      final batch = _firestore.batch();
      int count = 0;
      
      for (var doc in oldNotificationsSnapshot.docs) {
        final data = doc.data();
        if (data['date'] != null) {
          try {
            final notificationDate = DateFormat('yyyy-MM-dd').parse(data['date']);
            if (notificationDate.isBefore(thirtyDaysAgo)) {
              batch.delete(doc.reference);
              count++;
            }
          } catch (e) {
            // Skip invalid dates
            print('Invalid date format for notification: ${doc.id}');
          }
        }
      }
      
      if (count > 0) {
        await batch.commit();
        print('Cleaned up $count old notifications');
      }
    } catch (e) {
      print('Error cleaning up old notifications: $e');
    }
  }
  
  // التحقق مما إذا كان المستخدم الحالي مسموح له بإرسال إشعارات
  Future<bool> canSendNotifications() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return false;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = userData['role'];
      
      // فقط المسؤولون والدكاترة يمكنهم إرسال إشعارات
      return userRole == 'Admin' || userRole == 'Doctor' || userRole == 'admin' || userRole == 'doctor';
    } catch (e) {
      print('Error checking notification permissions: $e');
      return false;
    }
  }

  // إنشاء إشعار عند تسجيل حضور الطالب
  Future<NotificationModel?> createStudentAttendanceRecordedNotification({
    required String studentId,
    required String courseId,
    required String lectureName,
    required String courseName,
  }) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final formattedTime = DateFormat('HH:mm').format(now);
      
      // إنشاء إشعار للطالب
      final notification = await createNotification(
        subject: 'Attendance Confirmed',
        description: 'Your attendance has been recorded for $lectureName in $courseName',
        courseId: courseId,
        type: 'attendance_confirmation',
        recipients: [studentId],
        isRead: false,
      );
      
      // إرسال إشعار FCM إذا كان لدى الطالب رمز FCM
      final studentDoc = await _firestore.collection('users').doc(studentId).get();
      if (studentDoc.exists) {
        final userData = studentDoc.data() as Map<String, dynamic>;
        final fcmToken = userData['fcmToken'];
        
        if (fcmToken != null && fcmToken.toString().isNotEmpty) {
          await _sendFCMNotification(
            token: fcmToken,
            title: 'Attendance Confirmed',
            body: 'Your attendance has been recorded for $lectureName in $courseName',
            type: 'attendance_confirmation',
            courseId: courseId,
            senderName: 'Attendance System',
          );
        }
      }
      
      return notification;
    } catch (e) {
      print('Error creating attendance notification: $e');
      return null;
    }
  }
} 