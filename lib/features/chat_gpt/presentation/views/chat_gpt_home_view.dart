import 'package:attendance_app/core/provider/chat_provider.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/core/widgets/show_animated_dialog.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/widgets/bottom_chat_field.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/widgets/chat_gpt_bar.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/widgets/chat_messages_list.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/widgets/no_chats_messages.dart';
import 'package:attendance_app/features/chat_gpt/presentation/manager/Providers/profile_provider.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/chat_history_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatGPTHomeView extends StatefulWidget {
  const ChatGPTHomeView({super.key});

  @override
  State<ChatGPTHomeView> createState() => _ChatGPTHomeViewState();
}

class _ChatGPTHomeViewState extends State<ChatGPTHomeView> {
  final _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(microseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.messagesInChat.isNotEmpty) {
          scrollToBottom();
        }

        // scroll to bottom on new message
        chatProvider.addListener(() {
          if (chatProvider.messagesInChat.isNotEmpty) {
            scrollToBottom();
          }
        });

        return Scaffold(
          backgroundColor: profileProvider.isDarkMode
              ? const Color(0xff1E1E1E)
              : Colors.white,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: profileProvider.isDarkMode
                ? const Color(0xff1E1E1E)
                : AppColors.primaryColor,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Go back to the main app view (root screen)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            title: const ChatHomeAppBar(),
            // actions: [
            //   if (chatProvider.messagesInChat.isNotEmpty)
            //     Padding(
            //       padding: const EdgeInsets.only(right: 5),
            //       child: IconButton(
            //         onPressed: () {
            //           // start new chat
            //           showAnimatedDialog(
            //             title: 'Confirm Addition',
            //             context: context,
            //             description:
            //                 'Are you sure you want to start a new chat with gemini?',
            //             onConfirm: () {
            //               setState(() {
            //                 // start new chat
            //                 chatProvider.prepareChatRoom(
            //                   chatId: '',
            //                   newChat: true,
            //                 );
            //               });
            //             },
            //           );
            //         },
            //         icon: const Icon(
            //           Icons.edit_square,
            //           size: 30,
            //           color: Colors.white,
            //         ),
            //       ),
            //     )
            // ],

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'new_chat') {
                      showAnimatedDialog(
                        title: 'Confirm Addition',
                        context: context,
                        description:
                            'Are you sure you want to start a new chat with gemini?',
                        onConfirm: () {
                          setState(() {
                            chatProvider.prepareChatRoom(
                              chatId: '',
                              newChat: true,
                            );
                          });
                        },
                      );
                    } else if (value == 'chat_history') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatHistoryView(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 28,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'new_chat',
                      child: Row(
                        children: [
                          Icon(Icons.chat, color: Colors.black54),
                          SizedBox(width: 10),
                          Text('New Chat'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'chat_history',
                      child: Row(
                        children: [
                          Icon(Icons.history, color: Colors.black54),
                          SizedBox(width: 10),
                          Text('Chat History'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.messagesInChat.isEmpty
                        ? const NoChatMessages()
                        : ChatMessagesList(
                            scrollController: _scrollController,
                            chatProvider: chatProvider,
                          ),
                  ),
                  BottomChatField(
                    chatProvider: chatProvider,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
