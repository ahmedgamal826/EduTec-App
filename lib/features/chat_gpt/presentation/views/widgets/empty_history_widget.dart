import 'package:attendance_app/core/provider/chat_provider.dart';
import 'package:attendance_app/features/chat_gpt/presentation/manager/Providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return InkWell(
      onTap: () {
        // Navigate to chat room
        final chatProvider = context.read<ChatProvider>();
        chatProvider.prepareChatRoom(chatId: '', newChat: true);
        chatProvider.setCurrentChatId(newChatId: '1');
      },
      child: Center(
        child: Container(
          child: Text(
            'No Found Chat, Start New Chat',
            style: TextStyle(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              color: profileProvider.isDarkMode
                  ? const Color.fromARGB(255, 152, 148, 148)
                  : const Color.fromARGB(255, 97, 95, 95),
            ),
          ),
        ),
      ),
    );
  }
}
