// // // // // lib/cubits/cubit_student/lecture_cubit.dart
// // // // import 'package:flutter_bloc/flutter_bloc.dart';
// // // // import '../../models/lecture_model_student.dart';
// // // // import 'lecture_state.dart';

// // // // class StudentLectureCubit extends Cubit<StudentLectureStatus> {
// // // //   StudentLectureCubit() : super(StudentLectureStatus(lectures: _getInitialLectures()));

// // // //   static List<Lecture> _getInitialLectures() {
// // // //     return [
// // // //       Lecture(number: 1, date: '10-12', time: '09:30 AM', isPresent: true),
// // // //       Lecture(number: 2, date: '10-12', time: '11:00 AM', isPresent: false),
// // // //       Lecture(number: 3, date: '10-12', time: '01:30 PM', isPresent: true),
// // // //       Lecture(number: 4, date: '10-15', time: '10:15 AM', isPresent: true),
// // // //       Lecture(number: 5, date: '10-17', time: '02:45 PM', isPresent: false),
// // // //     ];
// // // //   }

// // // //   void searchLectures(String query) {
// // // //     emit(state.copyWith(searchQuery: query));
// // // //   }

// // // // // You can add more methods here like addLecture, updateAttendance, etc.
// // // // }

// // // // lib/features/attendance/cubits/cubit_student/student_lecture_state.dart
// // // import 'package:attendance_app/features/attendance/models/lecture_model_student.dart';

// // // enum StudentLectureStatus { initial, loading, success, failure }

// // // class StudentLectureState {
// // //   final StudentLectureStatus status;
// // //   final List<StudentLectureModel> lectures;
// // //   final List<StudentLectureModel> filteredLectures;
// // //   final String? errorMessage;
// // //   final String searchQuery;

// // //   const StudentLectureState({
// // //     this.status = StudentLectureStatus.initial,
// // //     this.lectures = const [],
// // //     this.filteredLectures = const [],
// // //     this.errorMessage,
// // //     this.searchQuery = '',
// // //   });

// // //   StudentLectureState copyWith({
// // //     StudentLectureStatus? status,
// // //     List<StudentLectureModel>? lectures,
// // //     List<StudentLectureModel>? filteredLectures,
// // //     String? errorMessage,
// // //     String? searchQuery,
// // //   }) {
// // //     return StudentLectureState(
// // //       status: status ?? this.status,
// // //       lectures: lectures ?? this.lectures,
// // //       filteredLectures: filteredLectures ?? this.filteredLectures,
// // //       errorMessage: errorMessage ?? this.errorMessage,
// // //       searchQuery: searchQuery ?? this.searchQuery,
// // //     );
// // //   }
// // // }

// // // lib/features/attendance/cubits/cubit_student/student_lecture_cubit.dart
// // import 'package:attendance_app/features/attendance/cubits/cubit_student/lecture_state.dart';
// // import 'package:attendance_app/features/attendance/models/lecture_model_student.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';

// // class StudentLectureCubit extends Cubit<StudentLectureState> {
// //   final String courseId;

// //   StudentLectureCubit({required this.courseId})
// //       : super(const StudentLectureState()) {
// //     loadLectures();
// //   }

// //   Future<void> loadLectures() async {
// //     emit(state.copyWith(status: StudentLectureStatus.loading));

// //     try {
// //       // Get the current student's UID
// //       User? currentUser = FirebaseAuth.instance.currentUser;
// //       if (currentUser == null) {
// //         emit(state.copyWith(
// //           status: StudentLectureStatus.failure,
// //           errorMessage: 'User not logged in',
// //         ));
// //         return;
// //       }
// //       String studentUid = currentUser.uid;

// //       // Fetch lectures for the course
// //       DocumentReference courseRef =
// //           FirebaseFirestore.instance.collection('Courses').doc(courseId);
// //       QuerySnapshot lecturesSnapshot = await courseRef
// //           .collection('lectures')
// //           .orderBy('lectureNumber', descending: false)
// //           .get();

// //       List<StudentLectureModel> lectures = [];
// //       for (var doc in lecturesSnapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>;

// //         // Fetch the student's attendance for this lecture
// //         DocumentSnapshot attendanceDoc = await courseRef
// //             .collection('lectures')
// //             .doc(doc.id)
// //             .collection('attendance')
// //             .doc(studentUid)
// //             .get();

// //         bool isPresent = false;
// //         if (attendanceDoc.exists) {
// //           var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
// //           isPresent = attendanceData['isPresent'] ?? false;
// //         }

// //         lectures.add(StudentLectureModel(
// //           number: data['lectureNumber'] ?? 0,
// //           name: data['name'] ?? 'Unknown',
// //           date: data['date'] ?? 'Unknown',
// //           time: data['time'] ?? 'Unknown',
// //           isPresent: isPresent,
// //         ));
// //       }

// //       emit(state.copyWith(
// //         status: StudentLectureStatus.success,
// //         lectures: lectures,
// //         filteredLectures: lectures,
// //       ));
// //     } catch (e) {
// //       emit(state.copyWith(
// //         status: StudentLectureStatus.failure,
// //         errorMessage: 'Failed to load lectures: ${e.toString()}',
// //       ));
// //     }
// //   }

// //   void searchLectures(String query) {
// //     final searchText = query.toLowerCase().trim();

// //     if (searchText.isEmpty) {
// //       emit(state.copyWith(
// //         searchQuery: searchText,
// //         filteredLectures: state.lectures,
// //       ));
// //       return;
// //     }

// //     int? searchNumber;
// //     final lectureNumberMatch = RegExp(r'\d+').firstMatch(searchText);
// //     if (lectureNumberMatch != null) {
// //       searchNumber = int.tryParse(lectureNumberMatch.group(0)!);
// //     }

// //     final filtered = state.lectures.where((lecture) {
// //       final matchesName = lecture.name.toLowerCase().contains(searchText);
// //       final matchesNumber =
// //           searchNumber != null && lecture.number == searchNumber;
// //       final matchesLectureText =
// //           'lecture ${lecture.number}'.toLowerCase().contains(searchText);

// //       return matchesName || matchesNumber || matchesLectureText;
// //     }).toList();

// //     emit(state.copyWith(
// //       searchQuery: searchText,
// //       filteredLectures: filtered,
// //     ));
// //   }

// //   Future<void> refreshLectures() async {
// //     await loadLectures();
// //   }
// // }

// // lib/features/attendance/cubits/cubit_student/student_lecture_cubit.dart
// import 'package:attendance_app/features/attendance/cubits/cubit_student/lecture_state.dart';
// import 'package:attendance_app/features/attendance/models/lecture_model_student.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class StudentLectureCubit extends Cubit<StudentLectureState> {
//   final String courseId;

//   StudentLectureCubit({required this.courseId})
//       : super(const StudentLectureState()) {
//     loadLectures();
//   }

//   Future<void> loadLectures() async {
//     emit(state.copyWith(status: StudentLectureStatus.loading));

//     try {
//       // Get the current student's UID
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) {
//         emit(state.copyWith(
//           status: StudentLectureStatus.failure,
//           errorMessage: 'User not logged in',
//         ));
//         return;
//       }
//       String studentUid = currentUser.uid;

//       // Fetch lectures for the course
//       DocumentReference courseRef =
//           FirebaseFirestore.instance.collection('Courses').doc(courseId);
//       QuerySnapshot lecturesSnapshot = await courseRef
//           .collection('lectures')
//           .orderBy('lectureNumber', descending: false)
//           .get();

//       List<StudentLectureModel> lectures = [];
//       for (var doc in lecturesSnapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;

//         // Fetch the student's attendance for this lecture
//         DocumentSnapshot attendanceDoc = await courseRef
//             .collection('lectures')
//             .doc(doc.id)
//             .collection('attendance')
//             .doc(studentUid)
//             .get();

//         bool isPresent = false;
//         if (attendanceDoc.exists) {
//           var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
//           isPresent = attendanceData['isPresent'] ?? false;
//         }

//         lectures.add(StudentLectureModel(
//           number: data['lectureNumber'] ?? 0,
//           name: data['name'] ?? 'Unknown',
//           date: data['date'] ?? 'Unknown',
//           time: data['time'] ?? 'Unknown',
//           isPresent: isPresent,
//         ));
//       }

//       emit(state.copyWith(
//         status: StudentLectureStatus.success,
//         lectures: lectures,
//         filteredLectures: lectures,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         status: StudentLectureStatus.failure,
//         errorMessage: 'Failed to load lectures: ${e.toString()}',
//       ));
//     }
//   }

//   void searchLectures(String query) {
//     final searchText = query.toLowerCase().trim();

//     if (searchText.isEmpty) {
//       emit(state.copyWith(
//         searchQuery: searchText,
//         filteredLectures: state.lectures,
//       ));
//       return;
//     }

//     final filtered = state.lectures.where((lecture) {
//       // Check if the query is a number
//       final isNumeric = RegExp(r'^\d+$').hasMatch(searchText);
//       if (isNumeric) {
//         final searchNumber = int.tryParse(searchText);
//         return searchNumber != null && lecture.number == searchNumber;
//       } else {
//         // If not a number, search by name
//         return lecture.name.toLowerCase().contains(searchText);
//       }
//     }).toList();

//     emit(state.copyWith(
//       searchQuery: searchText,
//       filteredLectures: filtered,
//     ));
//   }

//   Future<void> refreshLectures() async {
//     await loadLectures();
//   }
// }

// lib/features/attendance/cubits/cubit_student/student_lecture_cubit.dart
import 'package:attendance_app/features/attendance/cubits/cubit_student/lecture_state.dart';
import 'package:attendance_app/features/attendance/models/lecture_model_student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentLectureCubit extends Cubit<StudentLectureState> {
  final String courseId;

  StudentLectureCubit({required this.courseId})
      : super(const StudentLectureState()) {
    loadLectures();
  }

  // Future<void> loadLectures() async {
  //   emit(state.copyWith(status: StudentLectureStatus.loading));

  //   try {
  //     // Get the current student's name
  //     User? currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User not logged in',
  //       ));
  //       return;
  //     }
  //     String? studentName = currentUser.displayName;
  //     if (studentName == null || studentName.isEmpty) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User name not found',
  //       ));
  //       return;
  //     }

  //     // Fetch lectures for the course
  //     DocumentReference courseRef =
  //         FirebaseFirestore.instance.collection('Courses').doc(courseId);
  //     QuerySnapshot lecturesSnapshot = await courseRef
  //         .collection('lectures')
  //         .orderBy('lectureNumber', descending: false)
  //         .get();

  //     List<StudentLectureModel> lectures = [];
  //     for (var doc in lecturesSnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;

  //       // Fetch all attendance records for this lecture
  //       QuerySnapshot attendanceSnapshot = await courseRef
  //           .collection('lectures')
  //           .doc(doc.id)
  //           .collection('attendance')
  //           .get();

  //       bool hasAttended = false;
  //       int bonusCount = 0;

  //       // Check if the current student's name exists in the attendance collection
  //       for (var attendanceDoc in attendanceSnapshot.docs) {
  //         var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
  //         String? nameInAttendance = attendanceData['name'];
  //         if (nameInAttendance == studentName) {
  //           hasAttended = true;
  //           bonusCount = attendanceData['bonusCount'] ?? 0;
  //           break;
  //         }
  //       }

  //       lectures.add(StudentLectureModel(
  //         number: data['lectureNumber'] ?? 0,
  //         name: data['name'] ?? 'Unknown',
  //         date: data['date'] ?? 'Unknown',
  //         time: data['time'] ?? 'Unknown',
  //         hasAttended: hasAttended,
  //         bonusCount: bonusCount,
  //       ));
  //     }

  //     emit(state.copyWith(
  //       status: StudentLectureStatus.success,
  //       lectures: lectures,
  //       filteredLectures: lectures,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: StudentLectureStatus.failure,
  //       errorMessage: 'Failed to load lectures: ${e.toString()}',
  //     ));
  //   }
  // }

  // Future<void> loadLectures() async {
  //   emit(state.copyWith(status: StudentLectureStatus.loading));

  //   try {
  //     // Get the current student's UID
  //     User? currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User not logged in',
  //       ));
  //       return;
  //     }

  //     // Fetch the student's name from Firestore using their UID
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUser.uid)
  //         .get();

  //     if (!userDoc.exists) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User data not found in Firestore',
  //       ));
  //       return;
  //     }

  //     String? studentName = userDoc['name'];
  //     if (studentName == null || studentName.isEmpty) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User name not found in Firestore',
  //       ));
  //       return;
  //     }

  //     // Normalize the student name (convert to lowercase and trim spaces)
  //     studentName = studentName.toLowerCase().trim();

  //     // Fetch lectures for the course
  //     DocumentReference courseRef =
  //         FirebaseFirestore.instance.collection('Courses').doc(courseId);
  //     QuerySnapshot lecturesSnapshot = await courseRef
  //         .collection('lectures')
  //         .orderBy('lectureNumber', descending: false)
  //         .get();

  //     List<StudentLectureModel> lectures = [];
  //     for (var doc in lecturesSnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;

  //       // Fetch all attendance records for this lecture
  //       QuerySnapshot attendanceSnapshot = await courseRef
  //           .collection('lectures')
  //           .doc(doc.id)
  //           .collection('attendance')
  //           .get();

  //       bool hasAttended = false;
  //       int bonusCount = 0;

  //       // Check if the current student's name exists in the attendance collection
  //       for (var attendanceDoc in attendanceSnapshot.docs) {
  //         var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
  //         String? nameInAttendance = attendanceData['name'];
  //         if (nameInAttendance != null) {
  //           // Normalize the name from attendance (convert to lowercase and trim spaces)
  //           nameInAttendance = nameInAttendance.toLowerCase().trim();
  //           if (nameInAttendance == studentName) {
  //             hasAttended = true;
  //             bonusCount = attendanceData['bonusCount']?.toInt() ?? 0;
  //             break;
  //           }
  //         }
  //       }

  //       // Determine the time format (combine start_hour_12 and end_hour_12)
  //       String startHour = data['start_hour_12']?.toString() ?? 'Unknown';
  //       String startMinute =
  //           data['start_minute']?.toString().padLeft(2, '0') ?? '00';
  //       String endHour = data['end_hour_12']?.toString() ?? 'Unknown';
  //       String endMinute =
  //           data['end_minute']?.toString().padLeft(2, '0') ?? '00';
  //       String period = data['end_period'] ?? '';
  //       String time = '$startHour:$startMinute - $endHour:$endMinute $period';

  //       lectures.add(StudentLectureModel(
  //         number: data['lectureNumber']?.toInt() ?? 0,
  //         name: data['name'] ?? 'Unknown',
  //         date: data['date'] ?? 'Unknown',
  //         time: time,
  //         hasAttended: hasAttended,
  //         bonusCount: bonusCount,
  //       ));
  //     }

  //     emit(state.copyWith(
  //       status: StudentLectureStatus.success,
  //       lectures: lectures,
  //       filteredLectures: lectures,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: StudentLectureStatus.failure,
  //       errorMessage: 'Failed to load lectures: ${e.toString()}',
  //     ));
  //   }
  // }

  // Future<void> loadLectures() async {
  //   emit(state.copyWith(status: StudentLectureStatus.loading));

  //   try {
  //     // Get the current student's UID
  //     User? currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User not logged in',
  //       ));
  //       return;
  //     }

  //     // Fetch the student's name from Firestore using their UID
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUser.uid)
  //         .get();

  //     if (!userDoc.exists) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User data not found in Firestore',
  //       ));
  //       return;
  //     }

  //     String? studentName = userDoc['name'];
  //     if (studentName == null || studentName.isEmpty) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User name not found in Firestore',
  //       ));
  //       return;
  //     }

  //     // Normalize the student name (convert to lowercase, trim spaces, and replace multiple spaces with single space)
  //     studentName =
  //         studentName.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  //     print('Normalized Student Name: "$studentName"');

  //     // Fetch lectures for the course
  //     DocumentReference courseRef =
  //         FirebaseFirestore.instance.collection('Courses').doc(courseId);
  //     QuerySnapshot lecturesSnapshot = await courseRef
  //         .collection('lectures')
  //         .orderBy('lectureNumber', descending: false)
  //         .get();

  //     List<StudentLectureModel> lectures = [];
  //     for (var doc in lecturesSnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;

  //       // Fetch all attendance records for this lecture
  //       QuerySnapshot attendanceSnapshot = await courseRef
  //           .collection('lectures')
  //           .doc(doc.id)
  //           .collection('attendance')
  //           .get();

  //       bool hasAttended = false;
  //       int bonusCount = 0;

  //       // Check if the current student's name exists in the attendance collection
  //       for (var attendanceDoc in attendanceSnapshot.docs) {
  //         var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
  //         String? nameInAttendance = attendanceData['name'];

  //         if (nameInAttendance != null) {
  //           // Normalize the name from attendance (convert to lowercase, trim spaces, and replace multiple spaces with single space)
  //           nameInAttendance = nameInAttendance
  //               .toLowerCase()
  //               .trim()
  //               .replaceAll(RegExp(r'\s+'), ' ');
  //           print('Student Name in Attendance: "$nameInAttendance"');

  //           // Check if the name matches
  //           if (nameInAttendance == studentName) {
  //             // Read the Check-out field
  //             String? checkOut = attendanceData['Check-out']?.toString();
  //             print('Check-out Value for $nameInAttendance: "$checkOut"');

  //             // Check if Check-out is not empty
  //             if (checkOut != null && checkOut.trim().isNotEmpty) {
  //               hasAttended = true;
  //               bonusCount = attendanceData['bonusCount']?.toInt() ?? 0;
  //               print(
  //                   'Attendance Match Found! Has Attended: $hasAttended, Bonus: $bonusCount');
  //               break;
  //             } else {
  //               print(
  //                   'No Check-out for $nameInAttendance: Check-out Valid=${checkOut != null && checkOut.trim().isNotEmpty}');
  //             }
  //           }
  //         }
  //       }

  //       // Determine the time format (combine start_hour_12 and end_hour_12)
  //       String startHour = data['start_hour_12']?.toString() ?? 'Unknown';
  //       String startMinute =
  //           data['start_minute']?.toString().padLeft(2, '0') ?? '00';
  //       String endHour = data['end_hour_12']?.toString() ?? 'Unknown';
  //       String endMinute =
  //           data['end_minute']?.toString().padLeft(2, '0') ?? '00';
  //       String period = data['end_period'] ?? '';
  //       String time = '$startHour:$startMinute - $endHour:$endMinute $period';

  //       lectures.add(StudentLectureModel(
  //         number: data['lectureNumber']?.toInt() ?? 0,
  //         name: data['name'] ?? 'Unknown',
  //         date: data['date'] ?? 'Unknown',
  //         time: time,
  //         hasAttended: hasAttended,
  //         bonusCount: bonusCount,
  //       ));
  //     }

  //     emit(state.copyWith(
  //       status: StudentLectureStatus.success,
  //       lectures: lectures,
  //       filteredLectures: lectures,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: StudentLectureStatus.failure,
  //       errorMessage: 'Failed to load lectures: ${e.toString()}',
  //     ));
  //   }
  // }

  // Future<void> loadLectures() async {
  //   emit(state.copyWith(status: StudentLectureStatus.loading));

  //   try {
  //     // Get the current student's UID
  //     User? currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User not logged in',
  //       ));
  //       return;
  //     }

  //     // Fetch the student's name from Firestore using their UID
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUser.uid)
  //         .get();

  //     if (!userDoc.exists) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User data not found in Firestore',
  //       ));
  //       return;
  //     }

  //     String? studentName = userDoc['name'];
  //     if (studentName == null || studentName.isEmpty) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User name not found in Firestore',
  //       ));
  //       return;
  //     }

  //     // Normalize the student name (convert to lowercase, trim spaces, and replace multiple spaces with single space)
  //     studentName =
  //         studentName.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  //     print('Normalized Student Name: "$studentName"');

  //     // Fetch lectures for the course
  //     DocumentReference courseRef =
  //         FirebaseFirestore.instance.collection('Courses').doc(courseId);
  //     QuerySnapshot lecturesSnapshot = await courseRef
  //         .collection('lectures')
  //         .orderBy('lectureNumber', descending: false)
  //         .get();

  //     List<StudentLectureModel> lectures = [];
  //     for (var doc in lecturesSnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;

  //       // Fetch all attendance records for this lecture
  //       QuerySnapshot attendanceSnapshot = await courseRef
  //           .collection('lectures')
  //           .doc(doc.id)
  //           .collection('attendance')
  //           .get();

  //       bool hasAttended = false;
  //       int bonusCount = 0;

  //       // Check for matching documents
  //       for (var attendanceDoc in attendanceSnapshot.docs) {
  //         var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
  //         String? nameInAttendance = attendanceData['name'];

  //         if (nameInAttendance != null) {
  //           // Normalize the name from attendance
  //           nameInAttendance = nameInAttendance
  //               .toLowerCase()
  //               .trim()
  //               .replaceAll(RegExp(r'\s+'), ' ');
  //           print(
  //               'Student Name in Attendance for doc ${attendanceDoc.id}: "$nameInAttendance"');

  //           // Only proceed if the name matches
  //           if (nameInAttendance == studentName) {
  //             // Print all fields in the document to debug
  //             print('Document ${attendanceDoc.id} Data: $attendanceData');

  //             // Try to find the Check-out field inside nested maps
  //             String? checkOut;
  //             // Look for a nested map (like "2025-04-27") and read Check-out from it
  //             for (var key in attendanceData.keys) {
  //               if (key != 'name' && attendanceData[key] is Map) {
  //                 var nestedData = attendanceData[key] as Map<String, dynamic>;
  //                 checkOut = nestedData['Check-out']?.toString();
  //                 if (checkOut != null && checkOut.trim().isNotEmpty) {
  //                   bonusCount = nestedData['bonusCount']?.toInt() ?? 0;
  //                   break;
  //                 }
  //               }
  //             }

  //             print('Check-out Value for doc ${attendanceDoc.id}: "$checkOut"');

  //             // Check if Check-out is not empty
  //             if (checkOut != null && checkOut.trim().isNotEmpty) {
  //               hasAttended = true;
  //               print(
  //                   'Attendance Match Found for doc ${attendanceDoc.id}! Has Attended: $hasAttended, Bonus: $bonusCount');
  //               break;
  //             } else {
  //               print(
  //                   'No Check-out for doc ${attendanceDoc.id}: Check-out Valid=${checkOut != null && checkOut.trim().isNotEmpty}, continuing to search...');
  //             }
  //           }
  //         }
  //       }

  //       // Determine the time format (combine start_hour_12 and end_hour_12)
  //       String startHour = data['start_hour_12']?.toString() ?? 'Unknown';
  //       String startMinute =
  //           data['start_minute']?.toString().padLeft(2, '0') ?? '00';
  //       String endHour = data['end_hour_12']?.toString() ?? 'Unknown';
  //       String endMinute =
  //           data['end_minute']?.toString().padLeft(2, '0') ?? '00';
  //       String period = data['end_period'] ?? '';
  //       String time = '$startHour:$startMinute - $endHour:$endMinute $period';

  //       lectures.add(StudentLectureModel(
  //         number: data['lectureNumber']?.toInt() ?? 0,
  //         name: data['name'] ?? 'Unknown',
  //         date: data['date'] ?? 'Unknown',
  //         time: time,
  //         hasAttended: hasAttended,
  //         bonusCount: bonusCount,
  //       ));
  //     }

  //     emit(state.copyWith(
  //       status: StudentLectureStatus.success,
  //       lectures: lectures,
  //       filteredLectures: lectures,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: StudentLectureStatus.failure,
  //       errorMessage: 'Failed to load lectures: ${e.toString()}',
  //     ));
  //   }
  // }

  // Future<void> loadLectures() async {
  //   emit(state.copyWith(status: StudentLectureStatus.loading));

  //   try {
  //     // Get the current student's UID
  //     User? currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User not logged in',
  //       ));
  //       return;
  //     }

  //     // Fetch the student's name from Firestore using their UID
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUser.uid)
  //         .get();

  //     if (!userDoc.exists) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User data not found in Firestore',
  //       ));
  //       return;
  //     }

  //     String? studentName = userDoc['name'];
  //     if (studentName == null || studentName.isEmpty) {
  //       emit(state.copyWith(
  //         status: StudentLectureStatus.failure,
  //         errorMessage: 'User name not found in Firestore',
  //       ));
  //       return;
  //     }

  //     // Normalize the student name (convert to lowercase, trim spaces, and replace multiple spaces with single space)
  //     studentName =
  //         studentName.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  //     print('Normalized Student Name: "$studentName"');

  //     // Fetch lectures for the course
  //     DocumentReference courseRef =
  //         FirebaseFirestore.instance.collection('Courses').doc(courseId);
  //     QuerySnapshot lecturesSnapshot = await courseRef
  //         .collection('lectures')
  //         .orderBy('lectureNumber', descending: false)
  //         .get();

  //     List<StudentLectureModel> lectures = [];
  //     for (var doc in lecturesSnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;

  //       // Fetch all attendance records for this lecture
  //       QuerySnapshot attendanceSnapshot = await courseRef
  //           .collection('lectures')
  //           .doc(doc.id)
  //           .collection('attendance')
  //           .get();

  //       bool hasAttended = false;
  //       int bonusCount = 0;

  //       // Check for matching documents
  //       for (var attendanceDoc in attendanceSnapshot.docs) {
  //         var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
  //         String? nameInAttendance = attendanceData['name'];

  //         if (nameInAttendance != null) {
  //           // Normalize the name from attendance
  //           nameInAttendance = nameInAttendance
  //               .toLowerCase()
  //               .trim()
  //               .replaceAll(RegExp(r'\s+'), ' ');
  //           print(
  //               'Student Name in Attendance for doc ${attendanceDoc.id}: "$nameInAttendance"');

  //           // Only proceed if the name matches
  //           if (nameInAttendance == studentName) {
  //             // Print all fields in the document to debug
  //             print('Document ${attendanceDoc.id} Data: $attendanceData');

  //             // Try to find the Check-out field inside nested maps
  //             String? checkOut;
  //             // Look for a nested map (like "2025-04-27") and read Check-out from it
  //             for (var key in attendanceData.keys) {
  //               if (key != 'name' && attendanceData[key] is Map) {
  //                 var nestedData = attendanceData[key] as Map<String, dynamic>;
  //                 checkOut = nestedData['Check-out']?.toString();
  //                 if (checkOut != null && checkOut.trim().isNotEmpty) {
  //                   bonusCount = nestedData['bonusCount']?.toInt() ?? 0;
  //                   break;
  //                 }
  //               }
  //             }

  //             print('Check-out Value for doc ${attendanceDoc.id}: "$checkOut"');

  //             // Check if Check-out is not empty and not "--"
  //             if (checkOut != null &&
  //                 checkOut.trim().isNotEmpty &&
  //                 checkOut.trim() != "--") {
  //               hasAttended = true;
  //               print(
  //                   'Attendance Match Found for doc ${attendanceDoc.id}! Has Attended: $hasAttended, Bonus: $bonusCount');
  //               break;
  //             } else {
  //               print(
  //                   'No Check-out for doc ${attendanceDoc.id}: Check-out Valid=${checkOut != null && checkOut.trim().isNotEmpty && checkOut.trim() != "--"}, continuing to search...');
  //             }
  //           }
  //         }
  //       }

  //       // Determine the time format (combine start_hour_12 and end_hour_12)
  //       String startHour = data['start_hour_12']?.toString() ?? 'Unknown';
  //       String startMinute =
  //           data['start_minute']?.toString().padLeft(2, '0') ?? '00';
  //       String endHour = data['end_hour_12']?.toString() ?? 'Unknown';
  //       String endMinute =
  //           data['end_minute']?.toString().padLeft(2, '0') ?? '00';
  //       String period = data['end_period'] ?? '';
  //       String time = '$startHour:$startMinute - $endHour:$endMinute $period';

  //       lectures.add(StudentLectureModel(
  //         number: data['lectureNumber']?.toInt() ?? 0,
  //         name: data['name'] ?? 'Unknown',
  //         date: data['date'] ?? 'Unknown',
  //         time: time,
  //         hasAttended: hasAttended,
  //         bonusCount: bonusCount,
  //       ));
  //     }

  //     emit(state.copyWith(
  //       status: StudentLectureStatus.success,
  //       lectures: lectures,
  //       filteredLectures: lectures,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: StudentLectureStatus.failure,
  //       errorMessage: 'Failed to load lectures: ${e.toString()}',
  //     ));
  //   }
  // }

  Future<void> loadLectures() async {
    emit(state.copyWith(status: StudentLectureStatus.loading));

    try {
      // Get the current student's UID
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: StudentLectureStatus.failure,
          errorMessage: 'User not logged in',
        ));
        return;
      }

      // Fetch the student's name from Firestore using their UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        emit(state.copyWith(
          status: StudentLectureStatus.failure,
          errorMessage: 'User data not found in Firestore',
        ));
        return;
      }

      String? studentName = userDoc['name'];
      if (studentName == null || studentName.isEmpty) {
        emit(state.copyWith(
          status: StudentLectureStatus.failure,
          errorMessage: 'User name not found in Firestore',
        ));
        return;
      }

      // Normalize the student name (convert to lowercase, trim spaces, and replace multiple spaces with single space)
      studentName =
          studentName.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
      print('Normalized Student Name: "$studentName"');

      // Fetch lectures for the course
      DocumentReference courseRef =
          FirebaseFirestore.instance.collection('Courses').doc(courseId);
      QuerySnapshot lecturesSnapshot = await courseRef
          .collection('lectures')
          .orderBy('lectureNumber', descending: false)
          .get();

      List<StudentLectureModel> lectures = [];
      for (var doc in lecturesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Fetch all attendance records for this lecture
        QuerySnapshot attendanceSnapshot = await courseRef
            .collection('lectures')
            .doc(doc.id)
            .collection('attendance')
            .get();

        bool hasAttended = false;
        int bonusCount = 0;

        // Check for matching documents
        for (var attendanceDoc in attendanceSnapshot.docs) {
          var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
          String? nameInAttendance = attendanceData['name'];

          if (nameInAttendance != null) {
            // Normalize the name from attendance
            nameInAttendance = nameInAttendance
                .toLowerCase()
                .trim()
                .replaceAll(RegExp(r'\s+'), ' ');
            print(
                'Student Name in Attendance for doc ${attendanceDoc.id}: "$nameInAttendance"');

            // Only proceed if the name matches
            if (nameInAttendance == studentName) {
              // Print all fields in the document to debug
              print('Document ${attendanceDoc.id} Data: $attendanceData');

              // Read bonusCount from the top level first
              bonusCount = attendanceData['bonusCount']?.toInt() ?? 0;
              print(
                  'Bonus Count (Top Level) for doc ${attendanceDoc.id}: $bonusCount');

              // Try to find the Check-out inside nested maps
              String? checkOut;
              for (var key in attendanceData.keys) {
                if (key != 'name' && attendanceData[key] is Map) {
                  var nestedData = attendanceData[key] as Map<String, dynamic>;
                  // If bonusCount wasn't found in the top level, try to read it from nested map
                  if (bonusCount == 0) {
                    bonusCount = nestedData['bonusCount']?.toInt() ?? 0;
                    print(
                        'Bonus Count (Nested) for doc ${attendanceDoc.id}: $bonusCount');
                  }

                  // Read Check-out
                  checkOut = nestedData['Check-out']?.toString();
                  print(
                      'Check-out Value for doc ${attendanceDoc.id}: "$checkOut"');

                  // Check if Check-out is valid
                  if (checkOut != null &&
                      checkOut.trim().isNotEmpty &&
                      checkOut.trim() != "--") {
                    hasAttended = true;
                    print(
                        'Attendance Match Found for doc ${attendanceDoc.id}! Has Attended: $hasAttended, Bonus: $bonusCount');
                    break;
                  }
                }
              }

              // If we found a valid Check-out, break the loop
              if (hasAttended) {
                break;
              } else {
                print(
                    'No Check-out for doc ${attendanceDoc.id}: Check-out Valid=${checkOut != null && checkOut.trim().isNotEmpty && checkOut.trim() != "--"}, continuing to search...');
              }
            }
          }
        }

        // Determine the time format (combine start_hour_12 and end_hour_12)
        String startHour = data['start_hour_12']?.toString() ?? 'Unknown';
        String startMinute =
            data['start_minute']?.toString().padLeft(2, '0') ?? '00';
        String endHour = data['end_hour_12']?.toString() ?? 'Unknown';
        String endMinute =
            data['end_minute']?.toString().padLeft(2, '0') ?? '00';
        String period = data['end_period'] ?? '';
        String time = '$startHour:$startMinute - $endHour:$endMinute $period';

        lectures.add(StudentLectureModel(
          number: data['lectureNumber']?.toInt() ?? 0,
          name: data['name'] ?? 'Unknown',
          date: data['date'] ?? 'Unknown',
          time: time,
          hasAttended: hasAttended,
          bonusCount: bonusCount,
        ));
      }

      emit(state.copyWith(
        status: StudentLectureStatus.success,
        lectures: lectures,
        filteredLectures: lectures,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentLectureStatus.failure,
        errorMessage: 'Failed to load lectures: ${e.toString()}',
      ));
    }
  }

  void searchLectures(String query) {
    final searchText = query.toLowerCase().trim();

    if (searchText.isEmpty) {
      emit(state.copyWith(
        searchQuery: searchText,
        filteredLectures: state.lectures,
      ));
      return;
    }

    final filtered = state.lectures.where((lecture) {
      final isNumeric = RegExp(r'^\d+$').hasMatch(searchText);
      if (isNumeric) {
        final searchNumber = int.tryParse(searchText);
        return searchNumber != null && lecture.number == searchNumber;
      } else {
        return lecture.name.toLowerCase().contains(searchText);
      }
    }).toList();

    emit(state.copyWith(
      searchQuery: searchText,
      filteredLectures: filtered,
    ));
  }

  Future<void> refreshLectures() async {
    await loadLectures();
  }
}
