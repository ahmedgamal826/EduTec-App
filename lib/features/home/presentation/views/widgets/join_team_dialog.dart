import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/home/presentation/views/payment_courses_view.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/success_dialog.dart';

class JoinTeamDialog {
  static Future<void> show(BuildContext context) async {
    // First check if student has reached the maximum free courses limit
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String studentUid = currentUser.uid;

    try {
      // Clean up deleted courses first before checking enrollment limits
      await _cleanupDeletedCourses(studentUid);

      // Get the student's enrolled courses
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentUid)
          .get();

      if (!studentDoc.exists) {
        _showErrorDialog(context, 'Student data not found');
        return;
      }

      var studentData = studentDoc.data() as Map<String, dynamic>;
      List<dynamic> enrolledCourses = studentData['enrolledCourses'] ?? [];

      // Print for debugging
      print('Enrolled courses: ${enrolledCourses.length}');

      // Get number of premium courses allowed (0 if not set)
      int premiumCoursesAllowed = studentData['premiumCoursesAllowed'] ?? 0;

      // Print for debugging
      print('Premium courses allowed: $premiumCoursesAllowed');

      // Check if student has reached the maximum free courses limit (5)
      const int maxFreeCourses = 5;

      // Print for debugging
      print('Max allowed: ${maxFreeCourses + premiumCoursesAllowed}');

      // Check if student can still register for free courses
      if (enrolledCourses.length < maxFreeCourses) {
        // Student still has free courses available
        print('Student can register for free courses');
        _showBeautifulJoinDialog(
            context, enrolledCourses.length, maxFreeCourses);
      }
      // Check if student has premium slots available
      else if (enrolledCourses.length <
          maxFreeCourses + premiumCoursesAllowed) {
        // Student has used all free courses but has premium slots
        print('Student using premium slot');
        _showBeautifulJoinDialog(context, enrolledCourses.length,
            maxFreeCourses + premiumCoursesAllowed);
      } else {
        // No more slots available, show premium options
        print('No more slots available');
        _showPremiumOptionsDialog(context);
      }
    } catch (e) {
      print('Error in JoinTeamDialog.show: $e');
      _showErrorDialog(context, 'Error checking enrolled courses: $e');
    }
  }

  // Function to clean up deleted courses
  static Future<void> _cleanupDeletedCourses(String studentUid) async {
    try {
      // Get the student document
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentUid)
          .get();

      if (!studentDoc.exists) return;

      var studentData = studentDoc.data() as Map<String, dynamic>;
      List<dynamic> enrolledCourses = studentData['enrolledCourses'] ?? [];

      if (enrolledCourses.isEmpty) return;

      print('Before cleanup: ${enrolledCourses.length} courses');

      // List to store valid course codes
      List<String> validCourseCodes = [];

      // Check each course code
      for (var courseCode in enrolledCourses) {
        // Query to check if the course exists
        QuerySnapshot courseQuery = await FirebaseFirestore.instance
            .collection('Courses')
            .where('courseCode', isEqualTo: courseCode)
            .get();

        if (courseQuery.docs.isNotEmpty) {
          // Course exists
          validCourseCodes.add(courseCode.toString());
        } else {
          print('Course with code $courseCode not found and will be removed');
        }
      }

      // Update the student document only if there's a change
      if (validCourseCodes.length != enrolledCourses.length) {
        print(
            'Updating enrolledCourses from ${enrolledCourses.length} to ${validCourseCodes.length}');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(studentUid)
            .update({'enrolledCourses': validCourseCodes});
      }
    } catch (e) {
      print('Error in _cleanupDeletedCourses: $e');
    }
  }

  static void _showPremiumOptionsDialog(BuildContext context) {
    final dialogContext = context; // حفظ السياق الأساسي

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return true; // السماح بالإغلاق بدون استخدام Navigator
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon section with blue circle background (similar to AwesomeDialog)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.info,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Title
                  const Text(
                    'Premium Courses',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Description
                  const Text(
                    'You have reached the maximum limit of 5 free courses. Choose an option to continue:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Buttons - similar style to AwesomeDialog
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Enter Code Button (Cancel Button)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(120, 45),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // أغلق الحوار أولاً
                          _showCodeEntryDialog(
                              dialogContext); // استخدم السياق الأصلي
                        },
                        child: const Text(
                          'Enter Code',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Payment Button (OK Button)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(120, 45),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // أغلق الحوار أولاً
                          Navigator.push(
                            dialogContext, // استخدم السياق الأصلي
                            MaterialPageRoute(
                              builder: (context) => const PaymentCoursesView(),
                            ),
                          );
                        },
                        child: const Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void _showBeautifulJoinDialog(
      BuildContext context, int currentCourses, int maxCourses) {
    final TextEditingController codeController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.blue.shade50,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school,
                      color: AppColors.primaryColor,
                      size: 50,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Join New Course",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Show remaining courses info
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3))),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You have ${maxCourses - currentCourses} free courses remaining",
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: codeController,
                      cursorColor: AppColors.primaryColor,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "Enter Course Code",
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        errorText: errorMessage,
                        prefixIcon: const Icon(Icons.code,
                            color: AppColors.primaryColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoundedButton(
                            context,
                            "Cancel",
                            Colors.grey.shade200,
                            Colors.black87,
                            () => Navigator.pop(context)),
                        _buildRoundedButton(context, "Join Course",
                            AppColors.primaryColor, Colors.white, () async {
                          String courseCode = codeController.text.trim();
                          if (courseCode.isEmpty) {
                            setState(() {
                              errorMessage = 'Please enter a course code';
                            });
                            return;
                          }

                          try {
                            // Check if the course code exists in the Courses collection
                            QuerySnapshot courseSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('Courses')
                                    .where('courseCode', isEqualTo: courseCode)
                                    .get();

                            if (courseSnapshot.docs.isEmpty) {
                              setState(() {
                                errorMessage = 'Invalid course code';
                              });
                              return;
                            }

                            // Get the course document
                            var courseDoc = courseSnapshot.docs.first;
                            String courseId = courseDoc.id;

                            // Get the current student's UID
                            User? currentUser =
                                FirebaseAuth.instance.currentUser;
                            if (currentUser == null) {
                              setState(() {
                                errorMessage = 'User not logged in';
                              });
                              return;
                            }

                            String studentUid = currentUser.uid;

                            // Get the student's data from the users collection
                            DocumentSnapshot studentDoc =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(studentUid)
                                    .get();

                            if (!studentDoc.exists) {
                              setState(() {
                                errorMessage = 'Student data not found';
                              });
                              return;
                            }

                            var studentData =
                                studentDoc.data() as Map<String, dynamic>;
                            String studentName =
                                studentData['name'] ?? 'Unknown';
                            String studentEmail = studentData['email'] ?? '';
                            String studentImage = studentData['image'] ?? '';

                            // Add the student to the students subcollection under the course
                            await FirebaseFirestore.instance
                                .collection('Courses')
                                .doc(courseId)
                                .collection('students')
                                .doc(studentUid)
                                .set({
                              'uid': studentUid,
                              'name': studentName,
                              'email': studentEmail,
                              'image': studentImage,
                              'joinedAt': FieldValue.serverTimestamp(),
                            });

                            // Add the course to the student's enrolledCourses in users collection
                            DocumentReference studentRef = FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(studentUid);

                            await studentRef.update({
                              'enrolledCourses':
                                  FieldValue.arrayUnion([courseCode])
                            });

                            Navigator.pop(context);

                            // Show success dialog
                            _showSuccessDialog(context,
                                courseDoc['courseName'] ?? 'the course');
                          } catch (e) {
                            setState(() {
                              errorMessage = 'Error joining course: $e';
                            });
                          }
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void _showCodeEntryDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    String? errorMessage;
    final dialogContext = context; // حفظ السياق الأصلي

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return true; // السماح بالإغلاق بدون استخدام Navigator
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon section with blue circle background (similar to AwesomeDialog)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.vpn_key,
                            color: AppColors.primaryColor,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Enter Premium Course Code",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Please enter the premium code you received after payment",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Text field for entering the code
                      TextField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        cursorColor: AppColors.primaryColor,
                        decoration: InputDecoration(
                          labelText: "Premium Code",
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          errorText: errorMessage,
                          prefixIcon: const Icon(Icons.code,
                              color: AppColors.primaryColor),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Cancel button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(120, 45),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // Verify button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(120, 45),
                            ),
                            onPressed: () async {
                              String premiumCode = codeController.text.trim();
                              if (premiumCode.isEmpty) {
                                setState(() {
                                  errorMessage = 'Please enter a code';
                                });
                                return;
                              }

                              // Check if the code is valid using our PremiumCodeManager
                              if (PremiumCodeManager.isValidCode(premiumCode)) {
                                Navigator.of(context).pop();

                                // Show success dialog
                                SuccessDialog.show(dialogContext,
                                    'You can now register for an additional course!');

                                // Here you would update the database to allow the user an additional course
                                // This part would integrate with your actual database
                                try {
                                  User? currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  if (currentUser != null) {
                                    // Add a field to the user document indicating they've purchased a premium course
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(currentUser.uid)
                                        .update({
                                      'premiumCoursesAllowed':
                                          FieldValue.increment(1),
                                      'usedPremiumCodes':
                                          FieldValue.arrayUnion([premiumCode])
                                    });
                                  }
                                } catch (e) {
                                  print("Error updating premium status: $e");
                                }
                              } else {
                                setState(() {
                                  errorMessage = 'Invalid premium code';
                                });
                              }
                            },
                            child: const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void _showSuccessDialog(BuildContext context, String courseName) {
    // Use our custom success dialog instead of AwesomeDialog
    SuccessDialog.show(context, 'You have successfully joined $courseName');
  }

  static void _showErrorDialog(BuildContext context, String errorMessage) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Error',
      desc: errorMessage,
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
    ).show();
  }

  static Widget _buildRoundedButton(BuildContext context, String text,
      Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
