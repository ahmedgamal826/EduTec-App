import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/data/models/assignment_model_admin.dart';
import 'package:attendance_app/features/assignments/presentation/views/assignment_submissions_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignmentListItem extends StatefulWidget {
  final AssignmentModel assignment;
  final Animation<double> animation;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onEditQuestions;
  final String? courseName;

  const AssignmentListItem({
    super.key,
    required this.assignment,
    required this.animation,
    required this.onDelete,
    required this.onTap,
    required this.onEditQuestions,
    this.courseName,
  });

  @override
  State<AssignmentListItem> createState() => _AssignmentListItemState();
}

class _AssignmentListItemState extends State<AssignmentListItem> {
  bool _isHovering = false;
  bool _expanded = false;
  bool _isAdmin = false; // Added flag to track if user is admin
  String? _currentUserName; // Store the current user's name

  @override
  void initState() {
    super.initState();
    _checkIfUserIsAdmin(); // Check user role when widget initializes
    _fetchCurrentUserName(); // Fetch the user's name when the widget initializes
  }

  // Function to check if current user is admin
  Future<void> _checkIfUserIsAdmin() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _isAdmin = userDoc["role"]?.toString().toLowerCase() == "admin";
          });
        }
      }
    } catch (e) {
      print("Error in checking role: $e");
    }
  }

  // Function to fetch current user's name
  Future<void> _fetchCurrentUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _currentUserName = userData?['name'] ?? 'Unknown User';
          });
        } else {
          setState(() {
            _currentUserName = 'Unknown User';
          });
        }
      } else {
        setState(() {
          _currentUserName = 'Unknown User';
        });
      }
    } catch (e) {
      setState(() {
        _currentUserName = 'Unknown User';
      });
      print("Error fetching user name: $e");
    }
  }

  String _formatDate(String dateString) {
    try {
      final parsedDate = DateFormat('dd-MM-yyyy HH:mm').parseStrict(dateString);
      return DateFormat('dd MMM yyyy, h:mm a').format(parsedDate);
    } catch (e) {
      print('Error parsing date: $dateString, Error: $e');
      return dateString;
    }
  }

  String _calculateTimeRemaining(String deadlineString) {
    try {
      final deadline =
          DateFormat('dd-MM-yyyy HH:mm').parseStrict(deadlineString);
      final now = DateTime.now();

      if (deadline.isBefore(now)) {
        return 'Deadline passed';
      }

      final difference = deadline.difference(now);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} left';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} left';
      } else {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} left';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format dates
    final String createdDate = _formatDate(widget.assignment.date);
    final String? deadlineDate = widget.assignment.deadline != null
        ? _formatDate(widget.assignment.deadline!)
        : null;

    // Check if deadline is passed
    bool isDeadlinePassed = false;
    String timeRemaining = '';
    if (widget.assignment.deadline != null) {
      try {
        final deadline = DateFormat('dd-MM-yyyy HH:mm')
            .parseStrict(widget.assignment.deadline!);
        isDeadlinePassed = deadline.isBefore(DateTime.now());
        if (!isDeadlinePassed) {
          timeRemaining = _calculateTimeRemaining(widget.assignment.deadline!);
        }
      } catch (e) {
        print(
            'Error parsing deadline: ${widget.assignment.deadline}, Error: $e');
      }
    }

    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - widget.animation.value)),
          child: Opacity(
            opacity: widget.animation.value,
            child: MouseRegion(
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
                          : Colors.black.withOpacity(0.4),
                      blurRadius: _isHovering ? 10 : 5,
                      offset:
                          _isHovering ? const Offset(0, 5) : const Offset(0, 3),
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
                      // Header with name and status
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
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
                                        widget.assignment.name,
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
                                  // Only show the Active/Expired label for non-admin users
                                  if (deadlineDate != null && !_expanded && !_isAdmin)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDeadlinePassed
                                            ? Colors.red.withOpacity(0.9)
                                            : Colors.green.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isDeadlinePassed ? 'Expired' : 'Active',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),

                                  //Edit icon always visible
                                  InkWell(
                                    onTap: widget.onTap,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Content
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Admin info
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 10, 16, 5),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.1),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            widget.assignment.doctor
                                                        .startsWith('Dr') ||
                                                    widget.assignment.doctor
                                                        .startsWith('dr')
                                                ? widget.assignment.doctor
                                                : 'Dr/ ${widget.assignment.doctor}',
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

                              const Divider(
                                  indent: 16, endIndent: 16, height: 20),

                              // Dates info
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 5, 16, 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Creation date
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
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

                              if (deadlineDate != null) ...[
                                const SizedBox(height: 14),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Deadline date
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isDeadlinePassed
                                                    ? Colors.red.shade50
                                                    : Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.timer_outlined,
                                                color: isDeadlinePassed
                                                    ? Colors.red.shade700
                                                    : Colors.green.shade700,
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
                                                    'Deadline',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    deadlineDate,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isDeadlinePassed
                                                          ? Colors.red.shade700
                                                          : Colors
                                                              .green.shade700,
                                                    ),
                                                    overflow: _expanded
                                                        ? TextOverflow.visible
                                                        : TextOverflow.ellipsis,
                                                  ),
                                                  if (!isDeadlinePassed &&
                                                      timeRemaining
                                                          .isNotEmpty) ...[
                                                    const SizedBox(height: 5),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .green.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        timeRemaining,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .green.shade700,
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

                              // Bottom actions
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // View Submissions button
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              if (_currentUserName == null) {
                                                await _fetchCurrentUserName();
                                              }
                                              final currentUser = FirebaseAuth
                                                  .instance.currentUser;
                                              final adminId =
                                                  currentUser?.uid ?? '';

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AssignmentSubmissionsView(
                                                    adminId: adminId,
                                                    assignmentId:
                                                        widget.assignment.name,
                                                    assignmentTitle:
                                                        widget.assignment.name,
                                                    courseName:
                                                        widget.courseName ??
                                                            'IOT',
                                                    currentUserName:
                                                        _currentUserName ?? 'Unknown User',
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                    color:
                                                        Colors.green.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Student Submissions',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade700,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Edit Questions button
                                        Expanded(
                                          child: InkWell(
                                            onTap: widget.onEditQuestions,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .question_answer_outlined,
                                                    size: 18,
                                                    color:
                                                        Colors.amber.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Edit Questions',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.amber.shade700,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Delete button
                                        Expanded(
                                          child: InkWell(
                                            onTap: widget.onDelete,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.delete_outline,
                                                    size: 18,
                                                    color: Colors.red.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.red.shade700,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
