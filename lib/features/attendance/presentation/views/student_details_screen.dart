import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  final String courseId;
  final int lectureNumber;

  const StudentDetailsScreen({
    Key? key,
    required this.student,
    required this.courseId,
    required this.lectureNumber,
  }) : super(key: key);

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  bool showAssignmentDetails = false;
  bool showTestDetails = false;

  // Streams for assignments and tests
  late Stream<List<Map<String, dynamic>>> assignmentsStream;
  late Stream<List<Map<String, dynamic>>> testsStream;
  late Stream<int> completedAssignmentsStream;
  late Stream<int> completedTestsStream;

  @override
  void initState() {
    super.initState();

    // First check if we're using a course code or a course name
    String courseIdentifier = widget.courseId;

    // Debug output
    print("Student details initialized for: ${widget.student['name']}");
    print("Student ID: ${widget.student['id']}");
    print("Course ID: $courseIdentifier");

    // Check if we need to find the course by name
    if (!courseIdentifier.contains("/")) {
      FirebaseFirestore.instance.collection('Courses').get().then((snapshot) {
        for (var doc in snapshot.docs) {
          var data = doc.data();
          if (data['name'] == courseIdentifier) {
            courseIdentifier = doc.id;
            print(
                "Found course ID $courseIdentifier for course name $courseIdentifier");
            break;
          }
        }

        // Initialize streams with the correct course ID
        assignmentsStream = getStudentAssignments(courseIdentifier);
        testsStream = getStudentTests(courseIdentifier);
        completedAssignmentsStream =
            getCompletedAssignmentsCount(courseIdentifier);
        completedTestsStream = getCompletedTestsCount(courseIdentifier);
      });
    } else {
      // Use the provided course ID directly
      assignmentsStream = getStudentAssignments(courseIdentifier);
      testsStream = getStudentTests(courseIdentifier);
      completedAssignmentsStream =
          getCompletedAssignmentsCount(courseIdentifier);
      completedTestsStream = getCompletedTestsCount(courseIdentifier);
    }
  }

  // دالة لاسترجاع عدد المحاضرات التي حضرها الطالب
  Stream<int> getAttendedLecturesCount() {
    return FirebaseFirestore.instance
        .collection('Courses')
        .doc(widget.courseId)
        .collection('lectures')
        .snapshots()
        .asyncMap((lectureSnapshot) async {
      int attendedLectures = 0;

      for (var lectureDoc in lectureSnapshot.docs) {
        DocumentSnapshot studentDoc = await lectureDoc.reference
            .collection('attendance')
            .doc(widget.student['id'])
            .get();

        if (studentDoc.exists) {
          var studentData = studentDoc.data() as Map<String, dynamic>;
          for (var entry in studentData.entries) {
            if (entry.key != 'name' &&
                entry.key != 'imageUrl' &&
                entry.key != 'isStarred' &&
                entry.key != 'bonusCount') {
              var attendanceData = entry.value as Map<String, dynamic>;
              if (attendanceData['Check-out'] != '--') {
                attendedLectures++;
                break;
              }
            }
          }
        }
      }
      return attendedLectures;
    });
  }

  // دالة لاسترجاع عدد الواجبات التي أكملها الطالب
  Stream<int> getCompletedAssignmentsCount([String? courseId]) {
    final String effectiveCourseId = courseId ?? widget.courseId;
    print(
        "Getting completed assignments count for student: ${widget.student['id']} in course: $effectiveCourseId");

    return FirebaseFirestore.instance
        .collection('Courses')
        .doc(effectiveCourseId)
        .collection('assignments')
        .snapshots()
        .asyncMap((snapshot) async {
      int completedAssignments = 0;
      int totalAssignments = snapshot.docs.length;

      print("Total assignments in course: $totalAssignments");

      // Try to get assignments with both Firebase UID and studentId
      for (var assignmentDoc in snapshot.docs) {
        print("Checking assignment: ${assignmentDoc.id}");

        // Try with student['id'] (Firebase Auth UID)
        DocumentSnapshot studentStatus = await assignmentDoc.reference
            .collection('studentStatus')
            .doc(widget.student['id'])
            .get();

        // If not found with Firebase UID, try querying the whole collection for a matching name
        if (!studentStatus.exists) {
          print(
              "Assignment status not found with ID ${widget.student['id']}, trying to find by name");

          QuerySnapshot allStatusDocs =
              await assignmentDoc.reference.collection('studentStatus').get();

          for (var doc in allStatusDocs.docs) {
            try {
              // Fetch user document to check name
              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(doc.id)
                  .get();

              if (userDoc.exists) {
                String userName = userDoc.get('name');
                if (userName == widget.student['name']) {
                  print("Found matching user by name: $userName");
                  studentStatus = doc;
                  break;
                }
              }
            } catch (e) {
              print("Error checking user: ${e.toString()}");
            }
          }
        }

        if (studentStatus.exists) {
          var statusData = studentStatus.data() as Map<String, dynamic>?;
          bool isCompleted = statusData?['isCompleted'] ?? false;
          String scoreStr = statusData?['score'] ?? '';

          print(
              "Assignment ${assignmentDoc.id} status: exists=${studentStatus.exists}, completed=$isCompleted, score=$scoreStr");

          if (isCompleted) {
            completedAssignments++;
          }
        } else {
          print(
              "No status found for student in assignment ${assignmentDoc.id}");
        }
      }

      print("Total completed assignments: $completedAssignments");
      return completedAssignments;
    });
  }

  // دالة لاسترجاع بيانات الواجبات مع نسب الدرجات من 100%
  Stream<List<Map<String, dynamic>>> getStudentAssignments([String? courseId]) {
    final String effectiveCourseId = courseId ?? widget.courseId;

    return FirebaseFirestore.instance
        .collection('Courses')
        .doc(effectiveCourseId)
        .collection('assignments')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> assignments = [];

      for (var assignmentDoc in snapshot.docs) {
        var assignmentData = assignmentDoc.data();

        // Try with student['id'] (Firebase Auth UID)
        DocumentSnapshot studentStatus = await assignmentDoc.reference
            .collection('studentStatus')
            .doc(widget.student['id'])
            .get();

        // If not found with Firebase UID, try querying the whole collection for a matching name
        if (!studentStatus.exists) {
          QuerySnapshot allStatusDocs =
              await assignmentDoc.reference.collection('studentStatus').get();

          for (var doc in allStatusDocs.docs) {
            try {
              // Fetch user document to check name
              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(doc.id)
                  .get();

              if (userDoc.exists) {
                String userName = userDoc.get('name');
                if (userName == widget.student['name']) {
                  studentStatus = doc;
                  break;
                }
              }
            } catch (e) {
              print("Error checking user: ${e.toString()}");
            }
          }
        }

        if (studentStatus.exists) {
          var statusData = studentStatus.data() as Map<String, dynamic>?;
          bool isCompleted = statusData?['isCompleted'] ?? false;

          if (isCompleted) {
            // استخراج الدرجة وتحويلها إلى نسبة مئوية
            String scoreStr = statusData?['score'] ?? '0';
            scoreStr = scoreStr.replaceAll('"', '').replaceAll("'", "");
            double numericalScore =
                double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;

            // إضافة الواجب إلى القائمة
            assignments.add({
              'name': assignmentData['name'] ??
                  'Assignment ${assignments.length + 1}',
              'score': '${numericalScore.toStringAsFixed(0)}%',
              'scoreValue': numericalScore,
            });
          }
        }
      }

      print("Found ${assignments.length} completed assignments with scores");
      return assignments;
    });
  }

  // دالة لاسترجاع عدد الاختبارات التي أكملها الطالب
  Stream<int> getCompletedTestsCount([String? courseId]) {
    final String effectiveCourseId = courseId ?? widget.courseId;
    print(
        "Getting completed tests count for student: ${widget.student['id']} in course: $effectiveCourseId");

    return FirebaseFirestore.instance
        .collection('Courses')
        .doc(effectiveCourseId)
        .collection('tests')
        .snapshots()
        .asyncMap((snapshot) async {
      int completedTests = 0;
      int totalTests = snapshot.docs.length;

      print("Total tests in course: $totalTests");

      for (var testDoc in snapshot.docs) {
        print("Checking test: ${testDoc.id}");

        // Try with student['id'] (Firebase Auth UID)
        DocumentSnapshot studentStatus = await testDoc.reference
            .collection('studentStatus')
            .doc(widget.student['id'])
            .get();

        // If not found with Firebase UID, try querying the whole collection for a matching name
        if (!studentStatus.exists) {
          print(
              "Test status not found with ID ${widget.student['id']}, trying to find by name");

          QuerySnapshot allStatusDocs =
              await testDoc.reference.collection('studentStatus').get();

          for (var doc in allStatusDocs.docs) {
            try {
              // Fetch user document to check name
              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(doc.id)
                  .get();

              if (userDoc.exists) {
                String userName = userDoc.get('name');
                if (userName == widget.student['name']) {
                  print("Found matching user by name: $userName");
                  studentStatus = doc;
                  break;
                }
              }
            } catch (e) {
              print("Error checking user: ${e.toString()}");
            }
          }
        }

        if (studentStatus.exists) {
          var statusData = studentStatus.data() as Map<String, dynamic>?;
          bool isCompleted = statusData?['isCompleted'] ?? false;
          String scoreStr = statusData?['score'] ?? '';

          print(
              "Test ${testDoc.id} status: exists=${studentStatus.exists}, completed=$isCompleted, score=$scoreStr");

          if (isCompleted) {
            completedTests++;
          }
        } else {
          print("No status found for student in test ${testDoc.id}");
        }
      }

      print("Total completed tests: $completedTests");
      return completedTests;
    });
  }

  // دالة لاسترجاع بيانات الاختبارات مع نسب الدرجات من 100%
  Stream<List<Map<String, dynamic>>> getStudentTests([String? courseId]) {
    final String effectiveCourseId = courseId ?? widget.courseId;

    return FirebaseFirestore.instance
        .collection('Courses')
        .doc(effectiveCourseId)
        .collection('tests')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> tests = [];

      for (var testDoc in snapshot.docs) {
        var testData = testDoc.data();

        // Try with student['id'] (Firebase Auth UID)
        DocumentSnapshot studentStatus = await testDoc.reference
            .collection('studentStatus')
            .doc(widget.student['id'])
            .get();

        // If not found with Firebase UID, try querying the whole collection for a matching name
        if (!studentStatus.exists) {
          QuerySnapshot allStatusDocs =
              await testDoc.reference.collection('studentStatus').get();

          for (var doc in allStatusDocs.docs) {
            try {
              // Fetch user document to check name
              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(doc.id)
                  .get();

              if (userDoc.exists) {
                String userName = userDoc.get('name');
                if (userName == widget.student['name']) {
                  studentStatus = doc;
                  break;
                }
              }
            } catch (e) {
              print("Error checking user: ${e.toString()}");
            }
          }
        }

        if (studentStatus.exists) {
          var statusData = studentStatus.data() as Map<String, dynamic>?;
          bool isCompleted = statusData?['isCompleted'] ?? false;

          if (isCompleted) {
            // استخراج الدرجة وتحويلها إلى نسبة مئوية
            String scoreStr = statusData?['score'] ?? '0';
            scoreStr = scoreStr.replaceAll('"', '').replaceAll("'", "");
            double numericalScore =
                double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;

            // إضافة الاختبار إلى القائمة
            tests.add({
              'name': testData['name'] ?? 'Test ${tests.length + 1}',
              'score': '${numericalScore.toStringAsFixed(0)}%',
              'scoreValue': numericalScore,
            });
          }
        }
      }

      print("Found ${tests.length} completed tests with scores");
      return tests;
    });
  }

  // دالة لعرض الصورة في وضع ملء الشاشة
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Student Photo',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Hero(
                tag: 'studentImage',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Student Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [Colors.white, Color(0xFFE3F2FD)],
          // ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Courses')
                    .doc(widget.courseId)
                    .collection('lectures')
                    .where('lectureNumber', isEqualTo: widget.lectureNumber)
                    .snapshots()
                    .asyncMap((snapshot) async {
                  if (snapshot.docs.isEmpty) {
                    throw Exception('Lecture not found');
                  }
                  var lectureDoc = snapshot.docs.first;
                  return await lectureDoc.reference
                      .collection('attendance')
                      .doc(widget.student['id'])
                      .get();
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading student data'));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Student data not found'));
                  }

                  var studentData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  // استرجاع imageUrl بنفس الطريقة المستخدمة في LectureAttendanceScreen
                  Map<String, dynamic> attendanceDates = {};
                  String? latestDate;
                  Map<String, dynamic>? latestAttendanceData;

                  studentData.forEach((key, value) {
                    if (key.startsWith('20') && value is Map<String, dynamic>) {
                      attendanceDates[key] = value;
                    }
                  });

                  String imageUrl;
                  if (attendanceDates.isNotEmpty) {
                    var sortedDates = attendanceDates.keys.toList()
                      ..sort((a, b) => b.compareTo(a));
                    latestDate = sortedDates.first;
                    latestAttendanceData = attendanceDates[latestDate];
                    imageUrl = latestAttendanceData?['imageUrl'] ??
                        studentData['imageUrl'] ??
                        'https://i.pravatar.cc/150';
                  } else {
                    imageUrl =
                        studentData['imageUrl'] ?? 'https://i.pravatar.cc/150';
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Student profile section
                      Column(
                        children: [
                          // صورة الطالب مع إمكانية الضغط لعرض الصورة بملء الشاشة
                          GestureDetector(
                            onTap: () =>
                                _showFullScreenImage(context, imageUrl),
                            child: Hero(
                              tag: 'studentImage',
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Name
                          Text(
                            studentData['name'] ?? widget.student['name'],
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          // زر النجمة لتفعيل/إلغاء البونص
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Courses')
                                .doc(widget.courseId)
                                .collection('lectures')
                                .where('lectureNumber',
                                    isEqualTo: widget.lectureNumber)
                                .snapshots()
                                .asyncMap((snapshot) async {
                              var lectureDoc = snapshot.docs.first;
                              return await lectureDoc.reference
                                  .collection('attendance')
                                  .doc(widget.student['id'])
                                  .get();
                            }),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return const Text('Error loading star status');
                              }
                              bool isStarred = false;
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data!.exists) {
                                var studentData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                isStarred = studentData['isStarred'] ?? false;
                              }

                              return Icon(
                                isStarred ? Icons.star : Icons.star_border,
                                color: AppColors.primaryColor,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Info Cards Section
                      Container(
                        width: 300,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Bonus info
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Courses')
                                  .doc(widget.courseId)
                                  .collection('lectures')
                                  .where('lectureNumber',
                                      isEqualTo: widget.lectureNumber)
                                  .snapshots()
                                  .asyncMap((snapshot) async {
                                var lectureDoc = snapshot.docs.first;
                                return await lectureDoc.reference
                                    .collection('attendance')
                                    .doc(widget.student['id'])
                                    .get();
                              }),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return infoItem('Num of bonus: Loading...');
                                }
                                if (snapshot.hasError) {
                                  return infoItem('Num of bonus: Error');
                                }
                                int bonusCount = 0;
                                if (snapshot.hasData &&
                                    snapshot.data != null &&
                                    snapshot.data!.exists) {
                                  var studentData = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  bonusCount = studentData['bonusCount'] ?? 0;
                                }
                                return infoItem('Num of bonus: $bonusCount');
                              },
                            ),
                            const SizedBox(height: 15),
                            // Lectures attended info
                            StreamBuilder<int>(
                              stream: getAttendedLecturesCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return infoItem('Num of Lec: Loading...');
                                }
                                if (snapshot.hasError) {
                                  return infoItem('Num of Lec: Error');
                                }
                                return infoItem(
                                    'Num of Lec: ${snapshot.data ?? 0}');
                              },
                            ),
                            const SizedBox(height: 15),
                            // Assignments section with dropdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                StreamBuilder<int>(
                                  stream: completedAssignmentsStream,
                                  builder: (context, snapshot) {
                                    int completed = snapshot.data ?? 0;
                                    return Text(
                                      'Num of Assig: $completed',
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showAssignmentDetails =
                                          !showAssignmentDetails;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primaryColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      showAssignmentDetails
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Assignment details when expanded
                      if (showAssignmentDetails)
                        Container(
                          width: 300,
                          margin: const EdgeInsets.only(top: 15),
                          child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: assignmentsStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text("No completed assignments found"),
                                );
                              }

                              return Column(
                                children: snapshot.data!.map((assignment) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: AppColors.primaryColor,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            assignment['name'],
                                            style: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            assignment['score'],
                                            style: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Tests section
                      Container(
                        width: 300,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StreamBuilder<int>(
                              stream: completedTestsStream,
                              builder: (context, snapshot) {
                                int completed = snapshot.data ?? 0;
                                return Text(
                                  'Num of Tests: $completed',
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showTestDetails = !showTestDetails;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  showTestDetails
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Test details when expanded
                      if (showTestDetails)
                        Container(
                          width: 300,
                          margin: const EdgeInsets.only(top: 15),
                          child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: testsStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text("No completed tests found"),
                                );
                              }

                              return Column(
                                children: snapshot.data!.map((test) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: AppColors.primaryColor,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryColor
                                                .withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            test['name'],
                                            style: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            test['score'],
                                            style: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create consistent info items
  Widget infoItem(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
