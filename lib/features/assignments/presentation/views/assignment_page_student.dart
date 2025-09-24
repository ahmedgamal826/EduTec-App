// // // // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // // // import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignments_viewmodel.dart';
// // // // // import 'package:attendance_app/features/assignments/presentation/views/student_assignment_detail_view.dart';
// // // // // import 'package:attendance_app/features/assignments/presentation/views/widgets/assignment_list_item_student.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:provider/provider.dart';

// // // // // import 'package:attendance_app/features/assignments/presentation/views/student_submission_detail_view.dart';

// // // // // class AssignmentsPageStudent extends StatefulWidget {
// // // // //   final String courseId;

// // // // //   const AssignmentsPageStudent({Key? key, required this.courseId})
// // // // //       : super(key: key);

// // // // //   @override
// // // // //   State<AssignmentsPageStudent> createState() => _AssignmentsPageStudentState();
// // // // // }

// // // // // class _AssignmentsPageStudentState extends State<AssignmentsPageStudent>
// // // // //     with WidgetsBindingObserver {
// // // // //   late StudentAssignmentsViewModel _viewModel;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     WidgetsBinding.instance.addObserver(this);
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     WidgetsBinding.instance.removeObserver(this);
// // // // //     super.dispose();
// // // // //   }

// // // // //   @override
// // // // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // // // //     if (state == AppLifecycleState.resumed) {
// // // // //       // Refresh when app is resumed
// // // // //       if (_viewModel != null) {
// // // // //         _viewModel.refreshAssignments();
// // // // //       }
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final screenWidth = MediaQuery.of(context).size.width;
// // // // //     final screenHeight = MediaQuery.of(context).size.height;

// // // // //     return ChangeNotifierProvider(
// // // // //       create: (_) => StudentAssignmentsViewModel(courseId: widget.courseId),
// // // // //       child: Consumer<StudentAssignmentsViewModel>(
// // // // //         builder: (context, viewModel, child) {
// // // // //           _viewModel = viewModel; // Store for lifecycle methods

// // // // //           // إظهار رسائل النجاح
// // // // //           if (viewModel.successMessage.isNotEmpty) {
// // // // //             // جدولة رسالة النجاح لتظهر بعد بناء الواجهة
// // // // //             WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //               ScaffoldMessenger.of(context).showSnackBar(
// // // // //                 SnackBar(
// // // // //                   content: Text(viewModel.successMessage),
// // // // //                   backgroundColor: Colors.green,
// // // // //                 ),
// // // // //               );
// // // // //               // مسح الرسالة بعد عرضها
// // // // //               viewModel.clearMessages();
// // // // //             });
// // // // //           }

// // // // //           // إظهار رسائل الخطأ
// // // // //           if (viewModel.errorMessage.isNotEmpty) {
// // // // //             // جدولة رسالة الخطأ لتظهر بعد بناء الواجهة
// // // // //             WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //               ScaffoldMessenger.of(context).showSnackBar(
// // // // //                 SnackBar(
// // // // //                   content: Text(viewModel.errorMessage),
// // // // //                   backgroundColor: Colors.red,
// // // // //                 ),
// // // // //               );
// // // // //               // مسح الرسالة بعد عرضها
// // // // //               viewModel.clearMessages();
// // // // //             });
// // // // //           }

// // // // //           return Scaffold(
// // // // //             backgroundColor: const Color(0xFFF0F7FF),
// // // // //             appBar: AppBar(
// // // // //               iconTheme: const IconThemeData(
// // // // //                 color: Colors.white,
// // // // //               ),
// // // // //               title: const Text(
// // // // //                 "Student Assignments",
// // // // //                 style: TextStyle(
// // // // //                   fontWeight: FontWeight.bold,
// // // // //                   fontSize: 22,
// // // // //                   color: Colors.white,
// // // // //                 ),
// // // // //               ),
// // // // //               backgroundColor: AppColors.primaryColor,
// // // // //               elevation: 0,
// // // // //               centerTitle: true,
// // // // //               actions: [
// // // // //                 // Add refresh button
// // // // //                 IconButton(
// // // // //                   icon: const Icon(Icons.refresh),
// // // // //                   onPressed: () {
// // // // //                     viewModel.refreshAssignments();
// // // // //                   },
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //             body: Stack(
// // // // //               children: [
// // // // //                 // محتوى الصفحة الرئيسي
// // // // //                 viewModel.isLoading
// // // // //                     ? const Center(
// // // // //                         child: CircularProgressIndicator(
// // // // //                         color: AppColors.primaryColor,
// // // // //                       ))
// // // // //                     : viewModel.assignments.isEmpty
// // // // //                         ? Center(
// // // // //                             child: Column(
// // // // //                               mainAxisAlignment: MainAxisAlignment.center,
// // // // //                               children: [
// // // // //                                 const Icon(Icons.assignment,
// // // // //                                     size: 80, color: Colors.grey),
// // // // //                                 SizedBox(height: screenHeight * 0.03),
// // // // //                                 Text('No Assignments available',
// // // // //                                     textAlign: TextAlign.center,
// // // // //                                     style: TextStyle(
// // // // //                                         fontSize: screenHeight * 0.03,
// // // // //                                         color: Colors.grey,
// // // // //                                         fontWeight: FontWeight.w500)),
// // // // //                                 SizedBox(height: screenHeight * 0.01),
// // // // //                                 Text('Check back later for new assignments!',
// // // // //                                     textAlign: TextAlign.center,
// // // // //                                     style: TextStyle(
// // // // //                                         fontSize: screenHeight * 0.02,
// // // // //                                         color: Colors.grey)),
// // // // //                               ],
// // // // //                             ),
// // // // //                           )
// // // // //                         : Padding(
// // // // //                             padding: EdgeInsets.all(screenWidth * 0.04),
// // // // //                             child: ListView.builder(
// // // // //                               itemCount: viewModel.assignments.length,
// // // // //                               itemBuilder: (context, index) {
// // // // //                                 final assignment = viewModel.assignments[index];
// // // // //                                 return TestListItem(
// // // // //                                   test: assignment,
// // // // //                                   onTap: () async {
// // // // //                                     if (assignment.isCompleted) {
// // // // //                                       final submission = await viewModel
// // // // //                                           .getSubmissionDetails(assignment.id);
// // // // //                                       if (submission != null) {
// // // // //                                         await Navigator.push(
// // // // //                                           context,
// // // // //                                           MaterialPageRoute(
// // // // //                                             builder: (context) =>
// // // // //                                                 StudentSubmissionDetailView(
// // // // //                                               adminId: widget.courseId,
// // // // //                                               assignmentId: assignment.id,
// // // // //                                               assignmentTitle: assignment.title,
// // // // //                                               submission: submission,
// // // // //                                               courseName:
// // // // //                                                   assignment.courseName ??
// // // // //                                                       'Unknown Course',
// // // // //                                             ),
// // // // //                                           ),
// // // // //                                         );
// // // // //                                       } else {
// // // // //                                         ScaffoldMessenger.of(context)
// // // // //                                             .showSnackBar(
// // // // //                                           const SnackBar(
// // // // //                                             content: Text(
// // // // //                                                 'Error: Could not fetch submission details'),
// // // // //                                             backgroundColor: Colors.red,
// // // // //                                           ),
// // // // //                                         );
// // // // //                                       }
// // // // //                                     } else {
// // // // //                                       await Navigator.push(
// // // // //                                         context,
// // // // //                                         MaterialPageRoute(
// // // // //                                           builder: (context) =>
// // // // //                                               StudentAssignmentDetailView(
// // // // //                                             courseId: widget.courseId,
// // // // //                                             assignmentId: assignment.id,
// // // // //                                             assignmentTitle: assignment.title,
// // // // //                                           ),
// // // // //                                         ),
// // // // //                                       );
// // // // //                                     }
// // // // //                                     viewModel.refreshAssignments();
// // // // //                                   },
// // // // //                                 );
// // // // //                               },
// // // // //                             ),

// // // // //                             // child: ListView.builder(
// // // // //                             //   itemCount: viewModel.assignments.length,
// // // // //                             //   itemBuilder: (context, index) {
// // // // //                             //     final assignment = viewModel.assignments[index];
// // // // //                             //     return TestListItem(
// // // // //                             //       test: assignment,
// // // // //                             //       onTap: () async {
// // // // //                             //         // Navigate to the new assignment detail view
// // // // //                             //         await Navigator.push(
// // // // //                             //           context,
// // // // //                             //           MaterialPageRoute(
// // // // //                             //             builder: (context) =>
// // // // //                             //                 StudentAssignmentDetailView(
// // // // //                             //               courseId: widget.courseId,
// // // // //                             //               assignmentId: assignment
// // // // //                             //                   .title, // Using title as ID for now
// // // // //                             //               assignmentTitle: assignment.title,
// // // // //                             //             ),
// // // // //                             //           ),
// // // // //                             //         );

// // // // //                             //         // Refresh assignments when returning from detail view
// // // // //                             //         viewModel.refreshAssignments();
// // // // //                             //       },
// // // // //                             //     );
// // // // //                             //   },
// // // // //                             // ),
// // // // //                           ),
// // // // //               ],
// // // // //             ),
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // // import 'package:attendance_app/features/assignments/models/assignment_model_student.dart'; // إضافة الـ import لـ StudentAssignmentSubmission
// // // // import 'package:attendance_app/features/assignments/models/student_assignment_response.dart';
// // // // import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignments_viewmodel.dart';
// // // // import 'package:attendance_app/features/assignments/presentation/views/student_assignment_detail_view.dart';
// // // // import 'package:attendance_app/features/assignments/presentation/views/student_submission_detail_view.dart';
// // // // import 'package:attendance_app/features/assignments/presentation/views/widgets/assignment_list_item_student.dart';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:provider/provider.dart';

// // // // class AssignmentsPageStudent extends StatefulWidget {
// // // //   final String courseId;

// // // //   const AssignmentsPageStudent({Key? key, required this.courseId})
// // // //       : super(key: key);

// // // //   @override
// // // //   State<AssignmentsPageStudent> createState() => _AssignmentsPageStudentState();
// // // // }

// // // // class _AssignmentsPageStudentState extends State<AssignmentsPageStudent>
// // // //     with WidgetsBindingObserver {
// // // //   StudentAssignmentsViewModel? _viewModel;
// // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // // //   final FirebaseAuth _auth = FirebaseAuth.instance;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     WidgetsBinding.instance.addObserver(this);
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     WidgetsBinding.instance.removeObserver(this);
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // // //     if (state == AppLifecycleState.resumed) {
// // // //       if (_viewModel != null) {
// // // //         _viewModel!.refreshAssignments();
// // // //       }
// // // //     }
// // // //   }

// // // //   // دالة لجلب تفاصيل الـ submission وتحويلها لـ StudentAssignmentSubmission
// // // //   Future<StudentAssignmentSubmission?> fetchSubmissionDetails(
// // // //       String assignmentId) async {
// // // //     try {
// // // //       final currentUser = _auth.currentUser;
// // // //       if (currentUser == null) {
// // // //         return null;
// // // //       }

// // // //       final doc = await _firestore
// // // //           .collection('Courses')
// // // //           .doc(widget.courseId)
// // // //           .collection('assignments')
// // // //           .doc(assignmentId)
// // // //           .collection('studentSubmits')
// // // //           .doc(currentUser.uid)
// // // //           .get();

// // // //       if (doc.exists) {
// // // //         return StudentAssignmentSubmission.fromMap(
// // // //             doc.data()!); // تحويل الـ Map لـ StudentAssignmentSubmission
// // // //       }
// // // //       return null;
// // // //     } catch (e) {
// // // //       debugPrint('Error fetching submission: $e');
// // // //       return null;
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final screenWidth = MediaQuery.of(context).size.width;
// // // //     final screenHeight = MediaQuery.of(context).size.height;

// // // //     return ChangeNotifierProvider(
// // // //       create: (_) => StudentAssignmentsViewModel(courseId: widget.courseId),
// // // //       child: Consumer<StudentAssignmentsViewModel>(
// // // //         builder: (context, viewModel, child) {
// // // //           _viewModel = viewModel;

// // // //           if (viewModel.successMessage.isNotEmpty) {
// // // //             WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //               if (mounted) {
// // // //                 ScaffoldMessenger.of(context).showSnackBar(
// // // //                   SnackBar(
// // // //                     content: Text(viewModel.successMessage),
// // // //                     backgroundColor: Colors.green,
// // // //                   ),
// // // //                 );
// // // //                 viewModel.clearMessages();
// // // //               }
// // // //             });
// // // //           }

// // // //           if (viewModel.errorMessage.isNotEmpty) {
// // // //             WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //               if (mounted) {
// // // //                 ScaffoldMessenger.of(context).showSnackBar(
// // // //                   SnackBar(
// // // //                     content: Text(viewModel.errorMessage),
// // // //                     backgroundColor: Colors.red,
// // // //                   ),
// // // //                 );
// // // //                 viewModel.clearMessages();
// // // //               }
// // // //             });
// // // //           }

// // // //           return Scaffold(
// // // //             backgroundColor: const Color(0xFFF0F7FF),
// // // //             appBar: AppBar(
// // // //               iconTheme: const IconThemeData(
// // // //                 color: Colors.white,
// // // //               ),
// // // //               title: const Text(
// // // //                 "Student Assignments",
// // // //                 style: TextStyle(
// // // //                   fontWeight: FontWeight.bold,
// // // //                   fontSize: 22,
// // // //                   color: Colors.white,
// // // //                 ),
// // // //               ),
// // // //               backgroundColor: AppColors.primaryColor,
// // // //               elevation: 0,
// // // //               centerTitle: true,
// // // //               actions: [
// // // //                 IconButton(
// // // //                   icon: const Icon(Icons.refresh),
// // // //                   onPressed: () {
// // // //                     viewModel.refreshAssignments();
// // // //                   },
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             body: Stack(
// // // //               children: [
// // // //                 viewModel.isLoading
// // // //                     ? const Center(
// // // //                         child: CircularProgressIndicator(
// // // //                           color: AppColors.primaryColor,
// // // //                         ),
// // // //                       )
// // // //                     : viewModel.assignments.isEmpty
// // // //                         ? Center(
// // // //                             child: Column(
// // // //                               mainAxisAlignment: MainAxisAlignment.center,
// // // //                               children: [
// // // //                                 const Icon(
// // // //                                   Icons.assignment,
// // // //                                   size: 80,
// // // //                                   color: Colors.grey,
// // // //                                 ),
// // // //                                 SizedBox(height: screenHeight * 0.03),
// // // //                                 Text(
// // // //                                   'No Assignments available',
// // // //                                   textAlign: TextAlign.center,
// // // //                                   style: TextStyle(
// // // //                                     fontSize: screenHeight * 0.03,
// // // //                                     color: Colors.grey,
// // // //                                     fontWeight: FontWeight.w500,
// // // //                                   ),
// // // //                                 ),
// // // //                                 SizedBox(height: screenHeight * 0.01),
// // // //                                 Text(
// // // //                                   'Check back later for new assignments!',
// // // //                                   textAlign: TextAlign.center,
// // // //                                   style: TextStyle(
// // // //                                     fontSize: screenHeight * 0.02,
// // // //                                     color: Colors.grey,
// // // //                                   ),
// // // //                                 ),
// // // //                               ],
// // // //                             ),
// // // //                           )
// // // //                         : Padding(
// // // //                             padding: EdgeInsets.all(screenWidth * 0.04),
// // // //                             child: ListView.builder(
// // // //                               itemCount: viewModel.assignments.length,
// // // //                               itemBuilder: (context, index) {
// // // //                                 final assignment = viewModel.assignments[index];
// // // //                                 return TestListItem(
// // // //                                   test: assignment,
// // // //                                   onTap: () async {
// // // //                                     if (assignment.isCompleted) {
// // // //                                       // جلب تفاصيل الـ submission
// // // //                                       final submission =
// // // //                                           await fetchSubmissionDetails(
// // // //                                               assignment.title);
// // // //                                       if (submission != null) {
// // // //                                         await Navigator.push(
// // // //                                           context,
// // // //                                           MaterialPageRoute(
// // // //                                             builder: (context) =>
// // // //                                                 StudentSubmissionDetailView(
// // // //                                               adminId: widget.courseId,
// // // //                                               assignmentId: assignment
// // // //                                                   .title, // استخدام title بدل id
// // // //                                               assignmentTitle: assignment.title,
// // // //                                               submission:
// // // //                                                   submission, // تمرير كـ StudentAssignmentSubmission
// // // //                                               courseName: assignment.title ??
// // // //                                                   'Unknown Course', // تصحيح هنا
// // // //                                             ),
// // // //                                           ),
// // // //                                         );
// // // //                                       } else {
// // // //                                         if (mounted) {
// // // //                                           ScaffoldMessenger.of(context)
// // // //                                               .showSnackBar(
// // // //                                             const SnackBar(
// // // //                                               content: Text(
// // // //                                                   'Error: Could not fetch submission details'),
// // // //                                               backgroundColor: Colors.red,
// // // //                                             ),
// // // //                                           );
// // // //                                         }
// // // //                                       }
// // // //                                     } else {
// // // //                                       await Navigator.push(
// // // //                                         context,
// // // //                                         MaterialPageRoute(
// // // //                                           builder: (context) =>
// // // //                                               StudentAssignmentDetailView(
// // // //                                             courseId: widget.courseId,
// // // //                                             assignmentId: assignment
// // // //                                                 .title, // استخدام title بدل id
// // // //                                             assignmentTitle: assignment.title,
// // // //                                           ),
// // // //                                         ),
// // // //                                       );
// // // //                                     }
// // // //                                     viewModel.refreshAssignments();
// // // //                                   },
// // // //                                 );
// // // //                               },
// // // //                             ),
// // // //                           ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // import 'package:attendance_app/features/assignments/models/assignment_model_student.dart';
// // // import 'package:attendance_app/features/assignments/models/student_assignment_response.dart';
// // // import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignments_viewmodel.dart';
// // // import 'package:attendance_app/features/assignments/presentation/views/student_assignment_detail_view.dart';
// // // import 'package:attendance_app/features/assignments/presentation/views/student_submission_detail_view.dart';
// // // import 'package:attendance_app/features/assignments/presentation/views/widgets/assignment_list_item_student.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';

// // // class AssignmentsPageStudent extends StatefulWidget {
// // //   final String courseId;

// // //   const AssignmentsPageStudent({Key? key, required this.courseId})
// // //       : super(key: key);

// // //   @override
// // //   State<AssignmentsPageStudent> createState() => _AssignmentsPageStudentState();
// // // }

// // // class _AssignmentsPageStudentState extends State<AssignmentsPageStudent>
// // //     with WidgetsBindingObserver {
// // //   StudentAssignmentsViewModel? _viewModel;
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addObserver(this);
// // //   }

// // //   @override
// // //   void dispose() {
// // //     WidgetsBinding.instance.removeObserver(this);
// // //     super.dispose();
// // //   }

// // //   @override
// // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // //     if (state == AppLifecycleState.resumed) {
// // //       if (_viewModel != null) {
// // //         _viewModel!.refreshAssignments();
// // //       }
// // //     }
// // //   }

// // //   Future<StudentAssignmentSubmission?> fetchSubmissionDetails(
// // //       String assignmentId) async {
// // //     try {
// // //       final currentUser = _auth.currentUser;
// // //       if (currentUser == null) {
// // //         debugPrint('No current user');
// // //         return null;
// // //       }

// // //       final doc = await _firestore
// // //           .collection('Courses')
// // //           .doc(widget.courseId)
// // //           .collection('assignments')
// // //           .doc(assignmentId)
// // //           .collection('studentSubmits')
// // //           .doc(currentUser.uid)
// // //           .get();

// // //       if (!doc.exists) {
// // //         debugPrint(
// // //             'No submission found for assignmentId: $assignmentId, user: ${currentUser.uid}');
// // //         return null;
// // //       }

// // //       debugPrint('Submission data: ${doc.data()}');
// // //       return StudentAssignmentSubmission.fromMap(doc.data()!);
// // //     } catch (e) {
// // //       debugPrint('Error fetching submission: $e');
// // //       return null;
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final screenWidth = MediaQuery.of(context).size.width;
// // //     final screenHeight = MediaQuery.of(context).size.height;

// // //     return ChangeNotifierProvider(
// // //       create: (_) => StudentAssignmentsViewModel(courseId: widget.courseId),
// // //       child: Consumer<StudentAssignmentsViewModel>(
// // //         builder: (context, viewModel, child) {
// // //           _viewModel = viewModel;

// // //           if (viewModel.successMessage.isNotEmpty) {
// // //             WidgetsBinding.instance.addPostFrameCallback((_) {
// // //               if (mounted) {
// // //                 ScaffoldMessenger.of(context).showSnackBar(
// // //                   SnackBar(
// // //                     content: Text(viewModel.successMessage),
// // //                     backgroundColor: Colors.green,
// // //                   ),
// // //                 );
// // //                 viewModel.clearMessages();
// // //               }
// // //             });
// // //           }

// // //           if (viewModel.errorMessage.isNotEmpty) {
// // //             WidgetsBinding.instance.addPostFrameCallback((_) {
// // //               if (mounted) {
// // //                 ScaffoldMessenger.of(context).showSnackBar(
// // //                   SnackBar(
// // //                     content: Text(viewModel.errorMessage),
// // //                     backgroundColor: Colors.red,
// // //                   ),
// // //                 );
// // //                 viewModel.clearMessages();
// // //               }
// // //             });
// // //           }

// // //           return Scaffold(
// // //             backgroundColor: const Color(0xFFF0F7FF),
// // //             appBar: AppBar(
// // //               iconTheme: const IconThemeData(color: Colors.white),
// // //               title: const Text(
// // //                 "Student Assignments",
// // //                 style: TextStyle(
// // //                   fontWeight: FontWeight.bold,
// // //                   fontSize: 22,
// // //                   color: Colors.white,
// // //                 ),
// // //               ),
// // //               backgroundColor: AppColors.primaryColor,
// // //               elevation: 0,
// // //               centerTitle: true,
// // //               actions: [
// // //                 IconButton(
// // //                   icon: const Icon(Icons.refresh),
// // //                   onPressed: () {
// // //                     viewModel.refreshAssignments();
// // //                   },
// // //                 ),
// // //               ],
// // //             ),
// // //             body: Stack(
// // //               children: [
// // //                 viewModel.isLoading
// // //                     ? const Center(
// // //                         child: CircularProgressIndicator(
// // //                           color: AppColors.primaryColor,
// // //                         ),
// // //                       )
// // //                     : viewModel.assignments.isEmpty
// // //                         ? Center(
// // //                             child: Column(
// // //                               mainAxisAlignment: MainAxisAlignment.center,
// // //                               children: [
// // //                                 const Icon(
// // //                                   Icons.assignment,
// // //                                   size: 80,
// // //                                   color: Colors.grey,
// // //                                 ),
// // //                                 SizedBox(height: screenHeight * 0.03),
// // //                                 Text(
// // //                                   'No Assignments available',
// // //                                   textAlign: TextAlign.center,
// // //                                   style: TextStyle(
// // //                                     fontSize: screenHeight * 0.03,
// // //                                     color: Colors.grey,
// // //                                     fontWeight: FontWeight.w500,
// // //                                   ),
// // //                                 ),
// // //                                 SizedBox(height: screenHeight * 0.01),
// // //                                 Text(
// // //                                   'Check back later for new assignments!',
// // //                                   textAlign: TextAlign.center,
// // //                                   style: TextStyle(
// // //                                     fontSize: screenHeight * 0.02,
// // //                                     color: Colors.grey,
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           )
// // //                         : Padding(
// // //                             padding: EdgeInsets.all(screenWidth * 0.04),
// // //                             child: ListView.builder(
// // //                               itemCount: viewModel.assignments.length,
// // //                               itemBuilder: (context, index) {
// // //                                 final assignment = viewModel.assignments[index];
// // //                                 return TestListItem(

// // //                                   test: assignment,
// // //                                   onTap: () async {
// // //                                     print('Tapped on ${assignment.title}');
// // //                                     if (assignment.isCompleted) {
// // //                                       final submission =
// // //                                           await fetchSubmissionDetails(
// // //                                               assignment.title);
// // //                                       if (submission != null) {
// // //                                         print(
// // //                                             'Navigation to Submission Detail View');
// // //                                         await Navigator.push(
// // //                                           context,
// // //                                           MaterialPageRoute(
// // //                                             builder: (context) =>
// // //                                                 StudentSubmissionDetailView(
// // //                                               adminId: widget.courseId,
// // //                                               assignmentId: assignment.title,
// // //                                               assignmentTitle: assignment.title,
// // //                                               submission: submission,
// // //                                               courseName: assignment.title ??
// // //                                                   'Unknown Course',
// // //                                             ),
// // //                                           ),
// // //                                         );
// // //                                       } else {
// // //                                         if (mounted) {
// // //                                           ScaffoldMessenger.of(context)
// // //                                               .showSnackBar(
// // //                                             const SnackBar(
// // //                                               content: Text(
// // //                                                   'Error: Could not fetch submission details'),
// // //                                               backgroundColor: Colors.red,
// // //                                             ),
// // //                                           );
// // //                                         }
// // //                                       }
// // //                                     } else {
// // //                                       print(
// // //                                           'Navigation to Assignment Detail View');
// // //                                       await Navigator.push(
// // //                                         context,
// // //                                         MaterialPageRoute(
// // //                                           builder: (context) =>
// // //                                               StudentAssignmentDetailView(
// // //                                             courseId: widget.courseId,
// // //                                             assignmentId: assignment.title,
// // //                                             assignmentTitle: assignment.title,
// // //                                           ),
// // //                                         ),
// // //                                       );
// // //                                     }
// // //                                     viewModel.refreshAssignments();
// // //                                   },
// // //                                 );
// // //                               },
// // //                             ),
// // //                           ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:attendance_app/core/utils/app_colors.dart';
// // import 'package:attendance_app/features/assignments/models/assignment_model_student.dart';
// // import 'package:attendance_app/features/assignments/models/student_assignment_response.dart';
// // import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignments_viewmodel.dart';
// // import 'package:attendance_app/features/assignments/presentation/views/assignment_submissions_view.dart';
// // import 'package:attendance_app/features/assignments/presentation/views/student_assignment_detail_view.dart';
// // import 'package:attendance_app/features/assignments/presentation/views/student_submission_detail_view.dart';
// // import 'package:attendance_app/features/assignments/presentation/views/widgets/assignment_list_item_student.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // class AssignmentsPageStudent extends StatefulWidget {
// //   final String courseId;

// //   const AssignmentsPageStudent({Key? key, required this.courseId})
// //       : super(key: key);

// //   @override
// //   State<AssignmentsPageStudent> createState() => _AssignmentsPageStudentState();
// // }

// // class _AssignmentsPageStudentState extends State<AssignmentsPageStudent>
// //     with WidgetsBindingObserver {
// //   StudentAssignmentsViewModel? _viewModel;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //   }

// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     super.dispose();
// //   }

// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.resumed) {
// //       if (_viewModel != null) {
// //         _viewModel!.refreshAssignments();
// //       }
// //     }
// //   }

// //   Future<StudentAssignmentSubmission?> fetchSubmissionDetails(
// //       String assignmentId) async {
// //     try {
// //       final currentUser = _auth.currentUser;
// //       if (currentUser == null) {
// //         debugPrint('No current user');
// //         return null;
// //       }

// //       final doc = await _firestore
// //           .collection('Courses')
// //           .doc(widget.courseId)
// //           .collection('assignments')
// //           .doc(assignmentId)
// //           .collection('studentSubmits')
// //           .doc(currentUser.uid)
// //           .get();

// //       if (!doc.exists) {
// //         debugPrint(
// //             'No submission found for assignmentId: $assignmentId, user: ${currentUser.uid}');
// //         return null;
// //       }

// //       debugPrint('Submission data: ${doc.data()}');
// //       return StudentAssignmentSubmission.fromMap(doc.data()!);
// //     } catch (e) {
// //       debugPrint('Error fetching submission: $e');
// //       return null;
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     return ChangeNotifierProvider(
// //       create: (_) => StudentAssignmentsViewModel(courseId: widget.courseId),
// //       child: Consumer<StudentAssignmentsViewModel>(
// //         builder: (context, viewModel, child) {
// //           _viewModel = viewModel;

// //           if (viewModel.successMessage.isNotEmpty) {
// //             WidgetsBinding.instance.addPostFrameCallback((_) {
// //               if (mounted) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(
// //                     content: Text(viewModel.successMessage),
// //                     backgroundColor: Colors.green,
// //                   ),
// //                 );
// //                 viewModel.clearMessages();
// //               }
// //             });
// //           }

// //           if (viewModel.errorMessage.isNotEmpty) {
// //             WidgetsBinding.instance.addPostFrameCallback((_) {
// //               if (mounted) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(
// //                     content: Text(viewModel.errorMessage),
// //                     backgroundColor: Colors.red,
// //                   ),
// //                 );
// //                 viewModel.clearMessages();
// //               }
// //             });
// //           }

// //           return Scaffold(
// //             backgroundColor: const Color(0xFFF0F7FF),
// //             appBar: AppBar(
// //               iconTheme: const IconThemeData(color: Colors.white),
// //               title: const Text(
// //                 "Student Assignments",
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 22,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               backgroundColor: AppColors.primaryColor,
// //               elevation: 0,
// //               centerTitle: true,
// //               actions: [
// //                 IconButton(
// //                   icon: const Icon(Icons.refresh),
// //                   onPressed: () {
// //                     viewModel.refreshAssignments();
// //                   },
// //                 ),
// //               ],
// //             ),
// //             body: Stack(
// //               children: [
// //                 viewModel.isLoading
// //                     ? const Center(
// //                         child: CircularProgressIndicator(
// //                           color: AppColors.primaryColor,
// //                         ),
// //                       )
// //                     : viewModel.assignments.isEmpty
// //                         ? Center(
// //                             child: Column(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 const Icon(
// //                                   Icons.assignment,
// //                                   size: 80,
// //                                   color: Colors.grey,
// //                                 ),
// //                                 SizedBox(height: screenHeight * 0.03),
// //                                 Text(
// //                                   'No Assignments available',
// //                                   textAlign: TextAlign.center,
// //                                   style: TextStyle(
// //                                     fontSize: screenHeight * 0.03,
// //                                     color: Colors.grey,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                                 SizedBox(height: screenHeight * 0.01),
// //                                 Text(
// //                                   'Check back later for new assignments!',
// //                                   textAlign: TextAlign.center,
// //                                   style: TextStyle(
// //                                     fontSize: screenHeight * 0.02,
// //                                     color: Colors.grey,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           )
// //                         : Padding(
// //                             padding: EdgeInsets.all(screenWidth * 0.04),
// //                             child: ListView.builder(
// //                               itemCount: viewModel.assignments.length,
// //                               itemBuilder: (context, index) {
// //                                 final assignment = viewModel.assignments[index];
// //                                 return TestListItem(
// //                                   test: assignment,
// //                                   onTap: () async {
// //                                     print('Tapped on ${assignment.title}');
// //                                     if (assignment.isCompleted) {
// //                                       final submission =
// //                                           await fetchSubmissionDetails(
// //                                               assignment.title);
// //                                       if (submission != null) {
// //                                         print(
// //                                             'Navigation to Submission Detail View');
// //                                         await Navigator.push(
// //                                           context,
// //                                           MaterialPageRoute(
// //                                             builder: (context) =>
// //                                                 StudentSubmissionDetailView(
// //                                               adminId: widget.courseId,
// //                                               assignmentId: assignment.title,
// //                                               assignmentTitle: assignment.title,
// //                                               submission: submission,
// //                                               courseName: assignment.title ??
// //                                                   'Unknown Course',
// //                                             ),
// //                                           ),
// //                                         );
// //                                       } else {
// //                                         if (mounted) {
// //                                           ScaffoldMessenger.of(context)
// //                                               .showSnackBar(
// //                                             const SnackBar(
// //                                               content: Text(
// //                                                   'Error: Could not fetch submission details'),
// //                                               backgroundColor: Colors.red,
// //                                             ),
// //                                           );
// //                                         }
// //                                       }
// //                                     } else {
// //                                       print(
// //                                           'Navigation to Assignment Detail View');
// //                                       await Navigator.push(
// //                                         context,
// //                                         MaterialPageRoute(
// //                                           builder: (context) =>
// //                                               StudentAssignmentDetailView(
// //                                             courseId: widget.courseId,
// //                                             assignmentId: assignment.title,
// //                                             assignmentTitle: assignment.title,
// //                                           ),
// //                                         ),
// //                                       );
// //                                     }
// //                                     viewModel.refreshAssignments();
// //                                   },
// //                                   onViewSubmissions: () async {
// //                                     final currentUser = _auth.currentUser;
// //                                     if (currentUser != null) {
// //                                       await Navigator.push(
// //                                         context,
// //                                         MaterialPageRoute(
// //                                           builder: (context) =>
// //                                               AssignmentSubmissionsView(
// //                                             adminId: currentUser.uid,
// //                                             assignmentId: assignment.title,
// //                                             assignmentTitle: assignment.title,
// //                                             courseName: widget.courseId,
// //                                           ),
// //                                         ),
// //                                       );
// //                                     } else {
// //                                       if (mounted) {
// //                                         ScaffoldMessenger.of(context)
// //                                             .showSnackBar(
// //                                           const SnackBar(
// //                                             content: Text(
// //                                                 'Error: User not authenticated'),
// //                                             backgroundColor: Colors.red,
// //                                           ),
// //                                         );
// //                                       }
// //                                     }
// //                                   },
// //                                 );
// //                               },
// //                             ),
// //                           ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/assignments/models/assignment_model_student.dart';
// import 'package:attendance_app/features/assignments/models/student_assignment_response.dart';
// import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignments_viewmodel.dart';
// import 'package:attendance_app/features/assignments/presentation/views/assignment_submissions_view.dart';
// import 'package:attendance_app/features/assignments/presentation/views/student_assignment_detail_view.dart';
// import 'package:attendance_app/features/assignments/presentation/views/student_submission_detail_view.dart';
// import 'package:attendance_app/features/assignments/presentation/views/widgets/assignment_list_item_student.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AssignmentsPageStudent extends StatefulWidget {
//   final String courseId;

//   const AssignmentsPageStudent({Key? key, required this.courseId})
//       : super(key: key);

//   @override
//   State<AssignmentsPageStudent> createState() => _AssignmentsPageStudentState();
// }

// class _AssignmentsPageStudentState extends State<AssignmentsPageStudent>
//     with WidgetsBindingObserver {
//   StudentAssignmentsViewModel? _viewModel;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String? _currentUserName; // Store the current user's name

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _fetchCurrentUserName(); // Fetch the name when the page loads
//   }

//   // Fetch the current user's name from Firestore
//   Future<void> _fetchCurrentUserName() async {
//     try {
//       final currentUser = _auth.currentUser;
//       if (currentUser != null) {
//         final userDoc =
//             await _firestore.collection('users').doc(currentUser.uid).get();
//         if (userDoc.exists) {
//           setState(() {
//             _currentUserName = userDoc.data()?['name'] ?? 'Unknown User';
//           });
//           debugPrint('Current user name: $_currentUserName');
//         } else {
//           debugPrint('User document does not exist in Firestore');
//           setState(() {
//             _currentUserName = 'Unknown User';
//           });
//         }
//       } else {
//         debugPrint('No current user found');
//         setState(() {
//           _currentUserName = 'Unknown User';
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching user name: $e');
//       setState(() {
//         _currentUserName = 'Unknown User';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       if (_viewModel != null) {
//         _viewModel!.refreshAssignments();
//       }
//     }
//   }

//   Future<StudentAssignmentSubmission?> fetchSubmissionDetails(
//       String assignmentId) async {
//     try {
//       final currentUser = _auth.currentUser;
//       if (currentUser == null) {
//         debugPrint('No current user');
//         return null;
//       }

//       final doc = await _firestore
//           .collection('Courses')
//           .doc(widget.courseId)
//           .collection('assignments')
//           .doc(assignmentId)
//           .collection('studentSubmits')
//           .doc(currentUser.uid)
//           .get();

//       if (!doc.exists) {
//         debugPrint(
//             'No submission found for assignmentId: $assignmentId, user: ${currentUser.uid}');
//         return null;
//       }

//       debugPrint('Submission data: ${doc.data()}');
//       return StudentAssignmentSubmission.fromMap(doc.data()!);
//     } catch (e) {
//       debugPrint('Error fetching submission: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return ChangeNotifierProvider(
//       create: (_) => StudentAssignmentsViewModel(courseId: widget.courseId),
//       child: Consumer<StudentAssignmentsViewModel>(
//         builder: (context, viewModel, child) {
//           _viewModel = viewModel;

//           if (viewModel.successMessage.isNotEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(viewModel.successMessage),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//                 viewModel.clearMessages();
//               }
//             });
//           }

//           if (viewModel.errorMessage.isNotEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(viewModel.errorMessage),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//                 viewModel.clearMessages();
//               }
//             });
//           }

//           return Scaffold(
//             backgroundColor: const Color(0xFFF0F7FF),
//             appBar: AppBar(
//               iconTheme: const IconThemeData(color: Colors.white),
//               title: const Text(
//                 "Student Assignments",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                   color: Colors.white,
//                 ),
//               ),
//               backgroundColor: AppColors.primaryColor,
//               elevation: 0,
//               centerTitle: true,
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: () {
//                     viewModel.refreshAssignments();
//                   },
//                 ),
//               ],
//             ),
//             body: Stack(
//               children: [
//                 viewModel.isLoading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           color: AppColors.primaryColor,
//                         ),
//                       )
//                     : viewModel.assignments.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.assignment,
//                                   size: 80,
//                                   color: Colors.grey,
//                                 ),
//                                 SizedBox(height: screenHeight * 0.03),
//                                 Text(
//                                   'No Assignments available',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: screenHeight * 0.03,
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 SizedBox(height: screenHeight * 0.01),
//                                 Text(
//                                   'Check back later for new assignments!',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: screenHeight * 0.02,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : Padding(
//                             padding: EdgeInsets.all(screenWidth * 0.04),
//                             child: ListView.builder(
//                               itemCount: viewModel.assignments.length,
//                               itemBuilder: (context, index) {
//                                 final assignment = viewModel.assignments[index];
//                                 return TestListItem(
//                                   test: assignment,
//                                   onTap: () async {
//                                     print('Tapped on ${assignment.title}');
//                                     if (assignment.isCompleted) {
//                                       final submission =
//                                           await fetchSubmissionDetails(
//                                               assignment.title);
//                                       if (submission != null) {
//                                         print(
//                                             'Navigation to Submission Detail View');
//                                         await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 StudentSubmissionDetailView(
//                                               adminId: widget.courseId,
//                                               assignmentId: assignment.title,
//                                               assignmentTitle: assignment.title,
//                                               submission: submission,
//                                               courseName: assignment.title ??
//                                                   'Unknown Course',
//                                             ),
//                                           ),
//                                         );
//                                       } else {
//                                         if (mounted) {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             const SnackBar(
//                                               content: Text(
//                                                   'Error: Could not fetch submission details'),
//                                               backgroundColor: Colors.red,
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     } else {
//                                       print(
//                                           'Navigation to Assignment Detail View');
//                                       await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               StudentAssignmentDetailView(
//                                             courseId: widget.courseId,
//                                             assignmentId: assignment.title,
//                                             assignmentTitle: assignment.title,
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                     viewModel.refreshAssignments();
//                                   },
//                                   onViewSubmissions: () async {
//                                     final currentUser = _auth.currentUser;
//                                     if (currentUser != null &&
//                                         _currentUserName != null) {
//                                       await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               AssignmentSubmissionsView(
//                                             adminId: currentUser.uid,
//                                             assignmentId: assignment.title,
//                                             assignmentTitle: assignment.title,
//                                             courseName: widget.courseId,
//                                             currentUserName:
//                                                 _currentUserName!, // Pass the current user's name
//                                           ),
//                                         ),
//                                       );
//                                     } else {
//                                       if (mounted) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           const SnackBar(
//                                             content: Text(
//                                                 'Error: User not authenticated or name not found'),
//                                             backgroundColor: Colors.red,
//                                           ),
//                                         );
//                                       }
//                                     }
//                                   },
//                                 );
//                               },
//                             ),
//                           ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/data/models/assignment_model_student.dart';
import 'package:attendance_app/features/assignments/data/models/student_assignment_response.dart';
import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignments_viewmodel.dart';
import 'package:attendance_app/features/assignments/presentation/views/assignment_submissions_view.dart';
import 'package:attendance_app/features/assignments/presentation/views/student_assignment_detail_view.dart';
import 'package:attendance_app/features/assignments/presentation/views/student_submission_detail_view.dart';
import 'package:attendance_app/features/assignments/presentation/views/widgets/assignment_list_item_student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class AssignmentsPageStudent extends StatefulWidget {
  final String courseId;

  const AssignmentsPageStudent({super.key, required this.courseId});

  @override
  State<AssignmentsPageStudent> createState() => _AssignmentsPageStudentState();
}

class _AssignmentsPageStudentState extends State<AssignmentsPageStudent>
    with WidgetsBindingObserver {
  StudentAssignmentsViewModel? _viewModel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserName; // Store the current user's name
  String? _adminId; // Store the admin ID for the course

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchCurrentUserName(); // Fetch the name when the page loads
    _fetchAdminId(); // Fetch the admin ID for the course
  }

  // Fetch the current user's name from Firestore
  Future<void> _fetchCurrentUserName() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          setState(() {
            _currentUserName = userDoc.data()?['name'] ?? 'Unknown User';
          });
          debugPrint('Current user name: $_currentUserName');
        } else {
          debugPrint('User document does not exist in Firestore');
          setState(() {
            _currentUserName = 'Unknown User';
          });
        }
      } else {
        debugPrint('No current user found');
        setState(() {
          _currentUserName = 'Unknown User';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      setState(() {
        _currentUserName = 'Unknown User';
      });
    }
  }

  // Fetch the admin ID for the course from Firestore
  Future<void> _fetchAdminId() async {
    try {
      final courseDoc =
          await _firestore.collection('Courses').doc(widget.courseId).get();
      if (courseDoc.exists) {
        setState(() {
          _adminId = courseDoc.data()?['adminId'] ?? '';
        });
        debugPrint('Course admin ID: $_adminId');
      } else {
        debugPrint('Course document does not exist in Firestore');
        setState(() {
          _adminId = '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching admin ID: $e');
      setState(() {
        _adminId = '';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_viewModel != null) {
        _viewModel!.refreshAssignments();
      }
    }
  }

  Future<StudentAssignmentSubmission?> fetchSubmissionDetails(
      String assignmentId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user');
        return null;
      }

      final doc = await _firestore
          .collection('Courses')
          .doc(widget.courseId)
          .collection('assignments')
          .doc(assignmentId)
          .collection('studentSubmits')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        debugPrint(
            'No submission found for assignmentId: $assignmentId, user: ${currentUser.uid}');
        return null;
      }

      debugPrint('Submission data: ${doc.data()}');
      return StudentAssignmentSubmission.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('Error fetching submission: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => StudentAssignmentsViewModel(courseId: widget.courseId),
      child: Consumer<StudentAssignmentsViewModel>(
        builder: (context, viewModel, child) {
          _viewModel = viewModel;

          if (viewModel.successMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.successMessage),
                    backgroundColor: Colors.green,
                  ),
                );
                viewModel.clearMessages();
              }
            });
          }

          if (viewModel.errorMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
                viewModel.clearMessages();
              }
            });
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF0F7FF),
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "Student Assignments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              // actions: [
              //   IconButton(
              //     icon: const Icon(Icons.refresh),
              //     onPressed: () {
              //       viewModel.refreshAssignments();
              //     },
              //   ),
              // ],
            ),
            body: Stack(
              children: [
                viewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : viewModel.assignments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.assignment,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                Text(
                                  'No Assignments available',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.03,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  'Check back later for new assignments!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.02,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: ListView.builder(
                              itemCount: viewModel.assignments.length,
                              itemBuilder: (context, index) {
                                final assignment = viewModel.assignments[index];
                                return TestListItem(
                                  test: assignment,
                                  onTap: () async {
                                    print('Tapped on ${assignment.title}');
                                    if (assignment.isCompleted) {
                                      final submission =
                                          await fetchSubmissionDetails(
                                              assignment.title);
                                      if (submission != null) {
                                        print(
                                            'Navigation to Submission Detail View');
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StudentSubmissionDetailView(
                                              adminId: _adminId ?? '',
                                              assignmentId: assignment.title,
                                              assignmentTitle: assignment.title,
                                              submission: submission,
                                              courseName: assignment.title ??
                                                  'Unknown Course',
                                            ),
                                          ),
                                        );
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Error: Could not fetch submission details'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      print(
                                          'Navigation to Assignment Detail View');
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StudentAssignmentDetailView(
                                            courseId: widget.courseId,
                                            assignmentId: assignment.title,
                                            assignmentTitle: assignment.title,
                                          ),
                                        ),
                                      );
                                    }
                                    viewModel.refreshAssignments();
                                  },
                                  onViewSubmissions: () async {
                                    final currentUser = _auth.currentUser;
                                    if (currentUser != null &&
                                        _currentUserName != null &&
                                        _adminId != null) {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AssignmentSubmissionsView(
                                            adminId: _adminId!,
                                            assignmentId: assignment.title,
                                            assignmentTitle: assignment.title,
                                            courseName: widget.courseId,
                                            currentUserName:
                                                _currentUserName!, // Pass the current user's name
                                          ),
                                        ),
                                      );
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Error: User not authenticated, name not found, or admin ID not found'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ).animate().flipV(duration: 400.ms);
                              },
                            ),
                          ),
              ],
            ),
          );
        },
      ),
    );
  }
}
