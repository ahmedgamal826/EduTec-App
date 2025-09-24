// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:flutter/material.dart';

// class DescriptionTextField extends StatelessWidget {
//   const DescriptionTextField({
//     super.key,
//     required this.controller,
//   });

//   final TextEditingController controller;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           )
//         ],
//       ),
//       child: TextField(
//         controller: controller,
//         maxLines: 5,
//         cursorColor: AppColors.primaryColor,
//         decoration: InputDecoration(
//           labelText: "Description",
//           labelStyle: const TextStyle(color: Colors.black),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.grey, width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide:
//                 const BorderSide(color: AppColors.primaryColor, width: 2),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 15, horizontal: 10),

//         ),

//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:attendance_app/core/utils/app_colors.dart';

class DescriptionTextField extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      cursorColor: AppColors.primaryColor,
      decoration: InputDecoration(
        labelText: "Description",
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Description is required";
        }
        return null;
      },
    );
  }
}
