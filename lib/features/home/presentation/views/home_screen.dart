// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/admin_drawer.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/join_team_dialog.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/student_drawer.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   TextEditingController searchController = TextEditingController();
//   List<Map<String, String>> subjects = [
//     {
//       "title": "Subject 1",
//       "year": "Fourth Year",
//       "date": "12/03/2025",
//       "lecturer": "Dr/ Ahmed Elnemr"
//     },
//     {
//       "title": "Subject 2",
//       "year": "Third Year",
//       "date": "15/03/2025",
//       "lecturer": "Dr/ Ahmed Beherry"
//     },
//     {
//       "title": "Subject 3",
//       "year": "Second Year",
//       "date": "20/03/2025",
//       "lecturer": "Dr/ Ahmed Elnemr"
//     },
//     {
//       "title": "Subject 2",
//       "year": "Third Year",
//       "date": "15/03/2025",
//       "lecturer": "Dr/ Ahmed Beherry"
//     },
//   ];
//   List<Map<String, String>> filteredSubjects = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredSubjects = subjects;
//   }

//   void filterSubjects(String query) {
//     setState(() {
//       filteredSubjects = subjects
//           .where((subject) =>
//               subject["title"]!.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   Future<bool> isAdmin() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .get();
//       return userDoc["role"] == "admin";
//     }
//     return false;
//   }

//   int selectedIndex = 1;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: isAdmin(),
//       builder: (context, snapshot) {
//         bool isAdmin = snapshot.data ?? false;
//         return Scaffold(
//           backgroundColor: AppColors.whiteColor,
//           drawer: isAdmin ? const AdminDrawer() : const StudentDrawer(),
//           appBar: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             centerTitle: true,
//             title: Text(
//               isAdmin ? "Admin Home Screen" : "Student Home Screen",
//               style: const TextStyle(
//                 fontSize: 22, // تقليل الحجم قليلاً ليكون أكثر تناسقًا
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             backgroundColor: AppColors.primaryColor,
//             actions: [
//               if (!isAdmin) // Student
//                 Padding(
//                   padding: const EdgeInsets.only(right: 12),
//                   child: GestureDetector(
//                     onTap: () {
//                       JoinTeamDialog.show(context);
//                     },
//                     child: CircleAvatar(
//                       radius: 20,
//                       backgroundColor: Colors.white.withOpacity(0.2),
//                       child: const Icon(
//                         Icons.add,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       )
//                     ],
//                   ),
//                   child: TextField(
//                     cursorColor: AppColors.primaryColor,
//                     controller: searchController,
//                     onChanged: filterSubjects,
//                     decoration: InputDecoration(
//                       hintText: "Search for subjects...",
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                       border: InputBorder.none,
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide:
//                             const BorderSide(color: Colors.grey, width: 1),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(
//                             color: AppColors.primaryColor, width: 2),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 15, horizontal: 10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: filteredSubjects.length,
//                     itemBuilder: (context, index) {
//                       return LayoutBuilder(
//                         builder: (context, constraints) {
//                           double cardHeight = constraints.maxWidth *
//                               0.4; // ارتفاع متناسب مع العرض
//                           double fontSizeTitle =
//                               constraints.maxWidth * 0.06; // حجم العنوان متناسب
//                           double fontSizeSubtitle =
//                               constraints.maxWidth * 0.04; // حجم النصوص الفرعية

//                           return Card(
//                             elevation: 5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Stack(
//                                 children: [
//                                   // صورة الخلفية
//                                   Image.asset(
//                                     "assets/images/1.jpg",
//                                     fit: BoxFit.cover,
//                                     width: double.infinity,
//                                     height: cardHeight, // ارتفاع ديناميكي
//                                   ),

//                                   // تدرج شفاف فوق الصورة
//                                   Container(
//                                     height: cardHeight,
//                                     decoration: BoxDecoration(
//                                       color: Colors.black.withOpacity(0.6),
//                                     ),
//                                   ),

//                                   // النصوص فوق الصورة
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 16.0, vertical: 12),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           width: constraints.maxWidth *
//                                               0.75, // تقليل العرض لتجنب overflow
//                                           child: Text(
//                                             filteredSubjects[index]["title"]!,
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                               fontSize: fontSizeTitle,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 6),

//                                         // السنة
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               right: 8.0), // مسافة من اليمين
//                                           child: Text(
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             filteredSubjects[index]["year"]!,
//                                             style: TextStyle(
//                                               fontSize: fontSizeSubtitle,
//                                               fontWeight: FontWeight.w500,
//                                               color:
//                                                   Colors.white.withOpacity(0.9),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                                   // اسم الدكتور في الأسفل
//                                   Positioned(
//                                     bottom: 8,
//                                     left: 12,
//                                     right: 20, // إعطاء مساحة من اليمين
//                                     child: Text(
//                                       filteredSubjects[index]["lecturer"]!,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         fontSize: fontSizeSubtitle,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.white.withOpacity(0.9),
//                                       ),
//                                     ),
//                                   ),

//                                   // زر الخيارات الثلاثية
//                                   Positioned(
//                                     top: 8,
//                                     right: 8,
//                                     child: IconButton(
//                                       icon: const Icon(Icons.more_vert,
//                                           color: Colors.white),
//                                       onPressed: () {},
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           floatingActionButton: isAdmin
//               ? FloatingActionButton(
//                   onPressed: () {},
//                   backgroundColor: AppColors.primaryColor,
//                   child: const Icon(
//                     Icons.add,
//                     color: Colors.white,
//                   ),
//                 )
//               : null,
//         );
//       },
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/home/presentation/views/admin_home_screen.dart';
import 'package:attendance_app/features/home/presentation/views/student_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<bool> isAdminOrDoctor() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      String role = userDoc["role"]?.toString().toLowerCase() ?? '';
      return role == "admin" || role == "doctor";
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAdminOrDoctor(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

        bool isAdminOrDoctor = snapshot.data ?? false;
        return isAdminOrDoctor ? const AdminHomeScreen() : const StudentHomeScreen();
      },
    );
  }
}
