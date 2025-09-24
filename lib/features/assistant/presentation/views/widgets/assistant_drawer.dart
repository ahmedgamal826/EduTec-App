import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/dark_mode_toggle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssistantDrawer extends StatefulWidget {
  const AssistantDrawer({super.key});

  @override
  State<AssistantDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AssistantDrawer> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Drawer(
        child: Center(child: Text("No user logged in.")),
      );
    }

    return Drawer(
      backgroundColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
      child: ListView(
        padding: EdgeInsets.zero,
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
                    color:
                        isDarkMode ? Colors.grey[900] : AppColors.primaryColor,
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              Map<String, dynamic> userData =
                  snapshot.data!.data() as Map<String, dynamic>;
              String name = userData["name"] ?? "Admin";
              String? image = userData['image'];
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : AppColors.primaryColor,
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      backgroundImage: (image != null && image.isNotEmpty)
                          ? NetworkImage(image)
                          : null,
                      child: (image == null || image.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 44,
                              color: Color(0xff70ACF4),
                            )
                          : null,
                    ),
                    SizedBox(height: 6),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
          ListTile(
            leading: Icon(
              Icons.home,
              size: 27,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
            ),
            title: Text(
              "Home",
              style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : AppColors.blackColor),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // ListTile(
          //   leading: const Icon(
          //     Icons.notifications_active,
          //     size: 27,
          //     color: AppColors.primaryColor,
          //   ),
          //   title: const Text(
          //     "Notifications",
          //     style: TextStyle(
          //       fontSize: 18,
          //     ),
          //   ),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => AdminNotifications(),
          //       ),
          //     );
          //   },
          // ),
          const DarkModeToggle(),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 27,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
            ),
            title: Text(
              "Log Out",
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white : AppColors.blackColor,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, "loginScreen");
            },
          ),
        ],
      ),
    );
  }
}
