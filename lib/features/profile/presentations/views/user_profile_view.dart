import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/profile/presentations/views/widgets/info_card.dart';
import 'package:attendance_app/features/profile/presentations/views/widgets/profile_picture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in to view your profile',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.blueAccent.shade700,
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.blueAccent.shade700,
            body: const Center(
              child: Text(
                'User data not found',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final name = userData['name'] ?? 'Unknown User';
        final email = userData['email'] ?? 'No email';
        final imageUrl = userData['image'] ?? '';
        final role = userData['role'] ?? 'User';
        final createdAt = userData['createdAt'] != null
            ? (userData['createdAt'] as Timestamp).toDate()
            : DateTime.now();

        return Scaffold(
          backgroundColor: Colors
              .transparent, // Make Scaffold transparent to show the gradient
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture with Loading Indicator
                      ProfilePicture(imageUrl: imageUrl),
                      const SizedBox(height: 20),
                      // User Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          // shadows: [
                          //   Shadow(
                          //     color: Colors.black26,
                          //     blurRadius: 10,
                          //     offset: Offset(2, 2),
                          //   ),
                          // ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // User Role
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Info Cards (Email, Joined Date, Bio, etc.)
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: InfoCard(
                          icon: Icons.email,
                          title: 'Email',
                          value: email,
                          delay: 200,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 300),
                        child: InfoCard(
                          icon: Icons.person,
                          title: 'Role',
                          value: role,
                          delay: 400,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 500),
                        child: InfoCard(
                          icon: Icons.calendar_today,
                          title: 'Joined Date',
                          value: DateFormat('MMM d, yyyy').format(createdAt),
                          delay: 600,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Logout Button
                      OutlinedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(
                              context, "loginScreen"); // Adjust route as needed
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
