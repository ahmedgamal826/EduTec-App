// // // // Path: lib/features/analysis/presentation/widgets/analysis_view_student_body.dart

// // // import 'package:attendance_app/features/analysis/presentation/views/widgets/bar_chart_student.dart';
// // // import 'package:attendance_app/features/analysis/presentation/views/widgets/circular_progress_student.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_bloc/flutter_bloc.dart';
// // // import '../../../cubits/cubit_student/student_analysis_cubit.dart';
// // // import '../../../cubits/cubit_student/student_analysis_state.dart';

// // // class AnalysisViewStudentBody extends StatefulWidget {
// // //   const AnalysisViewStudentBody({Key? key}) : super(key: key);

// // //   @override
// // //   State<AnalysisViewStudentBody> createState() =>
// // //       _AnalysisViewStudentBodyState();
// // // }

// // // class _AnalysisViewStudentBodyState extends State<AnalysisViewStudentBody>
// // //     with SingleTickerProviderStateMixin {
// // //   late AnimationController _animationController;
// // //   late Animation<double> _animation;
// // //   bool _isDataLoaded = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _animationController = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 1500),
// // //     );
// // //     _animation = CurvedAnimation(
// // //       parent: _animationController,
// // //       curve: Curves.easeInOut,
// // //     );
// // //     // Animation will start when data is loaded
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _animationController.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Get screen size for responsive sizing
// // //     final screenWidth = MediaQuery.of(context).size.width;
// // //     final screenHeight = MediaQuery.of(context).size.height;
// // //     final isSmallScreen = screenWidth < 400;
// // //     final isMediumScreen = screenWidth >= 400 && screenWidth < 600;

// // //     // Calculate circle size based on screen width
// // //     final circleSize = isSmallScreen ? 80.0 : (isMediumScreen ? 90.0 : 100.0);

// // //     return BlocConsumer<StudentAnalysisCubit, StudentAnalysisState>(
// // //       listener: (context, state) {
// // //         // Start animation when data is loaded
// // //         if (!state.isLoading && !_isDataLoaded && state.error == null) {
// // //           _isDataLoaded = true;
// // //           // Ensure widget is mounted before starting animation
// // //           if (mounted) {
// // //             _animationController.forward().orCancel;
// // //           }
// // //         }
// // //       },
// // //       builder: (context, state) {
// // //         if (state.isLoading) {
// // //           return const Center(child: CircularProgressIndicator());
// // //         }

// // //         if (state.error != null) {
// // //           return Center(child: Text('Error: ${state.error}'));
// // //         }

// // //         // Theme color from the first metric
// // //         final themeColor = state.performanceMetrics.isNotEmpty
// // //             ? state.performanceMetrics[0].color
// // //             : Colors.green.shade600;

// // //         return SafeArea(
// // //           child: Padding(
// // //             padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
// // //             child: Column(
// // //               children: [
// // //                 // Top two circles in a row
// // //                 Container(
// // //                   height: circleSize * 1.5,
// // //                   margin: EdgeInsets.symmetric(
// // //                       vertical: isSmallScreen ? 8.0 : 16.0),
// // //                   child: Row(
// // //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                     children: [
// // //                       // First two metrics
// // //                       if (state.performanceMetrics.length >= 2)
// // //                         ...state.performanceMetrics.take(2).map(
// // //                               (metric) => Expanded(
// // //                                 child: AnimatedBuilder(
// // //                                   animation: _animation,
// // //                                   builder: (context, child) {
// // //                                     return CircularProgressStudent(
// // //                                       label: metric.label,
// // //                                       percentage: metric.percentage,
// // //                                       color: metric.color,
// // //                                       animationValue: _animation.value,
// // //                                       size: circleSize,
// // //                                       isSmallScreen: isSmallScreen,
// // //                                       showFilledCircle: true,
// // //                                     );
// // //                                   },
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                     ],
// // //                   ),
// // //                 ),

// // //                 // Middle circle (centered) - assuming the 3rd metric is the overall one
// // //                 if (state.performanceMetrics.length >= 3)
// // //                   Container(
// // //                     height: circleSize * 1.5,
// // //                     margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
// // //                     child: AnimatedBuilder(
// // //                       animation: _animation,
// // //                       builder: (context, child) {
// // //                         final overallMetric = state.performanceMetrics[2];
// // //                         return CircularProgressStudent(
// // //                           label: overallMetric.label,
// // //                           percentage: overallMetric.percentage,
// // //                           color: overallMetric.color,
// // //                           animationValue: _animation.value,
// // //                           size: circleSize,
// // //                           isSmallScreen: isSmallScreen,
// // //                           showFilledCircle: true,
// // //                         );
// // //                       },
// // //                     ),
// // //                   ),

// // //                 // Chart Section with Animation
// // //                 Expanded(
// // //                   child: AnimatedBuilder(
// // //                     animation: _animation,
// // //                     builder: (context, child) {
// // //                       return BarChartStudent(
// // //                         studentScores: state.studentScores,
// // //                         animationValue: _animation.value,
// // //                         isSmallScreen: isSmallScreen,
// // //                         isMediumScreen: isMediumScreen,
// // //                         themeColor: themeColor,
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../manager/analysis_manager.dart';
// // import 'bar_chart_student.dart';
// // import 'circular_progress_student.dart';

// // class AnalysisViewStudentBody extends StatefulWidget {
// //   const AnalysisViewStudentBody({Key? key}) : super(key: key);

// //   @override
// //   State<AnalysisViewStudentBody> createState() =>
// //       _AnalysisViewStudentBodyState();
// // }

// // class _AnalysisViewStudentBodyState extends State<AnalysisViewStudentBody>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _animationController;
// //   late Animation<double> _animation;
// //   bool _isDataLoaded = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1500),
// //     );
// //     _animation = CurvedAnimation(
// //       parent: _animationController,
// //       curve: Curves.easeInOut,
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final isSmallScreen = screenWidth < 400;
// //     final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
// //     final circleSize = isSmallScreen ? 80.0 : (isMediumScreen ? 90.0 : 100.0);

// //     return Consumer<AnalysisManager>(
// //       builder: (context, manager, child) {
// //         // Start animation when data is loaded
// //         if (!manager.isStudentLoading &&
// //             !_isDataLoaded &&
// //             manager.studentError == null) {
// //           _isDataLoaded = true;
// //           if (mounted) {
// //             _animationController.forward().orCancel;
// //           }
// //         }

// //         if (manager.isStudentLoading) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (manager.studentError != null) {
// //           return Center(child: Text('Error: ${manager.studentError}'));
// //         }

// //         final themeColor = manager.studentPerformanceMetrics.isNotEmpty
// //             ? manager.studentPerformanceMetrics[0].color
// //             : Colors.green.shade600;

// //         return SafeArea(
// //           child: Padding(
// //             padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
// //             child: Column(
// //               children: [
// //                 Container(
// //                   height: circleSize * 1.5,
// //                   margin: EdgeInsets.symmetric(
// //                       vertical: isSmallScreen ? 8.0 : 16.0),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: [
// //                       if (manager.studentPerformanceMetrics.length >= 2)
// //                         ...manager.studentPerformanceMetrics.take(2).map(
// //                               (metric) => Expanded(
// //                                 child: AnimatedBuilder(
// //                                   animation: _animation,
// //                                   builder: (context, child) {
// //                                     return CircularProgressStudent(
// //                                       label: metric.label,
// //                                       percentage: metric.percentage,
// //                                       color: metric.color,
// //                                       animationValue: _animation.value,
// //                                       size: circleSize,
// //                                       isSmallScreen: isSmallScreen,
// //                                       showFilledCircle: true,
// //                                     );
// //                                   },
// //                                 ),
// //                               ),
// //                             ),
// //                     ],
// //                   ),
// //                 ),
// //                 if (manager.studentPerformanceMetrics.length >= 3)
// //                   Container(
// //                     height: circleSize * 1.5,
// //                     margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
// //                     child: AnimatedBuilder(
// //                       animation: _animation,
// //                       builder: (context, child) {
// //                         final overallMetric =
// //                             manager.studentPerformanceMetrics[2];
// //                         return CircularProgressStudent(
// //                           label: overallMetric.label,
// //                           percentage: overallMetric.percentage,
// //                           color: overallMetric.color,
// //                           animationValue: _animation.value,
// //                           size: circleSize,
// //                           isSmallScreen: isSmallScreen,
// //                           showFilledCircle: true,
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 Expanded(
// //                   child: AnimatedBuilder(
// //                     animation: _animation,
// //                     builder: (context, child) {
// //                       return BarChartStudent(
// //                         studentScores: manager.studentScores,
// //                         animationValue: _animation.value,
// //                         isSmallScreen: isSmallScreen,
// //                         isMediumScreen: isMediumScreen,
// //                         themeColor: themeColor,
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../manager/analysis_manager.dart';
// import 'bar_chart_student.dart';
// import 'circular_progress_student.dart';

// class AnalysisViewStudentBody extends StatefulWidget {
//   const AnalysisViewStudentBody({Key? key}) : super(key: key);

//   @override
//   State<AnalysisViewStudentBody> createState() =>
//       _AnalysisViewStudentBodyState();
// }

// class _AnalysisViewStudentBodyState extends State<AnalysisViewStudentBody>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   bool _isDataLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );
//     _animation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 400;
//     final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
//     final circleSize = isSmallScreen ? 80.0 : (isMediumScreen ? 90.0 : 100.0);

//     return Consumer<AnalysisManager>(
//       builder: (context, manager, child) {
//         if (manager.isStudentLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (manager.studentError != null) {
//           return Center(child: Text('Error: ${manager.studentError}'));
//         }

//         // Start animation when data is loaded
//         if (!_isDataLoaded && manager.studentPerformanceMetrics.isNotEmpty) {
//           _isDataLoaded = true;
//           if (mounted) {
//             _animationController.forward().orCancel;
//           }
//         }

//         final themeColor = manager.studentPerformanceMetrics.isNotEmpty
//             ? manager.studentPerformanceMetrics[0].color
//             : Colors.green.shade600;

//         return SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
//             child: Column(
//               children: [
//                 Container(
//                   height: circleSize * 1.5,
//                   margin: EdgeInsets.symmetric(
//                       vertical: isSmallScreen ? 8.0 : 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       if (manager.studentPerformanceMetrics.length >= 2)
//                         ...manager.studentPerformanceMetrics.take(2).map(
//                               (metric) => Expanded(
//                                 child: AnimatedBuilder(
//                                   animation: _animation,
//                                   builder: (context, child) {
//                                     return CircularProgressStudent(
//                                       label: metric.label,
//                                       percentage: metric.percentage,
//                                       color: metric.color,
//                                       animationValue: _animation.value,
//                                       size: circleSize,
//                                       isSmallScreen: isSmallScreen,
//                                       showFilledCircle: true,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                     ],
//                   ),
//                 ),
//                 if (manager.studentPerformanceMetrics.length >= 3)
//                   Container(
//                     height: circleSize * 1.5,
//                     margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
//                     child: AnimatedBuilder(
//                       animation: _animation,
//                       builder: (context, child) {
//                         final overallMetric =
//                             manager.studentPerformanceMetrics[2];
//                         return CircularProgressStudent(
//                           label: overallMetric.label,
//                           percentage: overallMetric.percentage,
//                           color: overallMetric.color,
//                           animationValue: _animation.value,
//                           size: circleSize,
//                           isSmallScreen: isSmallScreen,
//                           showFilledCircle: true,
//                         );
//                       },
//                     ),
//                   ),
//                 Expanded(
//                   child: AnimatedBuilder(
//                     animation: _animation,
//                     builder: (context, child) {
//                       return BarChartStudent(
//                         studentScores: manager.studentScores,
//                         animationValue: _animation.value,
//                         isSmallScreen: isSmallScreen,
//                         isMediumScreen: isMediumScreen,
//                         themeColor: themeColor,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/analysis_manager.dart';
import 'bar_chart_student.dart';
import 'circular_progress_student.dart';

class AnalysisViewStudentBody extends StatefulWidget {
  const AnalysisViewStudentBody({super.key});

  @override
  State<AnalysisViewStudentBody> createState() =>
      _AnalysisViewStudentBodyState();
}

class _AnalysisViewStudentBodyState extends State<AnalysisViewStudentBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Determine screen size categories
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    
    // Calculate circle size based on screen width
    final circleSize = isSmallScreen ? 70.0 : (isMediumScreen ? 80.0 : 90.0);
    
    // Calculate padding based on screen size
    final horizontalPadding = isSmallScreen ? 8.0 : 16.0;
    final verticalPadding = isSmallScreen ? 8.0 : 12.0;

    return Consumer<AnalysisManager>(
      builder: (context, manager, child) {
        if (manager.isStudentLoading) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ));
        }

        if (manager.studentError != null) {
          return Center(child: Text('Error: ${manager.studentError}'));
        }

        // Start animation when data is loaded
        if (!_isDataLoaded && manager.studentPerformanceMetrics.isNotEmpty) {
          _isDataLoaded = true;
          if (mounted) {
            _animationController.forward().orCancel;
          }
        }

        final themeColor = manager.studentPerformanceMetrics.isNotEmpty
            ? manager.studentPerformanceMetrics[0].color
            : Colors.green.shade600;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              children: [
                // Container for all four circles in a single row
                SizedBox(
                  height: circleSize * 1.3, // Reduced height for circles
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Show all four metrics in a single row
                      if (manager.studentPerformanceMetrics.isNotEmpty)
                        ...manager.studentPerformanceMetrics.take(4).map(
                              (metric) => Expanded(
                                child: AnimatedBuilder(
                                  animation: _animation,
                                  builder: (context, child) {
                                    return CircularProgressStudent(
                                      label: metric.label,
                                      percentage: metric.percentage,
                                      color: metric.color,
                                      animationValue: _animation.value,
                                      size: circleSize * 0.9,
                                      isSmallScreen: true, // Force smaller text for all screens
                                      showFilledCircle: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                
                // Small spacer
                SizedBox(height: verticalPadding),
                
                // Chart Section with Animation - takes remaining space
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return BarChartStudent(
                        studentScores: manager.studentScores,
                        animationValue: _animation.value,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                        themeColor: themeColor,
                      );
                    },
                  ),
                ),
                
                // Add a small bottom padding to prevent overflow
                SizedBox(height: verticalPadding / 2),
              ],
            ),
          ),
        );
      },
    );
  }
}
