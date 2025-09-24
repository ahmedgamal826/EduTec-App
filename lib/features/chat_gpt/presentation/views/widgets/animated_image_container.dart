import 'package:attendance_app/features/chat_gpt/presentation/manager/Providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedImageContatiner extends StatelessWidget {
  const AnimatedImageContatiner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Center(
      child: GestureDetector(
        onTap: () async {
          await profileProvider.pickImage();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            image: profileProvider.image != null
                ? DecorationImage(
                    image: FileImage(profileProvider.image!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: profileProvider.image == null
              ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
