// import 'dart:async';
// import 'package:attendance_app/features/auth/presentations/views/admin_or_student.dart';
// import 'package:attendance_app/features/auth/presentations/views/login_screen.dart';
// import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/action_buttons_onboarding.dart';
// import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/build_description_setion.dart';
// import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/build_image_section.dart';
// import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/build_title_section.dart';
// import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/custom_indicator.dart';
// import 'package:flutter/material.dart';
//
// class OnboardScreen extends StatefulWidget {
//   const OnboardScreen({super.key});
//
//   @override
//   State<OnboardScreen> createState() => _OnboardScreenState();
// }
//
// class _OnboardScreenState extends State<OnboardScreen> {
//   int index = 0;
//   bool isOut = false;
//
//   List<String> images = [
//     'assets/images/1.jpg',
//     'assets/images/Materials_boarding.jpg',
//     'assets/images/tests.jpeg',
//   ];
//
//   List<String> titles = [
//     'Smart Attendance Tracking',
//     'Access Study Materials',
//     'Stay on Top of Your Tasks',
//   ];
//
//   List<String> descriptions = [
//     "Automatically track your daily attendance. No more manual check-ins!",
//     "Find all your course materials in one place. Study anytime, anywhere!",
//     "Manage your tests and assignments effortlessly. Get reminders and submit on time!",
//   ];
//
//   void _nextPage() {
//     setState(() {
//       isOut = !isOut;
//     });
//     Timer(const Duration(milliseconds: 300), () {
//       setState(() {
//         isOut = !isOut;
//         if (index == 2) {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const LoginScreen(),
//             ),
//             (route) => false,
//           );
//         }
//         index = index > 1 ? 2 : index + 1;
//       });
//     });
//   }
//
//   void _backPage() {
//     setState(() {
//       if (index > 0) {
//         isOut = !isOut;
//         Timer(const Duration(milliseconds: 300), () {
//           setState(() {
//             isOut = !isOut;
//             index--;
//           });
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               ImageSection(
//                 image: images[index],
//                 isOut: isOut,
//               ),
//               TitleSection(
//                 title: titles[index],
//                 isOut: isOut,
//               ),
//               DescriptionSection(
//                 description: descriptions[index],
//                 isOut: isOut,
//               ),
//               buildIndicators(),
//               ActionButtons(
//                 index: index,
//                 isOut: isOut,
//                 onNext: _nextPage,
//                 onBack: _backPage,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildIndicators() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CustomIndicator(active: index == 0),
//         const SizedBox(width: 8),
//         CustomIndicator(active: index == 1),
//         const SizedBox(width: 8),
//         CustomIndicator(active: index == 2),
//       ],
//     );
//   }
// }




import 'dart:async';
import 'package:attendance_app/features/auth/presentations/views/login_screen.dart';
import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/action_buttons_onboarding.dart';
import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/build_description_setion.dart';
import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/build_image_section.dart';
import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/build_title_section.dart';
import 'package:attendance_app/features/on%20boarding/presentation/views/widgets/custom_indicator.dart';
import 'package:flutter/material.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int index = 0;
  bool isOut = false;

  List<String> images = [
    'assets/images/1.jpg',
    'assets/images/Materials_boarding.jpg',
    'assets/images/tests.jpeg',
  ];

  List<String> titles = [
    'Smart Attendance Tracking',
    'Access Study Materials',
    'Stay on Top of Your Tasks',
  ];

  List<String> descriptions = [
    "Automatically track your daily attendance. No more manual check-ins!",
    "Find all your course materials in one place. Study anytime, anywhere!",
    "Manage your tests and assignments effortlessly. Get reminders and submit on time!",
  ];

  void _nextPage() {
    setState(() {
      isOut = !isOut;
    });
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        isOut = !isOut;
        if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
                (route) => false,
          );
        }
        index = index > 1 ? 2 : index + 1;
      });
    });
  }

  void _backPage() {
    setState(() {
      if (index > 0) {
        isOut = !isOut;
        Timer(const Duration(milliseconds: 300), () {
          setState(() {
            isOut = !isOut;
            index--;
          });
        });
      }
    });
  }

  void _skipOnboarding() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  ImageSection(
                    image: images[index],
                    isOut: isOut,
                  ),
                  TitleSection(
                    title: titles[index],
                    isOut: isOut,
                  ),
                  DescriptionSection(
                    description: descriptions[index],
                    isOut: isOut,
                  ),
                  buildIndicators(),
                  ActionButtons(
                    index: index,
                    isOut: isOut,
                    onNext: _nextPage,
                    onBack: _backPage,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: InkWell(
                onTap: _skipOnboarding,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIndicator(active: index == 0),
        const SizedBox(width: 8),
        CustomIndicator(active: index == 1),
        const SizedBox(width: 8),
        CustomIndicator(active: index == 2),
      ],
    );
  }
}