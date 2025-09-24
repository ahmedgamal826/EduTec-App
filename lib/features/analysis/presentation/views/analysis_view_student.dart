// // // // // Path: lib/features/analysis/presentation/views/analysis_view_student.dart

// // // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // // import 'package:attendance_app/features/analysis/presentation/views/widgets/analysis_view_student_body.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_bloc/flutter_bloc.dart';
// // // // import '../../cubits/cubit_student/student_analysis_cubit.dart';

// // // // class AnalysisViewStudent extends StatelessWidget {
// // // //   const AnalysisViewStudent({Key? key}) : super(key: key);

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return BlocProvider(
// // // //       create: (context) => StudentAnalysisCubit(),
// // // //       child: Scaffold(
// // // //         appBar: AppBar(
// // // //           iconTheme: const IconThemeData(
// // // //             color: Colors.white,
// // // //           ),
// // // //           title: const Text(
// // // //             'Student Analysis',
// // // //             style: TextStyle(
// // // //               fontSize: 22,
// // // //               fontWeight: FontWeight.bold,
// // // //               color: Colors.white,
// // // //             ),
// // // //           ),
// // // //           backgroundColor: AppColors.primaryColor,
// // // //           centerTitle: true,
// // // //           elevation: 0,
// // // //         ),
// // // //         backgroundColor: AppColors.backgroundScreenColor,
// // // //         body: const AnalysisViewStudentBody(),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // import 'package:attendance_app/features/analysis/presentation/manager/analysis_manager.dart';
// // // import 'package:attendance_app/features/analysis/presentation/views/widgets/analysis_view_student_body.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';

// // // class AnalysisViewStudent extends StatelessWidget {
// // //   const AnalysisViewStudent({Key? key}) : super(key: key);

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return ChangeNotifierProvider(
// // //       create: (context) => AnalysisManager(),
// // //       child: Scaffold(
// // //         appBar: AppBar(
// // //           iconTheme: const IconThemeData(color: Colors.white),
// // //           title: const Text(
// // //             'Student Analysis',
// // //             style: TextStyle(
// // //               color: Colors.white,
// // //               fontSize: 22,
// // //               fontWeight: FontWeight.bold,
// // //             ),
// // //           ),
// // //           backgroundColor: AppColors.primaryColor,
// // //           centerTitle: true,
// // //           elevation: 0,
// // //         ),
// // //         backgroundColor: AppColors.background,
// // //         body: const AnalysisViewStudentBody(),
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:attendance_app/core/utils/app_colors.dart';
// // import 'package:attendance_app/features/analysis/presentation/manager/analysis_manager.dart';
// // import 'package:attendance_app/features/analysis/presentation/views/widgets/analysis_view_student_body.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // class AnalysisViewStudent extends StatelessWidget {
// //   const AnalysisViewStudent({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return ChangeNotifierProvider(
// //       create: (context) => AnalysisManager(),
// //       child: Scaffold(
// //         appBar: AppBar(
// //           iconTheme: const IconThemeData(color: Colors.white),
// //           title: const Text(
// //             'Student Analysis',
// //             style: TextStyle(
// //               color: Colors.white,
// //               fontSize: 22,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           backgroundColor: AppColors.primaryColor,
// //           centerTitle: true,
// //           elevation: 0,
// //         ),
// //         backgroundColor: AppColors.background,
// //         body: const AnalysisViewStudentBody(),
// //       ),
// //     );
// //   }
// // }

// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/analysis/presentation/manager/analysis_manager.dart';
// import 'package:attendance_app/features/analysis/presentation/views/widgets/analysis_view_student_body.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AnalysisViewStudent extends StatelessWidget {
//   const AnalysisViewStudent({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // تعيين courseId يدويًا (بدون الاعتماد على courseCode)
//     String courseId = '1254'; // مثال لـ courseId ثابت
//     return ChangeNotifierProvider(
//       create: (context) => AnalysisManager(courseId),
//       child: Scaffold(
//         appBar: AppBar(
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: const Text(
//             'Student Analysis',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: AppColors.primaryColor,
//           centerTitle: true,
//           elevation: 0,
//         ),
//         backgroundColor: AppColors.background,
//         body: const AnalysisViewStudentBody(),
//       ),
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/analysis/presentation/manager/analysis_manager.dart';
import 'package:attendance_app/features/analysis/presentation/views/widgets/analysis_view_student_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnalysisViewStudent extends StatelessWidget {
  final String courseId; // تمرير courseId كمعامل

  const AnalysisViewStudent({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AnalysisManager(courseId),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Student Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: AppColors.background,
        body: const AnalysisViewStudentBody(),
      ),
    );
  }
}
