import 'dart:math';
import 'package:attendance_app/features/assignments/data/models/assignment_model_admin.dart';
import 'package:attendance_app/features/assignments/presentation/viewmodels/home_assignments_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'assignment_list_item.dart';

class AssignmentPageAdminBody extends StatefulWidget {
  final String courseId;

  const AssignmentPageAdminBody({super.key, required this.courseId});

  @override
  State<AssignmentPageAdminBody> createState() =>
      _AssignmentPageAdminBodyState();
}

class _AssignmentPageAdminBodyState extends State<AssignmentPageAdminBody>
    with SingleTickerProviderStateMixin {
  // Animation controller for list items
  late AnimationController _animationController;
  final List<Animation<double>> _animationsList = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animationController.forward();
  }

  void _initializeAnimations(int itemCount) {
    _animationsList.clear();
    for (int i = 0; i < itemCount; i++) {
      final Animation<double> animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(i * 0.2, min(1.0, i * 0.2 + 0.6),
              curve: Curves.easeInOut),
        ),
      );
      _animationsList.add(animation);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeAssignmentsViewModel(courseId: widget.courseId),
      child: Consumer<HomeAssignmentsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.assignments.isEmpty) {
            return const Center(child: Text('No assignments available'));
          }

          // Initialize animations when assignments are loaded
          if (_animationsList.isEmpty ||
              _animationsList.length != viewModel.assignments.length) {
            _initializeAnimations(viewModel.assignments.length);
            _animationController.reset();
            _animationController.forward();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.assignments.length,
            itemBuilder: (context, index) {
              // Get animation for this item or create a default one
              Animation<double> animation = index < _animationsList.length
                  ? _animationsList[index]
                  : kAlwaysCompleteAnimation;

              return AssignmentListItem(
                assignment: viewModel.assignments[index],
                animation: animation,
                onDelete: () {
                  viewModel.deleteAssignment(index);
                },
                onTap: () {
                  // Navigate to assignment detail page
                  print('Tapped on ${viewModel.assignments[index].name}');
                },
                onEditQuestions: () {
                  // This is a placeholder - actual implementation would depend on navigation needs
                  print(
                      'Edit questions for ${viewModel.assignments[index].name}');
                },
                courseName: viewModel.courseName,
              );
            },
          );
        },
      ),
    );
  }
}
