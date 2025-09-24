// // role_selection.dart

// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:flutter/material.dart';

// class RoleSelection extends StatelessWidget {
//   final String _role;
//   final ValueChanged<String> onChanged;

//   RoleSelection({
//     required String role,
//     required this.onChanged,
//   }) : _role = role;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // استخدام MediaQuery لمعرفة العرض الحالي
//         Text(
//           "Role: ",
//           style: TextStyle(
//             fontSize: MediaQuery.of(context).size.width > 600
//                 ? 23
//                 : 18, // بناءً على العرض
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         const SizedBox(width: 20),
//         Radio<String>(
//           value: "Admin",
//           groupValue: _role,
//           activeColor: AppColors.primaryColor,
//           onChanged: (value) {
//             onChanged(value!);
//           },
//         ),
//         Text(
//           "Admin",
//           style: TextStyle(
//             fontSize: MediaQuery.of(context).size.width > 600
//                 ? 23
//                 : 18, // بناءً على العرض
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(width: 20),
//         Radio<String>(
//           value: "Student",
//           groupValue: _role,
//           activeColor: AppColors.primaryColor,
//           onChanged: (value) {
//             onChanged(value!);
//           },
//         ),
//         Text(
//           "Student",
//           style: TextStyle(
//             fontSize: MediaQuery.of(context).size.width > 600
//                 ? 23
//                 : 18, // بناءً على العرض
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class RoleSelection extends StatelessWidget {
  final String _role;
  final ValueChanged<String> onChanged;
  final bool enabled; // إضافة الخاصية enabled

  const RoleSelection({super.key, 
    required String role,
    required this.onChanged,
    this.enabled = true, // افتراضيًا سيكون ممكن التفاعل
  }) : _role = role;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // استخدام MediaQuery لمعرفة العرض الحالي
        Text(
          "Role: ",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600
                ? 23
                : 18, // بناءً على العرض
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 20),
        // Radio button for Admin
        Radio<String>(
          value: "Admin",
          groupValue: _role,
          activeColor: AppColors.primaryColor,
          onChanged: enabled
              ? (value) {
                  onChanged(value!);
                }
              : null, // إذا كانت enabled=false، لا يتم تفعيل ال onChanged
        ),
        Text(
          "Admin",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600
                ? 23
                : 18, // بناءً على العرض
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 20),
        // Radio button for Student
        Radio<String>(
          value: "Student",
          groupValue: _role,
          activeColor: AppColors.primaryColor,
          onChanged: enabled
              ? (value) {
                  onChanged(value!);
                }
              : null, // إذا كانت enabled=false، لا يتم تفعيل ال onChanged
        ),
        Text(
          "Student",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600
                ? 23
                : 18, // بناءً على العرض
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
