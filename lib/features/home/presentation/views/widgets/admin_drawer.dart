import 'package:attendance_app/core/provider/app_provider.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
import 'package:attendance_app/features/home/presentation/views/student_attendance.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/dark_mode_toggle.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/open_camera_screen.dart';
import 'package:attendance_app/features/notifications/presentation/views/admin_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  @override
  void initState() {
    super.initState();
    // Update unread notifications count when drawer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchUnreadNotificationsCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Drawer(
        child: Center(child: Text("No user logged in.")),
      );
    }
    
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final appProvider = Provider.of<AppProvider>(context);
    
    return Drawer(
      backgroundColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
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
                      color: isDarkMode
                          ? AppColors.blackColor
                          : AppColors.primaryColor,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode
                            ? AppColors.whiteColor
                            : AppColors.primaryColor,
                      ),
                    ),
                  );
                }

                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                String name = userData["name"] ?? "Admin";
                String? image = userData['image'];
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.blackColor
                        : AppColors.primaryColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: (image != null && image.isNotEmpty)
                            ? NetworkImage(image)
                            : null,
                        child: (image == null || image.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 45,
                                color: Color(0xff70ACF4),
                              )
                            : null,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
            _buildListTile(
              icon: Icons.home,
              title: "Home",
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _buildListTile(
              icon: Icons.notifications_active,
              title: "Notifications",
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminNotifications(),
                  ),
                );
              },
            ),

            const DarkModeToggle(),

            const Divider(height: 1),

            _buildListTile(
              icon: Icons.logout,
              title: "Log Out",
              isDarkMode: isDarkMode,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "loginScreen");
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(
        icon,
        size: 25,
        color: isDarkMode ? AppColors.whiteColor : AppColors.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? AppColors.whiteColor : AppColors.blackColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
