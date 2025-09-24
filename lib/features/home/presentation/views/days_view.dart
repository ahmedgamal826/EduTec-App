// import 'package:attendance_app/features/attendance/presentation/views/student_attendance_view.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';

// class DaysScreen extends StatelessWidget {
//   final String month;
//   final int daysInMonth;

//   DaysScreen({
//     required this.month,
//     required this.daysInMonth,
//   });

//   @override
//   Widget build(BuildContext context) {
//     int year = 2025;
//     DateTime now = DateTime.now();
//     int monthNumber = monthsToNumber(month);

//     List<DateTime> dates = List.generate(
//       daysInMonth,
//       (index) => DateTime(year, monthNumber, index + 1),
//     );

//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.calendar_today, color: Colors.white, size: 28),
//             const SizedBox(width: 10),
//             Text(
//               "$month Days",
//               style: const TextStyle(
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xff70ACF4),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             mainAxisSpacing: 15,
//             childAspectRatio: 1,
//           ),
//           itemCount: dates.length,
//           itemBuilder: (context, index) {
//             DateTime date = dates[index];
//             bool isToday = date.day == now.day &&
//                 date.month == now.month &&
//                 date.year == now.year;
//             bool isPast = date.isBefore(now);
//             String dayName = DateFormat('EEEE').format(date);

//             return GestureDetector(
//               onTap: () {
//                 if (dayName == "Friday") {
//                   _showDialog(
//                     context,
//                     "Friday is a holiday!",
//                     "There are no classes on Friday. Enjoy your weekend! 🎉",
//                     DialogType.info,
//                     Colors.blue,
//                   );
//                 } else if (isToday || isPast) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => StudentAttendanceView(date: date),
//                     ),
//                   );
//                 } else {
//                   _showDialog(
//                     context,
//                     "Invalid Date",
//                     "This day has not arrived yet!",
//                     DialogType.warning,
//                     Colors.red,
//                   );
//                 }
//               },
//               child: Card(
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 color: isToday ? Colors.green : const Color(0xff70ACF4),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     gradient: isToday
//                         ? const LinearGradient(
//                             colors: [Colors.green, Colors.lightGreen],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           )
//                         : const LinearGradient(
//                             colors: [Color(0xff70ACF4), Color(0xff5A9EE0)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.calendar_today,
//                         color: Colors.white,
//                         size: 28,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         dayName,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         DateFormat('dd/MM').format(date),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _showDialog(BuildContext context, String title, String desc,
//       DialogType type, Color btnColor) {
//     AwesomeDialog(
//       context: context,
//       dialogType: type,
//       animType: AnimType.bottomSlide,
//       title: title,
//       titleTextStyle: const TextStyle(
//         fontSize: 25,
//         fontWeight: FontWeight.bold,
//       ),
//       descTextStyle: const TextStyle(fontSize: 18),
//       desc: desc,
//       btnOkColor: btnColor,
//       btnOkOnPress: () {},
//     ).show();
//   }

//   int monthsToNumber(String month) {
//     switch (month.substring(0, 3)) {
//       case 'Jan':
//         return 1;
//       case 'Feb':
//         return 2;
//       case 'Mar':
//         return 3;
//       case 'Apr':
//         return 4;
//       case 'May':
//         return 5;
//       case 'Jun':
//         return 6;
//       case 'Jul':
//         return 7;
//       case 'Aug':
//         return 8;
//       case 'Sep':
//         return 9;
//       case 'Oct':
//         return 10;
//       case 'Nov':
//         return 11;
//       case 'Dec':
//         return 12;
//       default:
//         return 1;
//     }
//   }
// }

// // import 'package:attendance_app/features/attendance/presentation/views/admin_view_attendance.dart';
// // import 'package:attendance_app/features/attendance/presentation/views/student_attendance_view.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:awesome_dialog/awesome_dialog.dart';

// // class DaysScreen extends StatelessWidget {
// //   final String month;
// //   final int daysInMonth;
// //   final bool isAdmin;

// //   DaysScreen({
// //     required this.month,
// //     required this.daysInMonth,
// //     required this.isAdmin,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     int year = 2025;
// //     DateTime now = DateTime.now();
// //     int monthNumber = monthsToNumber(month);

// //     List<DateTime> dates = List.generate(
// //       daysInMonth,
// //       (index) => DateTime(year, monthNumber, index + 1),
// //     );

// //     return Scaffold(
// //       appBar: AppBar(
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         centerTitle: true,
// //         title: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Icon(Icons.calendar_today, color: Colors.white, size: 28),
// //             const SizedBox(width: 10),
// //             Text(
// //               "$month Days",
// //               style: const TextStyle(
// //                 fontSize: 25,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: const Color(0xff70ACF4),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: GridView.builder(
// //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //             crossAxisCount: 3,
// //             mainAxisSpacing: 15,
// //             childAspectRatio: 1,
// //           ),
// //           itemCount: dates.length,
// //           itemBuilder: (context, index) {
// //             DateTime date = dates[index];
// //             bool isToday = date.day == now.day &&
// //                 date.month == now.month &&
// //                 date.year == now.year;
// //             bool isPast = date.isBefore(now);
// //             String dayName = DateFormat('EEEE').format(date);

// //             return GestureDetector(
// //               onTap: () {
// //                 if (dayName == "Friday") {
// //                   _showDialog(
// //                     context,
// //                     "Friday is a holiday!",
// //                     "There are no classes on Friday. Enjoy your weekend! 🎉",
// //                     DialogType.info,
// //                     Colors.blue,
// //                   );
// //                 } else if (isToday || isPast) {
// //                   if (isAdmin) {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (context) => AdminViewAttendance(date: date),
// //                       ),
// //                     );
// //                   } else {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (context) => StudentAttendanceView(date: date),
// //                       ),
// //                     );
// //                   }
// //                 } else {
// //                   _showDialog(
// //                     context,
// //                     "Invalid Date",
// //                     "This day has not arrived yet!",
// //                     DialogType.warning,
// //                     Colors.red,
// //                   );
// //                 }
// //               },
// //               child: Card(
// //                 elevation: 5,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(15),
// //                 ),
// //                 color: isToday ? Colors.green : const Color(0xff70ACF4),
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(15),
// //                     gradient: isToday
// //                         ? const LinearGradient(
// //                             colors: [Colors.green, Colors.lightGreen],
// //                             begin: Alignment.topLeft,
// //                             end: Alignment.bottomRight,
// //                           )
// //                         : const LinearGradient(
// //                             colors: [Color(0xff70ACF4), Color(0xff5A9EE0)],
// //                             begin: Alignment.topLeft,
// //                             end: Alignment.bottomRight,
// //                           ),
// //                   ),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       const Icon(
// //                         Icons.calendar_today,
// //                         color: Colors.white,
// //                         size: 28,
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Text(
// //                         dayName,
// //                         textAlign: TextAlign.center,
// //                         style: const TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         DateFormat('dd/MM').format(date),
// //                         textAlign: TextAlign.center,
// //                         style: const TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white70,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   void _showDialog(BuildContext context, String title, String desc,
// //       DialogType type, Color btnColor) {
// //     AwesomeDialog(
// //       context: context,
// //       dialogType: type,
// //       animType: AnimType.bottomSlide,
// //       title: title,
// //       titleTextStyle: const TextStyle(
// //         fontSize: 25,
// //         fontWeight: FontWeight.bold,
// //       ),
// //       descTextStyle: const TextStyle(fontSize: 18),
// //       desc: desc,
// //       btnOkColor: btnColor,
// //       btnOkOnPress: () {},
// //     ).show();
// //   }

// //   int monthsToNumber(String month) {
// //     switch (month.substring(0, 3)) {
// //       case 'Jan':
// //         return 1;
// //       case 'Feb':
// //         return 2;
// //       case 'Mar':
// //         return 3;
// //       case 'Apr':
// //         return 4;
// //       case 'May':
// //         return 5;
// //       case 'Jun':
// //         return 6;
// //       case 'Jul':
// //         return 7;
// //       case 'Aug':
// //         return 8;
// //       case 'Sep':
// //         return 9;
// //       case 'Oct':
// //         return 10;
// //       case 'Nov':
// //         return 11;
// //       case 'Dec':
// //         return 12;
// //       default:
// //         return 1;
// //     }
// //   }
// // }

import 'package:attendance_app/features/attendance/presentation/views/admin_view_attendance.dart';
import 'package:attendance_app/features/attendance/presentation/views/student_attendance_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DaysScreen extends StatelessWidget {
  final String month;
  final int daysInMonth;

  const DaysScreen({super.key, 
    required this.month,
    required this.daysInMonth,
  });

  /// دالة لاسترجاع الدور من Firestore للمستخدم الحالي
  Future<String> getUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data["role"] ?? "student";
    }
    return "student";
  }

  @override
  Widget build(BuildContext context) {
    int year = 2025;
    DateTime now = DateTime.now();
    int monthNumber = monthsToNumber(month);

    List<DateTime> dates = List.generate(
      daysInMonth,
      (index) => DateTime(year, monthNumber, index + 1),
    );

    return FutureBuilder<String>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Loading..."),
            ),
            body: const Center(
                child: CircularProgressIndicator(
              color: Color(0xff70ACF4),
            )),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
            ),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        String role = snapshot.data ?? "student";

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(
                  "$month Days",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xff70ACF4),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                childAspectRatio: 1,
              ),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                DateTime date = dates[index];
                bool isToday = date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year;
                bool isPast = date.isBefore(now);
                String dayName = DateFormat('EEEE').format(date);

                return GestureDetector(
                  onTap: () {
                    if (dayName == "Friday") {
                      _showDialog(
                        context,
                        "Friday is a holiday!",
                        "There are no classes on Friday. Enjoy your weekend! 🎉",
                        DialogType.info,
                        Colors.blue,
                      );
                    } else if (isToday || isPast) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => role == "admin"
                              ? AdminViewAttendance(date: date)
                              : StudentAttendanceView(date: date),
                        ),
                      );
                    } else {
                      _showDialog(
                        context,
                        "Invalid Date",
                        "This day has not arrived yet!",
                        DialogType.warning,
                        Colors.red,
                      );
                    }
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: isToday ? Colors.green : const Color(0xff70ACF4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: isToday
                            ? const LinearGradient(
                                colors: [Colors.green, Colors.lightGreen],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Color(0xff70ACF4), Color(0xff5A9EE0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM').format(date),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context, String title, String desc,
      DialogType type, Color btnColor) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.bottomSlide,
      title: title,
      titleTextStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: const TextStyle(fontSize: 18),
      desc: desc,
      btnOkColor: btnColor,
      btnOkOnPress: () {},
    ).show();
  }

  int monthsToNumber(String month) {
    switch (month.substring(0, 3)) {
      case 'Jan':
        return 1;
      case 'Feb':
        return 2;
      case 'Mar':
        return 3;
      case 'Apr':
        return 4;
      case 'May':
        return 5;
      case 'Jun':
        return 6;
      case 'Jul':
        return 7;
      case 'Aug':
        return 8;
      case 'Sep':
        return 9;
      case 'Oct':
        return 10;
      case 'Nov':
        return 11;
      case 'Dec':
        return 12;
      default:
        return 1;
    }
  }
}
