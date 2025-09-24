// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:attendance_app/features/attendance/presentation/manager/lecture_attendance_student_provider.dart';

// class StudentCardAttendance extends StatelessWidget {
//   final Map<String, dynamic> student;
//   final Map<String, dynamic> attendanceDates; // Map لجميع التواريخ
//   final String imageUrl;
//   final int index;
//   final List<Map<String, dynamic>> students;
//   final String courseId;
//   final int lectureNumber;
//   final Function(
//           BuildContext, Map<String, dynamic>, int, List<Map<String, dynamic>>)
//       showOptionsBottomSheet;
//   final VoidCallback? onTap;

//   const StudentCardAttendance({
//     Key? key,
//     required this.student,
//     required this.attendanceDates,
//     required this.imageUrl,
//     required this.index,
//     required this.students,
//     required this.courseId,
//     required this.lectureNumber,
//     required this.showOptionsBottomSheet,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool isStarred = student['isStarred'] ?? false;

//     // اختيار أحدث تاريخ من attendanceDates
//     String? latestDate;
//     Map<String, dynamic>? latestAttendanceData;
//     if (attendanceDates.isNotEmpty) {
//       // فرز التواريخ واختيار الأحدث
//       var sortedDates = attendanceDates.keys.toList()
//         ..sort((a, b) => b.compareTo(a));
//       latestDate = sortedDates.first;
//       latestAttendanceData =
//           attendanceDates[latestDate] as Map<String, dynamic>;
//     }

//     // Format time to 12-hour format with AM/PM
//     String formatTime(String? time) {
//       if (time == null || time == '--') return '--';
//       try {
//         final DateFormat inputFormat = DateFormat('HH:mm:ss');
//         final DateTime dateTime = inputFormat.parse(time);
//         final DateFormat outputFormat = DateFormat('hh:mm a');
//         return outputFormat.format(dateTime).toUpperCase();
//       } catch (e) {
//         return time; // Return original if parsing fails
//       }
//     }

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.white.withOpacity(0.2),
//               spreadRadius: 2,
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // صورة الطالب
//             ClipOval(
//               child: Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: AppColors.primaryColor,
//                     width: 2,
//                   ),
//                 ),
//                 child: imageUrl.isNotEmpty
//                     ? CachedNetworkImage(
//                         imageUrl: imageUrl,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) =>
//                             const CircularProgressIndicator(
//                           color: AppColors.primaryColor,
//                         ),
//                         errorWidget: (context, url, error) => const Icon(
//                           Icons.person,
//                           size: 30,
//                           color: Colors.grey,
//                         ),
//                       )
//                     : const Icon(
//                         Icons.person,
//                         size: 30,
//                         color: Colors.grey,
//                       ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // تفاصيل الطالب
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           student['name'] ?? 'Unknown',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primaryColor,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           // أيقونة النجمة
//                           IconButton(
//                             icon: Icon(
//                               isStarred ? Icons.star : Icons.star_border,
//                               color: isStarred
//                                   ? AppColors.primaryColor
//                                   : AppColors.primaryColor,
//                             ),
//                             onPressed: () async {
//                               final provider = Provider.of<AttendanceProvider>(
//                                   context,
//                                   listen: false);
//                               await provider.toggleStarStatus(
//                                 context,
//                                 courseId,
//                                 lectureNumber,
//                                 student['id'],
//                                 isStarred,
//                               );
//                             },
//                           ),
//                           // أيقونة الخيارات
//                           GestureDetector(
//                             onTap: () => showOptionsBottomSheet(
//                                 context, student, index, students),
//                             child: const Icon(
//                               Icons.more_vert,
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   // عرض Check-in و Check-out تحت بعض
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Check-in: ${formatTime(latestAttendanceData?['Check-in'])}',
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         'Check-out: ${formatTime(latestAttendanceData?['Check-out'])}',
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/features/attendance/presentation/manager/lecture_attendance_student_provider.dart';

class StudentCardAttendance extends StatelessWidget {
  final Map<String, dynamic> student;
  final Map<String, dynamic> attendanceDates; // Map لجميع التواريخ
  final String imageUrl;
  final int index;
  final List<Map<String, dynamic>> students;
  final String courseId;
  final int lectureNumber;
  final Function(
          BuildContext, Map<String, dynamic>, int, List<Map<String, dynamic>>)
      showOptionsBottomSheet;
  final VoidCallback? onTap;

  const StudentCardAttendance({
    Key? key,
    required this.student,
    required this.attendanceDates,
    required this.imageUrl,
    required this.index,
    required this.students,
    required this.courseId,
    required this.lectureNumber,
    required this.showOptionsBottomSheet,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isStarred = student['isStarred'] ?? false;

    // اختيار أحدث تاريخ من attendanceDates
    String? latestDate;
    Map<String, dynamic>? latestAttendanceData;
    if (attendanceDates.isNotEmpty) {
      // فرز التواريخ واختيار الأحدث
      var sortedDates = attendanceDates.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      latestDate = sortedDates.first;
      latestAttendanceData =
          attendanceDates[latestDate] as Map<String, dynamic>;
    }

    // Format time to 12-hour format with AM/PM
    String formatTime(String? time) {
      if (time == null || time == '--') return '--';
      try {
        final DateFormat inputFormat = DateFormat('HH:mm:ss');
        final DateTime dateTime = inputFormat.parse(time);
        final DateFormat outputFormat = DateFormat('hh:mm a');
        return outputFormat.format(dateTime).toUpperCase();
      } catch (e) {
        return time; // Return original if parsing fails
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5, // Mimics the boxShadow effect
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // تفاصيل الطالب
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            student['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Row(
                          children: [
                            // أيقونة النجمة
                            IconButton(
                              icon: Icon(
                                isStarred ? Icons.star : Icons.star_border,
                                color: isStarred
                                    ? AppColors.primaryColor
                                    : AppColors.primaryColor,
                              ),
                              onPressed: () async {
                                final provider =
                                    Provider.of<AttendanceProvider>(context,
                                        listen: false);
                                await provider.toggleStarStatus(
                                  context,
                                  courseId,
                                  lectureNumber,
                                  student['id'],
                                  isStarred,
                                );
                              },
                            ),
                            // أيقونة الخيارات
                            GestureDetector(
                              onTap: () => showOptionsBottomSheet(
                                  context, student, index, students),
                              child: const Icon(
                                Icons.more_vert,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // عرض Check-in و Check-out تحت بعض
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-in: ${formatTime(latestAttendanceData?['Check-in'])}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Check-out: ${formatTime(latestAttendanceData?['Check-out'])}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
