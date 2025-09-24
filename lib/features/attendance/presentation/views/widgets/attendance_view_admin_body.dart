// // import 'package:attendance_app/core/utils/app_colors.dart';
// // import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_cubit.dart';
// // import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_state.dart';
// // import 'package:attendance_app/features/attendance/models/lecture_model_admin.dart';
// // import 'package:attendance_app/features/attendance/presentation/views/update_lecture_view.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:awesome_dialog/awesome_dialog.dart';
// // import '../lecture_attendance_screen.dart';

// // class AttendanceAdminBody extends StatefulWidget {
// //   final String courseId;

// //   const AttendanceAdminBody({Key? key, required this.courseId})
// //       : super(key: key);

// //   @override
// //   State<AttendanceAdminBody> createState() => _AttendanceAdminBodyState();
// // }

// // class _AttendanceAdminBodyState extends State<AttendanceAdminBody> {
// //   final TextEditingController _searchController = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _searchController.addListener(_onSearchChanged);
// //   }

// //   @override
// //   void dispose() {
// //     _searchController.removeListener(_onSearchChanged);
// //     _searchController.dispose();
// //     super.dispose();
// //   }

// //   void _onSearchChanged() {
// //     context.read<LectureCubit>().searchLectures(_searchController.text);
// //   }

// //   void _showLectureOptions(BuildContext parentContext, LectureModel lecture) {
// //     final lectureCubit = context.read<LectureCubit>();

// //     showModalBottomSheet(
// //       context: context,
// //       builder: (newContext) {
// //         return Container(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Text(
// //                 'Lecture ${lecture.number} Options',
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.blue[800],
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //               ListTile(
// //                 leading: const Icon(Icons.edit),
// //                 title: const Text('Edit Lecture'),
// //                 onTap: () {
// //                   Navigator.pop(newContext); // إغلاق الـ BottomSheet
// //                   Navigator.push(
// //                     parentContext,
// //                     MaterialPageRoute(
// //                       builder: (context) => UpdateLecturePage(
// //                         lecture: lecture,
// //                         courseId: widget.courseId,
// //                         lectureCubit: lectureCubit, // تمرير LectureCubit
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //               ListTile(
// //                 leading: const Icon(Icons.delete, color: Colors.red),
// //                 title: const Text('Delete Lecture'),
// //                 onTap: () {
// //                   AwesomeDialog(
// //                     context: newContext,
// //                     dialogType: DialogType.warning,
// //                     animType: AnimType.bottomSlide,
// //                     title: 'Delete Lecture ${lecture.number}',
// //                     desc: 'Are you sure you want to delete this lecture?',
// //                     btnCancelOnPress: () {},
// //                     btnOkOnPress: () {
// //                       lectureCubit.deleteLecture(lecture.number);
// //                       Navigator.pop(newContext);
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         SnackBar(
// //                           content: Text('Lecture ${lecture.number} deleted'),
// //                         ),
// //                       );
// //                     },
// //                     btnOkText: 'Delete',
// //                     btnCancelText: 'Cancel',
// //                     btnOkColor: Colors.red,
// //                     btnCancelColor: Colors.grey,
// //                   ).show();
// //                 },
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   void _navigateToLectureAttendance(BuildContext context, int lectureNumber) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => LectureAttendanceScreen(
// //           lectureNumber: lectureNumber,
// //           courseId: widget.courseId,
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: [
// //             Colors.blue[100]!,
// //             Colors.white,
// //           ],
// //         ),
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(8),
// //                 border: Border.all(color: Colors.grey.shade300),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.05),
// //                     blurRadius: 4,
// //                     offset: const Offset(0, 2),
// //                   ),
// //                 ],
// //               ),
// //               child: TextField(
// //                 cursorColor: AppColors.primaryColor,
// //                 controller: _searchController,
// //                 decoration: InputDecoration(
// //                   hintText: 'Search lecture (name/number)',
// //                   prefixIcon: Icon(Icons.search, color: Colors.blue[600]),
// //                   border: InputBorder.none,
// //                   contentPadding: const EdgeInsets.symmetric(vertical: 15),
// //                   suffixIcon: _searchController.text.isNotEmpty
// //                       ? IconButton(
// //                           icon: const Icon(Icons.clear),
// //                           onPressed: () {
// //                             _searchController.clear();
// //                           },
// //                         )
// //                       : null,
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 10),
// //             Expanded(
// //               child: BlocBuilder<LectureCubit, LectureState>(
// //                 builder: (context, state) {
// //                   print(
// //                       'BlocBuilder state: ${state.filteredLectures.map((l) => l.name).toList()}'); // للتصحيح
// //                   if (state.status == LectureStatus.loading) {
// //                     return const Center(
// //                       child: CircularProgressIndicator(),
// //                     );
// //                   } else if (state.status == LectureStatus.failure) {
// //                     return Center(
// //                       child: Text(
// //                         state.errorMessage ?? 'An error occurred',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.red[600],
// //                         ),
// //                       ),
// //                     );
// //                   } else if (state.filteredLectures.isEmpty) {
// //                     return Center(
// //                       child: Text(
// //                         'No lectures found',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.grey[600],
// //                         ),
// //                       ),
// //                     );
// //                   } else {
// //                     return ListView.builder(
// //                       itemCount: state.filteredLectures.length,
// //                       itemBuilder: (context, index) {
// //                         final lecture = state.filteredLectures[index];
// //                         return _buildLectureItem(context, lecture);
// //                       },
// //                     );
// //                   }
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildLectureItem(BuildContext context, LectureModel lecture) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: InkWell(
// //         onTap: () {
// //           _navigateToLectureAttendance(context, lecture.number);
// //         },
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(
// //               color: Colors.blue[300]!,
// //               width: 1.5,
// //             ),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.05),
// //                 blurRadius: 4,
// //                 offset: const Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.all(12.0),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'Lecture ${lecture.number}',
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.blue[800],
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         lecture.name,
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.black87,
// //                         ),
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         children: [
// //                           Icon(
// //                             Icons.calendar_today,
// //                             size: 16,
// //                             color: Colors.grey[600],
// //                           ),
// //                           const SizedBox(width: 6),
// //                           Text(
// //                             'Date: ',
// //                             style: TextStyle(
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.w500,
// //                               color: Colors.grey[700],
// //                             ),
// //                           ),
// //                           Text(
// //                             lecture.date,
// //                             style: TextStyle(
// //                               fontSize: 15,
// //                               color: Colors.grey[600],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         children: [
// //                           Icon(
// //                             Icons.access_time_rounded,
// //                             size: 16,
// //                             color: Colors.grey[600],
// //                           ),
// //                           const SizedBox(width: 6),
// //                           Text(
// //                             'Time: ',
// //                             style: TextStyle(
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.w500,
// //                               color: Colors.grey[700],
// //                             ),
// //                           ),
// //                           Text(
// //                             lecture.time,
// //                             style: TextStyle(
// //                               fontSize: 15,
// //                               color: Colors.grey[600],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(
// //                     Icons.more_vert,
// //                     color: Colors.black,
// //                   ),
// //                   onPressed: () {
// //                     _showLectureOptions(context, lecture);
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_cubit.dart';
// import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_state.dart';
// import 'package:attendance_app/features/attendance/models/lecture_model_admin.dart';
// import 'package:attendance_app/features/attendance/presentation/views/update_lecture_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../lecture_attendance_screen.dart';

// class AttendanceAdminBody extends StatefulWidget {
//   final String courseId;

//   const AttendanceAdminBody({Key? key, required this.courseId})
//       : super(key: key);

//   @override
//   State<AttendanceAdminBody> createState() => _AttendanceAdminBodyState();
// }

// class _AttendanceAdminBodyState extends State<AttendanceAdminBody> {
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     context.read<LectureCubit>().searchLectures(_searchController.text);
//   }

//   // دالة مساعدة لحذف الـ attendance collection
//   Future<void> _deleteAttendanceCollection(int lectureNumber) async {
//     try {
//       // جلب الـ lecture document بناءً على lectureNumber
//       QuerySnapshot lectureSnapshot = await FirebaseFirestore.instance
//           .collection('Courses')
//           .doc(widget.courseId)
//           .collection('lectures')
//           .where('lectureNumber', isEqualTo: lectureNumber)
//           .get();

//       if (lectureSnapshot.docs.isNotEmpty) {
//         var lectureDoc = lectureSnapshot.docs.first;
//         // جلب الـ attendance collection
//         QuerySnapshot attendanceSnapshot =
//             await lectureDoc.reference.collection('attendance').get();

//         // حذف كل الـ documents جوا الـ attendance collection
//         for (var doc in attendanceSnapshot.docs) {
//           await doc.reference.delete();
//         }
//         print('Attendance collection deleted for lecture $lectureNumber');
//       }
//     } catch (e) {
//       print('Error deleting attendance collection: $e');
//       throw Exception('Failed to delete attendance collection: $e');
//     }
//   }

//   void _showLectureOptions(BuildContext parentContext, LectureModel lecture) {
//     final lectureCubit = context.read<LectureCubit>();

//     showModalBottomSheet(
//       context: context,
//       builder: (newContext) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Lecture ${lecture.number} Options',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue[800],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ListTile(
//                 leading: const Icon(Icons.edit),
//                 title: const Text('Edit Lecture'),
//                 onTap: () {
//                   Navigator.pop(newContext); // إغلاق الـ BottomSheet
//                   Navigator.push(
//                     parentContext,
//                     MaterialPageRoute(
//                       builder: (context) => UpdateLecturePage(
//                         lecture: lecture,
//                         courseId: widget.courseId,
//                         lectureCubit: lectureCubit,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.delete, color: Colors.red),
//                 title: const Text('Delete Lecture'),
//                 onTap: () {
//                   Navigator.pop(newContext); // إغلاق الـ BottomSheet
//                   AwesomeDialog(
//                     context: parentContext,
//                     dialogType: DialogType.warning,
//                     animType: AnimType.bottomSlide,
//                     title: 'Delete Lecture ${lecture.number}',
//                     desc: 'Are you sure you want to delete this lecture?',
//                     btnCancelOnPress: () {},
//                     btnOkOnPress: () async {
//                       try {
//                         // حذف الـ attendance collection أولاً
//                         await _deleteAttendanceCollection(lecture.number);
//                         // بعدين حذف الـ lecture
//                         lectureCubit.deleteLecture(lecture.number);
//                         if (parentContext.mounted) {
//                           ScaffoldMessenger.of(parentContext).showSnackBar(
//                             SnackBar(
//                               content:
//                                   Text('Lecture ${lecture.number} deleted'),
//                             ),
//                           );
//                         }
//                       } catch (e) {
//                         if (parentContext.mounted) {
//                           ScaffoldMessenger.of(parentContext).showSnackBar(
//                             SnackBar(
//                               content: Text('Error deleting lecture: $e'),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       }
//                     },
//                     btnOkText: 'Delete',
//                     btnCancelText: 'Cancel',
//                     btnOkColor: Colors.red,
//                     btnCancelColor: Colors.grey,
//                   ).show();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _navigateToLectureAttendance(BuildContext context, int lectureNumber) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LectureAttendanceScreen(
//           lectureNumber: lectureNumber,
//           courseId: widget.courseId,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.blue[100]!,
//             Colors.white,
//           ],
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 cursorColor: AppColors.primaryColor,
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search lecture (name/number)',
//                   prefixIcon: Icon(Icons.search, color: Colors.blue[600]),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 15),
//                   suffixIcon: _searchController.text.isNotEmpty
//                       ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             _searchController.clear();
//                           },
//                         )
//                       : null,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: BlocBuilder<LectureCubit, LectureState>(
//                 builder: (context, state) {
//                   print(
//                       'BlocBuilder state: ${state.filteredLectures.map((l) => l.name).toList()}');
//                   if (state.status == LectureStatus.loading) {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   } else if (state.status == LectureStatus.failure) {
//                     return Center(
//                       child: Text(
//                         state.errorMessage ?? 'An error occurred',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.red[600],
//                         ),
//                       ),
//                     );
//                   } else if (state.filteredLectures.isEmpty) {
//                     return Center(
//                       child: Text(
//                         'No lectures found',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     );
//                   } else {
//                     return ListView.builder(
//                       itemCount: state.filteredLectures.length,
//                       itemBuilder: (context, index) {
//                         final lecture = state.filteredLectures[index];
//                         return _buildLectureItem(context, lecture);
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLectureItem(BuildContext context, LectureModel lecture) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: () {
//           _navigateToLectureAttendance(context, lecture.number);
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: Colors.blue[300]!,
//               width: 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Lecture ${lecture.number}',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         lecture.name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.black87,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today,
//                             size: 16,
//                             color: Colors.grey[600],
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Date: ',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           Text(
//                             lecture.date,
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.access_time_rounded,
//                             size: 16,
//                             color: Colors.grey[600],
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Time: ',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           Text(
//                             lecture.time,
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(
//                     Icons.more_vert,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                     _showLectureOptions(context, lecture);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_cubit.dart';
import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_state.dart';
import 'package:attendance_app/features/attendance/models/lecture_model_admin.dart';
import 'package:attendance_app/features/attendance/presentation/views/update_lecture_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lecture_attendance_screen.dart';

class AttendanceAdminBody extends StatefulWidget {
  final String courseId;

  const AttendanceAdminBody({super.key, required this.courseId});

  @override
  State<AttendanceAdminBody> createState() => _AttendanceAdminBodyState();
}

class _AttendanceAdminBodyState extends State<AttendanceAdminBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<LectureCubit>().searchLectures(_searchController.text);
  }

  // دالة مساعدة لحذف الـ attendance collection
  Future<void> _deleteAttendanceCollection(int lectureNumber) async {
    try {
      // جلب الـ lecture document بناءً على lectureNumber
      QuerySnapshot lectureSnapshot = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(widget.courseId)
          .collection('lectures')
          .where('lectureNumber', isEqualTo: lectureNumber)
          .get();

      if (lectureSnapshot.docs.isNotEmpty) {
        var lectureDoc = lectureSnapshot.docs.first;
        // جلب الـ attendance collection
        QuerySnapshot attendanceSnapshot =
            await lectureDoc.reference.collection('attendance').get();

        // حذف كل الـ documents جوا الـ attendance collection
        for (var doc in attendanceSnapshot.docs) {
          await doc.reference.delete();
        }
        print('Attendance collection deleted for lecture $lectureNumber');
      }
    } catch (e) {
      print('Error deleting attendance collection: $e');
      throw Exception('Failed to delete attendance collection: $e');
    }
  }

  void _showLectureOptions(BuildContext parentContext, LectureModel lecture) {
    final lectureCubit = context.read<LectureCubit>();

    showModalBottomSheet(
      context: context,
      builder: (newContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lecture ${lecture.number} Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Lecture'),
                onTap: () {
                  Navigator.pop(newContext); // إغلاق الـ BottomSheet
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (context) => UpdateLecturePage(
                        lecture: lecture,
                        courseId: widget.courseId,
                        lectureCubit: lectureCubit,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Lecture'),
                onTap: () {
                  Navigator.pop(newContext); // إغلاق الـ BottomSheet
                  AwesomeDialog(
                    context: parentContext,
                    dialogType: DialogType.warning,
                    animType: AnimType.bottomSlide,
                    title: 'Delete Lecture ${lecture.number}',
                    desc: 'Are you sure you want to delete this lecture?',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () async {
                      // إظهار CircularProgressIndicator أثناء الحذف
                      showDialog(
                        context: parentContext,
                        barrierDismissible: false,
                        builder: (loadingContext) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );

                      try {
                        // حذف الـ attendance collection أولاً
                        await _deleteAttendanceCollection(lecture.number);
                        // بعدين حذف الـ lecture
                        lectureCubit.deleteLecture(lecture.number);
                        if (parentContext.mounted) {
                          // إغلاق CircularProgressIndicator بعد اكتمال الحذف
                          Navigator.pop(parentContext); // إغلاق الـ Dialog
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Lecture ${lecture.number} deleted'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (parentContext.mounted) {
                          // إغلاق CircularProgressIndicator في حالة حدوث خطأ
                          Navigator.pop(parentContext); // إغلاق الـ Dialog
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text('Error deleting lecture: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    btnOkText: 'Delete',
                    btnCancelText: 'Cancel',
                    btnOkColor: Colors.red,
                    btnCancelColor: Colors.grey,
                  ).show();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToLectureAttendance(BuildContext context, int lectureNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LectureAttendanceScreen(
          lectureNumber: lectureNumber,
          courseId: widget.courseId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                // color: Colors.white,
                // borderRadius: BorderRadius.circular(8),
                // border: Border.all(color: Colors.grey.shade300),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.05),
                //     blurRadius: 4,
                //     offset: const Offset(0, 2),
                //   ),
                // ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                cursorColor: AppColors.primaryColor,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search lecture (name/number)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true, // Enable background fill
                  fillColor: Colors.grey[200], // Set grey background color
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<LectureCubit, LectureState>(
                builder: (context, state) {
                  print(
                      'BlocBuilder state: ${state.filteredLectures.map((l) => l.name).toList()}');
                  if (state.status == LectureStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state.status == LectureStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'An error occurred',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red[600],
                        ),
                      ),
                    );
                  } else if (state.filteredLectures.isEmpty) {
                    return Center(
                      child: Text(
                        'No lectures found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: state.filteredLectures.length,
                      itemBuilder: (context, index) {
                        final lecture = state.filteredLectures[index];
                        return FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: Duration(milliseconds: index * 500),
                          child: _buildLectureItem(
                            context,
                            lecture,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureItem(BuildContext context, LectureModel lecture) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _navigateToLectureAttendance(context, lecture.number);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lecture ${lecture.number}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lecture.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Date: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            lecture.date,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Time: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            lecture.time,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    _showLectureOptions(context, lecture);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
