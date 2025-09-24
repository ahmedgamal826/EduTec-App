import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/chats/data/repositories/chat_repository.dart';
import 'package:attendance_app/features/chats/presentation/manager/chat_view_model_provider.dart';
import 'package:attendance_app/features/chats/presentation/views/chat_view.dart';
import 'package:attendance_app/features/chats/presentation/views/new_chat_view.dart';
import 'package:attendance_app/features/chats/presentation/views/user_profile_view.dart';
import 'package:attendance_app/features/chats/presentation/views/widgets/long_press_chat_item.dart';
import 'package:attendance_app/features/chats/presentation/views/widgets/search_chats_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeChatsView extends StatelessWidget {
  const HomeChatsView({super.key});

  Future<Map<String, dynamic>?> _fetchCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userDoc.data();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatViewModel(ChatRepository()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            'Chats',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _fetchCurrentUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfileView(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  final userData = snapshot.data!;
                  final imageUrl =
                      userData['image'] ?? ''; // حقل الصورة في Firestore

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfileView(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      backgroundColor: Colors.white,
                      child: imageUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primaryColor,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<ChatViewModel>(
            builder: (context, viewModel, child) {
              print(
                  'بناء HomeChatsView، عدد المحادثات: ${viewModel.chats.length}');
              for (var chat in viewModel.chats) {
                print('اسم المحادثة: ${chat.name}, ID: ${chat.id}');
              }

              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              if (viewModel.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.listenToChats();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SearchChatsTextField(
                      hintText: 'Search or start a new chat',
                      onChanged: (query) {
                        viewModel.filterChats(query);
                      },
                    ),
                  ),
                  Expanded(
                    child: viewModel.chats.isEmpty
                        ? const Center(
                            child: Text(
                              'No chats found',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: viewModel.chats.length,
                            itemBuilder: (context, index) {
                              final chat = viewModel.chats[index];
                              print(
                                  'عرض ChatItem للمحادثة: ${chat.name}, ID: ${chat.id}');
                              return LongPressChatItem(
                                chat: chat,
                                onTap: () async {
                                  // عند النقر على عنصر المحادثة، انتقل إلى ChatView مع تغليفها بـ Provider
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider.value(
                                        // استخدم نفس نموذج ViewModel الموجود حاليًا
                                        value: viewModel,
                                        child: ChatView(chat: chat),
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  await viewModel.deleteChat(chat.id);
                                  if (viewModel.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(viewModel.errorMessage!)),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "_home_chats_screen",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewChatView(),
              ),
            );
          },
          backgroundColor: AppColors.primaryColor,
          child: const Icon(
            Icons.add_comment_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }
}
