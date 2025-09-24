import 'package:attendance_app/features/tests/data/models/student_tests_response.dart';
import 'package:attendance_app/features/tests/presentation/viewmodels/tests_submissions_viewmodel.dart';
import 'package:attendance_app/features/tests/presentation/views/tests_students_submissions_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestSubmissionView extends StatelessWidget {
  final String adminId;
  final String testId;
  final String testTitle;
  final String courseName;
  final String currentUserName; // Parameter to filter submissions

  const TestSubmissionView({
    super.key,
    required this.adminId,
    required this.testId,
    required this.testTitle,
    required this.courseName,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAdmin = currentUser?.uid == adminId; // Check if the user is admin

    return ChangeNotifierProvider(
      create: (_) => TestsSubmissionsViewModel(
        adminId: adminId,
        testId: testId,
        courseName: courseName,
      )..fetchSubmissions(),
      child: Consumer<TestsSubmissionsViewModel>(
        builder: (context, viewModel, child) {
          // Filter submissions based on user role
          final submissionsToShow = isAdmin
              ? viewModel.submissions // Show all submissions for admin
              : viewModel.submissions
                  .where(
                      (submission) => submission.studentName == currentUserName)
                  .toList(); // Show only current user's submissions for students

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'Submissions for $testTitle',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              // actions: [
              //   IconButton(
              //     icon: const Icon(Icons.refresh),
              //     onPressed: () => viewModel.refreshSubmissions(),
              //     tooltip: 'Refresh submissions',
              //   ),
              // ],
            ),
            body: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ))
                : _buildSubmissionsContent(
                    context, viewModel, submissionsToShow, isAdmin),
          );
        },
      ),
    );
  }

  Widget _buildSubmissionsContent(
      BuildContext context,
      TestsSubmissionsViewModel viewModel,
      List<TestsStudentSubmission> submissions,
      bool isAdmin) {
    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'No submission found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              viewModel.errorMessage.isNotEmpty
                  ? 'Error: ${viewModel.errorMessage}'
                  : isAdmin
                      ? 'No students have submitted this test yet.'
                      : 'You have not submitted this test yet.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAdmin ? 'All Submissions' : 'Your Submission',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${submissions.length} submission${submissions.length == 1 ? '' : 's'} found',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                return _buildSubmissionCard(
                  context,
                  submissions[index],
                  viewModel,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(
    BuildContext context,
    TestsStudentSubmission submission,
    TestsSubmissionsViewModel viewModel,
  ) {
    final Color statusColor = _getStatusColor(submission.status);
    final String statusText = _getStatusText(submission.status);
    final bool needsGrading = submission.status == 'submitted' ||
        submission.status == 'partially_graded' ||
        submission.status == 'graded';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 7,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestsStudentSubmissionDetailView(
                adminId: adminId,
                testId: testId,
                testTitle: testTitle,
                submission: submission,
                courseName: courseName,
              ),
            ),
          ).then((_) => viewModel.refreshSubmissions());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Student Name
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            submission.studentName.isNotEmpty
                                ? submission.studentName[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            submission.studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Submission details
              Row(
                children: [
                  _buildInfoItem(
                    Icons.score_outlined,
                    Colors.blue,
                    'Score',
                    submission.totalScore != null
                        ? '${submission.totalScore}/${submission.maxScore}'
                        : submission.scoreDisplay ?? 'Not graded',
                  ),
                  const Spacer(),
                  _buildInfoItem(
                    Icons.calendar_today_outlined,
                    Colors.green,
                    'Submitted on',
                    _formatDate(submission.submittedAt),
                  ),
                  const Spacer(),
                  if (submission.gradedAt != null)
                    _buildInfoItem(
                      Icons.check_circle_outline,
                      Colors.purple,
                      'Graded on',
                      _formatDate(submission.gradedAt!),
                    )
                  else
                    _buildInfoItem(
                      Icons.pending_outlined,
                      Colors.orange,
                      'Status',
                      needsGrading
                          ? _getScoreLabel(submission.scorePercentage!)
                          : 'Not graded',
                    ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.question_answer,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${submission.responses.length} questions',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  if (!needsGrading)
                    const Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tap to grade',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  if (needsGrading)
                    const Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          color: Colors.blue,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'View details',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale();
  }

  String _getScoreLabel(int scorePercentage) {
    if (scorePercentage == 100) {
      return 'Excellent';
    } else if (scorePercentage >= 80 && scorePercentage <= 99) {
      return 'Very Good';
    } else if (scorePercentage >= 50 && scorePercentage <= 79) {
      return 'Good';
    } else {
      return 'Failure';
    }
  }

  Widget _buildInfoItem(
      IconData icon, Color color, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'graded':
        return Colors.green;
      case 'partially_graded':
        return Colors.orange;
      case 'submitted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'graded':
        return 'Graded';
      case 'submitted':
        return 'Submitted';
      case 'partially_graded':
        return 'Partially Graded';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    // Format with month and day
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
