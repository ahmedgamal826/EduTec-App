import 'package:attendance_app/features/auth/presentations/views/widget/show_snack_bar.dart';
import 'package:attendance_app/features/chat_gpt/presentation/manager/Providers/profile_provider.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/widgets/animated_image_container.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/widgets/animation_button.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/widgets/custom_profile_list_tiles.dart';
import 'package:attendance_app/features/chat_gpt/presentation/views/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor:
          profileProvider.isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: profileProvider.isDarkMode
            ? Colors.grey[900]
            : Colors.blueAccent.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              profileProvider.isDarkMode
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
              color: Colors.white,
            ),
            onPressed: () {
              profileProvider.toggleDarkMode();
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const AnimatedImageContatiner(),
                const SizedBox(height: 20),
                CustomTextField(
                  context,
                  label: 'Name',
                  controller: TextEditingController(text: profileProvider.name),
                  onChanged: (value) {
                    profileProvider.name = value;
                  },
                  isDarkMode: profileProvider.isDarkMode,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  context,
                  label: 'Email',
                  controller:
                      TextEditingController(text: profileProvider.email),
                  onChanged: (value) {
                    profileProvider.email = value;
                  },
                  isDarkMode: profileProvider.isDarkMode,
                ),
                const SizedBox(height: 20),
                CustomProfileListTiles(
                  onDeleteAllPressed: () {
                    profileProvider.clearProfileData();
                  },
                  context,
                  title: 'Dark Mode',
                  value: profileProvider.isDarkMode,
                  onChanged: (value) {
                    profileProvider.toggleDarkMode();
                  },
                  isDarkMode: profileProvider.isDarkMode,
                ),
                const SizedBox(height: 50),
                AnimatedButton(
                  onPressed: () async {
                    await profileProvider.saveUserData();

                    CustomSnackBar.showSuccessSnackBar(
                        context, 'Changes saved successfully!');
                  },
                  isDarkMode: profileProvider.isDarkMode,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
