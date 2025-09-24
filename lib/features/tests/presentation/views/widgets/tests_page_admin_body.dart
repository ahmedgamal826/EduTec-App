import 'dart:math';
import 'package:attendance_app/features/tests/data/models/tests_model_admin.dart';
import 'package:attendance_app/features/tests/presentation/viewmodels/home_tests_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tests_list_item_admin.dart';

class TestsTestsPageAdminBody extends StatefulWidget {
  final String courseId;

  const TestsTestsPageAdminBody({super.key, required this.courseId});

  @override
  State<TestsTestsPageAdminBody> createState() =>
      Tests_TestsTestsPageAdminBodyState();
}

class Tests_TestsTestsPageAdminBodyState extends State<TestsTestsPageAdminBody>
    with SingleTickerProviderStateMixin {
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
      create: (_) => TestsHomeViewModel(courseId: widget.courseId),
      child: Consumer<TestsHomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.assignments.isEmpty) {
            return const Center(child: Text('No tests available'));
          }

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
              Animation<double> animation = index < _animationsList.length
                  ? _animationsList[index]
                  : kAlwaysCompleteAnimation;

              return TestsListItemAdmin(
                test: viewModel.assignments[index],
                animation: animation,
                onDelete: () {
                  viewModel.deleteAssignment(index);
                },
                onTap: () {
                  print('Tapped on ${viewModel.assignments[index].name}');
                },
                onEditQuestions: () {
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
