import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/chats/data/models/chat_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatItem({
    super.key,
    required this.chat,
    required this.onTap,
  });

  // تنسيق الوقت بشكل مشابه للواتساب (مثلاً: 10:30 AM)
  // String _formatTo12Hour(DateTime? timestamp) {
  //   if (timestamp == null) return '';

  //   try {
  //     final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
  //     final minute = timestamp.minute.toString().padLeft(2, '0');
  //     final period = timestamp.hour >= 12 ? 'PM' : 'AM';
  //     return '${hour.toString().padLeft(2, '0')}:$minute $period';
  //   } catch (e) {
  //     print('Error formatting timestamp in ChatItem: $timestamp, error: $e');
  //     return '';
  //   }
  // }

  // تنسيق الوقت/التاريخ بناءً على الشرط (Yesterday أو التاريخ الكامل)
  String _formatChatDateTime(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (messageDay == today) {
      return _formatTo12Hour(timestamp); // عرض الوقت إذا كان اليوم
    } else if (messageDay == yesterday) {
      return 'Yesterday';
    } else {
      return '${messageDay.day}/${messageDay.month}/${messageDay.year}';
    }
  }

  // تنسيق الوقت بشكل 12 ساعة
  String _formatTo12Hour(DateTime? timestamp) {
    if (timestamp == null) return '';

    try {
      final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      print('Error formatting timestamp in ChatItem: $timestamp, error: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Last message for chat ${chat.name}: ${chat.lastMessage}');
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // جلب الرسالة الأخيرة من messages
    final lastMessage = chat.messages.isNotEmpty ? chat.messages.last : null;
    final isMe =
        lastMessage != null && lastMessage['senderId'] == currentUserId;
    final isRead = lastMessage != null && lastMessage['isRead'] == true;
    final isLastMessageImage =
        lastMessage != null && lastMessage['isImage'] == true;
    final isLastMessageDocument =
        lastMessage != null && lastMessage['isDocument'] == true;

    // فحص unreadCount للتأكد من أنه عدد صحيح وأكبر من 0
    final unreadCount =
        chat.unreadCount > 0 ? chat.unreadCount : 0;
    print('Unread count for chat ${chat.name} (${chat.id}): $unreadCount');

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.primaryColor,
        child: chat.avatar.isNotEmpty && chat.avatar.startsWith('http')
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: chat.avatar,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  errorWidget: (context, url, error) {
                    print('Error loading avatar in ChatItem: $error');
                    return const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    );
                  },
                ),
              )
            : const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
      ),
      title: Text(
        chat.name,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      subtitle: Row(
        children: [
          if (isMe) ...[
            Icon(
              isRead ? Icons.done_all : Icons.done,
              size: 16,
              color: isRead ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 5),
          ],
          if (isLastMessageImage) ...[
            const Icon(
              Icons.image,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 5),
            const Text(
              'Image',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ] else if (isLastMessageDocument) ...[
            const Icon(
              Icons.description,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                lastMessage['fileName'] != null
                    ? lastMessage['fileName']
                    : 'Document', // نعرض اسم الملف لو موجود، ولو مش موجود نعرض "Document"
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ] else ...[
            Expanded(
              child: Text(
                chat.lastMessage,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            // _formatTo12Hour(chat.timestamp),
            _formatChatDateTime(chat.timestamp), // استخدام الدالة الجديدة
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
