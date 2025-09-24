// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/tests/data/models/student_tests_response.dart'; // Added for StudentTestsSubmission
// import 'package:attendance_app/features/tests/presentation/viewmodels/student_tests_viewmodel.dart';
// import 'package:attendance_app/features/tests/presentation/views/tests_submissions_view.dart';
// import 'package:attendance_app/features/tests/presentation/views/widgets/tests_list_item_student.dart'; // Added for TestsListItemStudent
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:provider/provider.dart';

// class TestsPageStudent extends StatefulWidget {
//   final String courseId;

//   const TestsPageStudent({Key? key, required this.courseId}) : super(key: key);

//   @override
//   State<TestsPageStudent> createState() => _TestsPageStudentState();
// }

// class _TestsPageStudentState extends State<TestsPageStudent>
//     with WidgetsBindingObserver {
//   TestsStudentViewModel? _viewModel;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String? _currentUserName;
//   String? _adminId;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _fetchCurrentUserName();
//     _fetchAdminId();
//   }

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

//   Future<void> _fetchAdminId() async {
//     try {
//       final courseDoc =
//           await _firestore.collection('Courses').doc(widget.courseId).get();
//       if (courseDoc.exists) {
//         setState(() {
//           _adminId = courseDoc.data()?['adminId'] ?? '';
//         });
//         debugPrint('Course admin ID: $_adminId');
//       } else {
//         debugPrint('Course document does not exist in Firestore');
//         setState(() {
//           _adminId = '';
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching admin ID: $e');
//       setState(() {
//         _adminId = '';
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

//   Future<TestsStudentSubmission?> fetchSubmissionDetails(String testId) async {
//     try {
//       final currentUser = _auth.currentUser;
//       if (currentUser == null) {
//         debugPrint('No current user');
//         return null;
//       }

//       final doc = await _firestore
//           .collection('Courses')
//           .doc(widget.courseId)
//           .collection('tests')
//           .doc(testId)
//           .collection('studentSubmits')
//           .doc(currentUser.uid)
//           .get();

//       if (!doc.exists) {
//         debugPrint(
//             'No submission found for testId: $testId, user: ${currentUser.uid}');
//         return null;
//       }

//       debugPrint('Submission data: ${doc.data()}');
//       return TestsStudentSubmission.fromMap(doc.data()!);
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
//       create: (_) => TestsStudentViewModel(courseId: widget.courseId),
//       child: Consumer<TestsStudentViewModel>(
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
//                 "Student Tests",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                   color: Colors.white,
//                 ),
//               ),
//               backgroundColor: AppColors.primaryColor,
//               elevation: 0,
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
//                                   'No Tests available',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: screenHeight * 0.03,
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 SizedBox(height: screenHeight * 0.01),
//                                 Text(
//                                   'Check back later for new tests!',
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
//                                 final test = viewModel.assignments[index];
//                                 return TestsListItemStudent(
//                                   test: test,
//                                   onTap: () async {
//                                     debugPrint('Tapped on ${test.title}');
//                                     if (test.isCompleted) {
//                                       final submission =
//                                           await fetchSubmissionDetails(
//                                               test.title);
//                                       if (submission != null) {
//                                         debugPrint(
//                                             'Navigation to Submission Detail View');
//                                         await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 StudentSubmissionDetailView(
//                                               adminId: _adminId ?? '',
//                                               testId: test.title,
//                                               testTitle: test.title,
//                                               submission: submission,
//                                               courseName: widget.courseId,
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
//                                       debugPrint(
//                                           'Navigation to Tests Detail View');
//                                       await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               StudentTestsDetailView(
//                                             courseId: widget.courseId,
//                                             testId: test.title,
//                                             testTitle: test.title,
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                     viewModel.refreshAssignments();
//                                   },
//                                   onViewSubmissions: () async {
//                                     final currentUser = _auth.currentUser;
//                                     if (currentUser != null &&
//                                         _currentUserName != null &&
//                                         _adminId != null) {
//                                       await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               TestsSubmissionsView(
//                                             adminId: _adminId!,
//                                             testId: test.title,
//                                             testTitle: test.title,
//                                             courseName: widget.courseId,
//                                             currentUserName: _currentUserName!,
//                                           ),
//                                         ),
//                                       );
//                                     } else {
//                                       if (mounted) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           const SnackBar(
//                                             content: Text(
//                                                 'Error: User not authenticated, name not found, or admin ID not found'),
//                                             backgroundColor: Colors.red,
//                                           ),
//                                         );
//                                       }
//                                     }
//                                   },
//                                 ).animate().flipV(duration: 400.ms);
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
import 'package:attendance_app/features/tests/data/models/student_tests_response.dart';
import 'package:attendance_app/features/tests/presentation/viewmodels/student_tests_viewmodel.dart';
import 'package:attendance_app/features/tests/presentation/views/student_test_detail_view.dart';
import 'package:attendance_app/features/tests/presentation/views/test_submission_view.dart';
import 'package:attendance_app/features/tests/presentation/views/tests_students_submissions_details_view.dart';
import 'package:attendance_app/features/tests/presentation/views/widgets/tests_list_item_student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class TestsPageStudent extends StatefulWidget {
  final String courseId;

  const TestsPageStudent({super.key, required this.courseId});

  @override
  State<TestsPageStudent> createState() => _TestsPageStudentState();
}

class _TestsPageStudentState extends State<TestsPageStudent>
    with WidgetsBindingObserver {
  TestsStudentViewModel? _viewModel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserName;
  String? _adminId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchCurrentUserName();
    _fetchAdminId();
  }

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

  Future<TestsStudentSubmission?> fetchSubmissionDetails(String testId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user');
        return null;
      }

      final doc = await _firestore
          .collection('Courses')
          .doc(widget.courseId)
          .collection('tests')
          .doc(testId)
          .collection('studentSubmits')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        debugPrint(
            'No submission found for testId: $testId, user: ${currentUser.uid}');
        return null;
      }

      debugPrint('Submission data: ${doc.data()}');
      return TestsStudentSubmission.fromMap(doc.data()!);
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
      create: (_) => TestsStudentViewModel(courseId: widget.courseId),
      child: Consumer<TestsStudentViewModel>(
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
                "Student Tests",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
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
                                  'No Tests available',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.03,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  'Check back later for new tests!',
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
                                final test = viewModel.assignments[index];
                                return TestsListItemStudent(
                                  test: test,
                                  onTap: () async {
                                    debugPrint('Tapped on ${test.title}');
                                    if (test.isCompleted) {
                                      final submission =
                                          await fetchSubmissionDetails(
                                              test.title);
                                      if (submission != null) {
                                        debugPrint(
                                            'Navigation to Submission Detail View');
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TestsStudentSubmissionDetailView(
                                              adminId: _adminId ?? '',
                                              testId: test.title,
                                              testTitle: test.title,
                                              submission: submission,
                                              courseName: widget.courseId,
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
                                      debugPrint(
                                          'Navigation to Tests Detail View');
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StudentTestDetailView(
                                            courseId: widget.courseId,
                                            testId: test.title,
                                            testTitle: test.title,
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
                                              TestSubmissionView(
                                            adminId: _adminId!,
                                            testId: test.title,
                                            testTitle: test.title,
                                            courseName: widget.courseId,
                                            currentUserName: _currentUserName!,
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
