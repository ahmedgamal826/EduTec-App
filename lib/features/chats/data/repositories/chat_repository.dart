import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_app/features/chats/data/models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  /// استرجاع تيار الشاتات للمستخدم الحالي
  Stream<List<ChatModel>> getChatsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatModel.fromFirestore(doc, currentUser.uid);
      }).toList();
    });
  }

  /// إنشاء شات جديد بين المستخدم الحالي ومستخدم آخر
  Future<String> createChat(
      String otherUserId, String name, String email, String avatar) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      // التحقق من وجود شات بين المستخدمين
      final existingChat = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .where('participants', arrayContains: otherUserId)
          .limit(1)
          .get();

      if (existingChat.docs.isNotEmpty) {
        print('المحادثة موجودة بالفعل بين ${currentUser.uid} و $otherUserId');
        return existingChat.docs.first.id; // إرجاع معرف الشات الموجود
      }

      // إنشاء شات جديد
      final chatRef = await _firestore.collection('chats').add({
        'participants': [currentUser.uid, otherUserId],
        'lastMessage': '',
        'avatar': avatar,
        'name': name,
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
        'unreadCounts': {
          currentUser.uid: 0,
          otherUserId: 0,
        },
        'hasCheckmark': false,
        'messages': [],
      });

      print('تم إنشاء محادثة جديدة بمعرف: ${chatRef.id}');
      return chatRef.id;
    } catch (e) {
      print('خطأ في إنشاء المحادثة: $e');
      rethrow;
    }
  }

  /// حذف شات
  Future<void> deleteChat(String chatId) async {
    try {
      await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
    } catch (e) {
      throw Exception('خطأ في حذف المحادثة: $e');
    }
  }

  Future<void> updateChatName(String chatId, String newName) async {
    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();

      final participants = List<String>.from(chatDoc['participants'] ?? []);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      final otherUserId = participants.firstWhere((id) => id != currentUserId,
          orElse: () => '');

      if (otherUserId.isEmpty) {
        throw Exception('لم يتم العثور على مستخدم آخر في المحادثة');
      }

      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'names.$otherUserId': newName, // تحديث اسم المستخدم الآخر
      });

      print('تم تحديث اسم المحادثة لـ $newName في names.$otherUserId');
    } catch (e) {
      print('خطأ في تحديث اسم المحادثة: $e');
      throw Exception('خطأ في تحديث اسم المحادثة: $e');
    }
  }

  /// تحديث اسم المستخدم في collection المستخدمين
  Future<void> updateUserName(String name) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('لا يوجد مستخدم مسجل حاليًا');
      }

      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({
          'name': name,
        });
      } else {
        await docRef.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'name': name,
          'image': user.photoURL ?? '',
        });
      }
      print('تم تحديث اسم المستخدم إلى: $name');
    } catch (e) {
      print('خطأ في تحديث اسم المستخدم: $e');
      rethrow;
    }
  }

  /// إضافة رسالة جديدة إلى الشات
  Future<void> updateMessages(
      String chatId, Map<String, dynamic> message, String recipientId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'messages': FieldValue.arrayUnion([
          {
            ...message,
            'isRead': false, // إضافة isRead للرسالة الجديدة
          }
        ]),
        'lastMessage': message['isImage'] ? 'Photo' : message['text'],
        'timestamp': FieldValue.serverTimestamp(),
        'unreadCounts.$recipientId': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('خطأ في إرسال الرسالة: $e');
    }
  }

  Future<void> deleteMessage(
      String chatId, String messageId, String senderId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }
      if (currentUser.uid != senderId) {
        throw Exception('لا يمكنك حذف رسالة ليست لك');
      }

      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();
      final messages =
          List<Map<String, dynamic>>.from(chatDoc['messages'] ?? []);

      final updatedMessages =
          messages.where((msg) => msg['messageId'] != messageId).toList();

      String lastMessage = '';
      Timestamp? lastTimestamp;
      if (updatedMessages.isNotEmpty) {
        final lastMsg = updatedMessages.last;
        lastMessage = lastMsg['isImage'] == true ? 'Photo' : lastMsg['text'];
        lastTimestamp = lastMsg['time'] != null
            ? Timestamp.fromDate(DateTime.parse(lastMsg['time']))
            : Timestamp.now();
      }

      // تحديث المحادثة في Firestore
      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'messages': updatedMessages,
        'lastMessage': lastMessage,
        'timestamp': lastTimestamp ??
            chatDoc['timestamp'], // الإبقاء على timestamp القديم لو مفيش رسائل
      });
    } catch (e) {
      throw Exception('خطأ في حذف الرسالة: $e');
    }
  }

  /// التحقق من وجود شات بين المستخدم الحالي ومستخدم آخر
  Future<bool> checkIfChatExists(
      String currentUserId, String otherUserId) async {
    try {
      // استخدام arrayContains مرة واحدة بس للمستخدم الحالي
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      // فحص النتايج يدويًا للتأكد إن المستخدم الآخر موجود
      for (var doc in querySnapshot.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(otherUserId)) {
          return true; // الشات موجود
        }
      }
      return false; // الشات مش موجود
    } catch (e) {
      throw Exception('خطأ أثناء التحقق من وجود المحادثة: $e');
    }
  }

  Future<void> addChatWithUser(String email, String name, String image) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      // جلب بيانات المستخدم الحالي
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final currentUserName = currentUserDoc['name'] ?? currentUser.email ?? '';
      final currentUserImage = currentUserDoc['image'] ?? '';

      // جلب بيانات المستخدم الآخر بناءً على الإيميل
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      final otherUserId = userQuery.docs.first.id;
      final otherUserName = userQuery.docs.first['name'] ?? email;
      final otherUserImage = userQuery.docs.first['image'] ?? '';

      final chatExists = await checkIfChatExists(currentUser.uid, otherUserId);
      if (chatExists) {
        throw Exception('توجد محادثة مع هذا البريد الإلكتروني بالفعل');
      }

      // إنشاء شات جديد
      final chatRef = FirebaseFirestore.instance.collection('chats').doc();
      final chatData = {
        'participants': [currentUser.uid, otherUserId],
        'unreadCounts': {
          currentUser.uid: 0,
          otherUserId: 0,
        },
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
        'names': {
          currentUser.uid: currentUserName,
          otherUserId: name.isEmpty ? otherUserName : name,
        },
        'avatars': {
          currentUser.uid: currentUserImage,
          otherUserId: image.isEmpty ? otherUserImage : image,
        },
        'email': email, // إضافة الإيميل هنا
        'messages': [],
      };

      await chatRef.set(chatData);
    } catch (e) {
      print('خطأ أثناء إضافة المحادثة: $e');
    }
  }

  /// جلب بيانات المستخدم بناءً على الإيميل
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return {
          'uid': querySnapshot.docs.first.id,
          'image': querySnapshot.docs.first['image'] ?? '',
          'name': querySnapshot.docs.first['name'] ?? '',
        };
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب المستخدم بالبريد: $e');
    }
  }

  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    try {
      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();
      final messages =
          List<Map<String, dynamic>>.from(chatDoc['messages'] ?? []);

      // تحديث حالة القراءة للرسائل اللي مش من المستخدم الحالي
      final updatedMessages = messages.map((msg) {
        if (msg['senderId'] != currentUserId && !(msg['isRead'] ?? false)) {
          return {...msg, 'isRead': true};
        }
        return msg;
      }).toList();

      // تحديث الرسائل وإعادة تعيين unreadCounts للمستخدم الحالي بس
      await chatRef.update({
        'messages': updatedMessages,
        'unreadCounts.$currentUserId': 0, // استخدام dot notation
      });

      print('تم تحديث حالة القراءة للرسائل في المحادثة: $chatId');
    } catch (e) {
      print('خطأ أثناء تحديث حالة الرسائل: $e');
      throw Exception('خطأ أثناء تحديث حالة الرسائل: $e');
    }
  }

  /// إعادة تعيين عدد الرسائل غير المقروءة
  Future<void> resetUnreadCount(String chatId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'unreadCounts.${currentUser.uid}': 0,
      });
    } catch (e) {
      throw Exception('خطأ أثناء إعادة تعيين عدد الرسائل غير المقروءة: $e');
    }
  }

  ///////////////////////////////
  // Send a message to Firestore
//   Future<void> sendMessage(
//       String chatId, Map<String, dynamic> messageData) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('users_chats')
//           .doc(chatId)
//           .collection('messages')
//           .doc(messageData['messageId'])
//           .set(messageData);
//     } catch (e) {
//       throw Exception('Failed to send message: $e');
//     }
//   }
// }
}
