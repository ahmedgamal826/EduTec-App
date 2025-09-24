// // import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_cubit.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:intl/intl.dart';

// // class ScheduleScreen extends StatefulWidget {
// //   final String courseId;
// //   final LectureCubit lectureCubit;
// //   const ScheduleScreen({
// //     Key? key,
// //     required this.courseId,
// //     required this.lectureCubit,
// //   }) : super(key: key);

// //   @override
// //   _ScheduleScreenState createState() => _ScheduleScreenState();
// // }

// // class _ScheduleScreenState extends State<ScheduleScreen>
// //     with SingleTickerProviderStateMixin {
// //   final _firestore = FirebaseFirestore.instance;
// //   int startHour = 1;
// //   int startMinute = 0;
// //   String startPeriod = 'AM';
// //   int endHour = 1;
// //   int endMinute = 0;
// //   String endPeriod = 'AM';
// //   bool isLoading = false;
// //   String cameraStatus = 'closed';
// //   final TextEditingController _lectureNameController = TextEditingController();
// //   final TextEditingController _dateController = TextEditingController();
// //   late AnimationController _animationController;
// //   late Animation<double> _buttonScaleAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _lectureNameController.text = '';
// //     _dateController.text = '';
// //     startHour = 1;
// //     startMinute = 0;
// //     startPeriod = 'AM';
// //     endHour = 1;
// //     endMinute = 0;
// //     endPeriod = 'AM';
// //     cameraStatus = 'closed';

// //     _animationController = AnimationController(
// //       duration: const Duration(milliseconds: 200),
// //       vsync: this,
// //     );
// //     _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
// //       CurvedAnimation(
// //         parent: _animationController,
// //         curve: Curves.easeInOut,
// //       ),
// //     );

// //     _loadInitialSchedule();
// //     _listenToCameraStatus();
// //   }

// //   void _loadInitialSchedule() async {
// //     try {
// //       DocumentSnapshot doc =
// //           await _firestore.collection('schedule').doc('daily').get();
// //       if (doc.exists) {
// //         final data = doc.data() as Map<String, dynamic>;
// //         setState(() {
// //           startHour = data['start_hour_12'] ?? 1;
// //           startMinute = data['start_minute'] ?? 0;
// //           startPeriod = data['start_period'] ?? 'AM';
// //           endHour = data['end_hour_12'] ?? 1;
// //           endMinute = data['end_minute'] ?? 0;
// //           endPeriod = data['end_period'] ?? 'AM';
// //           cameraStatus = data['camera_status'] ?? 'closed';
// //         });
// //       }
// //     } catch (e) {
// //       print('Error loading initial schedule: $e');
// //     }
// //   }

// //   void _listenToCameraStatus() {
// //     _firestore.collection('schedule').doc('daily').snapshots().listen(
// //       (snapshot) {
// //         if (snapshot.exists) {
// //           final data = snapshot.data() as Map<String, dynamic>;
// //           setState(() {
// //             cameraStatus = data['camera_status'] ?? 'closed';
// //           });
// //         }
// //       },
// //       onError: (error) {
// //         print('Error listening to camera status: $error');
// //       },
// //     );
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
// //             colorScheme: ColorScheme.light(
// //               primary: Colors.blue.shade700,
// //               onPrimary: Colors.white,
// //               onSurface: Colors.black,
// //             ),
// //             textButtonTheme: TextButtonThemeData(
// //               style: TextButton.styleFrom(
// //                 foregroundColor: Colors.blue.shade700,
// //               ),
// //             ),
// //           ),
// //           child: child!,
// //         );
// //       },
// //     );

// //     if (pickedDate != null) {
// //       setState(() {
// //         _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
// //       });
// //     }
// //   }

// //   // void _saveSchedule() async {
// //   //   if (_lectureNameController.text.isEmpty) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       const SnackBar(
// //   //         content: Text('Please enter lecture name'),
// //   //         backgroundColor: Colors.red,
// //   //       ),
// //   //     );
// //   //     return;
// //   //   }

// //   //   if (_dateController.text.isEmpty) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       const SnackBar(
// //   //         content: Text('Please select a date'),
// //   //         backgroundColor: Colors.red,
// //   //       ),
// //   //     );
// //   //     return;
// //   //   }

// //   //   int startHour24 = startHour;
// //   //   if (startPeriod == 'PM' && startHour != 12) startHour24 += 12;
// //   //   if (startPeriod == 'AM' && startHour == 12) startHour24 = 0;
// //   //   int endHour24 = endHour;
// //   //   if (endPeriod == 'PM' && endHour != 12) endHour24 += 12;
// //   //   if (endPeriod == 'AM' && endHour == 12) endHour24 = 0;

// //   //   int startMinutes = startHour24 * 60 + startMinute;
// //   //   int endMinutes = endHour24 * 60 + endMinute;

// //   //   if (endMinutes <= startMinutes) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       const SnackBar(
// //   //         content: Text('End time must be after start time'),
// //   //         backgroundColor: Colors.red,
// //   //       ),
// //   //     );
// //   //     return;
// //   //   }

// //   //   setState(() {
// //   //     isLoading = true;
// //   //   });

// //   //   try {
// //   //     await _firestore.collection('schedule').doc('daily').set({
// //   //       'start_hour_12': startHour,
// //   //       'start_minute': startMinute,
// //   //       'start_period': startPeriod,
// //   //       'end_hour_12': endHour,
// //   //       'end_minute': endMinute,
// //   //       'end_period': endPeriod,
// //   //       'camera_status': 'closed',
// //   //       'lecture_name': _lectureNameController.text,
// //   //       'date': _dateController.text,
// //   //       'last_updated': Timestamp.now(),
// //   //     });

// //   //     // جلب عدد المحاضرات الحالية لحساب lectureNumber
// //   //     final lecturesSnapshot = await _firestore
// //   //         .collection('Courses')
// //   //         .doc(widget.courseId)
// //   //         .collection('lectures')
// //   //         .get();
// //   //     final lectureCount = lecturesSnapshot.docs.length;
// //   //     final newLectureNumber = lectureCount + 1;

// //   //     // إضافة المحاضرة الجديدة مع lectureNumber
// //   //     DocumentReference courseRef =
// //   //         _firestore.collection('Courses').doc(widget.courseId);
// //   //     await courseRef.collection('lectures').add({
// //   //       'name': _lectureNameController.text,
// //   //       'date': _dateController.text,
// //   //       'time':
// //   //           '$startHour:${startMinute.toString().padLeft(2, '0')} $startPeriod',
// //   //       'created_at': Timestamp.now(),
// //   //       'lectureNumber': newLectureNumber,
// //   //     });

// //   //     widget.lectureCubit.loadLectures();

// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       SnackBar(
// //   //         content: Text(
// //   //             'Schedule saved successfully: ${_lectureNameController.text} on ${_dateController.text}'),
// //   //         backgroundColor: Colors.green,
// //   //       ),
// //   //     );

// //   //     Navigator.pop(context);
// //   //   } catch (e) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       SnackBar(
// //   //         content: Text('Error saving schedule: $e'),
// //   //         backgroundColor: Colors.red,
// //   //       ),
// //   //     );
// //   //   } finally {
// //   //     setState(() {
// //   //       isLoading = false;
// //   //     });
// //   //   }
// //   // }

// //   // void _saveSchedule() async {
// //   //   if (_lectureNameController.text.isEmpty) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       const SnackBar(
// //   //         content: Text('Please enter lecture name'),
// //   //         backgroundColor: Colors.red,
// //   //       ),
// //   //     );
// //   //     return;
// //   //   }

// //   //   if (_dateController.text.isEmpty) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       const SnackBar(
// //   //         content: Text('Please select a date'),
// //   //         backgroundColor: Colors.red,
// //   //       ),
// //   //     );
// //   //     return;
// //   //   }

// //   //   int startHour24 = startHour;
// //   //   if (startPeriod == 'PM' && startHour != 12) startHour24 += 12;
// //   //   if (startPeriod == 'AM' && startHour == 12) startHour24 = 0;
// //   //   int endHour24 = endHour;
// //   //   if (endPeriod == 'PM' && endHour != 12) endHour24 += 12;
// //   //   if (endPeriod == 'AM' && endHour == 12) endHour24 = 0;

// //   //   int startMinutes = startHour24 * 60 + startMinute;
// //   //   int endMinutes = endHour24 * 60 + endMinute;

// //   //   if (endMinutes <= startMinutes) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       const SnackBar(
// //   //         content: Text('End time must be after start time'),
// //   //         backgroundColor: Colors.red,
// //   //       ),
// //   //     );
// //   //     return;
// //   //   }

// //   //   setState(() {
// //   //     isLoading = true;
// //   //   });

// //   //   try {
// //   //     await _firestore.collection('schedule').doc('daily').set({
// //   //       'start_hour_12': startHour,
// //   //       'start_minute': startMinute,
// //   //       'start_period': startPeriod,
// //   //       'end_hour_12': endHour,
// //   //       'end_minute': endMinute,
// //   //       'end_period': endPeriod,
// //   //       'camera_status': 'closed',
// //   //       'lecture_name': _lectureNameController.text,
// //   //       'date': _dateController.text,
// //   //       'last_updated': Timestamp.now(),
// //   //     });

// //   //     // جلب عدد المحاضرات الحالية لحساب lectureNumber
// //   //     final lecturesSnapshot = await _firestore
// //   //         .collection('Courses')
// //   //         .doc(widget.courseId)
// //   //         .collection('lectures')
// //   //         .get();
// //   //     final lectureCount = lecturesSnapshot.docs.length;
// //   //     final newLectureNumber = lectureCount + 1;

// //   //     print('Adding lecture to courseId: ${widget.courseId}'); // للتصحيح
// //   //     print('Total existing lectures: $lectureCount'); // للتصحيح
// //   //     print('New lecture number: $newLectureNumber'); // للتصحيح

// //   //     // إضافة المحاضرة الجديدة مع lectureNumber
// //   //     DocumentReference courseRef =
// //   //         _firestore.collection('Courses').doc(widget.courseId);
// //   //     DocumentReference lectureRef =
// //   //         await courseRef.collection('lectures').add({
// //   //       'name': _lectureNameController.text,
// //   //       'date': _dateController.text,
// //   //       'time':
// //   //           '$startHour:${startMinute.toString().padLeft(2, '0')} $startPeriod',
// //   //       'created_at': Timestamp.now(),
// //   //       'lectureNumber': newLectureNumber,
// //   //     });

// //   //     print('Lecture added with ID: ${lectureRef.id}'); // للتصحيح
// //   //     print('Lecture path: ${lectureRef.path}'); // للتصحيح

// //   //     // إنشاء attendance collection تحت المحاضرة الجديدة
// //   //     CollectionReference attendanceRef = lectureRef.collection('attendance');
// //   //     print(
// //   //         'Attendance collection reference created: ${attendanceRef.path}'); // للتصحيح

// //   //     // إضافة وثيقة دائمة للتأكد من إنشاء الـ attendance collection
// //   //     await attendanceRef.doc('placeholder').set({
// //   //       'placeholder':
// //   //           'This is a placeholder document to ensure attendance collection creation',
// //   //       'created_at': Timestamp.now(),
// //   //     });
// //   //     print(
// //   //         'Placeholder document added to attendance collection for lecture: ${lectureRef.id}'); // للتصحيح

// //   //     widget.lectureCubit.loadLectures();

// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       SnackBar(
// //   //         content: Text(
// //   //             'Schedule saved successfully: ${_lectureNameController.text} on ${_dateController.text}'),
// //   //         backgroundColor: Colors.green,
// //   //       ),
// //   //     );

// //   //     Navigator.pop(context);
// //   //   } catch (e) {
// //   //     print(
// //   //         'Error saving schedule or creating attendance collection: $e'); // للتصحيح
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       SnackBar(
// //   //         content: Text('Error saving schedule: $e'),
// //   //         backgroundColor: Colors.red,
// //   //       ),
// //   //     );
// //   //   } finally {
// //   //     setState(() {
// //   //       isLoading = false;
// //   //     });
// //   //   }
// //   // }

// //   void _saveSchedule() async {
// //     if (_lectureNameController.text.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Please enter lecture name'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }

// //     if (_dateController.text.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Please select a date'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }

// //     int startHour24 = startHour;
// //     if (startPeriod == 'PM' && startHour != 12) startHour24 += 12;
// //     if (startPeriod == 'AM' && startHour == 12) startHour24 = 0;
// //     int endHour24 = endHour;
// //     if (endPeriod == 'PM' && endHour != 12) endHour24 += 12;
// //     if (endPeriod == 'AM' && endHour == 12) endHour24 = 0;

// //     int startMinutes = startHour24 * 60 + startMinute;
// //     int endMinutes = endHour24 * 60 + endMinute;

// //     if (endMinutes <= startMinutes) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('End time must be after start time'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }

// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       await _firestore.collection('schedule').doc('daily').set({
// //         'start_hour_12': startHour,
// //         'start_minute': startMinute,
// //         'start_period': startPeriod,
// //         'end_hour_12': endHour,
// //         'end_minute': endMinute,
// //         'end_period': endPeriod,
// //         'camera_status': 'closed',
// //         'lecture_name': _lectureNameController.text,
// //         'date': _dateController.text,
// //         'last_updated': Timestamp.now(),
// //       });

// //       // جلب عدد المحاضرات الحالية لحساب lectureNumber
// //       final lecturesSnapshot = await _firestore
// //           .collection('Courses')
// //           .doc(widget.courseId)
// //           .collection('lectures')
// //           .get();
// //       final lectureCount = lecturesSnapshot.docs.length;
// //       final newLectureNumber = lectureCount + 1;

// //       print('Adding lecture to courseId: ${widget.courseId}');
// //       print('Total existing lectures: $lectureCount');
// //       print('New lecture number: $newLectureNumber');

// //       // إضافة المحاضرة الجديدة مع lectureNumber
// //       DocumentReference courseRef =
// //           _firestore.collection('Courses').doc(widget.courseId);
// //       DocumentReference lectureRef =
// //           await courseRef.collection('lectures').add({
// //         'name': _lectureNameController.text,
// //         'date': _dateController.text,
// //         'time':
// //             '$startHour:${startMinute.toString().padLeft(2, '0')} $startPeriod',
// //         'created_at': Timestamp.now(),
// //         'lectureNumber': newLectureNumber,
// //       });

// //       print('Lecture added with ID: ${lectureRef.id}');
// //       print('Lecture path: ${lectureRef.path}');

// //       // إنشاء attendance collection تحت المحاضرة الجديدة
// //       CollectionReference attendanceRef = lectureRef.collection('attendance');
// //       print('Attendance collection reference created: ${attendanceRef.path}');

// //       // قايمة الطلاب (مثال، ممكن تجيبها من مصدر بياناتك)
// //       List<Map<String, dynamic>> students = [
// //         {
// //           'name': 'Student 1',
// //           'imageUrl': 'https://i.pravatar.cc/150?img=1',
// //           'isPresent': false,
// //           'isLocalImage': false,
// //           'isStarred': false,
// //         },
// //         {
// //           'name': 'Student 2',
// //           'imageUrl': 'https://i.pravatar.cc/150?img=2',
// //           'isPresent': false,
// //           'isLocalImage': false,
// //           'isStarred': false,
// //         },
// //         {
// //           'name': 'Student 3',
// //           'imageUrl': 'https://i.pravatar.cc/150?img=3',
// //           'isPresent': false,
// //           'isLocalImage': false,
// //           'isStarred': false,
// //         },
// //       ];

// //       // إضافة الطلاب للـ attendance collection
// //       for (var student in students) {
// //         await attendanceRef.add(student);
// //       }
// //       print(
// //           'Students added to attendance collection for lecture: ${lectureRef.id}');

// //       widget.lectureCubit.loadLectures();

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(
// //               'Schedule saved successfully: ${_lectureNameController.text} on ${_dateController.text}'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );

// //       Navigator.pop(context);
// //     } catch (e) {
// //       print('Error saving schedule or adding students: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Error saving schedule: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     } finally {
// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   void _closeCamera() async {
// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       await _firestore.collection('schedule').doc('daily').update({
// //         'camera_status': 'stopped',
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Camera closed successfully'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Error closing camera: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     } finally {
// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   void _openCamera() async {
// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       await _firestore.collection('schedule').doc('daily').update({
// //         'camera_status': 'open',
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Camera opened successfully'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Error opening camera: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     } finally {
// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _lectureNameController.dispose();
// //     _dateController.dispose();
// //     _animationController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: BoxDecoration(
// //           // gradient: LinearGradient(
// //           //   colors: [Colors.blue.shade100, Colors.blue.shade300],
// //           //   begin: Alignment.topLeft,
// //           //   end: Alignment.bottomRight,
// //           // ),

// //           color: Colors.blue.shade300,
// //         ),
// //         child: SafeArea(
// //           child: Padding(
// //             padding: const EdgeInsets.all(20.0),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         'Add Lecture',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 26,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                           shadows: [
// //                             Shadow(
// //                               color: Colors.black.withOpacity(0.2),
// //                               offset: const Offset(2, 2),
// //                               blurRadius: 4,
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       IconButton(
// //                         icon: const Icon(Icons.close,
// //                             color: Colors.white, size: 30),
// //                         onPressed: () => Navigator.pop(context),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Text(
// //                     'Lecture Name',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.95),
// //                       borderRadius: BorderRadius.circular(15),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.1),
// //                           blurRadius: 8,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: TextField(
// //                       controller: _lectureNameController,
// //                       decoration: InputDecoration(
// //                         hintText: 'Enter lecture name',
// //                         hintStyle: GoogleFonts.poppins(
// //                           color: Colors.grey.shade600,
// //                         ),
// //                         border: InputBorder.none,
// //                         contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 15,
// //                           vertical: 15,
// //                         ),
// //                         prefixIcon: Icon(
// //                           Icons.book,
// //                           color: Colors.blue.shade700,
// //                         ),
// //                       ),
// //                       style: GoogleFonts.poppins(
// //                         color: Colors.blue.shade900,
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Text(
// //                     'Date',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.95),
// //                       borderRadius: BorderRadius.circular(15),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.1),
// //                           blurRadius: 8,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: TextField(
// //                       controller: _dateController,
// //                       readOnly: true,
// //                       onTap: _pickDate,
// //                       decoration: InputDecoration(
// //                         hintText: 'Select date (DD/MM/YYYY)',
// //                         hintStyle: GoogleFonts.poppins(
// //                           color: Colors.grey.shade600,
// //                         ),
// //                         border: InputBorder.none,
// //                         contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 15,
// //                           vertical: 15,
// //                         ),
// //                         suffixIcon: Icon(
// //                           Icons.calendar_today,
// //                           color: Colors.blue.shade700,
// //                         ),
// //                       ),
// //                       style: GoogleFonts.poppins(
// //                         color: Colors.blue.shade900,
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 30),
// //                   Center(
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                           horizontal: 15, vertical: 8),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white.withOpacity(0.95),
// //                         borderRadius: BorderRadius.circular(20),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.black.withOpacity(0.1),
// //                             blurRadius: 8,
// //                             offset: const Offset(0, 4),
// //                           ),
// //                         ],
// //                       ),
// //                       child: Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Icon(
// //                             cameraStatus == 'open'
// //                                 ? Icons.videocam
// //                                 : Icons.videocam_off,
// //                             color: cameraStatus == 'open'
// //                                 ? Colors.green
// //                                 : Colors.red,
// //                             size: 20,
// //                           ),
// //                           const SizedBox(width: 8),
// //                           Text(
// //                             cameraStatus == 'open'
// //                                 ? 'Camera Open'
// //                                 : 'Camera Closed',
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 14,
// //                               color: cameraStatus == 'open'
// //                                   ? Colors.green
// //                                   : Colors.red,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 30),
// //                   Text(
// //                     'Start Time',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       _buildDropdown(
// //                         value: startHour,
// //                         items: List.generate(12, (index) => index + 1),
// //                         onChanged: (value) =>
// //                             setState(() => startHour = value!),
// //                         width: 80,
// //                       ),
// //                       Text(
// //                         ':',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 20,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                       _buildDropdown(
// //                         value: startMinute,
// //                         items: List.generate(60, (index) => index),
// //                         onChanged: (value) =>
// //                             setState(() => startMinute = value!),
// //                         width: 80,
// //                         format: (value) => value.toString().padLeft(2, '0'),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       _buildDropdown(
// //                         value: startPeriod,
// //                         items: const ['AM', 'PM'],
// //                         onChanged: (value) =>
// //                             setState(() => startPeriod = value!),
// //                         width: 80,
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 30),
// //                   Text(
// //                     'End Time',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       _buildDropdown(
// //                         value: endHour,
// //                         items: List.generate(12, (index) => index + 1),
// //                         onChanged: (value) => setState(() => endHour = value!),
// //                         width: 80,
// //                       ),
// //                       Text(
// //                         ':',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 20,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                       _buildDropdown(
// //                         value: endMinute,
// //                         items: List.generate(60, (index) => index),
// //                         onChanged: (value) =>
// //                             setState(() => endMinute = value!),
// //                         width: 80,
// //                         format: (value) => value.toString().padLeft(2, '0'),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       _buildDropdown(
// //                         value: endPeriod,
// //                         items: const ['AM', 'PM'],
// //                         onChanged: (value) =>
// //                             setState(() => endPeriod = value!),
// //                         width: 80,
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 40),
// //                   Center(
// //                     child: ScaleTransition(
// //                       scale: _buttonScaleAnimation,
// //                       child: ElevatedButton.icon(
// //                         onPressed: isLoading
// //                             ? null
// //                             : () {
// //                                 _animationController.forward(from: 0);
// //                                 _saveSchedule();
// //                               },
// //                         icon: isLoading
// //                             ? const SizedBox(
// //                                 width: 20,
// //                                 height: 20,
// //                                 child: CircularProgressIndicator(
// //                                   strokeWidth: 2,
// //                                   valueColor: AlwaysStoppedAnimation<Color>(
// //                                       Colors.white),
// //                                 ),
// //                               )
// //                             : const Icon(Icons.save, color: Colors.white),
// //                         label: Text(
// //                           isLoading ? 'Saving...' : 'Save Schedule',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 16,
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.blue.shade700,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 30, vertical: 15),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(30),
// //                           ),
// //                           elevation: 8,
// //                           shadowColor: Colors.black.withOpacity(0.3),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Center(
// //                     child: ScaleTransition(
// //                       scale: _buttonScaleAnimation,
// //                       child: ElevatedButton.icon(
// //                         onPressed: (isLoading || cameraStatus != 'open')
// //                             ? null
// //                             : () {
// //                                 _animationController.forward(from: 0);
// //                                 _closeCamera();
// //                               },
// //                         icon:
// //                             const Icon(Icons.videocam_off, color: Colors.white),
// //                         label: Text(
// //                           isLoading ? 'Closing...' : 'Close Camera',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 16,
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.red.shade600,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 30, vertical: 15),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(30),
// //                           ),
// //                           elevation: 8,
// //                           shadowColor: Colors.black.withOpacity(0.3),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   // Center(
// //                   //   child: ScaleTransition(
// //                   //     scale: _buttonScaleAnimation,
// //                   //     child: ElevatedButton.icon(
// //                   //       onPressed: (isLoading || cameraStatus == 'open')
// //                   //           ? null
// //                   //           : () {
// //                   //               _animationController.forward(from: 0);
// //                   //               _openCamera();
// //                   //             },
// //                   //       icon: const Icon(Icons.videocam, color: Colors.white),
// //                   //       label: Text(
// //                   //         isLoading ? 'Opening...' : 'Open Camera',
// //                   //         style: GoogleFonts.poppins(
// //                   //           fontSize: 16,
// //                   //           color: Colors.white,
// //                   //           fontWeight: FontWeight.w600,
// //                   //         ),
// //                   //       ),
// //                   //       style: ElevatedButton.styleFrom(
// //                   //         backgroundColor: Colors.green.shade600,
// //                   //         padding: const EdgeInsets.symmetric(
// //                   //             horizontal: 30, vertical: 15),
// //                   //         shape: RoundedRectangleBorder(
// //                   //           borderRadius: BorderRadius.circular(30),
// //                   //         ),
// //                   //         elevation: 8,
// //                   //         shadowColor: Colors.black.withOpacity(0.3),
// //                   //       ),
// //                   //     ),
// //                   //   ),
// //                   // ),

// //                   Center(
// //                     child: ScaleTransition(
// //                       scale: _buttonScaleAnimation,
// //                       child: ElevatedButton.icon(
// //                         onPressed: (isLoading ||
// //                                 cameraStatus == 'open' ||
// //                                 _lectureNameController.text.isEmpty ||
// //                                 _dateController.text.isEmpty)
// //                             ? null
// //                             : () {
// //                                 _animationController.forward(from: 0);
// //                                 _openCamera();
// //                               },
// //                         icon: const Icon(Icons.videocam, color: Colors.white),
// //                         label: Text(
// //                           isLoading ? 'Opening...' : 'Open Camera',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 16,
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.green.shade600,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 30, vertical: 15),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(30),
// //                           ),
// //                           elevation: 8,
// //                           shadowColor: Colors.black.withOpacity(0.3),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDropdown<T>({
// //     required T value,
// //     required List<T> items,
// //     required ValueChanged<T?> onChanged,
// //     required double width,
// //     String Function(T)? format,
// //   }) {
// //     return Container(
// //       width: width,
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.95),
// //         borderRadius: BorderRadius.circular(15),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 8,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: DropdownButtonHideUnderline(
// //         child: DropdownButton<T>(
// //           value: value,
// //           items: items.map((item) {
// //             return DropdownMenuItem<T>(
// //               value: item,
// //               child: Text(
// //                 format != null ? format(item) : item.toString(),
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 16,
// //                   color: Colors.blue.shade900,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             );
// //           }).toList(),
// //           onChanged: onChanged,
// //           isExpanded: true,
// //           icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
// //           dropdownColor: Colors.white,
// //           borderRadius: BorderRadius.circular(15),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_cubit.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// class ScheduleScreen extends StatefulWidget {
//   final String courseId;
//   final LectureCubit lectureCubit;
//   const ScheduleScreen({
//     Key? key,
//     required this.courseId,
//     required this.lectureCubit,
//   }) : super(key: key);

//   @override
//   _ScheduleScreenState createState() => _ScheduleScreenState();
// }

// class _ScheduleScreenState extends State<ScheduleScreen>
//     with SingleTickerProviderStateMixin {
//   final _firestore = FirebaseFirestore.instance;
//   int startHour = 1;
//   int startMinute = 0;
//   String startPeriod = 'AM';
//   int endHour = 1;
//   int endMinute = 0;
//   String endPeriod = 'AM';
//   bool isLoading = false;
//   String cameraStatus = 'closed';
//   final TextEditingController _lectureNameController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   late AnimationController _animationController;
//   late Animation<double> _buttonScaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _lectureNameController.text = '';
//     _dateController.text = '';
//     startHour = 1;
//     startMinute = 0;
//     startPeriod = 'AM';
//     endHour = 1;
//     endMinute = 0;
//     endPeriod = 'AM';
//     cameraStatus = 'closed';

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _loadInitialSchedule();
//     _listenToCameraStatus();
//   }

//   void _loadInitialSchedule() async {
//     try {
//       DocumentSnapshot doc =
//           await _firestore.collection('schedule').doc('daily').get();
//       if (doc.exists) {
//         final data = doc.data() as Map<String, dynamic>;
//         setState(() {
//           startHour = data['start_hour_12'] ?? 1;
//           startMinute = data['start_minute'] ?? 0;
//           startPeriod = data['start_period'] ?? 'AM';
//           endHour = data['end_hour_12'] ?? 1;
//           endMinute = data['end_minute'] ?? 0;
//           endPeriod = data['end_period'] ?? 'AM';
//           cameraStatus = data['camera_status'] ?? 'closed';
//         });
//       }
//     } catch (e) {
//       print('Error loading initial schedule: $e');
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
//             colorScheme: ColorScheme.light(
//               primary: Colors.blue.shade700,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.blue.shade700,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (pickedDate != null) {
//       setState(() {
//         _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
//       });
//     }
//   }

//   Future<bool> _saveLectureData() async {
//     if (_lectureNameController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter lecture name'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }

//     if (_dateController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a date'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }

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
//       return false;
//     }

//     try {
//       await _firestore.collection('schedule').doc('daily').set({
//         'start_hour_12': startHour,
//         'start_minute': startMinute,
//         'start_period': startPeriod,
//         'end_hour_12': endHour,
//         'end_minute': endMinute,
//         'end_period': endPeriod,
//         'camera_status': 'closed',
//         'lecture_name': _lectureNameController.text,
//         'date': _dateController.text,
//         'last_updated': Timestamp.now(),
//       });

//       final lecturesSnapshot = await _firestore
//           .collection('Courses')
//           .doc(widget.courseId)
//           .collection('lectures')
//           .get();
//       final lectureCount = lecturesSnapshot.docs.length;
//       final newLectureNumber = lectureCount + 1;

//       print('Adding lecture to courseId: ${widget.courseId}');
//       print('Total existing lectures: $lectureCount');
//       print('New lecture number: $newLectureNumber');

//       DocumentReference courseRef =
//           _firestore.collection('Courses').doc(widget.courseId);
//       DocumentReference lectureRef =
//           await courseRef.collection('lectures').add({
//         'name': _lectureNameController.text,
//         'date': _dateController.text,
//         'time':
//             '$startHour:${startMinute.toString().padLeft(2, '0')} $startPeriod',
//         'created_at': Timestamp.now(),
//         'lectureNumber': newLectureNumber,
//       });

//       print('Lecture added with ID: ${lectureRef.id}');
//       print('Lecture path: ${lectureRef.path}');

//       CollectionReference attendanceRef = lectureRef.collection('attendance');
//       print('Attendance collection reference created: ${attendanceRef.path}');

//       List<Map<String, dynamic>> students = [
//         {
//           'name': 'Student 1',
//           'imageUrl': 'https://i.pravatar.cc/150?img=1',
//           'isPresent': false,
//           'isLocalImage': false,
//           'isStarred': false,
//         },
//         {
//           'name': 'Student 2',
//           'imageUrl': 'https://i.pravatar.cc/150?img=2',
//           'isPresent': false,
//           'isLocalImage': false,
//           'isStarred': false,
//         },
//         {
//           'name': 'Student 3',
//           'imageUrl': 'https://i.pravatar.cc/150?img=3',
//           'isPresent': false,
//           'isLocalImage': false,
//           'isStarred': false,
//         },
//       ];

//       for (var student in students) {
//         await attendanceRef.add(student);
//       }
//       print(
//           'Students added to attendance collection for lecture: ${lectureRef.id}');

//       widget.lectureCubit.loadLectures();
//       return true;
//     } catch (e) {
//       print('Error saving lecture data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error saving lecture: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }
//   }

//   void _saveSchedule() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       bool success = await _saveLectureData();
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Schedule saved successfully: ${_lectureNameController.text} on ${_dateController.text}'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _openCamera() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       bool success = await _saveLectureData();
//       if (success) {
//         await _firestore.collection('schedule').doc('daily').update({
//           'camera_status': 'open',
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Lecture saved and camera opened successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
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
//       await _firestore.collection('schedule').doc('daily').update({
//         'camera_status': 'stopped',
//       });
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

//   @override
//   void dispose() {
//     _lectureNameController.dispose();
//     _dateController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           color: Colors.blue.shade300,
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Add Lecture',
//                         style: GoogleFonts.poppins(
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           shadows: [
//                             Shadow(
//                               color: Colors.black.withOpacity(0.2),
//                               offset: const Offset(2, 2),
//                               blurRadius: 4,
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close,
//                             color: Colors.white, size: 30),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Lecture Name',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.95),
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: TextField(
//                       controller: _lectureNameController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter lecture name',
//                         hintStyle: GoogleFonts.poppins(
//                           color: Colors.grey.shade600,
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 15,
//                           vertical: 15,
//                         ),
//                         prefixIcon: Icon(
//                           Icons.book,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                       style: GoogleFonts.poppins(
//                         color: Colors.blue.shade900,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Date',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.95),
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: TextField(
//                       controller: _dateController,
//                       readOnly: true,
//                       onTap: _pickDate,
//                       decoration: InputDecoration(
//                         hintText: 'Select date (DD/MM/YYYY)',
//                         hintStyle: GoogleFonts.poppins(
//                           color: Colors.grey.shade600,
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 15,
//                           vertical: 15,
//                         ),
//                         suffixIcon: Icon(
//                           Icons.calendar_today,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                       style: GoogleFonts.poppins(
//                         color: Colors.blue.shade900,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Center(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 15, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.95),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             cameraStatus == 'open'
//                                 ? Icons.videocam
//                                 : Icons.videocam_off,
//                             color: cameraStatus == 'open'
//                                 ? Colors.green
//                                 : Colors.red,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             cameraStatus == 'open'
//                                 ? 'Camera Open'
//                                 : 'Camera Closed',
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               color: cameraStatus == 'open'
//                                   ? Colors.green
//                                   : Colors.red,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Text(
//                     'Start Time',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildDropdown(
//                         value: startHour,
//                         items: List.generate(12, (index) => index + 1),
//                         onChanged: (value) =>
//                             setState(() => startHour = value!),
//                         width: 80,
//                       ),
//                       Text(
//                         ':',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           color: Colors.white,
//                         ),
//                       ),
//                       _buildDropdown(
//                         value: startMinute,
//                         items: List.generate(60, (index) => index),
//                         onChanged: (value) =>
//                             setState(() => startMinute = value!),
//                         width: 80,
//                         format: (value) => value.toString().padLeft(2, '0'),
//                       ),
//                       const SizedBox(width: 10),
//                       _buildDropdown(
//                         value: startPeriod,
//                         items: const ['AM', 'PM'],
//                         onChanged: (value) =>
//                             setState(() => startPeriod = value!),
//                         width: 80,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   Text(
//                     'End Time',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildDropdown(
//                         value: endHour,
//                         items: List.generate(12, (index) => index + 1),
//                         onChanged: (value) => setState(() => endHour = value!),
//                         width: 80,
//                       ),
//                       Text(
//                         ':',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           color: Colors.white,
//                         ),
//                       ),
//                       _buildDropdown(
//                         value: endMinute,
//                         items: List.generate(60, (index) => index),
//                         onChanged: (value) =>
//                             setState(() => endMinute = value!),
//                         width: 80,
//                         format: (value) => value.toString().padLeft(2, '0'),
//                       ),
//                       const SizedBox(width: 10),
//                       _buildDropdown(
//                         value: endPeriod,
//                         items: const ['AM', 'PM'],
//                         onChanged: (value) =>
//                             setState(() => endPeriod = value!),
//                         width: 80,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 40),
//                   Center(
//                     child: ScaleTransition(
//                       scale: _buttonScaleAnimation,
//                       child: ElevatedButton.icon(
//                         onPressed: isLoading
//                             ? null
//                             : () {
//                                 _animationController.forward(from: 0);
//                                 _saveSchedule();
//                               },
//                         icon: isLoading
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 ),
//                               )
//                             : const Icon(Icons.save, color: Colors.white),
//                         label: Text(
//                           isLoading ? 'Saving...' : 'Save Schedule',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue.shade700,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 30, vertical: 15),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           elevation: 8,
//                           shadowColor: Colors.black.withOpacity(0.3),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Center(
//                     child: ScaleTransition(
//                       scale: _buttonScaleAnimation,
//                       child: ElevatedButton.icon(
//                         onPressed: (isLoading || cameraStatus != 'open')
//                             ? null
//                             : () {
//                                 _animationController.forward(from: 0);
//                                 _closeCamera();
//                               },
//                         icon:
//                             const Icon(Icons.videocam_off, color: Colors.white),
//                         label: Text(
//                           isLoading ? 'Closing...' : 'Close Camera',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red.shade600,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 30, vertical: 15),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           elevation: 8,
//                           shadowColor: Colors.black.withOpacity(0.3),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Center(
//                     child: ScaleTransition(
//                       scale: _buttonScaleAnimation,
//                       child: ElevatedButton.icon(
//                         onPressed: (isLoading ||
//                                 cameraStatus == 'open' ||
//                                 _lectureNameController.text.isEmpty ||
//                                 _dateController.text.isEmpty)
//                             ? null
//                             : () {
//                                 _animationController.forward(from: 0);
//                                 _openCamera();
//                               },
//                         icon: const Icon(Icons.videocam, color: Colors.white),
//                         label: Text(
//                           isLoading ? 'Opening...' : 'Open Camera',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green.shade600,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 30, vertical: 15),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           elevation: 8,
//                           shadowColor: Colors.black.withOpacity(0.3),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
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
//         color: Colors.white.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
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
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.blue.shade900,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: onChanged,
//           isExpanded: true,
//           icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
//           dropdownColor: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//         ),
//       ),
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/attendance/cubits/cubit_admin/lecture_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  final String courseId;
  final LectureCubit lectureCubit;
  const ScheduleScreen({
    super.key,
    required this.courseId,
    required this.lectureCubit,
  });

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  int startHour = 1;
  int startMinute = 0;
  String startPeriod = 'AM';
  int endHour = 1;
  int endMinute = 0;
  String endPeriod = 'AM';
  bool isLoading = false;
  String cameraStatus = 'closed';
  final TextEditingController _lectureNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _lectureNameController.text = '';
    _dateController.text = '';
    startHour = 1;
    startMinute = 0;
    startPeriod = 'AM';
    endHour = 1;
    endMinute = 0;
    endPeriod = 'AM';
    cameraStatus = 'closed';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
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
  //           colorScheme: ColorScheme.light(
  //             primary: Colors.blue.shade700,
  //             onPrimary: Colors.white,
  //             onSurface: Colors.black,
  //           ),
  //           textButtonTheme: TextButtonThemeData(
  //             style: TextButton.styleFrom(
  //               foregroundColor: Colors.blue.shade700,
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
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
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

  Future<bool> _saveLectureData() async {
    if (_lectureNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter lecture name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
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
      return false;
    }

    try {
      final lecturesSnapshot = await _firestore
          .collection('Courses')
          .doc(widget.courseId)
          .collection('lectures')
          .get();
      final lectureCount = lecturesSnapshot.docs.length;
      final newLectureNumber = lectureCount + 1;

      print('Adding lecture to courseId: ${widget.courseId}');
      print('Total existing lectures: $lectureCount');
      print('New lecture number: $newLectureNumber');

      DocumentReference courseRef =
          _firestore.collection('Courses').doc(widget.courseId);
      DocumentReference lectureRef =
          await courseRef.collection('lectures').add({
        'name': _lectureNameController.text,
        'date': _dateController.text,
        'time':
            '$startHour:${startMinute.toString().padLeft(2, '0')} $startPeriod',
        'created_at': Timestamp.now(),
        'lectureNumber': newLectureNumber,
        'start_hour_12': startHour,
        'start_minute': startMinute,
        'start_period': startPeriod,
        'end_hour_12': endHour,
        'end_minute': endMinute,
        'end_period': endPeriod,
        'camera_status': 'closed',
      });

      print('Lecture added with ID: ${lectureRef.id}');
      print('Lecture path: ${lectureRef.path}');

      CollectionReference attendanceRef = lectureRef.collection('attendance');
      print('Attendance collection reference created: ${attendanceRef.path}');

      // List<Map<String, dynamic>> students = [
      //   {
      //     'name': 'Student 1',
      //     'imageUrl': 'https://i.pravatar.cc/150?img=1',
      //     'isPresent': false,
      //     'isLocalImage': false,
      //     'isStarred': false,
      //   },
      //   {
      //     'name': 'Student 2',
      //     'imageUrl': 'https://i.pravatar.cc/150?img=2',
      //     'isPresent': false,
      //     'isLocalImage': false,
      //     'isStarred': false,
      //   },
      //   {
      //     'name': 'Student 3',
      //     'imageUrl': 'https://i.pravatar.cc/150?img=3',
      //     'isPresent': false,
      //     'isLocalImage': false,
      //     'isStarred': false,
      //   },
      // ];

      // for (var student in students) {
      //   await attendanceRef.add(student);
      // }
      // print(
      //     'Students added to attendance collection for lecture: ${lectureRef.id}');

      widget.lectureCubit.loadLectures();
      return true;
    } catch (e) {
      print('Error saving lecture data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving lecture: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void _saveSchedule() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool success = await _saveLectureData();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Lecture saved successfully: ${_lectureNameController.text} on ${_dateController.text}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openCamera() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool success = await _saveLectureData();
      if (success) {
        final lecturesSnapshot = await _firestore
            .collection('Courses')
            .doc(widget.courseId)
            .collection('lectures')
            .where('name', isEqualTo: _lectureNameController.text)
            .where('date', isEqualTo: _dateController.text)
            .get();

        if (lecturesSnapshot.docs.isNotEmpty) {
          var lectureDoc = lecturesSnapshot.docs.first;
          await lectureDoc.reference.update({
            'camera_status': 'open',
          });
        }

        setState(() {
          cameraStatus = 'open';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lecture saved and camera opened successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
      final lecturesSnapshot = await _firestore
          .collection('Courses')
          .doc(widget.courseId)
          .collection('lectures')
          .where('name', isEqualTo: _lectureNameController.text)
          .where('date', isEqualTo: _dateController.text)
          .get();

      if (lecturesSnapshot.docs.isNotEmpty) {
        var lectureDoc = lecturesSnapshot.docs.first;
        await lectureDoc.reference.update({
          'camera_status': 'closed',
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

  @override
  void dispose() {
    _lectureNameController.dispose();
    _dateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add Lecture',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            right: 20,
            left: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       'Add Lecture',
                //       style: GoogleFonts.poppins(
                //         fontSize: 26,
                //         fontWeight: FontWeight.bold,
                //         color: AppColors.primaryColor,
                //         shadows: [
                //           Shadow(
                //             color: Colors.black.withOpacity(0.1),
                //             offset: const Offset(2, 2),
                //             blurRadius: 4,
                //           ),
                //         ],
                //       ),
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.close,
                //           color: AppColors.primaryColor, size: 30),
                //       onPressed: () => Navigator.pop(context),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 20),
                Text(
                  'Lecture Name',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  // elevation: 3,
                  // color: Colors.white,
                  // shape: BorderRadius.circular(radius),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    //  borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    cursorColor: Colors.white,
                    controller: _lectureNameController,
                    decoration: InputDecoration(
                      fillColor: AppColors.primaryColor,
                      filled: true,
                      hintText: 'Enter lecture name',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.book,
                        color: Colors.white,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Date',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    cursorColor: Colors.white,
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(
                      fillColor: AppColors.primaryColor,
                      filled: true,
                      hintText: 'Select date (DD/MM/YYYY)',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cameraStatus == 'open'
                              ? Icons.videocam
                              : Icons.videocam_off,
                          color: cameraStatus == 'open'
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cameraStatus == 'open'
                              ? 'Camera Open'
                              : 'Camera Closed',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: cameraStatus == 'open'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Start Time',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                    Text(
                      ':',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
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
                const SizedBox(height: 30),
                Text(
                  'End Time',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                    Text(
                      ':',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
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
                const SizedBox(height: 40),
                Center(
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              _animationController.forward(from: 0);
                              _saveSchedule();
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        isLoading ? 'Saving...' : 'Save Schedule',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: ElevatedButton.icon(
                      onPressed: (isLoading || cameraStatus != 'open')
                          ? null
                          : () {
                              _animationController.forward(from: 0);
                              _closeCamera();
                            },
                      icon: const Icon(Icons.videocam_off, color: Colors.white),
                      label: Text(
                        isLoading ? 'Closing...' : 'Close Camera',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: ElevatedButton.icon(
                      onPressed: (isLoading ||
                              cameraStatus == 'open' ||
                              _lectureNameController.text.isEmpty ||
                              _dateController.text.isEmpty)
                          ? null
                          : () {
                              _animationController.forward(from: 0);
                              _openCamera();
                            },
                      icon: const Icon(Icons.videocam, color: Colors.white),
                      label: Text(
                        isLoading ? 'Opening...' : 'Open Camera',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
