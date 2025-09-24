// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/analysis/models/performance_metric.dart';
// import 'package:attendance_app/features/analysis/models/student_score_admin.dart';
// import 'package:attendance_app/features/analysis/models/student_score_student.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AnalysisManager extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String courseId;

//   // Admin data
//   List<StudentScoreAdmin> _topStudents = [];
//   List<PerformanceMetric> _adminPerformanceMetrics = [];
//   bool _isAdminLoading = true;
//   String? _adminError;

//   // Student data
//   List<StudentScoreStudent> _studentScores = [];
//   List<PerformanceMetric> _studentPerformanceMetrics = [];
//   bool _isStudentLoading = true;
//   String? _studentError;

//   // Getters
//   List<StudentScoreAdmin> get topStudents => _topStudents;
//   List<PerformanceMetric> get adminPerformanceMetrics =>
//       _adminPerformanceMetrics;
//   bool get isAdminLoading => _isAdminLoading;
//   String? get adminError => _adminError;

//   List<StudentScoreStudent> get studentScores => _studentScores;
//   List<PerformanceMetric> get studentPerformanceMetrics =>
//       _studentPerformanceMetrics;
//   bool get isStudentLoading => _isStudentLoading;
//   String? get studentError => _studentError;

//   AnalysisManager(this.courseId) {
//     loadAdminAnalysisData();
//     loadStudentAnalysisData();
//   }

//   Future<void> loadAdminAnalysisData() async {
//     _isAdminLoading = true;
//     notifyListeners();

//     try {
//       // Data structures to store student metrics
//       Map<String, int> attendedLecturesCount = {};
//       Map<String, int> totalLecturesCount = {};
//       Map<String, int> assignmentsCount = {};
//       Map<String, int> completedAssignmentsCount = {};
//       Map<String, double> assignmentsScores = {};
//       Map<String, int> testsCount = {};
//       Map<String, int> completedTestsCount = {};
//       Map<String, double> testsScores = {};

//       // Fetch all lectures for this course
//       DocumentReference courseRef =
//           _firestore.collection('Courses').doc(courseId);
//       QuerySnapshot lecturesSnapshot =
//           await courseRef.collection('lectures').get();

//       // Process attendance data
//       int totalLecturesInCourse = lecturesSnapshot.docs.length;

//       for (var lectureDoc in lecturesSnapshot.docs) {
//         String lectureId = lectureDoc.id;

//         // Get all students in attendance collection
//         QuerySnapshot attendanceSnapshot = await courseRef
//             .collection('lectures')
//             .doc(lectureId)
//             .collection('attendance')
//             .get();

//         // Process each student in this lecture
//         for (var studentDoc in attendanceSnapshot.docs) {
//           String studentId = studentDoc.id;
//           Map<String, dynamic> studentData =
//               studentDoc.data() as Map<String, dynamic>;

//           // Get student name - try from data or fetch from users collection if needed
//           String studentName;
//           if (studentData.containsKey('name') && studentData['name'] != null) {
//             studentName = studentData['name'];
//           } else {
//             // Fetch from users collection
//             try {
//               DocumentSnapshot userDoc =
//                   await _firestore.collection('users').doc(studentId).get();
//               if (userDoc.exists) {
//                 Map<String, dynamic>? userData =
//                     userDoc.data() as Map<String, dynamic>?;
//                 studentName = userData?['name'] ?? 'Unknown';
//               } else {
//                 studentName = 'Unknown';
//               }
//             } catch (e) {
//               print('Error fetching user name: $e');
//               studentName = 'Unknown';
//             }
//           }

//           // Count this as a lecture for this student
//           totalLecturesCount[studentName] =
//               (totalLecturesCount[studentName] ?? 0) + 1;

//           // ONLY count attendance if student has BOTH check-in AND check-out
//           bool hasFullAttendance = false;

//           // Check for both Check-in and Check-out in direct fields
//           bool checkInValid = studentData.containsKey('Check-in') &&
//               studentData['Check-in'] != null &&
//               studentData['Check-in'].toString().isNotEmpty;

//           bool checkOutValid = studentData.containsKey('Check-out') &&
//               studentData['Check-out'] != null &&
//               studentData['Check-out'] != "-" &&
//               studentData['Check-out'].toString().isNotEmpty;

//           // Debugging attendance data
//           print("Validating attendance for $studentName:");
//           print(
//               "  Check-in: ${studentData['Check-in']} (valid: $checkInValid)");
//           print(
//               "  Check-out: ${studentData['Check-out']} (valid: $checkOutValid)");

//           if (checkInValid && checkOutValid) {
//             hasFullAttendance = true;
//             print("  ✓ Full attendance validated");
//           } else {
//             print("  ✗ Missing valid check-in or check-out");
//             // Also check if there's a date-based structure with both Check-in and Check-out
//             for (var key in studentData.keys) {
//               if (key != 'name' &&
//                   key != 'imageUrl' &&
//                   key != 'isStarred' &&
//                   key != 'bonusCount') {
//                 var dateData = studentData[key];
//                 if (dateData is Map<String, dynamic>) {
//                   bool dateLevelCheckInValid =
//                       dateData.containsKey('Check-in') &&
//                           dateData['Check-in'] != null &&
//                           dateData['Check-in'].toString().isNotEmpty;

//                   bool dateLevelCheckOutValid =
//                       dateData.containsKey('Check-out') &&
//                           dateData['Check-out'] != null &&
//                           dateData['Check-out'].toString().isNotEmpty &&
//                           dateData['Check-out'] != "-";

//                   print("  Date key $key:");
//                   print(
//                       "    Check-in: ${dateData['Check-in']} (valid: $dateLevelCheckInValid)");
//                   print(
//                       "    Check-out: ${dateData['Check-out']} (valid: $dateLevelCheckOutValid)");

//                   if (dateLevelCheckInValid && dateLevelCheckOutValid) {
//                     hasFullAttendance = true;
//                     print("    ✓ Full attendance validated for date");
//                     break;
//                   } else {
//                     print("    ✗ Missing valid check-in or check-out for date");
//                   }
//                 }
//               }
//             }
//           }

//           if (hasFullAttendance) {
//             attendedLecturesCount[studentName] =
//                 (attendedLecturesCount[studentName] ?? 0) + 1;
//           }
//         }
//       }

//       // Fetch all assignments
//       QuerySnapshot assignmentsSnapshot =
//           await courseRef.collection('assignments').get();

//       // Process assignments data
//       for (var assignmentDoc in assignmentsSnapshot.docs) {
//         String assignmentId = assignmentDoc.id;

//         // Get student status for this assignment
//         QuerySnapshot studentStatusSnapshot = await courseRef
//             .collection('assignments')
//             .doc(assignmentId)
//             .collection('studentStatus')
//             .get();

//         for (var studentDoc in studentStatusSnapshot.docs) {
//           Map<String, dynamic> statusData =
//               studentDoc.data() as Map<String, dynamic>;
//           String studentId = studentDoc.id;

//           // Get student name from student id document
//           DocumentSnapshot studentSnapshot =
//               await _firestore.collection('users').doc(studentId).get();

//           if (studentSnapshot.exists) {
//             Map<String, dynamic>? userData =
//                 studentSnapshot.data() as Map<String, dynamic>?;
//             String studentName = userData?['name'] ?? 'Unknown';

//             // Count this as an assignment for this student
//             assignmentsCount[studentName] =
//                 (assignmentsCount[studentName] ?? 0) + 1;

//             // Check if student completed the assignment
//             bool isCompleted = statusData['isCompleted'] ?? false;
//             if (isCompleted) {
//               completedAssignmentsCount[studentName] =
//                   (completedAssignmentsCount[studentName] ?? 0) + 1;

//               // Add score if available
//               String scoreStr = statusData['score'] ?? '';
//               if (scoreStr.isNotEmpty) {
//                 double score =
//                     double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
//                 assignmentsScores[studentName] =
//                     (assignmentsScores[studentName] ?? 0) + score;
//               }
//             }
//           }
//         }
//       }

//       // Fetch all tests
//       QuerySnapshot testsSnapshot = await courseRef.collection('tests').get();

//       // Process tests data
//       for (var testDoc in testsSnapshot.docs) {
//         String testId = testDoc.id;

//         // Get student status for this test
//         QuerySnapshot studentStatusSnapshot = await courseRef
//             .collection('tests')
//             .doc(testId)
//             .collection('studentStatus')
//             .get();

//         for (var studentDoc in studentStatusSnapshot.docs) {
//           Map<String, dynamic> statusData =
//               studentDoc.data() as Map<String, dynamic>;
//           String studentId = studentDoc.id;

//           // Get student name from student id document
//           DocumentSnapshot studentSnapshot =
//               await _firestore.collection('users').doc(studentId).get();

//           if (studentSnapshot.exists) {
//             Map<String, dynamic>? userData =
//                 studentSnapshot.data() as Map<String, dynamic>?;
//             String studentName = userData?['name'] ?? 'Unknown';

//             // Count this as a test for this student
//             testsCount[studentName] = (testsCount[studentName] ?? 0) + 1;

//             // Check if student completed the test
//             bool isCompleted = statusData['isCompleted'] ?? false;
//             if (isCompleted) {
//               completedTestsCount[studentName] =
//                   (completedTestsCount[studentName] ?? 0) + 1;

//               // Add score if available
//               String scoreStr = statusData['score'] ?? '';
//               if (scoreStr.isNotEmpty) {
//                 double score =
//                     double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
//                 testsScores[studentName] =
//                     (testsScores[studentName] ?? 0) + score;
//               }
//             }
//           }
//         }
//       }

//       // حساب مقاييس الأداء لكل طالب
//       Map<String, double> overallPerformance = {};
//       Map<String, double> attendancePerformance = {};

//       // الحصول على جميع أسماء الطلاب الفريدة عبر الحضور والواجبات والاختبارات
//       Set<String> allStudents = {};
//       allStudents.addAll(totalLecturesCount.keys);
//       allStudents.addAll(assignmentsCount.keys);
//       allStudents.addAll(testsCount.keys);

//       // الحصول على العدد الكلي للمحاضرات المتاحة في المقرر
//       int lecturesInCourse = lecturesSnapshot.docs.length;

//       print("==== تحليل بيانات الطلاب ====");
//       print("→ إجمالي عدد المحاضرات المتاحة في المقرر: $lecturesInCourse");

//       for (String studentName in allStudents) {
//         print("\nتحليل الطالب: $studentName");

//         // حساب نسبة الحضور - استخدام العدد الكلي للمحاضرات في المقرر بدلاً من المحاضرات المسجلة فقط
//         int attendedLectures = attendedLecturesCount[studentName] ?? 0;
//         double attendancePercent = 0.0;
//         bool hasValidAttendance = false;

//         // استخدام إجمالي عدد المحاضرات في المقرر بدلاً من المحاضرات المسجلة فقط
//         if (lecturesInCourse > 0) {
//           attendancePercent = (attendedLectures / lecturesInCourse) * 100;
//           hasValidAttendance =
//               attendedLectures > 0; // فقط إذا حضر محاضرة واحدة على الأقل
//           print(
//               "✓ الحضور: $attendedLectures من $lecturesInCourse محاضرة (${attendancePercent.toStringAsFixed(1)}%)");
//         } else {
//           print("✗ الحضور: غير متوفر أو لم يحضر أي محاضرة");
//         }

//         // حساب نسبة الواجبات
//         int totalAssignments = assignmentsCount[studentName] ?? 0;
//         int completedAssignments = completedAssignmentsCount[studentName] ?? 0;
//         double assignmentAvgScore = 0.0;
//         bool hasValidAssignments = false;

//         // إجمالي نقاط الواجبات المتاحة (كل واجب = 100 نقطة)
//         double totalPossiblePoints = totalAssignments * 100.0;

//         if (completedAssignments > 0) {
//           // درجة الواجبات المحصلة من إجمالي الدرجات المتاحة
//           double earnedPoints = assignmentsScores[studentName] ?? 0;
//           assignmentAvgScore = (totalPossiblePoints > 0)
//               ? (earnedPoints / totalPossiblePoints) * 100
//               : 0.0;

//           // التحقق من أن الدرجة فعلية وليست صفر
//           hasValidAssignments = assignmentAvgScore > 0;
//           print(
//               "✓ الواجبات: أكمل $completedAssignments من $totalAssignments واجب (${assignmentAvgScore.toStringAsFixed(1)}%)");
//           print(
//               "   - درجات الواجبات: $earnedPoints من أصل $totalPossiblePoints (كل واجب = 100 درجة)");
//         } else {
//           print("✗ الواجبات: لم يكمل أي واجب");
//         }

//         // حساب نسبة الاختبارات
//         int totalTests = testsCount[studentName] ?? 0;
//         int completedTests = completedTestsCount[studentName] ?? 0;
//         double testAvgScore = 0.0;
//         bool hasValidTests = false;

//         // إجمالي نقاط الاختبارات المتاحة (كل اختبار = 100 نقطة)
//         double totalPossibleTestPoints = totalTests * 100.0;

//         if (completedTests > 0) {
//           // درجة الاختبارات المحصلة من إجمالي الدرجات المتاحة
//           double earnedPoints = testsScores[studentName] ?? 0;
//           testAvgScore = (totalPossibleTestPoints > 0)
//               ? (earnedPoints / totalPossibleTestPoints) * 100
//               : 0.0;

//           // التحقق من أن الدرجة فعلية وليست صفر
//           hasValidTests = testAvgScore > 0;
//           print(
//               "✓ الاختبارات: أكمل $completedTests من $totalTests اختبار (${testAvgScore.toStringAsFixed(1)}%)");
//           print(
//               "   - درجات الاختبارات: $earnedPoints من أصل $totalPossibleTestPoints (كل اختبار = 100 درجة)");
//         } else {
//           print("✗ الاختبارات: لم يكمل أي اختبار");
//         }

//         // تخزين نسبة الحضور لجميع الطلاب
//         attendancePerformance[studentName] = attendancePercent;

//         // حساب الأداء العام بالترجيح المناسب لكل طالب
//         double overall = 0.0;
//         double weightSum = 0.0;

//         // فقط تضمين المقاييس التي لديها بيانات فعلية
//         if (hasValidAttendance) {
//           overall += attendancePercent * 0.4;
//           weightSum += 0.4;
//           print(
//               "- إضافة ${attendancePercent.toStringAsFixed(1)}% × 0.4 للأداء العام");
//         }

//         if (hasValidAssignments) {
//           overall += assignmentAvgScore * 0.3;
//           weightSum += 0.3;
//           print(
//               "- إضافة ${assignmentAvgScore.toStringAsFixed(1)}% × 0.3 للأداء العام");
//         }

//         if (hasValidTests) {
//           overall += testAvgScore * 0.3;
//           weightSum += 0.3;
//           print(
//               "- إضافة ${testAvgScore.toStringAsFixed(1)}% × 0.3 للأداء العام");
//         }

//         // تطبيع بناءً على المقاييس المتاحة
//         if (weightSum > 0) {
//           overall = overall / weightSum * 100;
//           print(
//               "↳ الأداء العام النهائي: ${overall.toStringAsFixed(1)}% (بعد التطبيع)");
//         } else {
//           overall = 0;
//           print("↳ الأداء العام النهائي: 0% (لا توجد بيانات صالحة)");
//         }

//         // التأكد من عدم تجاوز 100%
//         overall = overall > 100 ? 100 : overall;

//         // فقط تضمين الطلاب الذين لديهم على الأقل مقياس واحد صالح
//         if (hasValidAttendance || hasValidAssignments || hasValidTests) {
//           overallPerformance[studentName] = overall;
//         } else {
//           print("! تم استبعاد الطالب من الأداء العام لعدم وجود بيانات صالحة");
//           overallPerformance[studentName] = 0;
//         }
//       }

//       // Calculate overall metrics across all students
//       int totalStudentsWithLectures = 0;
//       int totalAttendedLectures = 0;
//       int totalPossibleLectures = 0;

//       // Get the total number of lectures in the course
//       // lecturesInCourse is already defined above

//       // Sum up attended lectures across all students
//       for (String studentName in attendancePerformance.keys) {
//         int studentAttendedLectures = attendedLecturesCount[studentName] ?? 0;
//         if (studentAttendedLectures > 0) {
//           totalAttendedLectures += studentAttendedLectures;
//           totalStudentsWithLectures++;
//         }
//       }

//       // Calculate how many lectures all students should have attended
//       totalPossibleLectures = totalStudentsWithLectures * lecturesInCourse;

//       // Calculate overall attendance rate - handle the zero case
//       double avgAttendance =
//           (totalPossibleLectures > 0 && totalStudentsWithLectures > 0)
//               ? (totalAttendedLectures * 100.0) / totalPossibleLectures
//               : 0.0;

//       // حساب متوسط الأداء عبر جميع الطلاب ذوي البيانات الفعلية
//       double avgPerformance = 0.0;
//       int studentsWithData = 0;

//       print("\n==== حساب متوسط الأداء العام ====");

//       if (overallPerformance.isNotEmpty) {
//         double totalPerformance = 0.0;
//         List<String> includedStudents = [];
//         List<String> excludedStudents = [];

//         for (var entry in overallPerformance.entries) {
//           String studentName = entry.key;
//           double score = entry.value;

//           // التحقق من وجود درجات فعلية في الواجبات والاختبارات
//           double assignmentScore = 0;
//           if (completedAssignmentsCount[studentName] != null &&
//               completedAssignmentsCount[studentName]! > 0) {
//             assignmentScore = (assignmentsScores[studentName] ?? 0) /
//                 completedAssignmentsCount[studentName]!;
//           }

//           double testScore = 0;
//           if (completedTestsCount[studentName] != null &&
//               completedTestsCount[studentName]! > 0) {
//             testScore = (testsScores[studentName] ?? 0) /
//                 completedTestsCount[studentName]!;
//           }

//           // التحقق من أن الطالب قد حضر محاضرات وأكمل واجبات أو اختبارات
//           bool hasRealAttendance = attendedLecturesCount[studentName] != null &&
//               attendedLecturesCount[studentName]! > 0;

//           bool hasRealAssignments =
//               completedAssignmentsCount[studentName] != null &&
//                   completedAssignmentsCount[studentName]! > 0 &&
//                   assignmentScore > 0;

//           bool hasRealTests = completedTestsCount[studentName] != null &&
//               completedTestsCount[studentName]! > 0 &&
//               testScore > 0;

//           // يجب أن يكون لدى الطالب حضور وعلى الأقل إما واجبات أو اختبارات مكتملة
//           if (hasRealAttendance &&
//               (hasRealAssignments || hasRealTests) &&
//               score > 0) {
//             totalPerformance += score;
//             studentsWithData++;
//             includedStudents.add("$studentName (${score.toStringAsFixed(1)}%)");
//             print(
//                 "✓ تضمين الطالب $studentName بدرجة ${score.toStringAsFixed(1)}% في حساب المتوسط");
//             print(
//                 "   - حضور: ${(attendedLecturesCount[studentName] ?? 0)}/${(totalLecturesCount[studentName] ?? 0)}");
//             print(
//                 "   - واجبات: ${hasRealAssignments ? 'نعم' : 'لا'} (${assignmentScore.toStringAsFixed(1)}%)");
//             print(
//                 "   - اختبارات: ${hasRealTests ? 'نعم' : 'لا'} (${testScore.toStringAsFixed(1)}%)");
//           } else {
//             excludedStudents.add(studentName);
//             print("✗ استبعاد الطالب $studentName من حساب المتوسط");
//             print(
//                 "   - حضور: ${hasRealAttendance ? 'نعم' : 'لا'} (${(attendedLecturesCount[studentName] ?? 0)}/${(totalLecturesCount[studentName] ?? 0)})");
//             print(
//                 "   - واجبات: ${hasRealAssignments ? 'نعم' : 'لا'} (${assignmentScore.toStringAsFixed(1)}%)");
//             print(
//                 "   - اختبارات: ${hasRealTests ? 'نعم' : 'لا'} (${testScore.toStringAsFixed(1)}%)");
//           }
//         }

//         // حساب المتوسط من الطلاب ذوي البيانات فقط
//         avgPerformance =
//             studentsWithData > 0 ? totalPerformance / studentsWithData : 0.0;

//         print(
//             "\n→ متوسط الأداء العام النهائي: ${avgPerformance.toStringAsFixed(1)}% (من $studentsWithData طالب)");
//       } else {
//         print("! لا توجد بيانات طلاب لحساب متوسط الأداء");
//       }

//       // Ensure values are between 0-100 and not NaN
//       avgPerformance = avgPerformance.isNaN || avgPerformance < 0
//           ? 0
//           : (avgPerformance > 100 ? 100 : avgPerformance);
//       avgAttendance = avgAttendance.isNaN || avgAttendance < 0
//           ? 0
//           : (avgAttendance > 100 ? 100 : avgAttendance);

//       // حساب نسب درجات الواجبات والاختبارات للطلاب من إجمالي الدرجات المتاحة
//       double totalEarnedAssignmentPoints = 0.0;
//       double totalEarnedTestPoints = 0.0;

//       // الحصول على العدد الكلي للواجبات والاختبارات المتاحة في المقرر
//       int totalAssignmentsInCourse = assignmentsSnapshot.docs.length;
//       int totalTestsInCourse = testsSnapshot.docs.length;

//       // حساب مجموع النقاط الممكنة: (عدد الطلاب × عدد الواجبات/الاختبارات × 100)
//       int totalStudents = allStudents.length;
//       double totalPossibleAssignmentPoints =
//           totalStudents * totalAssignmentsInCourse * 100.0;
//       double totalPossibleTestPoints =
//           totalStudents * totalTestsInCourse * 100.0;

//       // حساب مجموع النقاط المحصلة لجميع الطلاب
//       for (String studentName in allStudents) {
//         // جمع درجات الواجبات المحلولة
//         double earnedAssignmentPoints = assignmentsScores[studentName] ?? 0;
//         totalEarnedAssignmentPoints += earnedAssignmentPoints;

//         // جمع درجات الاختبارات المحلولة
//         double earnedTestPoints = testsScores[studentName] ?? 0;
//         totalEarnedTestPoints += earnedTestPoints;
//       }

//       // حساب النسب المئوية من إجمالي الدرجات المتاحة
//       double avgAssignmentGrade = totalPossibleAssignmentPoints > 0
//           ? (totalEarnedAssignmentPoints / totalPossibleAssignmentPoints) * 100
//           : 0.0;

//       double avgTestGrade = totalPossibleTestPoints > 0
//           ? (totalEarnedTestPoints / totalPossibleTestPoints) * 100
//           : 0.0;

//       // ضمان أن القيم في النطاق الصحيح
//       avgAssignmentGrade = avgAssignmentGrade.isNaN || avgAssignmentGrade < 0
//           ? 0
//           : (avgAssignmentGrade > 100 ? 100 : avgAssignmentGrade);

//       avgTestGrade = avgTestGrade.isNaN || avgTestGrade < 0
//           ? 0
//           : (avgTestGrade > 100 ? 100 : avgTestGrade);

//       // حساب Student Performance كمتوسط مرجح لجميع الطلاب
//       double finalAvgPerformance = 0.0;
//       double weightSum = 0.0;

//       if (avgAttendance > 0) {
//         finalAvgPerformance += avgAttendance * 0.4;
//         weightSum += 0.4;
//       }
//       if (avgAssignmentGrade > 0) {
//         finalAvgPerformance += avgAssignmentGrade * 0.3;
//         weightSum += 0.3;
//       }
//       if (avgTestGrade > 0) {
//         finalAvgPerformance += avgTestGrade * 0.3;
//         weightSum += 0.3;
//       }

//       // تطبيع النتيجة بناءً على المقاييس المتاحة
//       if (weightSum > 0) {
//         finalAvgPerformance = finalAvgPerformance / weightSum;
//       }

//       // التأكد من أن القيمة بين 0 و100
//       finalAvgPerformance = finalAvgPerformance.isNaN || finalAvgPerformance < 0
//           ? 0
//           : (finalAvgPerformance > 100 ? 100 : finalAvgPerformance);

//       print(
//           "\n→ إجمالي درجات الواجبات: ${totalEarnedAssignmentPoints} من أصل ${totalPossibleAssignmentPoints} (${avgAssignmentGrade.toStringAsFixed(1)}%)");
//       print(
//           "→ إجمالي درجات الاختبارات: ${totalEarnedTestPoints} من أصل ${totalPossibleTestPoints} (${avgTestGrade.toStringAsFixed(1)}%)");

//       _adminPerformanceMetrics = [
//         PerformanceMetric(
//           label: 'Student\nPerformance',
//           percentage: finalAvgPerformance,
//           color: Colors.blue.shade700,
//         ),
//         PerformanceMetric(
//           label: 'Student\nAttendance',
//           percentage: avgAttendance,
//           color: Colors.blue.shade500,
//         ),
//         PerformanceMetric(
//           label: 'Assignment\nScores',
//           percentage: avgAssignmentGrade,
//           color: Colors.green.shade600,
//         ),
//         PerformanceMetric(
//           label: 'Test\nScores',
//           percentage: avgTestGrade,
//           color: Colors.orange.shade600,
//         ),
//       ];

//       // احصل على أفضل 5 طلاب حسب الأداء العام (وليس فقط الحضور)
//       // فقط تضمين الطلاب الذين لديهم بيانات فعلية
//       List<StudentScoreAdmin> allStudentsPerformance = [];

//       print("\n==== اختيار أفضل الطلاب للرسم البياني ====");

//       for (var entry in overallPerformance.entries) {
//         String studentName = entry.key;
//         double score = entry.value;

//         // التحقق من وجود درجات فعلية في الواجبات والاختبارات
//         double assignmentScore = 0;
//         if (completedAssignmentsCount[studentName] != null &&
//             completedAssignmentsCount[studentName]! > 0) {
//           assignmentScore = (assignmentsScores[studentName] ?? 0) /
//               completedAssignmentsCount[studentName]!;
//         }

//         double testScore = 0;
//         if (completedTestsCount[studentName] != null &&
//             completedTestsCount[studentName]! > 0) {
//           testScore = (testsScores[studentName] ?? 0) /
//               completedTestsCount[studentName]!;
//         }

//         // التحقق من أن الطالب قد حضر محاضرات وأكمل واجبات أو اختبارات
//         bool hasRealAttendance = attendedLecturesCount[studentName] != null &&
//             attendedLecturesCount[studentName]! > 0;

//         bool hasRealAssignments =
//             completedAssignmentsCount[studentName] != null &&
//                 completedAssignmentsCount[studentName]! > 0 &&
//                 assignmentScore > 0;

//         bool hasRealTests = completedTestsCount[studentName] != null &&
//             completedTestsCount[studentName]! > 0 &&
//             testScore > 0;

//         // يجب أن يكون لدى الطالب بيانات حضور على الأقل
//         if (hasRealAttendance) {
//           // Calculate what percentage of each category they've completed
//           double actualScore = 0;
//           double weightSum = 0;

//           // حساب درجة الطالب الفعلية باستخدام درجات الواجبات والاختبارات الفعلية
//           double attendanceScore = 0.0;
//           double assignmentScore = 0.0;
//           double testScore = 0.0;

//           if (hasRealAttendance) {
//             int attendedLectureCount = attendedLecturesCount[studentName] ?? 0;
//             // Use total lectures in the course rather than just the ones the student was tracked for
//             attendanceScore = (attendedLectureCount * 100.0) / lecturesInCourse;
//             actualScore += attendanceScore * 0.4;
//             weightSum += 0.4;
//             print(
//                 "   - إضافة ${attendanceScore.toStringAsFixed(1)}% حضور × 0.4 ($attendedLectureCount من $lecturesInCourse)");
//           }

//           // استخدام درجات الواجبات الفعلية من جميع الواجبات المتاحة في المقرر
//           if (hasRealAssignments) {
//             // حساب الدرجة كنسبة من إجمالي الدرجات المتاحة للواجبات في المقرر
//             double earnedPoints = assignmentsScores[studentName] ?? 0;
//             double possiblePoints = totalAssignmentsInCourse * 100.0;

//             assignmentScore = possiblePoints > 0
//                 ? (earnedPoints / possiblePoints) * 100
//                 : 0.0;

//             actualScore += assignmentScore * 0.3;
//             weightSum += 0.3;
//             print(
//                 "   - إضافة ${assignmentScore.toStringAsFixed(1)}% واجبات × 0.3 (${earnedPoints} من أصل $possiblePoints درجة)");
//           } else {
//             // For students who didn't do assignments, they get 0
//             // Make sure we're counting this in the weightSum
//             weightSum += 0.3;
//           }

//           // استخدام درجات الاختبارات الفعلية من جميع الاختبارات المتاحة في المقرر
//           if (hasRealTests) {
//             // حساب الدرجة كنسبة من إجمالي الدرجات المتاحة للاختبارات في المقرر
//             double earnedPoints = testsScores[studentName] ?? 0;
//             double possiblePoints = totalTestsInCourse * 100.0;

//             testScore = possiblePoints > 0
//                 ? (earnedPoints / possiblePoints) * 100
//                 : 0.0;

//             actualScore += testScore * 0.3;
//             weightSum += 0.3;
//             print(
//                 "   - إضافة ${testScore.toStringAsFixed(1)}% اختبارات × 0.3 (${earnedPoints} من أصل $possiblePoints درجة)");
//           } else {
//             // For students who didn't do tests, they get 0
//             // Make sure we're counting this in the weightSum
//             weightSum += 0.3;
//           }

//           // تطبيع الدرجة بناءً على البيانات المتاحة
//           if (weightSum > 0) {
//             // We don't need to normalize by weightSum anymore since we've added weights for all categories
//             // actualScore = actualScore / weightSum;
//             // التأكد من أن النتيجة في حدود 100%
//             actualScore = actualScore > 100 ? 100 : actualScore;
//             print("   ↳ الدرجة النهائية: ${actualScore.toStringAsFixed(1)}%");
//             print("      ✓ حضور: ${attendanceScore.toStringAsFixed(1)}%");
//             print("      ✓ واجبات: ${assignmentScore.toStringAsFixed(1)}%");
//             print("      ✓ اختبارات: ${testScore.toStringAsFixed(1)}%");
//           } else {
//             actualScore = 0;
//             print("   ↳ الدرجة النهائية: 0% (لا توجد بيانات كافية)");
//           }

//           allStudentsPerformance.add(StudentScoreAdmin(
//             studentName,
//             actualScore,
//             attendanceScore: attendanceScore,
//             assignmentScore: assignmentScore,
//             testScore: testScore,
//           ));
//         } else {
//           print("✗ استبعاد الطالب $studentName من الرسم البياني");
//           if (!hasRealAttendance) {
//             print("   - لم يحضر محاضرات على الإطلاق (سبب الاستبعاد)");
//           }

//           // Still print assignment and test status for debugging
//           print(
//               "   - الواجبات: ${hasRealAssignments ? 'مكتملة' : 'غير مكتملة'}");
//           print("   - الاختبارات: ${hasRealTests ? 'مكتملة' : 'غير مكتملة'}");
//         }
//       }

//       // Print detailed scores before sorting
//       print("\n==== قبل الترتيب: تفاصيل درجات كل طالب ====");
//       for (var student in allStudentsPerformance) {
//         print(
//             "${student.name}: النتيجة الإجمالية: ${student.score.toStringAsFixed(1)}%, " +
//                 "الحضور: ${student.attendanceScore.toStringAsFixed(1)}%, " +
//                 "الواجبات: ${student.assignmentScore.toStringAsFixed(1)}%, " +
//                 "الاختبارات: ${student.testScore.toStringAsFixed(1)}%");
//       }

//       // Sort by performance score (highest first)
//       allStudentsPerformance.sort((a, b) {
//         // First, prioritize students with higher overall score
//         int scoreCompare = b.score.compareTo(a.score);
//         if (scoreCompare != 0 && (b.score - a.score).abs() > 1.0) {
//           return scoreCompare;
//         }

//         // If overall scores are very close (within 1%), prioritize by attendance
//         int attendanceCompare = b.attendanceScore.compareTo(a.attendanceScore);
//         if (attendanceCompare != 0 &&
//             (b.attendanceScore - a.attendanceScore).abs() > 5.0) {
//           return attendanceCompare;
//         }

//         // If attendance is also similar, check assignments
//         int assignmentCompare = b.assignmentScore.compareTo(a.assignmentScore);
//         if (assignmentCompare != 0) {
//           return assignmentCompare;
//         }

//         // If assignments are also similar, check tests
//         int testCompare = b.testScore.compareTo(a.testScore);
//         if (testCompare != 0) {
//           return testCompare;
//         }

//         // Last resort - alphabetical order
//         return a.name.compareTo(b.name);
//       });

//       // Print sorted scores
//       print("\n==== بعد الترتيب: تفاصيل درجات كل طالب ====");
//       for (var student in allStudentsPerformance) {
//         print(
//             "${student.name}: النتيجة الإجمالية: ${student.score.toStringAsFixed(1)}%, " +
//                 "الحضور: ${student.attendanceScore.toStringAsFixed(1)}%, " +
//                 "الواجبات: ${student.assignmentScore.toStringAsFixed(1)}%, " +
//                 "الاختبارات: ${student.testScore.toStringAsFixed(1)}%");
//       }

//       // Filter out students with zero scores (they didn't participate in anything)
//       allStudentsPerformance =
//           allStudentsPerformance.where((student) => student.score > 0).toList();

//       // If we have students with data, use them
//       if (allStudentsPerformance.isNotEmpty) {
//         // Take only top 5 students with highest overall performance
//         _topStudents = allStudentsPerformance.take(5).toList();

//         // If less than 5 students, pad with empty students
//         if (_topStudents.length < 5) {
//           int currentLength = _topStudents.length;
//           for (int i = currentLength; i < 5; i++) {
//             _topStudents.add(StudentScoreAdmin('Student ${i + 1}', 0));
//           }
//         }
//       } else {
//         // If no students have data, create empty list
//         _topStudents = List.generate(
//             5, (index) => StudentScoreAdmin('Student ${index + 1}', 0));

//         // Set a message that there are no active students
//         print("No students with active participation found.");
//       }

//       // Log the students for debugging
//       print(
//           "Top Students: ${_topStudents.map((s) => "${s.name}: ${s.score}").join(", ")}");

//       _isAdminLoading = false;
//       _adminError = null;
//     } catch (e) {
//       _isAdminLoading = false;
//       _adminError = e.toString();
//       print('Error in loadAdminAnalysisData: $e');
//     }
//     notifyListeners();
//   }

//   Future<void> loadStudentAnalysisData() async {
//     _isStudentLoading = true;
//     notifyListeners();

//     try {
//       // Get current user
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) {
//         throw Exception('No user logged in');
//       }

//       String userId = currentUser.uid;
//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(userId).get();
//       String studentName = userDoc['name'] ?? 'Unknown';

//       // Get attendance data for this student
//       int attendedLectures = 0;
//       int totalLectures = 0;

//       // Fetch all lectures for this course
//       DocumentReference courseRef =
//           _firestore.collection('Courses').doc(courseId);
//       QuerySnapshot lecturesSnapshot =
//           await courseRef.collection('lectures').get();
//       totalLectures = lecturesSnapshot.docs.length;

//       // Check each lecture for student attendance
//       for (var lectureDoc in lecturesSnapshot.docs) {
//         String lectureId = lectureDoc.id;

//         // Search in attendance collection for this student
//         QuerySnapshot attendanceSnapshot = await courseRef
//             .collection('lectures')
//             .doc(lectureId)
//             .collection('attendance')
//             .where('name', isEqualTo: studentName)
//             .get();

//         if (attendanceSnapshot.docs.isNotEmpty) {
//           // Student is in this lecture's attendance list
//           var studentDoc = attendanceSnapshot.docs.first;
//           Map<String, dynamic> studentData =
//               studentDoc.data() as Map<String, dynamic>;

//           // ONLY count attendance if student has BOTH check-in AND check-out
//           bool hasFullAttendance = false;

//           // Check for both Check-in and Check-out in direct fields
//           bool checkInValid = studentData.containsKey('Check-in') &&
//               studentData['Check-in'] != null &&
//               studentData['Check-in'].toString().isNotEmpty;

//           bool checkOutValid = studentData.containsKey('Check-out') &&
//               studentData['Check-out'] != null &&
//               studentData['Check-out'] != "-" &&
//               studentData['Check-out'].toString().isNotEmpty;

//           // Debugging attendance data
//           print("Validating attendance for $studentName:");
//           print(
//               "  Check-in: ${studentData['Check-in']} (valid: $checkInValid)");
//           print(
//               "  Check-out: ${studentData['Check-out']} (valid: $checkOutValid)");

//           if (checkInValid && checkOutValid) {
//             hasFullAttendance = true;
//             print("  ✓ Full attendance validated");
//           } else {
//             print("  ✗ Missing valid check-in or check-out");
//             // Also check if there's a date-based structure with both Check-in and Check-out
//             for (var key in studentData.keys) {
//               if (key != 'name' &&
//                   key != 'imageUrl' &&
//                   key != 'isStarred' &&
//                   key != 'bonusCount') {
//                 var dateData = studentData[key];
//                 if (dateData is Map<String, dynamic>) {
//                   bool dateLevelCheckInValid =
//                       dateData.containsKey('Check-in') &&
//                           dateData['Check-in'] != null &&
//                           dateData['Check-in'].toString().isNotEmpty;

//                   bool dateLevelCheckOutValid =
//                       dateData.containsKey('Check-out') &&
//                           dateData['Check-out'] != null &&
//                           dateData['Check-out'].toString().isNotEmpty &&
//                           dateData['Check-out'] != "-";

//                   print("  Date key $key:");
//                   print(
//                       "    Check-in: ${dateData['Check-in']} (valid: $dateLevelCheckInValid)");
//                   print(
//                       "    Check-out: ${dateData['Check-out']} (valid: $dateLevelCheckOutValid)");

//                   if (dateLevelCheckInValid && dateLevelCheckOutValid) {
//                     hasFullAttendance = true;
//                     print("    ✓ Full attendance validated for date");
//                     break;
//                   } else {
//                     print("    ✗ Missing valid check-in or check-out for date");
//                   }
//                 }
//               }
//             }
//           }

//           if (hasFullAttendance) {
//             attendedLectures++;
//           }
//         }
//       }

//       // Calculate attendance percentage
//       double attendancePercent =
//           totalLectures > 0 ? (attendedLectures / totalLectures) * 100 : 0.0;

//       // Get assignment data for this student
//       int completedAssignments = 0;
//       double assignmentAvgScore = 0.0;
//       int totalAssignments = 0;

//       // Fetch all assignments
//       QuerySnapshot assignmentsSnapshot =
//           await courseRef.collection('assignments').get();
//       totalAssignments = assignmentsSnapshot.docs.length;

//       // Check each assignment for student completion
//       // Variables to track completion and total possible points
//       double totalEarnedPoints = 0.0;
//       double totalPossiblePoints =
//           totalAssignments * 100.0; // Each assignment is worth 100 points

//       for (var assignmentDoc in assignmentsSnapshot.docs) {
//         String assignmentId = assignmentDoc.id;

//         // Get student status for this assignment
//         DocumentSnapshot studentStatusDoc = await courseRef
//             .collection('assignments')
//             .doc(assignmentId)
//             .collection('studentStatus')
//             .doc(userId)
//             .get();

//         if (studentStatusDoc.exists) {
//           Map<String, dynamic> statusData =
//               studentStatusDoc.data() as Map<String, dynamic>;
//           bool isCompleted = statusData['isCompleted'] ?? false;

//           if (isCompleted) {
//             completedAssignments++;

//             // Add score if available
//             String scoreStr = statusData['score'] ?? '';
//             if (scoreStr.isNotEmpty) {
//               double score =
//                   double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
//               totalEarnedPoints += score;
//               print("✓ الواجب #$assignmentId: $score درجة من أصل 100");
//             }
//           }
//         }
//       }

//       // Calculate assignments score percentage based on total possible points
//       // For a single student, we calculate their score out of all available assignments in the course
//       assignmentAvgScore = totalPossiblePoints > 0
//           ? (totalEarnedPoints / totalPossiblePoints) * 100
//           : 0.0;

//       print(
//           "- إجمالي الواجبات: $totalAssignments, المحلولة: $completedAssignments, الدرجة: $totalEarnedPoints من أصل $totalPossiblePoints (${assignmentAvgScore.toStringAsFixed(1)}%)");

//       // Get test data for this student
//       int completedTests = 0;
//       double testAvgScore = 0.0;
//       int totalTests = 0;

//       // Fetch all tests
//       QuerySnapshot testsSnapshot = await courseRef.collection('tests').get();
//       totalTests = testsSnapshot.docs.length;

//       // Check each test for student completion
//       // Variables to track completion and total possible points
//       double totalEarnedTestPoints = 0.0;
//       double totalPossibleTestPoints =
//           totalTests * 100.0; // Each test is worth 100 points

//       for (var testDoc in testsSnapshot.docs) {
//         String testId = testDoc.id;

//         // Get student status for this test
//         DocumentSnapshot studentStatusDoc = await courseRef
//             .collection('tests')
//             .doc(testId)
//             .collection('studentStatus')
//             .doc(userId)
//             .get();

//         if (studentStatusDoc.exists) {
//           Map<String, dynamic> statusData =
//               studentStatusDoc.data() as Map<String, dynamic>;
//           bool isCompleted = statusData['isCompleted'] ?? false;

//           if (isCompleted) {
//             completedTests++;

//             // Add score if available
//             String scoreStr = statusData['score'] ?? '';
//             if (scoreStr.isNotEmpty) {
//               double score =
//                   double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
//               totalEarnedTestPoints += score;
//               print("✓ الاختبار #$testId: $score درجة من أصل 100");
//             }
//           }
//         }
//       }

//       // Calculate tests score percentage based on total possible points
//       // For a single student, we calculate their score out of all available tests in the course
//       testAvgScore = totalPossibleTestPoints > 0
//           ? (totalEarnedTestPoints / totalPossibleTestPoints) * 100
//           : 0.0;

//       print(
//           "- إجمالي الاختبارات: $totalTests, المحلولة: $completedTests, الدرجة: $totalEarnedTestPoints من أصل $totalPossibleTestPoints (${testAvgScore.toStringAsFixed(1)}%)");

//       // حساب الأداء العام (متوسط مرجح مع التحقق المناسب)
//       double overallPerformance = 0.0;
//       double weightSum = 0.0;

//       // طباعة لمساعدة التصحيح
//       print("\n== حساب أداء الطالب $studentName ==");
//       print("- نسبة الحضور: $attendancePercent%");
//       print("- نسبة الواجبات: $assignmentAvgScore%");
//       print("- نسبة الاختبارات: $testAvgScore%");

//       // يتم تضمين المقاييس فقط إذا كان الطالب قد أكمل العمل بالفعل
//       if (totalLectures > 0 && attendedLectures > 0) {
//         overallPerformance += attendancePercent * 0.4;
//         weightSum += 0.4;
//         print("✓ تضمين الحضور: $attendancePercent% × 0.4");
//       }

//       if (completedAssignments > 0) {
//         overallPerformance += assignmentAvgScore * 0.3;
//         weightSum += 0.3;
//         print("✓ تضمين الواجبات: $assignmentAvgScore% × 0.3");
//       }

//       if (completedTests > 0) {
//         overallPerformance += testAvgScore * 0.3;
//         weightSum += 0.3;
//         print("✓ تضمين الاختبارات: $testAvgScore% × 0.3");
//       }

//       // تطبيع بناءً على المقاييس المتاحة
//       if (weightSum > 0) {
//         overallPerformance = overallPerformance / weightSum;
//         print("→ النتيجة النهائية: $overallPerformance% (بعد التطبيع)");
//       } else {
//         // إذا لم تكن هناك مقاييس متاحة، يجب أن يكون الأداء 0
//         overallPerformance = 0;
//         print("→ النتيجة النهائية: 0% (لا توجد بيانات)");
//       }

//       // Ensure values are between 0-100 and not NaN
//       attendancePercent = attendancePercent.isNaN || attendancePercent < 0
//           ? 0
//           : (attendancePercent > 100 ? 100 : attendancePercent);
//       assignmentAvgScore = assignmentAvgScore.isNaN || assignmentAvgScore < 0
//           ? 0
//           : (assignmentAvgScore > 100 ? 100 : assignmentAvgScore);
//       overallPerformance = overallPerformance.isNaN || overallPerformance < 0
//           ? 0
//           : (overallPerformance > 100 ? 100 : overallPerformance);

//       // Set student performance metrics with test metrics
//       _studentPerformanceMetrics = [
//         PerformanceMetric(
//           label: 'Attendance',
//           percentage: attendancePercent,
//           color: AppColors.primaryColor,
//         ),
//         PerformanceMetric(
//           label: 'Assignment',
//           percentage: assignmentAvgScore,
//           color: Colors.green.shade600,
//         ),
//         PerformanceMetric(
//           label: 'Test',
//           percentage: testAvgScore,
//           color: Colors.orange.shade600,
//         ),
//         PerformanceMetric(
//           label: 'Overall',
//           percentage: overallPerformance,
//           color: Colors.blue.shade700,
//         ),
//       ];

//       // Calculate average scores across all students for the bar chart
//       double allStudentsAttendanceAvg = 0;
//       double allStudentsAssignmentAvg = 0;
//       double allStudentsTestAvg = 0;
//       double allStudentsOverallAvg = 0;
//       int studentCount = 0;

//       try {
//         // Fetch course data to get all students
//         DocumentReference courseRef =
//             _firestore.collection('Courses').doc(courseId);
//         QuerySnapshot attendanceSnapshot =
//             await courseRef.collection('lectures').get();

//         // Process all students' data
//         Map<String, double> studentAttendancePercentages = {};
//         Map<String, double> studentAssignmentScores = {};
//         Map<String, double> studentTestScores = {};
//         Set<String> allStudentIds = {};

//         // Process attendance data
//         for (var lectureDoc in attendanceSnapshot.docs) {
//           String lectureId = lectureDoc.id;
//           var attendanceCollection = await courseRef
//               .collection('lectures')
//               .doc(lectureId)
//               .collection('attendance')
//               .get();

//           for (var studentDoc in attendanceCollection.docs) {
//             String studentId = studentDoc.id;
//             allStudentIds.add(studentId);

//             // Track attendance for each student
//             studentAttendancePercentages[studentId] =
//                 (studentAttendancePercentages[studentId] ?? 0) + 1;
//           }
//         }

//         // Process assignments data
//         QuerySnapshot assignmentsSnapshot =
//             await courseRef.collection('assignments').get();
//         for (var assignmentDoc in assignmentsSnapshot.docs) {
//           String assignmentId = assignmentDoc.id;
//           var statusCollection = await courseRef
//               .collection('assignments')
//               .doc(assignmentId)
//               .collection('studentStatus')
//               .get();

//           for (var statusDoc in statusCollection.docs) {
//             String studentId = statusDoc.id;
//             allStudentIds.add(studentId);

//             Map<String, dynamic> statusData =
//                 statusDoc.data() as Map<String, dynamic>;
//             bool isCompleted = statusData['isCompleted'] ?? false;

//             if (isCompleted) {
//               String scoreStr = statusData['score'] ?? '';
//               if (scoreStr.isNotEmpty) {
//                 double score =
//                     double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
//                 studentAssignmentScores[studentId] =
//                     ((studentAssignmentScores[studentId] ?? 0) + score) /
//                         ((studentAssignmentScores.containsKey(studentId)
//                             ? 2
//                             : 1));
//               }
//             }
//           }
//         }

//         // Process tests data
//         QuerySnapshot testsSnapshot = await courseRef.collection('tests').get();
//         for (var testDoc in testsSnapshot.docs) {
//           String testId = testDoc.id;
//           var statusCollection = await courseRef
//               .collection('tests')
//               .doc(testId)
//               .collection('studentStatus')
//               .get();

//           for (var statusDoc in statusCollection.docs) {
//             String studentId = statusDoc.id;
//             allStudentIds.add(studentId);

//             Map<String, dynamic> statusData =
//                 statusDoc.data() as Map<String, dynamic>;
//             bool isCompleted = statusData['isCompleted'] ?? false;

//             if (isCompleted) {
//               String scoreStr = statusData['score'] ?? '';
//               if (scoreStr.isNotEmpty) {
//                 double score =
//                     double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
//                 studentTestScores[studentId] =
//                     ((studentTestScores[studentId] ?? 0) + score) /
//                         ((studentTestScores.containsKey(studentId) ? 2 : 1));
//               }
//             }
//           }
//         }

//         // Calculate averages
//         studentCount = allStudentIds.length;

//         if (studentCount > 0) {
//           // Calculate attendance average
//           int totalLecturesCount = attendanceSnapshot.docs.length;
//           if (totalLecturesCount > 0) {
//             for (var studentId in allStudentIds) {
//               double studentAttendance =
//                   (studentAttendancePercentages[studentId] ?? 0) /
//                       totalLecturesCount *
//                       100;
//               allStudentsAttendanceAvg += studentAttendance;
//             }
//             allStudentsAttendanceAvg /= studentCount;
//           }

//           // Calculate assignment average from total earned points across all students divided by total possible points
//           double totalEarnedAssignmentPoints = 0.0;
//           double totalPossibleAssignmentPoints =
//               assignmentsSnapshot.docs.length * studentCount * 100.0;

//           for (var studentId in allStudentIds) {
//             totalEarnedAssignmentPoints +=
//                 (studentAssignmentScores[studentId] ?? 0);
//           }

//           allStudentsAssignmentAvg = totalPossibleAssignmentPoints > 0
//               ? (totalEarnedAssignmentPoints / totalPossibleAssignmentPoints) *
//                   100
//               : 0.0;

//           print(
//               "All students assignment average: $allStudentsAssignmentAvg% ($totalEarnedAssignmentPoints/$totalPossibleAssignmentPoints)");

//           // Calculate test average from total earned points across all students divided by total possible points
//           double totalEarnedTestPoints = 0.0;
//           double totalPossibleTestPoints =
//               testsSnapshot.docs.length * studentCount * 100.0;

//           for (var studentId in allStudentIds) {
//             totalEarnedTestPoints += (studentTestScores[studentId] ?? 0);
//           }

//           allStudentsTestAvg = totalPossibleTestPoints > 0
//               ? (totalEarnedTestPoints / totalPossibleTestPoints) * 100
//               : 0.0;

//           print(
//               "All students test average: $allStudentsTestAvg% ($totalEarnedTestPoints/$totalPossibleTestPoints)");

//           // Calculate overall average
//           allStudentsOverallAvg = (allStudentsAttendanceAvg * 0.4) +
//               (allStudentsAssignmentAvg * 0.3) +
//               (allStudentsTestAvg * 0.3);
//         }
//       } catch (e) {
//         print('Error calculating averages: $e');
//       }

//       // Ensure values are valid and between 0-100
//       allStudentsAttendanceAvg = allStudentsAttendanceAvg.isNaN ||
//               allStudentsAttendanceAvg < 0
//           ? 0
//           : (allStudentsAttendanceAvg > 100 ? 100 : allStudentsAttendanceAvg);
//       allStudentsAssignmentAvg = allStudentsAssignmentAvg.isNaN ||
//               allStudentsAssignmentAvg < 0
//           ? 0
//           : (allStudentsAssignmentAvg > 100 ? 100 : allStudentsAssignmentAvg);
//       allStudentsTestAvg = allStudentsTestAvg.isNaN || allStudentsTestAvg < 0
//           ? 0
//           : (allStudentsTestAvg > 100 ? 100 : allStudentsTestAvg);
//       allStudentsOverallAvg =
//           allStudentsOverallAvg.isNaN || allStudentsOverallAvg < 0
//               ? 0
//               : (allStudentsOverallAvg > 100 ? 100 : allStudentsOverallAvg);

//       // Set student scores for the bar chart
//       _studentScores = [
//         // Show class average with yellow color for comparison (placed first to appear on the left)
//         StudentScoreStudent(
//           'All',
//           allStudentsOverallAvg.roundToDouble(),
//           Colors.amber.shade600,
//           attendance: allStudentsAttendanceAvg,
//           assignments: allStudentsAssignmentAvg,
//           tests: allStudentsTestAvg,
//         ),
//         // Show the student's score with blue color
//         StudentScoreStudent(
//           'You',
//           overallPerformance.roundToDouble(),
//           Colors.blue.shade700,
//           attendance: attendancePercent,
//           assignments: assignmentAvgScore,
//           tests: testAvgScore,
//         ),
//       ];

//       _isStudentLoading = false;
//       _studentError = null;
//     } catch (e) {
//       _isStudentLoading = false;
//       _studentError = e.toString();
//       print('Error in loadStudentAnalysisData: $e');
//     }
//     notifyListeners();
//   }

//   void loadStudentPerformanceData() async {
//     try {
//       isStudentLoading = true;
//       notifyListeners();

//       // Get the student data from current user
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) {
//         studentError = "لا يوجد مستخدم مسجل";
//         isStudentLoading = false;
//         notifyListeners();
//         return;
//       }

//       // Reset previous data
//       studentPerformanceMetrics.clear();
//       studentScores.clear();

//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();

//       if (!userDoc.exists) {
//         studentError = "بيانات المستخدم غير موجودة";
//         isStudentLoading = false;
//         notifyListeners();
//         return;
//       }

//       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//       String studentName = userData['name'] ?? "طالب";

//       // Get student attendance
//       double attendancePercentage =
//           await calculateStudentAttendance(currentUser.uid);

//       // Get student assignment scores
//       double assignmentCompletion =
//           await calculateStudentAssignmentScores(currentUser.uid);

//       // Get student test scores
//       double testCompletion = await calculateStudentTestScores(currentUser.uid);

//       // Calculate overall score (40% attendance, 30% assignments, 30% tests)
//       double overallScore = (attendancePercentage * 0.4) +
//           (assignmentCompletion * 0.3) +
//           (testCompletion * 0.3);

//       print("Student Performance Metrics:");
//       print("- Attendance: $attendancePercentage%");
//       print("- Assignments: $assignmentCompletion%");
//       print("- Tests: $testCompletion%");
//       print("- Overall: $overallScore%");

//       // Add metrics to list
//       studentPerformanceMetrics.add(PerformanceMetric(
//         label: "Attendance",
//         percentage: attendancePercentage,
//         color: Colors.blue,
//       ));

//       studentPerformanceMetrics.add(PerformanceMetric(
//         label: "Assignment",
//         percentage: assignmentCompletion,
//         color: Colors.green,
//       ));

//       studentPerformanceMetrics.add(PerformanceMetric(
//         label: "Test",
//         percentage: testCompletion,
//         color: Colors.orange,
//       ));

//       studentPerformanceMetrics.add(PerformanceMetric(
//         label: "Overall",
//         percentage: overallScore,
//         color: Colors.blue,
//       ));

//       // Add student scores to compare in bar chart
//       studentScores.add(StudentScoreStudent(
//         name: "You",
//         score: overallScore,
//         color: Colors.blue,
//         attendance: attendancePercentage,
//         assignments: assignmentCompletion,
//         tests: testCompletion,
//       ));

//       // Add class average score for comparison
//       await addClassAverageScore();

//       isStudentLoading = false;
//       notifyListeners();
//     } catch (e) {
//       studentError = "حدث خطأ: ${e.toString()}";
//       isStudentLoading = false;
//       notifyListeners();
//     }
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/analysis/models/performance_metric.dart';
import 'package:attendance_app/features/analysis/models/student_score_admin.dart';
import 'package:attendance_app/features/analysis/models/student_score_student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnalysisManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String courseId;

  // Admin data
  List<StudentScoreAdmin> _topStudents = [];
  List<PerformanceMetric> _adminPerformanceMetrics = [];
  bool _isAdminLoading = true;
  String? _adminError;

  // Student data
  List<StudentScoreStudent> _studentScores = [];
  List<PerformanceMetric> _studentPerformanceMetrics = [];
  bool _isStudentLoading = true;
  String? _studentError;

  // Getters
  List<StudentScoreAdmin> get topStudents => _topStudents;
  List<PerformanceMetric> get adminPerformanceMetrics =>
      _adminPerformanceMetrics;
  bool get isAdminLoading => _isAdminLoading;
  String? get adminError => _adminError;

  List<StudentScoreStudent> get studentScores => _studentScores;
  List<PerformanceMetric> get studentPerformanceMetrics =>
      _studentPerformanceMetrics;
  bool get isStudentLoading => _isStudentLoading;
  String? get studentError => _studentError;

  AnalysisManager(this.courseId) {
    loadAdminAnalysisData();
    loadStudentAnalysisData();
  }

  Future<void> loadAdminAnalysisData() async {
    _isAdminLoading = true;
    notifyListeners();

    try {
      // Data structures to store student metrics
      Map<String, int> attendedLecturesCount = {};
      Map<String, int> totalLecturesCount = {};
      Map<String, int> assignmentsCount = {};
      Map<String, int> completedAssignmentsCount = {};
      Map<String, double> assignmentsScores = {};
      Map<String, int> testsCount = {};
      Map<String, int> completedTestsCount = {};
      Map<String, double> testsScores = {};

      // Fetch all lectures for this course
      DocumentReference courseRef =
          _firestore.collection('Courses').doc(courseId);
      QuerySnapshot lecturesSnapshot =
          await courseRef.collection('lectures').get();

      // Process attendance data
      int totalLecturesInCourse = lecturesSnapshot.docs.length;

      for (var lectureDoc in lecturesSnapshot.docs) {
        String lectureId = lectureDoc.id;

        // Get all students in attendance collection
        QuerySnapshot attendanceSnapshot = await courseRef
            .collection('lectures')
            .doc(lectureId)
            .collection('attendance')
            .get();

        // Process each student in this lecture
        for (var studentDoc in attendanceSnapshot.docs) {
          String studentId = studentDoc.id;
          Map<String, dynamic> studentData =
              studentDoc.data() as Map<String, dynamic>;

          // Get student name - try from data or fetch from users collection if needed
          String studentName;
          if (studentData.containsKey('name') && studentData['name'] != null) {
            studentName = studentData['name'];
          } else {
            // Fetch from users collection
            try {
              DocumentSnapshot userDoc =
                  await _firestore.collection('users').doc(studentId).get();
              if (userDoc.exists) {
                Map<String, dynamic>? userData =
                    userDoc.data() as Map<String, dynamic>?;
                studentName = userData?['name'] ?? 'Unknown';
              } else {
                studentName = 'Unknown';
              }
            } catch (e) {
              print('Error fetching user name: $e');
              studentName = 'Unknown';
            }
          }

          // Count this as a lecture for this student
          totalLecturesCount[studentName] =
              (totalLecturesCount[studentName] ?? 0) + 1;

          // ONLY count attendance if student has BOTH check-in AND check-out
          bool hasFullAttendance = false;

          // Check for both Check-in and Check-out in direct fields
          bool checkInValid = studentData.containsKey('Check-in') &&
              studentData['Check-in'] != null &&
              studentData['Check-in'].toString().isNotEmpty;

          bool checkOutValid = studentData.containsKey('Check-out') &&
              studentData['Check-out'] != null &&
              studentData['Check-out'] != "-" &&
              studentData['Check-out'].toString().isNotEmpty;

          // Debugging attendance data
          print("Validating attendance for $studentName:");
          print(
              "  Check-in: ${studentData['Check-in']} (valid: $checkInValid)");
          print(
              "  Check-out: ${studentData['Check-out']} (valid: $checkOutValid)");

          if (checkInValid && checkOutValid) {
            hasFullAttendance = true;
            print("  ✓ Full attendance validated");
          } else {
            print("  ✗ Missing valid check-in or check-out");
            // Also check if there's a date-based structure with both Check-in and Check-out
            for (var key in studentData.keys) {
              if (key != 'name' &&
                  key != 'imageUrl' &&
                  key != 'isStarred' &&
                  key != 'bonusCount') {
                var dateData = studentData[key];
                if (dateData is Map<String, dynamic>) {
                  bool dateLevelCheckInValid =
                      dateData.containsKey('Check-in') &&
                          dateData['Check-in'] != null &&
                          dateData['Check-in'].toString().isNotEmpty;

                  bool dateLevelCheckOutValid =
                      dateData.containsKey('Check-out') &&
                          dateData['Check-out'] != null &&
                          dateData['Check-out'].toString().isNotEmpty &&
                          dateData['Check-out'] != "-";

                  print("  Date key $key:");
                  print(
                      "    Check-in: ${dateData['Check-in']} (valid: $dateLevelCheckInValid)");
                  print(
                      "    Check-out: ${dateData['Check-out']} (valid: $dateLevelCheckOutValid)");

                  if (dateLevelCheckInValid && dateLevelCheckOutValid) {
                    hasFullAttendance = true;
                    print("    ✓ Full attendance validated for date");
                    break;
                  } else {
                    print("    ✗ Missing valid check-in or check-out for date");
                  }
                }
              }
            }
          }

          if (hasFullAttendance) {
            attendedLecturesCount[studentName] =
                (attendedLecturesCount[studentName] ?? 0) + 1;
          }
        }
      }

      // Fetch all assignments
      QuerySnapshot assignmentsSnapshot =
          await courseRef.collection('assignments').get();

      // Process assignments data
      for (var assignmentDoc in assignmentsSnapshot.docs) {
        String assignmentId = assignmentDoc.id;

        // Get student status for this assignment
        QuerySnapshot studentStatusSnapshot = await courseRef
            .collection('assignments')
            .doc(assignmentId)
            .collection('studentStatus')
            .get();

        for (var studentDoc in studentStatusSnapshot.docs) {
          Map<String, dynamic> statusData =
              studentDoc.data() as Map<String, dynamic>;
          String studentId = studentDoc.id;

          // Get student name from student id document
          DocumentSnapshot studentSnapshot =
              await _firestore.collection('users').doc(studentId).get();

          if (studentSnapshot.exists) {
            Map<String, dynamic>? userData =
                studentSnapshot.data() as Map<String, dynamic>?;
            String studentName = userData?['name'] ?? 'Unknown';

            // Count this as an assignment for this student
            assignmentsCount[studentName] =
                (assignmentsCount[studentName] ?? 0) + 1;

            // Check if student completed the assignment
            bool isCompleted = statusData['isCompleted'] ?? false;
            if (isCompleted) {
              completedAssignmentsCount[studentName] =
                  (completedAssignmentsCount[studentName] ?? 0) + 1;

              // Add score if available
              String scoreStr = statusData['score'] ?? '';
              if (scoreStr.isNotEmpty) {
                double score =
                    double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
                assignmentsScores[studentName] =
                    (assignmentsScores[studentName] ?? 0) + score;
              }
            }
          }
        }
      }

      // Fetch all tests
      QuerySnapshot testsSnapshot = await courseRef.collection('tests').get();

      // Process tests data
      for (var testDoc in testsSnapshot.docs) {
        String testId = testDoc.id;

        // Get student status for this test
        QuerySnapshot studentStatusSnapshot = await courseRef
            .collection('tests')
            .doc(testId)
            .collection('studentStatus')
            .get();

        for (var studentDoc in studentStatusSnapshot.docs) {
          Map<String, dynamic> statusData =
              studentDoc.data() as Map<String, dynamic>;
          String studentId = studentDoc.id;

          // Get student name from student id document
          DocumentSnapshot studentSnapshot =
              await _firestore.collection('users').doc(studentId).get();

          if (studentSnapshot.exists) {
            Map<String, dynamic>? userData =
                studentSnapshot.data() as Map<String, dynamic>?;
            String studentName = userData?['name'] ?? 'Unknown';

            // Count this as a test for this student
            testsCount[studentName] = (testsCount[studentName] ?? 0) + 1;

            // Check if student completed the test
            bool isCompleted = statusData['isCompleted'] ?? false;
            if (isCompleted) {
              completedTestsCount[studentName] =
                  (completedTestsCount[studentName] ?? 0) + 1;

              // Add score if available
              String scoreStr = statusData['score'] ?? '';
              if (scoreStr.isNotEmpty) {
                double score =
                    double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
                testsScores[studentName] =
                    (testsScores[studentName] ?? 0) + score;
              }
            }
          }
        }
      }

      // حساب مقاييس الأداء لكل طالب
      Map<String, double> overallPerformance = {};
      Map<String, double> attendancePerformance = {};

      // الحصول على جميع أسماء الطلاب الفريدة عبر الحضور والواجبات والاختبارات
      Set<String> allStudents = {};
      allStudents.addAll(totalLecturesCount.keys);
      allStudents.addAll(assignmentsCount.keys);
      allStudents.addAll(testsCount.keys);

      // الحصول على العدد الكلي للمحاضرات المتاحة في المقرر
      int lecturesInCourse = lecturesSnapshot.docs.length;

      print("==== تحليل بيانات الطلاب ====");
      print("→ إجمالي عدد المحاضرات المتاحة في المقرر: $lecturesInCourse");

      for (String studentName in allStudents) {
        print("\nتحليل الطالب: $studentName");

        // حساب نسبة الحضور - استخدام العدد الكلي للمحاضرات في المقرر بدلاً من المحاضرات المسجلة فقط
        int attendedLectures = attendedLecturesCount[studentName] ?? 0;
        double attendancePercent = 0.0;
        bool hasValidAttendance = false;

        // استخدام إجمالي عدد المحاضرات في المقرر بدلاً من المحاضرات المسجلة فقط
        if (lecturesInCourse > 0) {
          attendancePercent = (attendedLectures / lecturesInCourse) * 100;
          hasValidAttendance =
              attendedLectures > 0; // فقط إذا حضر محاضرة واحدة على الأقل
          print(
              "✓ الحضور: $attendedLectures من $lecturesInCourse محاضرة (${attendancePercent.toStringAsFixed(1)}%)");
        } else {
          print("✗ الحضور: غير متوفر أو لم يحضر أي محاضرة");
        }

        // حساب نسبة الواجبات
        int totalAssignments = assignmentsCount[studentName] ?? 0;
        int completedAssignments = completedAssignmentsCount[studentName] ?? 0;
        double assignmentAvgScore = 0.0;
        bool hasValidAssignments = false;

        // إجمالي نقاط الواجبات المتاحة (كل واجب = 100 نقطة)
        double totalPossiblePoints = totalAssignments * 100.0;

        if (completedAssignments > 0) {
          // درجة الواجبات المحصلة من إجمالي الدرجات المتاحة
          double earnedPoints = assignmentsScores[studentName] ?? 0;
          assignmentAvgScore = (totalPossiblePoints > 0)
              ? (earnedPoints / totalPossiblePoints) * 100
              : 0.0;

          // التحقق من أن الدرجة فعلية وليست صفر
          hasValidAssignments = assignmentAvgScore > 0;
          print(
              "✓ الواجبات: أكمل $completedAssignments من $totalAssignments واجب (${assignmentAvgScore.toStringAsFixed(1)}%)");
          print(
              "   - درجات الواجبات: $earnedPoints من أصل $totalPossiblePoints (كل واجب = 100 درجة)");
        } else {
          print("✗ الواجبات: لم يكمل أي واجب");
        }

        // حساب نسبة الاختبارات
        int totalTests = testsCount[studentName] ?? 0;
        int completedTests = completedTestsCount[studentName] ?? 0;
        double testAvgScore = 0.0;
        bool hasValidTests = false;

        // إجمالي نقاط الاختبارات المتاحة (كل اختبار = 100 نقطة)
        double totalPossibleTestPoints = totalTests * 100.0;

        if (completedTests > 0) {
          // درجة الاختبارات المحصلة من إجمالي الدرجات المتاحة
          double earnedPoints = testsScores[studentName] ?? 0;
          testAvgScore = (totalPossibleTestPoints > 0)
              ? (earnedPoints / totalPossibleTestPoints) * 100
              : 0.0;

          // التحقق من أن الدرجة فعلية وليست صفر
          hasValidTests = testAvgScore > 0;
          print(
              "✓ الاختبارات: أكمل $completedTests من $totalTests اختبار (${testAvgScore.toStringAsFixed(1)}%)");
          print(
              "   - درجات الاختبارات: $earnedPoints من أصل $totalPossibleTestPoints (كل اختبار = 100 درجة)");
        } else {
          print("✗ الاختبارات: لم يكمل أي اختبار");
        }

        // تخزين نسبة الحضور لجميع الطلاب
        attendancePerformance[studentName] = attendancePercent;

        // حساب الأداء العام بالترجيح المناسب لكل طالب
        double overall = 0.0;
        double weightSum = 0.0;

        // فقط تضمين المقاييس التي لديها بيانات فعلية
        if (hasValidAttendance) {
          overall += attendancePercent * 0.4;
          weightSum += 0.4;
          print(
              "- إضافة ${attendancePercent.toStringAsFixed(1)}% × 0.4 للأداء العام");
        }

        if (hasValidAssignments) {
          overall += assignmentAvgScore * 0.3;
          weightSum += 0.3;
          print(
              "- إضافة ${assignmentAvgScore.toStringAsFixed(1)}% × 0.3 للأداء العام");
        }

        if (hasValidTests) {
          overall += testAvgScore * 0.3;
          weightSum += 0.3;
          print(
              "- إضافة ${testAvgScore.toStringAsFixed(1)}% × 0.3 للأداء العام");
        }

        // تطبيع بناءً على المقاييس المتاحة
        if (weightSum > 0) {
          overall = overall / weightSum * 100;
          print(
              "↳ الأداء العام النهائي: ${overall.toStringAsFixed(1)}% (بعد التطبيع)");
        } else {
          overall = 0;
          print("↳ الأداء العام النهائي: 0% (لا توجد بيانات صالحة)");
        }

        // التأكد من عدم تجاوز 100%
        overall = overall > 100 ? 100 : overall;

        // فقط تضمين الطلاب الذين لديهم على الأقل مقياس واحد صالح
        if (hasValidAttendance || hasValidAssignments || hasValidTests) {
          overallPerformance[studentName] = overall;
        } else {
          print("! تم استبعاد الطالب من الأداء العام لعدم وجود بيانات صالحة");
          overallPerformance[studentName] = 0;
        }
      }

      // Calculate overall metrics across all students
      int totalStudentsWithLectures = 0;
      int totalAttendedLectures = 0;
      int totalPossibleLectures = 0;

      // Get the total number of lectures in the course
      // lecturesInCourse is already defined above

      // Sum up attended lectures across all students
      for (String studentName in attendancePerformance.keys) {
        int studentAttendedLectures = attendedLecturesCount[studentName] ?? 0;
        if (studentAttendedLectures > 0) {
          totalAttendedLectures += studentAttendedLectures;
          totalStudentsWithLectures++;
        }
      }

      // Calculate how many lectures all students should have attended
      totalPossibleLectures = totalStudentsWithLectures * lecturesInCourse;

      // Calculate overall attendance rate - handle the zero case
      double avgAttendance =
          (totalPossibleLectures > 0 && totalStudentsWithLectures > 0)
              ? (totalAttendedLectures * 100.0) / totalPossibleLectures
              : 0.0;

      // حساب متوسط الأداء عبر جميع الطلاب ذوي البيانات الفعلية
      double avgPerformance = 0.0;
      int studentsWithData = 0;

      print("\n==== حساب متوسط الأداء العام ====");

      if (overallPerformance.isNotEmpty) {
        double totalPerformance = 0.0;
        List<String> includedStudents = [];
        List<String> excludedStudents = [];

        for (var entry in overallPerformance.entries) {
          String studentName = entry.key;
          double score = entry.value;

          // التحقق من وجود درجات فعلية في الواجبات والاختبارات
          double assignmentScore = 0;
          if (completedAssignmentsCount[studentName] != null &&
              completedAssignmentsCount[studentName]! > 0) {
            assignmentScore = (assignmentsScores[studentName] ?? 0) /
                completedAssignmentsCount[studentName]!;
          }

          double testScore = 0;
          if (completedTestsCount[studentName] != null &&
              completedTestsCount[studentName]! > 0) {
            testScore = (testsScores[studentName] ?? 0) /
                completedTestsCount[studentName]!;
          }

          // التحقق من أن الطالب قد حضر محاضرات وأكمل واجبات أو اختبارات
          bool hasRealAttendance = attendedLecturesCount[studentName] != null &&
              attendedLecturesCount[studentName]! > 0;

          bool hasRealAssignments =
              completedAssignmentsCount[studentName] != null &&
                  completedAssignmentsCount[studentName]! > 0 &&
                  assignmentScore > 0;

          bool hasRealTests = completedTestsCount[studentName] != null &&
              completedTestsCount[studentName]! > 0 &&
              testScore > 0;

          // يجب أن يكون لدى الطالب حضور وعلى الأقل إما واجبات أو اختبارات مكتملة
          if (hasRealAttendance &&
              (hasRealAssignments || hasRealTests) &&
              score > 0) {
            totalPerformance += score;
            studentsWithData++;
            includedStudents.add("$studentName (${score.toStringAsFixed(1)}%)");
            print(
                "✓ تضمين الطالب $studentName بدرجة ${score.toStringAsFixed(1)}% في حساب المتوسط");
            print(
                "   - حضور: ${(attendedLecturesCount[studentName] ?? 0)}/${(totalLecturesCount[studentName] ?? 0)}");
            print(
                "   - واجبات: ${hasRealAssignments ? 'نعم' : 'لا'} (${assignmentScore.toStringAsFixed(1)}%)");
            print(
                "   - اختبارات: ${hasRealTests ? 'نعم' : 'لا'} (${testScore.toStringAsFixed(1)}%)");
          } else {
            excludedStudents.add(studentName);
            print("✗ استبعاد الطالب $studentName من حساب المتوسط");
            print(
                "   - حضور: ${hasRealAttendance ? 'نعم' : 'لا'} (${(attendedLecturesCount[studentName] ?? 0)}/${(totalLecturesCount[studentName] ?? 0)})");
            print(
                "   - واجبات: ${hasRealAssignments ? 'نعم' : 'لا'} (${assignmentScore.toStringAsFixed(1)}%)");
            print(
                "   - اختبارات: ${hasRealTests ? 'نعم' : 'لا'} (${testScore.toStringAsFixed(1)}%)");
          }
        }

        // حساب المتوسط من الطلاب ذوي البيانات فقط
        avgPerformance =
            studentsWithData > 0 ? totalPerformance / studentsWithData : 0.0;

        print(
            "\n→ متوسط الأداء العام النهائي: ${avgPerformance.toStringAsFixed(1)}% (من $studentsWithData طالب)");
      } else {
        print("! لا توجد بيانات طلاب لحساب متوسط الأداء");
      }

      // Ensure values are between 0-100 and not NaN
      avgPerformance = avgPerformance.isNaN || avgPerformance < 0
          ? 0
          : (avgPerformance > 100 ? 100 : avgPerformance);
      avgAttendance = avgAttendance.isNaN || avgAttendance < 0
          ? 0
          : (avgAttendance > 100 ? 100 : avgAttendance);

      // حساب نسب درجات الواجبات والاختبارات للطلاب من إجمالي الدرجات المتاحة
      double totalEarnedAssignmentPoints = 0.0;
      double totalEarnedTestPoints = 0.0;

      // الحصول على العدد الكلي للواجبات والاختبارات المتاحة في المقرر
      int totalAssignmentsInCourse = assignmentsSnapshot.docs.length;
      int totalTestsInCourse = testsSnapshot.docs.length;

      // حساب مجموع النقاط الممكنة: (عدد الطلاب × عدد الواجبات/الاختبارات × 100)
      int totalStudents = allStudents.length;
      double totalPossibleAssignmentPoints =
          totalStudents * totalAssignmentsInCourse * 100.0;
      double totalPossibleTestPoints =
          totalStudents * totalTestsInCourse * 100.0;

      // حساب مجموع النقاط المحصلة لجميع الطلاب
      for (String studentName in allStudents) {
        // جمع درجات الواجبات المحلولة
        double earnedAssignmentPoints = assignmentsScores[studentName] ?? 0;
        totalEarnedAssignmentPoints += earnedAssignmentPoints;

        // جمع درجات الاختبارات المحلولة
        double earnedTestPoints = testsScores[studentName] ?? 0;
        totalEarnedTestPoints += earnedTestPoints;
      }

      // حساب النسب المئوية من إجمالي الدرجات المتاحة
      double avgAssignmentGrade = totalPossibleAssignmentPoints > 0
          ? (totalEarnedAssignmentPoints / totalPossibleAssignmentPoints) * 100
          : 0.0;

      double avgTestGrade = totalPossibleTestPoints > 0
          ? (totalEarnedTestPoints / totalPossibleTestPoints) * 100
          : 0.0;

      // ضمان أن القيم في النطاق الصحيح
      avgAssignmentGrade = avgAssignmentGrade.isNaN || avgAssignmentGrade < 0
          ? 0
          : (avgAssignmentGrade > 100 ? 100 : avgAssignmentGrade);

      avgTestGrade = avgTestGrade.isNaN || avgTestGrade < 0
          ? 0
          : (avgTestGrade > 100 ? 100 : avgTestGrade);

      // حساب Student Performance كمتوسط مرجح لجميع الطلاب
      double finalAvgPerformance = 0.0;
      double weightSum = 0.0;

      if (avgAttendance > 0) {
        finalAvgPerformance += avgAttendance * 0.4;
        weightSum += 0.4;
      }
      if (avgAssignmentGrade > 0) {
        finalAvgPerformance += avgAssignmentGrade * 0.3;
        weightSum += 0.3;
      }
      if (avgTestGrade > 0) {
        finalAvgPerformance += avgTestGrade * 0.3;
        weightSum += 0.3;
      }

      // تطبيع النتيجة بناءً على المقاييس المتاحة
      if (weightSum > 0) {
        finalAvgPerformance = finalAvgPerformance / weightSum;
      }

      // التأكد من أن القيمة بين 0 و100
      finalAvgPerformance = finalAvgPerformance.isNaN || finalAvgPerformance < 0
          ? 0
          : (finalAvgPerformance > 100 ? 100 : finalAvgPerformance);

      print(
          "\n→ إجمالي درجات الواجبات: $totalEarnedAssignmentPoints من أصل $totalPossibleAssignmentPoints (${avgAssignmentGrade.toStringAsFixed(1)}%)");
      print(
          "→ إجمالي درجات الاختبارات: $totalEarnedTestPoints من أصل $totalPossibleTestPoints (${avgTestGrade.toStringAsFixed(1)}%)");

      _adminPerformanceMetrics = [
        PerformanceMetric(
          label: 'Student\nPerformance',
          percentage: finalAvgPerformance,
          color: Colors.blue.shade700,
        ),
        PerformanceMetric(
          label: 'Student\nAttendance',
          percentage: avgAttendance,
          color: Colors.blue.shade500,
        ),
        PerformanceMetric(
          label: 'Assignment\nScores',
          percentage: avgAssignmentGrade,
          color: Colors.green.shade600,
        ),
        PerformanceMetric(
          label: 'Test\nScores',
          percentage: avgTestGrade,
          color: Colors.orange.shade600,
        ),
      ];

      // احصل على أفضل 5 طلاب حسب الأداء العام (وليس فقط الحضور)
      // فقط تضمين الطلاب الذين لديهم بيانات فعلية
      List<StudentScoreAdmin> allStudentsPerformance = [];

      print("\n==== اختيار أفضل الطلاب للرسم البياني ====");

      for (var entry in overallPerformance.entries) {
        String studentName = entry.key;
        double score = entry.value;

        // التحقق من وجود درجات فعلية في الواجبات والاختبارات
        double assignmentScore = 0;
        if (completedAssignmentsCount[studentName] != null &&
            completedAssignmentsCount[studentName]! > 0) {
          assignmentScore = (assignmentsScores[studentName] ?? 0) /
              completedAssignmentsCount[studentName]!;
        }

        double testScore = 0;
        if (completedTestsCount[studentName] != null &&
            completedTestsCount[studentName]! > 0) {
          testScore = (testsScores[studentName] ?? 0) /
              completedTestsCount[studentName]!;
        }

        // التحقق من أن الطالب قد حضر محاضرات وأكمل واجبات أو اختبارات
        bool hasRealAttendance = attendedLecturesCount[studentName] != null &&
            attendedLecturesCount[studentName]! > 0;

        bool hasRealAssignments =
            completedAssignmentsCount[studentName] != null &&
                completedAssignmentsCount[studentName]! > 0 &&
                assignmentScore > 0;

        bool hasRealTests = completedTestsCount[studentName] != null &&
            completedTestsCount[studentName]! > 0 &&
            testScore > 0;

        // يجب أن يكون لدى الطالب بيانات حضور على الأقل
        if (hasRealAttendance) {
          // Calculate what percentage of each category they've completed
          double actualScore = 0;
          double weightSum = 0;

          // حساب درجة الطالب الفعلية باستخدام درجات الواجبات والاختبارات الفعلية
          double attendanceScore = 0.0;
          double assignmentScore = 0.0;
          double testScore = 0.0;

          if (hasRealAttendance) {
            int attendedLectureCount = attendedLecturesCount[studentName] ?? 0;
            // Use total lectures in the course rather than just the ones the student was tracked for
            attendanceScore = (attendedLectureCount * 100.0) / lecturesInCourse;
            actualScore += attendanceScore * 0.4;
            weightSum += 0.4;
            print(
                "   - إضافة ${attendanceScore.toStringAsFixed(1)}% حضور × 0.4 ($attendedLectureCount من $lecturesInCourse)");
          }

          // استخدام درجات الواجبات الفعلية من جميع الواجبات المتاحة في المقرر
          if (hasRealAssignments) {
            // حساب الدرجة كنسبة من إجمالي الدرجات المتاحة للواجبات في المقرر
            double earnedPoints = assignmentsScores[studentName] ?? 0;
            double possiblePoints = totalAssignmentsInCourse * 100.0;

            assignmentScore = possiblePoints > 0
                ? (earnedPoints / possiblePoints) * 100
                : 0.0;

            actualScore += assignmentScore * 0.3;
            weightSum += 0.3;
            print(
                "   - إضافة ${assignmentScore.toStringAsFixed(1)}% واجبات × 0.3 ($earnedPoints من أصل $possiblePoints درجة)");
          } else {
            // For students who didn't do assignments, they get 0
            // Make sure we're counting this in the weightSum
            weightSum += 0.3;
          }

          // استخدام درجات الاختبارات الفعلية من جميع الاختبارات المتاحة في المقرر
          if (hasRealTests) {
            // حساب الدرجة كنسبة من إجمالي الدرجات المتاحة للاختبارات في المقرر
            double earnedPoints = testsScores[studentName] ?? 0;
            double possiblePoints = totalTestsInCourse * 100.0;

            testScore = possiblePoints > 0
                ? (earnedPoints / possiblePoints) * 100
                : 0.0;

            actualScore += testScore * 0.3;
            weightSum += 0.3;
            print(
                "   - إضافة ${testScore.toStringAsFixed(1)}% اختبارات × 0.3 ($earnedPoints من أصل $possiblePoints درجة)");
          } else {
            // For students who didn't do tests, they get 0
            // Make sure we're counting this in the weightSum
            weightSum += 0.3;
          }

          // تطبيع الدرجة بناءً على البيانات المتاحة
          if (weightSum > 0) {
            // We don't need to normalize by weightSum anymore since we've added weights for all categories
            // actualScore = actualScore / weightSum;
            // التأكد من أن النتيجة في حدود 100%
            actualScore = actualScore > 100 ? 100 : actualScore;
            print("   ↳ الدرجة النهائية: ${actualScore.toStringAsFixed(1)}%");
            print("      ✓ حضور: ${attendanceScore.toStringAsFixed(1)}%");
            print("      ✓ واجبات: ${assignmentScore.toStringAsFixed(1)}%");
            print("      ✓ اختبارات: ${testScore.toStringAsFixed(1)}%");
          } else {
            actualScore = 0;
            print("   ↳ الدرجة النهائية: 0% (لا توجد بيانات كافية)");
          }

          allStudentsPerformance.add(StudentScoreAdmin(
            studentName,
            actualScore,
            attendanceScore: attendanceScore,
            assignmentScore: assignmentScore,
            testScore: testScore,
          ));
        } else {
          print("✗ استبعاد الطالب $studentName من الرسم البياني");
          if (!hasRealAttendance) {
            print("   - لم يحضر محاضرات على الإطلاق (سبب الاستبعاد)");
          }

          // Still print assignment and test status for debugging
          print(
              "   - الواجبات: ${hasRealAssignments ? 'مكتملة' : 'غير مكتملة'}");
          print("   - الاختبارات: ${hasRealTests ? 'مكتملة' : 'غير مكتملة'}");
        }
      }

      // Print detailed scores before sorting
      print("\n==== قبل الترتيب: تفاصيل درجات كل طالب ====");
      for (var student in allStudentsPerformance) {
        print(
            "${student.name}: النتيجة الإجمالية: ${student.score.toStringAsFixed(1)}%, الحضور: ${student.attendanceScore.toStringAsFixed(1)}%, الواجبات: ${student.assignmentScore.toStringAsFixed(1)}%, الاختبارات: ${student.testScore.toStringAsFixed(1)}%");
      }

      // Sort by performance score (highest first)
      allStudentsPerformance.sort((a, b) {
        // First, prioritize students with higher overall score
        int scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0 && (b.score - a.score).abs() > 1.0) {
          return scoreCompare;
        }

        // If overall scores are very close (within 1%), prioritize by attendance
        int attendanceCompare = b.attendanceScore.compareTo(a.attendanceScore);
        if (attendanceCompare != 0 &&
            (b.attendanceScore - a.attendanceScore).abs() > 5.0) {
          return attendanceCompare;
        }

        // If attendance is also similar, check assignments
        int assignmentCompare = b.assignmentScore.compareTo(a.assignmentScore);
        if (assignmentCompare != 0) {
          return assignmentCompare;
        }

        // If assignments are also similar, check tests
        int testCompare = b.testScore.compareTo(a.testScore);
        if (testCompare != 0) {
          return testCompare;
        }

        // Last resort - alphabetical order
        return a.name.compareTo(b.name);
      });

      // Print sorted scores
      print("\n==== بعد الترتيب: تفاصيل درجات كل طالب ====");
      for (var student in allStudentsPerformance) {
        print(
            "${student.name}: النتيجة الإجمالية: ${student.score.toStringAsFixed(1)}%, الحضور: ${student.attendanceScore.toStringAsFixed(1)}%, الواجبات: ${student.assignmentScore.toStringAsFixed(1)}%, الاختبارات: ${student.testScore.toStringAsFixed(1)}%");
      }

      // Filter out students with zero scores (they didn't participate in anything)
      allStudentsPerformance =
          allStudentsPerformance.where((student) => student.score > 0).toList();

      // If we have students with data, use them
      if (allStudentsPerformance.isNotEmpty) {
        // Take only top 5 students with highest overall performance
        _topStudents = allStudentsPerformance.take(5).toList();

        // If less than 5 students, pad with empty students
        if (_topStudents.length < 5) {
          int currentLength = _topStudents.length;
          for (int i = currentLength; i < 5; i++) {
            _topStudents.add(StudentScoreAdmin('Student ${i + 1}', 0));
          }
        }
      } else {
        // If no students have data, create empty list
        _topStudents = List.generate(
            5, (index) => StudentScoreAdmin('Student ${index + 1}', 0));

        // Set a message that there are no active students
        print("No students with active participation found.");
      }

      // Log the students for debugging
      print(
          "Top Students: ${_topStudents.map((s) => "${s.name}: ${s.score}").join(", ")}");

      _isAdminLoading = false;
      _adminError = null;
    } catch (e) {
      _isAdminLoading = false;
      _adminError = e.toString();
      print('Error in loadAdminAnalysisData: $e');
    }
    notifyListeners();
  }

  Future<void> loadStudentAnalysisData() async {
    _isStudentLoading = true;
    notifyListeners();

    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      String userId = currentUser.uid;
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      String studentName = userDoc['name'] ?? 'Unknown';

      // Get attendance data for this student
      int attendedLectures = 0;
      int totalLectures = 0;

      // Fetch all lectures for this course
      DocumentReference courseRef =
          _firestore.collection('Courses').doc(courseId);
      QuerySnapshot lecturesSnapshot =
          await courseRef.collection('lectures').get();
      totalLectures = lecturesSnapshot.docs.length;

      // Check each lecture for student attendance
      for (var lectureDoc in lecturesSnapshot.docs) {
        String lectureId = lectureDoc.id;

        // Search in attendance collection for this student
        QuerySnapshot attendanceSnapshot = await courseRef
            .collection('lectures')
            .doc(lectureId)
            .collection('attendance')
            .where('name', isEqualTo: studentName)
            .get();

        if (attendanceSnapshot.docs.isNotEmpty) {
          // Student is in this lecture's attendance list
          var studentDoc = attendanceSnapshot.docs.first;
          Map<String, dynamic> studentData =
              studentDoc.data() as Map<String, dynamic>;

          // ONLY count attendance if student has BOTH check-in AND check-out
          bool hasFullAttendance = false;

          // Check for both Check-in and Check-out in direct fields
          bool checkInValid = studentData.containsKey('Check-in') &&
              studentData['Check-in'] != null &&
              studentData['Check-in'].toString().isNotEmpty;

          bool checkOutValid = studentData.containsKey('Check-out') &&
              studentData['Check-out'] != null &&
              studentData['Check-out'] != "-" &&
              studentData['Check-out'].toString().isNotEmpty;

          // Debugging attendance data
          print("Validating attendance for $studentName:");
          print(
              "  Check-in: ${studentData['Check-in']} (valid: $checkInValid)");
          print(
              "  Check-out: ${studentData['Check-out']} (valid: $checkOutValid)");

          if (checkInValid && checkOutValid) {
            hasFullAttendance = true;
            print("  ✓ Full attendance validated");
          } else {
            print("  ✗ Missing valid check-in or check-out");
            // Also check if there's a date-based structure with both Check-in and Check-out
            for (var key in studentData.keys) {
              if (key != 'name' &&
                  key != 'imageUrl' &&
                  key != 'isStarred' &&
                  key != 'bonusCount') {
                var dateData = studentData[key];
                if (dateData is Map<String, dynamic>) {
                  bool dateLevelCheckInValid =
                      dateData.containsKey('Check-in') &&
                          dateData['Check-in'] != null &&
                          dateData['Check-in'].toString().isNotEmpty;

                  bool dateLevelCheckOutValid =
                      dateData.containsKey('Check-out') &&
                          dateData['Check-out'] != null &&
                          dateData['Check-out'].toString().isNotEmpty &&
                          dateData['Check-out'] != "-";

                  print("  Date key $key:");
                  print(
                      "    Check-in: ${dateData['Check-in']} (valid: $dateLevelCheckInValid)");
                  print(
                      "    Check-out: ${dateData['Check-out']} (valid: $dateLevelCheckOutValid)");

                  if (dateLevelCheckInValid && dateLevelCheckOutValid) {
                    hasFullAttendance = true;
                    print("    ✓ Full attendance validated for date");
                    break;
                  } else {
                    print("    ✗ Missing valid check-in or check-out for date");
                  }
                }
              }
            }
          }

          if (hasFullAttendance) {
            attendedLectures++;
          }
        }
      }

      // Calculate attendance percentage
      double attendancePercent =
          totalLectures > 0 ? (attendedLectures / totalLectures) * 100 : 0.0;

      // Get assignment data for this student
      int completedAssignments = 0;
      double assignmentAvgScore = 0.0;
      int totalAssignments = 0;

      // Fetch all assignments
      QuerySnapshot assignmentsSnapshot =
          await courseRef.collection('assignments').get();
      totalAssignments = assignmentsSnapshot.docs.length;

      // Check each assignment for student completion
      // Variables to track completion and total possible points
      double totalEarnedPoints = 0.0;
      double totalPossiblePoints =
          totalAssignments * 100.0; // Each assignment is worth 100 points

      for (var assignmentDoc in assignmentsSnapshot.docs) {
        String assignmentId = assignmentDoc.id;

        // Get student status for this assignment
        DocumentSnapshot studentStatusDoc = await courseRef
            .collection('assignments')
            .doc(assignmentId)
            .collection('studentStatus')
            .doc(userId)
            .get();

        if (studentStatusDoc.exists) {
          Map<String, dynamic> statusData =
              studentStatusDoc.data() as Map<String, dynamic>;
          bool isCompleted = statusData['isCompleted'] ?? false;

          if (isCompleted) {
            completedAssignments++;

            // Add score if available
            String scoreStr = statusData['score'] ?? '';
            if (scoreStr.isNotEmpty) {
              double score =
                  double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
              totalEarnedPoints += score;
              print("✓ الواجب #$assignmentId: $score درجة من أصل 100");
            }
          }
        }
      }

      // Calculate assignments score percentage based on total possible points
      // For a single student, we calculate their score out of all available assignments in the course
      assignmentAvgScore = totalPossiblePoints > 0
          ? (totalEarnedPoints / totalPossiblePoints) * 100
          : 0.0;

      print(
          "- إجمالي الواجبات: $totalAssignments, المحلولة: $completedAssignments, الدرجة: $totalEarnedPoints من أصل $totalPossiblePoints (${assignmentAvgScore.toStringAsFixed(1)}%)");

      // Get test data for this student
      int completedTests = 0;
      double testAvgScore = 0.0;
      int totalTests = 0;

      // Fetch all tests
      QuerySnapshot testsSnapshot = await courseRef.collection('tests').get();
      totalTests = testsSnapshot.docs.length;

      // Check each test for student completion
      // Variables to track completion and total possible points
      double totalEarnedTestPoints = 0.0;
      double totalPossibleTestPoints =
          totalTests * 100.0; // Each test is worth 100 points

      for (var testDoc in testsSnapshot.docs) {
        String testId = testDoc.id;

        // Get student status for this test
        DocumentSnapshot studentStatusDoc = await courseRef
            .collection('tests')
            .doc(testId)
            .collection('studentStatus')
            .doc(userId)
            .get();

        if (studentStatusDoc.exists) {
          Map<String, dynamic> statusData =
              studentStatusDoc.data() as Map<String, dynamic>;
          bool isCompleted = statusData['isCompleted'] ?? false;

          if (isCompleted) {
            completedTests++;

            // Add score if available
            String scoreStr = statusData['score'] ?? '';
            if (scoreStr.isNotEmpty) {
              double score =
                  double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
              totalEarnedTestPoints += score;
              print("✓ الاختبار #$testId: $score درجة من أصل 100");
            }
          }
        }
      }

      // Calculate tests score percentage based on total possible points
      // For a single student, we calculate their score out of all available tests in the course
      testAvgScore = totalPossibleTestPoints > 0
          ? (totalEarnedTestPoints / totalPossibleTestPoints) * 100
          : 0.0;

      print(
          "- إجمالي الاختبارات: $totalTests, المحلولة: $completedTests, الدرجة: $totalEarnedTestPoints من أصل $totalPossibleTestPoints (${testAvgScore.toStringAsFixed(1)}%)");

      // حساب الأداء العام (متوسط مرجح مع التحقق المناسب)
      double overallPerformance = 0.0;
      double weightSum = 0.0;

      // طباعة لمساعدة التصحيح
      print("\n== حساب أداء الطالب $studentName ==");
      print("- نسبة الحضور: $attendancePercent%");
      print("- نسبة الواجبات: $assignmentAvgScore%");
      print("- نسبة الاختبارات: $testAvgScore%");

      // يتم تضمين المقاييس فقط إذا كان الطالب قد أكمل العمل بالفعل
      if (totalLectures > 0 && attendedLectures > 0) {
        overallPerformance += attendancePercent * 0.4;
        weightSum += 0.4;
        print("✓ تضمين الحضور: $attendancePercent% × 0.4");
      }

      if (completedAssignments > 0) {
        overallPerformance += assignmentAvgScore * 0.3;
        weightSum += 0.3;
        print("✓ تضمين الواجبات: $assignmentAvgScore% × 0.3");
      }

      if (completedTests > 0) {
        overallPerformance += testAvgScore * 0.3;
        weightSum += 0.3;
        print("✓ تضمين الاختبارات: $testAvgScore% × 0.3");
      }

      // تطبيع بناءً على المقاييس المتاحة
      if (weightSum > 0) {
        overallPerformance = overallPerformance / weightSum;
        print("→ النتيجة النهائية: $overallPerformance% (بعد التطبيع)");
      } else {
        // إذا لم تكن هناك مقاييس متاحة، يجب أن يكون الأداء 0
        overallPerformance = 0;
        print("→ النتيجة النهائية: 0% (لا توجد بيانات)");
      }

      // Ensure values are between 0-100 and not NaN
      attendancePercent = attendancePercent.isNaN || attendancePercent < 0
          ? 0
          : (attendancePercent > 100 ? 100 : attendancePercent);
      assignmentAvgScore = assignmentAvgScore.isNaN || assignmentAvgScore < 0
          ? 0
          : (assignmentAvgScore > 100 ? 100 : assignmentAvgScore);
      overallPerformance = overallPerformance.isNaN || overallPerformance < 0
          ? 0
          : (overallPerformance > 100 ? 100 : overallPerformance);

      // Set student performance metrics with test metrics
      _studentPerformanceMetrics = [
        PerformanceMetric(
          label: 'Overall',
          percentage: overallPerformance,
          color: Colors.blue.shade700,
        ),
        PerformanceMetric(
          label: 'Assignments',
          percentage: assignmentAvgScore,
          color: Colors.green.shade600,
        ),
        PerformanceMetric(
          label: 'Tests',
          percentage: testAvgScore,
          color: Colors.orange.shade600,
        ),
        PerformanceMetric(
          label: 'Attendance',
          percentage: attendancePercent,
          color: AppColors.primaryColor,
        ),
      ];

      // Calculate average scores across all students for the bar chart
      double allStudentsAttendanceAvg = 0;
      double allStudentsAssignmentAvg = 0;
      double allStudentsTestAvg = 0;
      double allStudentsOverallAvg = 0;
      int studentCount = 0;

      try {
        // Fetch course data to get all students
        DocumentReference courseRef =
            _firestore.collection('Courses').doc(courseId);
        QuerySnapshot attendanceSnapshot =
            await courseRef.collection('lectures').get();

        // Process all students' data
        Map<String, double> studentAttendancePercentages = {};
        Map<String, double> studentAssignmentScores = {};
        Map<String, double> studentTestScores = {};
        Set<String> allStudentIds = {};

        // Process attendance data
        for (var lectureDoc in attendanceSnapshot.docs) {
          String lectureId = lectureDoc.id;
          var attendanceCollection = await courseRef
              .collection('lectures')
              .doc(lectureId)
              .collection('attendance')
              .get();

          for (var studentDoc in attendanceCollection.docs) {
            String studentId = studentDoc.id;
            allStudentIds.add(studentId);

            // Track attendance for each student
            studentAttendancePercentages[studentId] =
                (studentAttendancePercentages[studentId] ?? 0) + 1;
          }
        }

        // Process assignments data
        QuerySnapshot assignmentsSnapshot =
            await courseRef.collection('assignments').get();
        for (var assignmentDoc in assignmentsSnapshot.docs) {
          String assignmentId = assignmentDoc.id;
          var statusCollection = await courseRef
              .collection('assignments')
              .doc(assignmentId)
              .collection('studentStatus')
              .get();

          for (var statusDoc in statusCollection.docs) {
            String studentId = statusDoc.id;
            allStudentIds.add(studentId);

            Map<String, dynamic> statusData =
                statusDoc.data();
            bool isCompleted = statusData['isCompleted'] ?? false;

            if (isCompleted) {
              String scoreStr = statusData['score'] ?? '';
              if (scoreStr.isNotEmpty) {
                double score =
                    double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
                studentAssignmentScores[studentId] =
                    ((studentAssignmentScores[studentId] ?? 0) + score) /
                        ((studentAssignmentScores.containsKey(studentId)
                            ? 2
                            : 1));
              }
            }
          }
        }

        // Process tests data
        QuerySnapshot testsSnapshot = await courseRef.collection('tests').get();
        for (var testDoc in testsSnapshot.docs) {
          String testId = testDoc.id;
          var statusCollection = await courseRef
              .collection('tests')
              .doc(testId)
              .collection('studentStatus')
              .get();

          for (var statusDoc in statusCollection.docs) {
            String studentId = statusDoc.id;
            allStudentIds.add(studentId);

            Map<String, dynamic> statusData =
                statusDoc.data();
            bool isCompleted = statusData['isCompleted'] ?? false;

            if (isCompleted) {
              String scoreStr = statusData['score'] ?? '';
              if (scoreStr.isNotEmpty) {
                double score =
                    double.tryParse(scoreStr.replaceAll('%', '')) ?? 0.0;
                studentTestScores[studentId] =
                    ((studentTestScores[studentId] ?? 0) + score) /
                        ((studentTestScores.containsKey(studentId) ? 2 : 1));
              }
            }
          }
        }

        // Calculate averages
        studentCount = allStudentIds.length;

        if (studentCount > 0) {
          // Calculate attendance average
          int totalLecturesCount = attendanceSnapshot.docs.length;
          if (totalLecturesCount > 0) {
            for (var studentId in allStudentIds) {
              double studentAttendance =
                  (studentAttendancePercentages[studentId] ?? 0) /
                      totalLecturesCount *
                      100;
              allStudentsAttendanceAvg += studentAttendance;
            }
            allStudentsAttendanceAvg /= studentCount;
          }

          // Calculate assignment average from total earned points across all students divided by total possible points
          double totalEarnedAssignmentPoints = 0.0;
          double totalPossibleAssignmentPoints =
              assignmentsSnapshot.docs.length * studentCount * 100.0;

          for (var studentId in allStudentIds) {
            totalEarnedAssignmentPoints +=
                (studentAssignmentScores[studentId] ?? 0);
          }

          allStudentsAssignmentAvg = totalPossibleAssignmentPoints > 0
              ? (totalEarnedAssignmentPoints / totalPossibleAssignmentPoints) *
                  100
              : 0.0;

          print(
              "All students assignment average: $allStudentsAssignmentAvg% ($totalEarnedAssignmentPoints/$totalPossibleAssignmentPoints)");

          // Calculate test average from total earned points across all students divided by total possible points
          double totalEarnedTestPoints = 0.0;
          double totalPossibleTestPoints =
              testsSnapshot.docs.length * studentCount * 100.0;

          for (var studentId in allStudentIds) {
            totalEarnedTestPoints += (studentTestScores[studentId] ?? 0);
          }

          allStudentsTestAvg = totalPossibleTestPoints > 0
              ? (totalEarnedTestPoints / totalPossibleTestPoints) * 100
              : 0.0;

          print(
              "All students test average: $allStudentsTestAvg% ($totalEarnedTestPoints/$totalPossibleTestPoints)");

          // Calculate overall average
          allStudentsOverallAvg = (allStudentsAttendanceAvg * 0.4) +
              (allStudentsAssignmentAvg * 0.3) +
              (allStudentsTestAvg * 0.3);
        }
      } catch (e) {
        print('Error calculating averages: $e');
      }

      // Ensure values are valid and between 0-100
      allStudentsAttendanceAvg = allStudentsAttendanceAvg.isNaN ||
              allStudentsAttendanceAvg < 0
          ? 0
          : (allStudentsAttendanceAvg > 100 ? 100 : allStudentsAttendanceAvg);
      allStudentsAssignmentAvg = allStudentsAssignmentAvg.isNaN ||
              allStudentsAssignmentAvg < 0
          ? 0
          : (allStudentsAssignmentAvg > 100 ? 100 : allStudentsAssignmentAvg);
      allStudentsTestAvg = allStudentsTestAvg.isNaN || allStudentsTestAvg < 0
          ? 0
          : (allStudentsTestAvg > 100 ? 100 : allStudentsTestAvg);
      allStudentsOverallAvg =
          allStudentsOverallAvg.isNaN || allStudentsOverallAvg < 0
              ? 0
              : (allStudentsOverallAvg > 100 ? 100 : allStudentsOverallAvg);

      // Set student scores for the bar chart
      _studentScores = [
        // نعرض متوسط أداء جميع الطلاب باللون الأصفر للمقارنة (وضعناه أولاً ليظهر على اليسار)
        StudentScoreStudent('All', allStudentsOverallAvg.roundToDouble(),
            Colors.amber.shade600),
        // نعرض نتيجة الطالب باللون الأزرق
        StudentScoreStudent(
            'You', overallPerformance.roundToDouble(), Colors.blue.shade700),
      ];

      _isStudentLoading = false;
      _studentError = null;
    } catch (e) {
      _isStudentLoading = false;
      _studentError = e.toString();
      print('Error in loadStudentAnalysisData: $e');
    }
    notifyListeners();
  }
}
