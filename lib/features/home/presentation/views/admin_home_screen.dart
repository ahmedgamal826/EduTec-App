import 'package:animate_do/animate_do.dart';
import 'package:attendance_app/core/provider/app_provider.dart';
import 'package:attendance_app/core/views/subject_screen.dart';
import 'package:attendance_app/features/attendance/presentation/views/update_course_view.dart';
import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
import 'package:attendance_app/features/home/presentation/views/add_subject_view.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/course_card_widget.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/no_course_found_widget.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/no_course_search__found_widget.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/search_course_text_field.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/admin_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredSubjects = [];
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  String? adminUid; // To store admin's uid

  @override
  void initState() {
    super.initState();
    _getAdminUid(); // Get admin uid when screen starts
    searchController.addListener(() {
      filterSubjects(searchController.text);
    });

    // Update unread notifications count when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false)
          .fetchUnreadNotificationsCount();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Function to retrieve admin uid based on email
  Future<void> _getAdminUid() async {
    try {
      // Get current user from Firebase Auth
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String email = currentUser.email ?? '';
        if (email.isNotEmpty) {
          // Search in users collection to get uid based on email
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            setState(() {
              adminUid = userSnapshot.docs.first.id; // Store admin's uid
            });
          } else {
            print('No user found with this email');
          }
        } else {
          print('No user email found');
        }
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Error fetching admin UID: $e');
    }
  }

  void filterSubjects(String query) {
    setState(() {
      // No need for local filtering, we rely on StreamBuilder
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      key: _scaffoldMessengerKey,
      backgroundColor: isDarkMode ? Colors.black : AppColors.whiteColor,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Admin Home Screen",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchCourseTextField(
              controller: searchController,
              onChanged: filterSubjects,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: adminUid == null
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    )) // Show loading indicator while fetching adminUid
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Courses')
                          .where('adminID',
                              isEqualTo: adminUid) // Filter based on adminID
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const NoCourseFoundWidget();
                        }

                        var subjects = snapshot.data!.docs.where((doc) {
                          String title =
                              (doc.data() as Map<String, dynamic>)['courseName']
                                      ?.toString()
                                      .toLowerCase() ??
                                  '';
                          String query = searchController.text.toLowerCase();
                          return title.contains(query);
                        }).toList();

                        if (subjects.isEmpty) {
                          return const NoCourseSearchFoundWidget();
                        }

                        return ListView.builder(
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            var subjectData =
                                subjects[index].data() as Map<String, dynamic>;
                            String courseId = subjects[index].id; // Course ID
                            String courseName =
                                subjectData['courseName']?.toString() ??
                                    'Unknown Subject';
                            String semester =
                                subjectData['semester']?.toString() ??
                                    'Unknown Year';
                            String date = subjectData['date']?.toString() ??
                                'Unknown Date';

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                double cardHeight = constraints.maxWidth * 0.4;
                                double fontSizeTitle =
                                    constraints.maxWidth * 0.06;
                                double fontSizeSubtitle =
                                    constraints.maxWidth * 0.04;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubjectScreen(
                                          courseId: courseId, // Pass courseId
                                          courseName:
                                              courseName, // Pass course name
                                        ),
                                      ),
                                    );
                                  },
                                  child: FadeInUp(
                                    duration: const Duration(milliseconds: 400),
                                    delay: Duration(milliseconds: index * 500),
                                    child: CourseCard(
                                      cardHeight: cardHeight,
                                      fontSizeTitle: fontSizeTitle,
                                      fontSizeSubtitle: fontSizeSubtitle,
                                      constraints: constraints,
                                      courseName: courseName,
                                      semester: semester,
                                      date: date,
                                      onMorePressed: (context) {
                                        _showBottomSheet(context,
                                            subjects[index].id, courseName);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSubjectPage(),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showBottomSheet(
      BuildContext context, String courseId, String courseName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Update Course"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateCoursePage(
                        courseId: courseId,
                        courseName: '',
                        courseCode: '',
                        semester: '',
                        date: '',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Course"),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(courseId, courseName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(String courseId, String courseName) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Delete Course',
      desc: 'Are you sure you want to delete $courseName?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        try {
          // Delete course document from Firestore
          await FirebaseFirestore.instance
              .collection('Courses')
              .doc(courseId)
              .delete();

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting course: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    ).show();
  }
}
