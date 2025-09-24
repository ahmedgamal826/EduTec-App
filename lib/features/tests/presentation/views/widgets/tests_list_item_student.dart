import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/data/models/assignment_model_student.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/tests_model_student.dart';

class TestsListItemStudent extends StatefulWidget {
  final TestsTestsModel test;
  final VoidCallback onTap;
  final VoidCallback onViewSubmissions;

  const TestsListItemStudent({
    super.key,
    required this.test,
    required this.onTap,
    required this.onViewSubmissions,
  });

  @override
  State<TestsListItemStudent> createState() => TestsListItemStudentState();
}

class TestsListItemStudentState extends State<TestsListItemStudent> {
  bool _isHovering = false;
  bool _expanded = false;

  String _formatDate(String dateString) {
    try {
      final parsedDate = DateFormat('dd-MM-yyyy HH:mm').parseStrict(dateString);
      return DateFormat('dd MMM yyyy, h:mm a').format(parsedDate);
    } catch (e) {
      print('Error parsing date: $dateString, Error: $e');
      return dateString;
    }
  }

  String _formatExamDate(String dateString) {
    try {
      final parsedDate = DateFormat('dd-MM-yyyy').parseStrict(dateString);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      print('Error parsing exam date: $dateString, Error: $e');
      return dateString;
    }
  }

  String _formatTimeWithAMPM(String timeString) {
    try {
      // Parse the time in 24-hour format (HH:mm)
      final timeParts = timeString.split(':');
      if (timeParts.length != 2) {
        return timeString;
      }

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      print('Error formatting time with AM/PM: $timeString, Error: $e');
      return timeString;
    }
  }

  bool isTestActive() {
    if (widget.test.examDate == null ||
        widget.test.startTime == null ||
        widget.test.endTime == null) {
      return false;
    }

    try {
      final now = DateTime.now();
      final examDate =
          DateFormat('dd-MM-yyyy').parseStrict(widget.test.examDate!);
      final startTimeParts = widget.test.startTime!.split(':');
      final endTimeParts = widget.test.endTime!.split(':');

      if (startTimeParts.length != 2 || endTimeParts.length != 2) {
        return false;
      }

      final startDateTime = DateTime(
        examDate.year,
        examDate.month,
        examDate.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
      );

      final endDateTime = DateTime(
        examDate.year,
        examDate.month,
        examDate.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );

      return now.isAfter(startDateTime) && now.isBefore(endDateTime);
    } catch (e) {
      print('Error checking if test is active: $e');
      return false;
    }
  }

  bool isTestExpired() {
    if (widget.test.examDate == null || widget.test.endTime == null) {
      return false;
    }

    try {
      final now = DateTime.now();
      final examDate =
          DateFormat('dd-MM-yyyy').parseStrict(widget.test.examDate!);
      final endTimeParts = widget.test.endTime!.split(':');

      if (endTimeParts.length != 2) {
        return false;
      }

      final endDateTime = DateTime(
        examDate.year,
        examDate.month,
        examDate.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );

      return now.isAfter(endDateTime);
    } catch (e) {
      print('Error checking if test is expired: $e');
      return false;
    }
  }

  bool isTestScheduled() {
    if (widget.test.examDate == null || widget.test.startTime == null) {
      return false;
    }

    try {
      final now = DateTime.now();
      final examDate =
          DateFormat('dd-MM-yyyy').parseStrict(widget.test.examDate!);
      final startTimeParts = widget.test.startTime!.split(':');

      if (startTimeParts.length != 2) {
        return false;
      }

      final startDateTime = DateTime(
        examDate.year,
        examDate.month,
        examDate.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
      );

      return now.isBefore(startDateTime);
    } catch (e) {
      print('Error checking if test is scheduled: $e');
      return false;
    }
  }

  String _calculateTimeRemaining() {
    if (widget.test.examDate == null || widget.test.startTime == null) {
      return '';
    }

    try {
      final now = DateTime.now();
      final examDate =
          DateFormat('dd-MM-yyyy').parseStrict(widget.test.examDate!);
      final startTimeParts = widget.test.startTime!.split(':');

      if (startTimeParts.length != 2) {
        return '';
      }

      final startDateTime = DateTime(
        examDate.year,
        examDate.month,
        examDate.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
      );

      if (startDateTime.isBefore(now)) {
        return '';
      }

      final difference = startDateTime.difference(now);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} left';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} left';
      } else {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} left';
      }
    } catch (e) {
      print('Error calculating time remaining: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String createdDate = _formatDate(widget.test.date);
    final bool isExpired = isTestExpired();
    final bool isActive = isTestActive();
    final bool isScheduled = isTestScheduled();
    final String timeRemaining = _calculateTimeRemaining();

    // Format start and end times with AM/PM
    final String startTimeFormatted = widget.test.startTime != null
        ? _formatTimeWithAMPM(widget.test.startTime!)
        : '';
    final String endTimeFormatted = widget.test.endTime != null
        ? _formatTimeWithAMPM(widget.test.endTime!)
        : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: _isHovering ? 10 : 5,
              offset: _isHovering ? const Offset(0, 5) : const Offset(0, 3),
              spreadRadius: _isHovering ? 1 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withBlue(220),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.test.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (!_expanded)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.test.isCompleted
                                    ? Colors.green.withOpacity(0.9)
                                    : isExpired
                                        ? Colors.red.withOpacity(0.9)
                                        : isActive
                                            ? Colors.green.withOpacity(0.9)
                                            : Colors.amber.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: widget.test.isCompleted
                                  ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Completed',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      isExpired
                                          ? 'Expired'
                                          : isActive
                                              ? 'Active'
                                              : 'Scheduled',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Created by',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.test.doctor.startsWith('Dr') ||
                                            widget.test.doctor.startsWith('dr')
                                        ? widget.test.doctor
                                        : 'Dr/ ${widget.test.doctor}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 20),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.test.isCompleted
                                    ? Colors.green.shade50
                                    : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.grade_outlined,
                                color: widget.test.isCompleted
                                    ? Colors.green.shade700
                                    : Colors.amber.shade700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Score',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.test.score,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: widget.test.isCompleted
                                          ? Colors.green.shade700
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Created on',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          createdDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: _expanded
                                              ? TextOverflow.visible
                                              : TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.test.examDate != null) ...[
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isExpired
                                            ? Colors.red.shade50
                                            : isActive
                                                ? Colors.green.shade50
                                                : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.event,
                                        color: isExpired
                                            ? Colors.red.shade700
                                            : isActive
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Exam Date',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            _formatExamDate(
                                                widget.test.examDate!),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isExpired
                                                  ? Colors.red.shade700
                                                  : isActive
                                                      ? Colors.green.shade700
                                                      : Colors.orange.shade700,
                                            ),
                                            overflow: _expanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                          ),
                                          if (timeRemaining.isNotEmpty) ...[
                                            const SizedBox(height: 5),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                timeRemaining,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (widget.test.startTime != null &&
                          widget.test.endTime != null) ...[
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isExpired
                                            ? Colors.red.shade50
                                            : isActive
                                                ? Colors.green.shade50
                                                : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.access_time,
                                        color: isExpired
                                            ? Colors.red.shade700
                                            : isActive
                                                ? Colors.green.shade700
                                                : Colors.blue.shade700,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Test Time',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '$startTimeFormatted - $endTimeFormatted',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isExpired
                                                  ? Colors.red.shade700
                                                  : isActive
                                                      ? Colors.green.shade700
                                                      : Colors.blue.shade700,
                                            ),
                                            overflow: _expanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: Column(
                          children: [
                            // Show "Review Submission" if the test is completed, regardless of deadline
                            if (widget.test.isCompleted) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: widget.onViewSubmissions,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.assignment_turned_in,
                                              size: 18,
                                              color: Colors.green.shade700,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Review Submission',
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                            // Show "Open Test" only if the test is active and not completed
                            else if (!widget.test.isCompleted && isActive) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: widget.onTap,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.assignment_outlined,
                                              size: 18,
                                              color: AppColors.primaryColor,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Open Test',
                                              style: TextStyle(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // If the test is scheduled or expired and not completed, show appropriate message
                            if (!widget.test.isCompleted && !isActive) ...[
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: Text(
                                    isExpired
                                        ? 'Test Expired'
                                        : 'Test not yet active',
                                    style: TextStyle(
                                      color: isExpired
                                          ? Colors.red.shade700
                                          : Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
