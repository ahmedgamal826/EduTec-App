// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/splash/data/splash_logic.dart';
// import 'package:attendance_app/features/splash/presentation/views/widgets/animated_text.dart';
// import 'package:flutter/material.dart';

// class SplashView extends StatelessWidget {
//   const SplashView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/images/4.png',
//               height: MediaQuery.of(context).size.height * 0.4,
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(height: 20),
//             AnimatedText(
//               onFinished: () => SplashLogic.NavigateToChatHomeView(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/splash/data/splash_logic.dart';
import 'package:attendance_app/features/splash/presentation/views/widgets/animated_text.dart';
import 'package:attendance_app/features/splash/presentation/views/widgets/logo_animation.dart';
import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
              Colors.blueAccent.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              LogoAnimation(
                width: size.width,
                height: size.height,
              ),
              // Animated Text
              AnimatedText(
                onFinished: () => SplashLogic.NavigateToChatHomeView(context),
              ),
              const SizedBox(height: 40),
              // Circular loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
