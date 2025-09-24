// // import 'package:attendance_app/core/utils/app_colors.dart';
// // import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_cubit.dart';
// // import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_state.dart';
// // import 'package:attendance_app/features/attendance/models/lecture_model_admin.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';

// // class UpdateLecturePage extends StatelessWidget {
// //   final LectureModel lecture;
// //   final String courseId;
// //   final LectureCubit lectureCubit; // استقبال LectureCubit

// //   const UpdateLecturePage({
// //     Key? key,
// //     required this.lecture,
// //     required this.courseId,
// //     required this.lectureCubit,
// //   }) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocProvider.value(
// //       value: lectureCubit, // استخدام LectureCubit الممرر
// //       child: UpdateLectureContent(lecture: lecture),
// //     );
// //   }
// // }

// // class UpdateLectureContent extends StatefulWidget {
// //   final LectureModel lecture;

// //   const UpdateLectureContent({Key? key, required this.lecture})
// //       : super(key: key);

// //   @override
// //   _UpdateLectureContentState createState() => _UpdateLectureContentState();
// // }

// // class _UpdateLectureContentState extends State<UpdateLectureContent> {
// //   late TextEditingController _lectureNameController;
// //   late TextEditingController _dateController;
// //   late TextEditingController _timeController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _lectureNameController = TextEditingController(text: widget.lecture.name);
// //     _dateController = TextEditingController(text: widget.lecture.date);
// //     _timeController = TextEditingController(text: widget.lecture.time);
// //   }

// //   @override
// //   void dispose() {
// //     _lectureNameController.dispose();
// //     _dateController.dispose();
// //     _timeController.dispose();
// //     super.dispose();
// //   }

// //   void _pickDate() async {
// //     DateTime? pickedDate = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(3000),
// //       builder: (context, child) {
// //         return Theme(
// //           data: Theme.of(context).copyWith(
// //             colorScheme: const ColorScheme.light(
// //               primary: AppColors.primaryColor,
// //               onPrimary: Colors.white,
// //               onSurface: Colors.black,
// //             ),
// //             textButtonTheme: TextButtonThemeData(
// //               style: TextButton.styleFrom(
// //                 foregroundColor: AppColors.primaryColor,
// //               ),
// //             ),
// //           ),
// //           child: child!,
// //         );
// //       },
// //     );

// //     if (pickedDate != null) {
// //       setState(() {
// //         _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
// //       });
// //     }
// //   }

// //   void _pickTime() async {
// //     TimeOfDay? pickedTime = await showTimePicker(
// //       context: context,
// //       initialTime: TimeOfDay.now(),
// //       builder: (context, child) {
// //         return Theme(
// //           data: Theme.of(context).copyWith(
// //             colorScheme: const ColorScheme.light(
// //               primary: AppColors.primaryColor,
// //               onPrimary: Colors.white,
// //               onSurface: Colors.black,
// //             ),
// //             textButtonTheme: TextButtonThemeData(
// //               style: TextButton.styleFrom(
// //                 foregroundColor: AppColors.primaryColor,
// //               ),
// //             ),
// //           ),
// //           child: child!,
// //         );
// //       },
// //     );

// //     if (pickedTime != null) {
// //       setState(() {
// //         _timeController.text = pickedTime.format(context);
// //       });
// //     }
// //   }

// //   void _updateLecture() {
// //     if (_lectureNameController.text.isEmpty ||
// //         _dateController.text.isEmpty ||
// //         _timeController.text.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Please fill all fields')),
// //       );
// //       return;
// //     }

// //     final updatedLecture = LectureModel(
// //       number: widget.lecture.number,
// //       name: _lectureNameController.text,
// //       date: _dateController.text,
// //       time: _timeController.text,
// //       isPresent: widget.lecture.isPresent,
// //     );

// //     context.read<LectureCubit>().updateLecture(updatedLecture);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocListener<LectureCubit, LectureState>(
// //       listener: (context, state) {
// //         print(
// //             'BlocListener state: status=${state.status}, isUpdating=${state.isUpdating}'); // للتصحيح
// //         if (state.status == LectureStatus.success && state.isUpdating) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text('Lecture ${widget.lecture.number} updated')),
// //           );
// //           Future.delayed(const Duration(milliseconds: 500), () {
// //             Navigator.pop(context);
// //           });
// //         } else if (state.status == LectureStatus.failure && state.isUpdating) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text('Error: ${state.errorMessage}')),
// //           );
// //         }
// //       },
// //       child: Scaffold(
// //         backgroundColor: Colors.white,
// //         appBar: AppBar(
// //           iconTheme: const IconThemeData(color: Colors.white),
// //           backgroundColor: AppColors.primaryColor,
// //           centerTitle: true,
// //           title: Text(
// //             'Update Lecture ${widget.lecture.number}',
// //             style: const TextStyle(
// //               fontSize: 22,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //         ),
// //         body: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 TextField(
// //                   controller: _lectureNameController,
// //                   decoration: InputDecoration(
// //                     labelText: 'Lecture Name',
// //                     labelStyle: const TextStyle(color: Colors.black),
// //                     enabledBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide:
// //                           const BorderSide(color: Colors.grey, width: 1),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: const BorderSide(
// //                           color: AppColors.primaryColor, width: 2),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(
// //                         vertical: 15, horizontal: 10),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 10),
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(12),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.grey.withOpacity(0.3),
// //                         blurRadius: 6,
// //                         offset: const Offset(0, 3),
// //                       ),
// //                     ],
// //                   ),
// //                   child: TextField(
// //                     controller: _dateController,
// //                     readOnly: true,
// //                     onTap: _pickDate,
// //                     decoration: InputDecoration(
// //                       labelText: 'Select Date',
// //                       labelStyle: const TextStyle(color: Colors.black),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                         borderSide:
// //                             const BorderSide(color: Colors.grey, width: 1),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                         borderSide: const BorderSide(
// //                             color: AppColors.primaryColor, width: 2),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                           vertical: 15, horizontal: 10),
// //                       suffixIcon: const Icon(Icons.calendar_today),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 10),
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(12),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.grey.withOpacity(0.3),
// //                         blurRadius: 6,
// //                         offset: const Offset(0, 3),
// //                       ),
// //                     ],
// //                   ),
// //                   child: TextField(
// //                     controller: _timeController,
// //                     readOnly: true,
// //                     onTap: _pickTime,
// //                     decoration: InputDecoration(
// //                       labelText: 'Select Time',
// //                       labelStyle: const TextStyle(color: Colors.black),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                         borderSide:
// //                             const BorderSide(color: Colors.grey, width: 1),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                         borderSide: const BorderSide(
// //                             color: AppColors.primaryColor, width: 2),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                           vertical: 15, horizontal: 10),
// //                       suffixIcon: const Icon(Icons.access_time),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 30),
// //                 Center(
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       BlocBuilder<LectureCubit, LectureState>(
// //                         builder: (context, state) {
// //                           return ElevatedButton(
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: AppColors.primaryColor,
// //                               padding: const EdgeInsets.symmetric(
// //                                   horizontal: 40, vertical: 15),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(10),
// //                               ),
// //                             ),
// //                             onPressed: state.status == LectureStatus.loading
// //                                 ? null
// //                                 : _updateLecture,
// //                             child: state.status == LectureStatus.loading
// //                                 ? const CircularProgressIndicator(
// //                                     color: Colors.white,
// //                                   )
// //                                 : const Text(
// //                                     'Update',
// //                                     style: TextStyle(
// //                                       fontSize: 20,
// //                                       color: Colors.white,
// //                                     ),
// //                                   ),
// //                           );
// //                         },
// //                       ),
// //                       const SizedBox(width: 20),
// //                       ElevatedButton(
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.grey,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 40, vertical: 15),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                         ),
// //                         onPressed: () {
// //                           Navigator.pop(context);
// //                         },
// //                         child: const Text(
// //                           'Cancel',
// //                           style: TextStyle(
// //                             fontSize: 20,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
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
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class UpdateLecturePage extends StatelessWidget {
//   final LectureModel lecture;
//   final String courseId;
//   final LectureCubit lectureCubit;

//   const UpdateLecturePage({
//     Key? key,
//     required this.lecture,
//     required this.courseId,
//     required this.lectureCubit,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: lectureCubit,
//       child: UpdateLectureContent(lecture: lecture, courseId: courseId),
//     );
//   }
// }

// class UpdateLectureContent extends StatefulWidget {
//   final LectureModel lecture;
//   final String courseId;

//   const UpdateLectureContent({
//     Key? key,
//     required this.lecture,
//     required this.courseId,
//   }) : super(key: key);

//   @override
//   _UpdateLectureContentState createState() => _UpdateLectureContentState();
// }

// class _UpdateLectureContentState extends State<UpdateLectureContent> {
//   late TextEditingController _lectureNameController;
//   late TextEditingController _dateController;
//   late TextEditingController _timeController;
//   late int startHour;
//   late int startMinute;
//   late String startPeriod;
//   late int endHour;
//   late int endMinute;
//   late String endPeriod;
//   bool isLoading = false;
//   String cameraStatus = 'closed';
//   final _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     _lectureNameController = TextEditingController(text: widget.lecture.name);
//     _dateController = TextEditingController(text: widget.lecture.date);
//     _timeController = TextEditingController(text: widget.lecture.time);
//     startHour = widget.lecture.startHour;
//     startMinute = widget.lecture.startMinute;
//     startPeriod = widget.lecture.startPeriod;
//     endHour = widget.lecture.endHour;
//     endMinute = widget.lecture.endMinute;
//     endPeriod = widget.lecture.endPeriod;

//     _loadCameraStatus();
//     _listenToCameraStatus();
//   }

//   void _loadCameraStatus() async {
//     try {
//       DocumentSnapshot doc =
//           await _firestore.collection('schedule').doc('daily').get();
//       if (doc.exists) {
//         final data = doc.data() as Map<String, dynamic>;
//         setState(() {
//           cameraStatus = data['camera_status'] ?? 'closed';
//         });
//       }
//     } catch (e) {
//       print('Error loading camera status: $e');
//     }
//   }

//   void _listenToCameraStatus() {
//     _firestore.collection('schedule').doc('daily').snapshots().listen(
//       (snapshot) {
//         if (snapshot.exists) {
//           final data = snapshot.data() as Map<String, dynamic>;
//           setState(() {
//             cameraStatus = data['camera_status'] ?? 'closed';
//           });
//         }
//       },
//       onError: (error) {
//         print('Error listening to camera status: $error');
//       },
//     );
//   }

//   void _pickDate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(3000),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (pickedDate != null) {
//       setState(() {
//         _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//       });
//     }
//   }

//   void _pickTime() async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (pickedTime != null) {
//       setState(() {
//         _timeController.text = pickedTime.format(context);
//       });
//     }
//   }

//   void _openCamera() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await _firestore.collection('schedule').doc('daily').set({
//         'camera_status': 'open',
//         'last_updated': Timestamp.now(),
//       }, SetOptions(merge: true));
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Camera opened successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error opening camera: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _closeCamera() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await _firestore.collection('schedule').doc('daily').set({
//         'camera_status': 'stopped',
//         'last_updated': Timestamp.now(),
//       }, SetOptions(merge: true));
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Camera closed successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error closing camera: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _updateLecture() async {
//     if (_lectureNameController.text.isEmpty ||
//         _dateController.text.isEmpty ||
//         _timeController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields')),
//       );
//       return;
//     }

//     // تحويل الأوقات إلى دقائق للتحقق
//     int startHour24 = startHour;
//     if (startPeriod == 'PM' && startHour != 12) startHour24 += 12;
//     if (startPeriod == 'AM' && startHour == 12) startHour24 = 0;
//     int endHour24 = endHour;
//     if (endPeriod == 'PM' && endHour != 12) endHour24 += 12;
//     if (endPeriod == 'AM' && endHour == 12) endHour24 = 0;

//     int startMinutes = startHour24 * 60 + startMinute;
//     int endMinutes = endHour24 * 60 + endMinute;

//     if (endMinutes <= startMinutes) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('End time must be after start time'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final updatedLecture = LectureModel(
//       number: widget.lecture.number,
//       name: _lectureNameController.text,
//       date: _dateController.text,
//       time: _timeController.text,
//       isPresent: widget.lecture.isPresent,
//       startHour: startHour,
//       startMinute: startMinute,
//       startPeriod: startPeriod,
//       endHour: endHour,
//       endMinute: endMinute,
//       endPeriod: endPeriod,
//     );

//     context.read<LectureCubit>().updateLecture(updatedLecture);
//   }

//   @override
//   void dispose() {
//     _lectureNameController.dispose();
//     _dateController.dispose();
//     _timeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<LectureCubit, LectureState>(
//       listener: (context, state) {
//         if (state.status == LectureStatus.success && state.isUpdating) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Lecture ${widget.lecture.number} updated')),
//           );
//           Future.delayed(const Duration(milliseconds: 500), () {
//             Navigator.pop(context);
//           });
//         } else if (state.status == LectureStatus.failure && state.isUpdating) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: ${state.errorMessage}')),
//           );
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           iconTheme: const IconThemeData(color: Colors.white),
//           backgroundColor: AppColors.primaryColor,
//           centerTitle: true,
//           title: Text(
//             'Update Lecture ${widget.lecture.number}',
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   controller: _lectureNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Lecture Name',
//                     labelStyle: const TextStyle(color: Colors.black),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Colors.grey, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                           color: AppColors.primaryColor, width: 2),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 15, horizontal: 10),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _dateController,
//                     readOnly: true,
//                     onTap: _pickDate,
//                     decoration: InputDecoration(
//                       labelText: 'Select Date',
//                       labelStyle: const TextStyle(color: Colors.black),
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
//                       suffixIcon: const Icon(Icons.calendar_today),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _timeController,
//                     readOnly: true,
//                     onTap: _pickTime,
//                     decoration: InputDecoration(
//                       labelText: 'Select Time',
//                       labelStyle: const TextStyle(color: Colors.black),
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
//                       suffixIcon: const Icon(Icons.access_time),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Start Time',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildDropdown(
//                       value: startHour,
//                       items: List.generate(12, (index) => index + 1),
//                       onChanged: (value) => setState(() => startHour = value!),
//                       width: 80,
//                     ),
//                     const Text(
//                       ':',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.black,
//                       ),
//                     ),
//                     _buildDropdown(
//                       value: startMinute,
//                       items: List.generate(60, (index) => index),
//                       onChanged: (value) =>
//                           setState(() => startMinute = value!),
//                       width: 80,
//                       format: (value) => value.toString().padLeft(2, '0'),
//                     ),
//                     const SizedBox(width: 10),
//                     _buildDropdown(
//                       value: startPeriod,
//                       items: const ['AM', 'PM'],
//                       onChanged: (value) =>
//                           setState(() => startPeriod = value!),
//                       width: 80,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'End Time',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildDropdown(
//                       value: endHour,
//                       items: List.generate(12, (index) => index + 1),
//                       onChanged: (value) => setState(() => endHour = value!),
//                       width: 80,
//                     ),
//                     const Text(
//                       ':',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.black,
//                       ),
//                     ),
//                     _buildDropdown(
//                       value: endMinute,
//                       items: List.generate(60, (index) => index),
//                       onChanged: (value) => setState(() => endMinute = value!),
//                       width: 80,
//                       format: (value) => value.toString().padLeft(2, '0'),
//                     ),
//                     const SizedBox(width: 10),
//                     _buildDropdown(
//                       value: endPeriod,
//                       items: const ['AM', 'PM'],
//                       onChanged: (value) => setState(() => endPeriod = value!),
//                       width: 80,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       BlocBuilder<LectureCubit, LectureState>(
//                         builder: (context, state) {
//                           return ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primaryColor,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 40, vertical: 15),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             onPressed: state.status == LectureStatus.loading
//                                 ? null
//                                 : _updateLecture,
//                             child: state.status == LectureStatus.loading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                 : const Text(
//                                     'Update',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           );
//                         },
//                       ),
//                       const SizedBox(width: 20),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 15),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           cameraStatus == 'open' ? Colors.red : Colors.green,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 40, vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: isLoading
//                         ? null
//                         : (cameraStatus == 'open' ? _closeCamera : _openCamera),
//                     child: isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             cameraStatus == 'open'
//                                 ? 'Close Camera'
//                                 : 'Open Camera',
//                             style: const TextStyle(
//                               fontSize: 20,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown<T>({
//     required T value,
//     required List<T> items,
//     required ValueChanged<T?> onChanged,
//     required double width,
//     String Function(T)? format,
//   }) {
//     return Container(
//       width: width,
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<T>(
//           value: value,
//           items: items.map((item) {
//             return DropdownMenuItem<T>(
//               value: item,
//               child: Text(
//                 format != null ? format(item) : item.toString(),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: onChanged,
//           isExpanded: true,
//           icon:
//               const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
//           dropdownColor: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_cubit.dart';
import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_state.dart';
import 'package:attendance_app/features/attendance/models/lecture_model_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateLecturePage extends StatelessWidget {
  final LectureModel lecture;
  final String courseId;
  final LectureCubit lectureCubit;

  const UpdateLecturePage({
    super.key,
    required this.lecture,
    required this.courseId,
    required this.lectureCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: lectureCubit,
      child: UpdateLectureContent(lecture: lecture, courseId: courseId),
    );
  }
}

class UpdateLectureContent extends StatefulWidget {
  final LectureModel lecture;
  final String courseId;

  const UpdateLectureContent({
    super.key,
    required this.lecture,
    required this.courseId,
  });

  @override
  _UpdateLectureContentState createState() => _UpdateLectureContentState();
}

class _UpdateLectureContentState extends State<UpdateLectureContent> {
  late TextEditingController _lectureNameController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late int startHour;
  late int startMinute;
  late String startPeriod;
  late int endHour;
  late int endMinute;
  late String endPeriod;
  bool isLoading = false;
  String cameraStatus = 'closed';
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _lectureNameController = TextEditingController(text: widget.lecture.name);
    _dateController = TextEditingController(text: widget.lecture.date);
    _timeController = TextEditingController(text: widget.lecture.time);
    startHour = widget.lecture.startHour;
    startMinute = widget.lecture.startMinute;
    startPeriod = widget.lecture.startPeriod;
    endHour = widget.lecture.endHour;
    endMinute = widget.lecture.endMinute;
    endPeriod = widget.lecture.endPeriod;
    cameraStatus = widget.lecture.cameraStatus;

    _listenToCameraStatus();
  }

  void _listenToCameraStatus() {
    _firestore
        .collection('Courses')
        .doc(widget.courseId)
        .collection('lectures')
        .where('lectureNumber', isEqualTo: widget.lecture.number)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          setState(() {
            cameraStatus = data['camera_status'] ?? 'closed';
          });
        }
      },
      onError: (error) {
        print('Error listening to camera status: $error');
      },
    );
  }

  void _pickDate() async {
    DateTime currentDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      selectableDayPredicate: (DateTime date) {
        return date.isAfter(currentDate.subtract(const Duration(days: 1))) ||
            date.isAtSameMomentAs(currentDate);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  // void _pickDate() async {
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(3000),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: const ColorScheme.light(
  //             primary: AppColors.primaryColor,
  //             onPrimary: Colors.white,
  //             onSurface: Colors.black,
  //           ),
  //           textButtonTheme: TextButtonThemeData(
  //             style: TextButton.styleFrom(
  //               foregroundColor: AppColors.primaryColor,
  //             ),
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (pickedDate != null) {
  //     setState(() {
  //       _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
  //     });
  //   }
  // }

  // void _pickTime() async {
  //   TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: const ColorScheme.light(
  //             primary: AppColors.primaryColor,
  //             onPrimary: Colors.white,
  //             onSurface: Colors.black,
  //           ),
  //           textButtonTheme: TextButtonThemeData(
  //             style: TextButton.styleFrom(
  //               foregroundColor: AppColors.primaryColor,
  //             ),
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (pickedTime != null) {
  //     setState(() {
  //       _timeController.text = pickedTime.format(context);
  //     });
  //   }
  // }

  void _pickTime() async {
    DateTime currentDateTime = DateTime.now();
    TimeOfDay currentTime = TimeOfDay.fromDateTime(currentDateTime);
    TimeOfDay initialTime = currentTime;
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // Convert pickedTime and currentTime to 24-hour format for comparison
      int pickedHour24 = pickedTime.hour;
      int currentHour24 = currentTime.hour;
      if (pickedTime.period == DayPeriod.pm && pickedTime.hour != 12)
        pickedHour24 += 12;
      if (pickedTime.period == DayPeriod.am && pickedTime.hour == 12)
        pickedHour24 = 0;
      if (currentTime.period == DayPeriod.pm && currentTime.hour != 12)
        currentHour24 += 12;
      if (currentTime.period == DayPeriod.am && currentTime.hour == 12)
        currentHour24 = 0;

      int pickedMinutes = pickedHour24 * 60 + pickedTime.minute;
      int currentMinutes = currentHour24 * 60 + currentTime.minute;

      // Reset to current time if picked time is earlier
      if (pickedMinutes < currentMinutes) {
        pickedTime = currentTime;
      }
      setState(() {
        _timeController.text = pickedTime!.format(context);
      });
    }
  }

  void _openCamera() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentReference courseRef =
          _firestore.collection('Courses').doc(widget.courseId);
      QuerySnapshot lecturesSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: widget.lecture.number)
          .get();

      if (lecturesSnapshot.docs.isNotEmpty) {
        var lectureDoc = lecturesSnapshot.docs.first;
        await lectureDoc.reference.update({
          'camera_status': 'open',
          'last_updated': Timestamp.now(),
        });
      }

      setState(() {
        cameraStatus = 'open';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera opened successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _closeCamera() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentReference courseRef =
          _firestore.collection('Courses').doc(widget.courseId);
      QuerySnapshot lecturesSnapshot = await courseRef
          .collection('lectures')
          .where('lectureNumber', isEqualTo: widget.lecture.number)
          .get();

      if (lecturesSnapshot.docs.isNotEmpty) {
        var lectureDoc = lecturesSnapshot.docs.first;
        await lectureDoc.reference.update({
          'camera_status': 'closed',
          'last_updated': Timestamp.now(),
        });
      }

      setState(() {
        cameraStatus = 'closed';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera closed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error closing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateLecture() async {
    if (_lectureNameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    int startHour24 = startHour;
    if (startPeriod == 'PM' && startHour != 12) startHour24 += 12;
    if (startPeriod == 'AM' && startHour == 12) startHour24 = 0;
    int endHour24 = endHour;
    if (endPeriod == 'PM' && endHour != 12) endHour24 += 12;
    if (endPeriod == 'AM' && endHour == 12) endHour24 = 0;

    int startMinutes = startHour24 * 60 + startMinute;
    int endMinutes = endHour24 * 60 + endMinute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedLecture = widget.lecture.copyWith(
      name: _lectureNameController.text,
      date: _dateController.text,
      time: _timeController.text,
      startHour: startHour,
      startMinute: startMinute,
      startPeriod: startPeriod,
      endHour: endHour,
      endMinute: endMinute,
      endPeriod: endPeriod,
      cameraStatus: cameraStatus,
    );

    context.read<LectureCubit>().updateLecture(updatedLecture);
  }

  @override
  void dispose() {
    _lectureNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LectureCubit, LectureState>(
      listener: (context, state) {
        if (state.status == LectureStatus.success && state.isUpdating) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lecture ${widget.lecture.number} updated')),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        } else if (state.status == LectureStatus.failure && state.isUpdating) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.errorMessage}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          title: Text(
            'Update Lecture ${widget.lecture.number}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _lectureNameController,
                  decoration: InputDecoration(
                    labelText: 'Lecture Name',
                    labelStyle: const TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      labelStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: _pickTime,
                    decoration: InputDecoration(
                      labelText: 'Select Time',
                      labelStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Start Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDropdown(
                      value: startHour,
                      items: List.generate(12, (index) => index + 1),
                      onChanged: (value) => setState(() => startHour = value!),
                      width: 80,
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    _buildDropdown(
                      value: startMinute,
                      items: List.generate(60, (index) => index),
                      onChanged: (value) =>
                          setState(() => startMinute = value!),
                      width: 80,
                      format: (value) => value.toString().padLeft(2, '0'),
                    ),
                    const SizedBox(width: 10),
                    _buildDropdown(
                      value: startPeriod,
                      items: const ['AM', 'PM'],
                      onChanged: (value) =>
                          setState(() => startPeriod = value!),
                      width: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'End Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDropdown(
                      value: endHour,
                      items: List.generate(12, (index) => index + 1),
                      onChanged: (value) => setState(() => endHour = value!),
                      width: 80,
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    _buildDropdown(
                      value: endMinute,
                      items: List.generate(60, (index) => index),
                      onChanged: (value) => setState(() => endMinute = value!),
                      width: 80,
                      format: (value) => value.toString().padLeft(2, '0'),
                    ),
                    const SizedBox(width: 10),
                    _buildDropdown(
                      value: endPeriod,
                      items: const ['AM', 'PM'],
                      onChanged: (value) => setState(() => endPeriod = value!),
                      width: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocBuilder<LectureCubit, LectureState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: state.status == LectureStatus.loading
                                ? null
                                : _updateLecture,
                            child: state.status == LectureStatus.loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          cameraStatus == 'open' ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : (cameraStatus == 'open' ? _closeCamera : _openCamera),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            cameraStatus == 'open'
                                ? 'Close Camera'
                                : 'Open Camera',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required double width,
    String Function(T)? format,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                format != null ? format(item) : item.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon:
              const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
