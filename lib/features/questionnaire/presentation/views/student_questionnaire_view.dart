// // // // // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // // // // import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
// // // // // // import 'package:attendance_app/features/questionnaire/presentation/viewmodels/student_questionnaire_viewmode.dart';
// // // // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_card.dart';
// // // // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_content.dart';
// // // // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/submit_button.dart';
// // // // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:provider/provider.dart';

// // // // // // class StudentQuestionnaireView extends StatelessWidget {
// // // // // //   final String questionnaireId;
// // // // // //   final String courseId;
// // // // // //   final VoidCallback onSubmit;

// // // // // //   const StudentQuestionnaireView({
// // // // // //     Key? key,
// // // // // //     required this.questionnaireId,
// // // // // //     required this.courseId,
// // // // // //     required this.onSubmit,
// // // // // //   }) : super(key: key);

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return ChangeNotifierProvider(
// // // // // //       create: (_) {
// // // // // //         final viewModel = StudentQuestionnaireViewmodel();
// // // // // //         FirebaseFirestore.instance
// // // // // //             .collection('Courses')
// // // // // //             .doc(courseId)
// // // // // //             .collection('questionnaires')
// // // // // //             .doc(questionnaireId)
// // // // // //             .get()
// // // // // //             .then((doc) {
// // // // // //           if (doc.exists) {
// // // // // //             final data = doc.data() as Map<String, dynamic>;
// // // // // //             final questions = (data['questions'] as List)
// // // // // //                 .map((q) => QuestionModel.fromMap(q))
// // // // // //                 .toList();
// // // // // //             viewModel
// // // // // //                 .initializeQuestions(questions.map((q) => q.toMap()).toList());
// // // // // //           }
// // // // // //         });
// // // // // //         return viewModel;
// // // // // //       },
// // // // // //       child: Consumer<StudentQuestionnaireViewmodel>(
// // // // // //         builder: (context, viewModel, child) {
// // // // // //           bool allQuestionsAnswered = viewModel.areAllQuestionsAnswered();

// // // // // //           return Scaffold(
// // // // // //             appBar: AppBar(
// // // // // //               iconTheme: const IconThemeData(color: Colors.white),
// // // // // //               title: const Text(
// // // // // //                 'Answer Questionnaire',
// // // // // //                 style: TextStyle(
// // // // // //                   color: Colors.white,
// // // // // //                   fontWeight: FontWeight.bold,
// // // // // //                 ),
// // // // // //               ),
// // // // // //               backgroundColor: AppColors.primaryColor,
// // // // // //             ),
// // // // // //             body: Column(
// // // // // //               children: [
// // // // // //                 Expanded(
// // // // // //                   child: SingleChildScrollView(
// // // // // //                     child: viewModel.questions.isEmpty
// // // // // //                         ? const Center(
// // // // // //                             child: Text(
// // // // // //                               'No questions available in this questionnaire.',
// // // // // //                               style: TextStyle(
// // // // // //                                 fontSize: 18,
// // // // // //                                 color: Colors.grey,
// // // // // //                               ),
// // // // // //                             ),
// // // // // //                           )
// // // // // //                         : QuestionContent(
// // // // // //                             question: viewModel.currentQuestion,
// // // // // //                             onAnswerSelected: (answer) {
// // // // // //                               viewModel.setAnswer(
// // // // // //                                   viewModel.currentQuestionIndex, answer);
// // // // // //                             },
// // // // // //                             selectedAnswer: viewModel
// // // // // //                                 .getAnswer(viewModel.currentQuestionIndex),
// // // // // //                           ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 SubmitButton(
// // // // // //                   viewModel: viewModel,
// // // // // //                   allQuestionsAnswered: allQuestionsAnswered,
// // // // // //                   onSubmit: () {
// // // // // //                     onSubmit();
// // // // // //                     final user = FirebaseAuth.instance.currentUser;
// // // // // //                     if (user != null) {
// // // // // //                       FirebaseFirestore.instance
// // // // // //                           .collection('Courses')
// // // // // //                           .doc(courseId)
// // // // // //                           .collection('questionnaires')
// // // // // //                           .doc(questionnaireId)
// // // // // //                           .collection('filledBy')
// // // // // //                           .doc(user.uid)
// // // // // //                           .set({
// // // // // //                         'uid': user.uid,
// // // // // //                         'timestamp': FieldValue.serverTimestamp(),
// // // // // //                       });
// // // // // //                       ScaffoldMessenger.of(context).showSnackBar(
// // // // // //                         SnackBar(
// // // // // //                           content: const Row(
// // // // // //                             children: [
// // // // // //                               Icon(Icons.check_circle, color: Colors.green),
// // // // // //                               SizedBox(width: 10),
// // // // // //                               Text(
// // // // // //                                 'Answers submitted successfully!',
// // // // // //                                 style: TextStyle(color: Colors.white),
// // // // // //                               ),
// // // // // //                             ],
// // // // // //                           ),
// // // // // //                           backgroundColor: AppColors.primaryColor,
// // // // // //                           duration: const Duration(seconds: 2),
// // // // // //                           behavior: SnackBarBehavior.floating,
// // // // // //                           shape: RoundedRectangleBorder(
// // // // // //                             borderRadius: BorderRadius.circular(10),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       );
// // // // // //                     }
// // // // // //                     Navigator.pop(context);
// // // // // //                   },
// // // // // //                 ),
// // // // // //                 if (!allQuestionsAnswered && viewModel.questions.isNotEmpty)
// // // // // //                   const Padding(
// // // // // //                     padding: EdgeInsets.only(bottom: 8.0),
// // // // // //                     child: Text(
// // // // // //                       'Please answer all questions before submitting',
// // // // // //                       style: TextStyle(
// // // // // //                         color: Colors.red,
// // // // // //                         fontWeight: FontWeight.bold,
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 Container(
// // // // // //                   height: 80,
// // // // // //                   padding: const EdgeInsets.symmetric(vertical: 10),
// // // // // //                   color: Colors.grey.shade200,
// // // // // //                   child: viewModel.questions.isEmpty
// // // // // //                       ? const Center(
// // // // // //                           child: Text(
// // // // // //                             'No questions yet',
// // // // // //                             style: TextStyle(color: Colors.grey),
// // // // // //                           ),
// // // // // //                         )
// // // // // //                       : ListView.builder(
// // // // // //                           scrollDirection: Axis.horizontal,
// // // // // //                           itemCount: viewModel.questions.length,
// // // // // //                           itemBuilder: (context, index) {
// // // // // //                             bool isAnswered =
// // // // // //                                 viewModel.isQuestionAnswered(index);
// // // // // //                             return QuestionCard(
// // // // // //                               role: 'Student',
// // // // // //                               index: index,
// // // // // //                               isSelected:
// // // // // //                                   viewModel.currentQuestionIndex == index,
// // // // // //                               isAnswered: isAnswered,
// // // // // //                               onTap: () {
// // // // // //                                 viewModel.selectQuestion(index);
// // // // // //                               },
// // // // // //                               onDelete: () {},
// // // // // //                             );
// // // // // //                           },
// // // // // //                         ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           );
// // // // // //         },
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // // // import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
// // // // // import 'package:attendance_app/features/questionnaire/presentation/viewmodels/student_questionnaire_viewmode.dart';
// // // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_card.dart';
// // // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_content.dart';
// // // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/submit_button.dart';
// // // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:provider/provider.dart';

// // // // // class StudentQuestionnaireView extends StatelessWidget {
// // // // //   final String questionnaireId;
// // // // //   final String courseId;
// // // // //   final VoidCallback onSubmit;

// // // // //   const StudentQuestionnaireView({
// // // // //     Key? key,
// // // // //     required this.questionnaireId,
// // // // //     required this.courseId,
// // // // //     required this.onSubmit,
// // // // //   }) : super(key: key);

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return ChangeNotifierProvider(
// // // // //       create: (_) {
// // // // //         final viewModel = StudentQuestionnaireViewmodel();
// // // // //         FirebaseFirestore.instance
// // // // //             .collection('Courses')
// // // // //             .doc(courseId)
// // // // //             .collection('questionnaires')
// // // // //             .doc(questionnaireId)
// // // // //             .get()
// // // // //             .then((doc) {
// // // // //           if (doc.exists) {
// // // // //             final data = doc.data() as Map<String, dynamic>;
// // // // //             final questions = (data['questions'] as List)
// // // // //                 .map((q) => QuestionModel.fromMap(q))
// // // // //                 .toList();
// // // // //             viewModel
// // // // //                 .initializeQuestions(questions.map((q) => q.toMap()).toList());
// // // // //           }
// // // // //         });
// // // // //         return viewModel;
// // // // //       },
// // // // //       child: Consumer<StudentQuestionnaireViewmodel>(
// // // // //         builder: (context, viewModel, child) {
// // // // //           final user = FirebaseAuth.instance.currentUser;
// // // // //           if (user == null)
// // // // //             return const Center(child: Text('User not logged in'));

// // // // //           return FutureBuilder<DocumentSnapshot>(
// // // // //             future: FirebaseFirestore.instance
// // // // //                 .collection('Courses')
// // // // //                 .doc(courseId)
// // // // //                 .collection('questionnaires')
// // // // //                 .doc(questionnaireId)
// // // // //                 .collection('filledBy')
// // // // //                 .doc(user.uid)
// // // // //                 .get(),
// // // // //             builder: (context, snapshot) {
// // // // //               if (snapshot.connectionState == ConnectionState.waiting) {
// // // // //                 return const Center(child: CircularProgressIndicator());
// // // // //               }

// // // // //               bool isCompleted = snapshot.data?.exists ?? false;

// // // // //               if (isCompleted) {
// // // // //                 return Scaffold(
// // // // //                   appBar: AppBar(
// // // // //                     iconTheme: const IconThemeData(color: Colors.white),
// // // // //                     title: const Text(
// // // // //                       'Answer Questionnaire',
// // // // //                       style: TextStyle(
// // // // //                         color: Colors.white,
// // // // //                         fontWeight: FontWeight.bold,
// // // // //                       ),
// // // // //                     ),
// // // // //                     backgroundColor: AppColors.primaryColor,
// // // // //                   ),
// // // // //                   body: const Center(
// // // // //                     child: Text(
// // // // //                       'You have already submitted this questionnaire.',
// // // // //                       style: TextStyle(fontSize: 18, color: Colors.grey),
// // // // //                       textAlign: TextAlign.center,
// // // // //                     ),
// // // // //                   ),
// // // // //                 );
// // // // //               }

// // // // //               bool allQuestionsAnswered = viewModel.areAllQuestionsAnswered();

// // // // //               return Scaffold(
// // // // //                 appBar: AppBar(
// // // // //                   iconTheme: const IconThemeData(color: Colors.white),
// // // // //                   title: const Text(
// // // // //                     'Answer Questionnaire',
// // // // //                     style: TextStyle(
// // // // //                       color: Colors.white,
// // // // //                       fontWeight: FontWeight.bold,
// // // // //                     ),
// // // // //                   ),
// // // // //                   backgroundColor: AppColors.primaryColor,
// // // // //                 ),
// // // // //                 body: Column(
// // // // //                   children: [
// // // // //                     Expanded(
// // // // //                       child: SingleChildScrollView(
// // // // //                         child: viewModel.questions.isEmpty
// // // // //                             ? const Center(
// // // // //                                 child: Text(
// // // // //                                   'No questions available in this questionnaire.',
// // // // //                                   style: TextStyle(
// // // // //                                     fontSize: 18,
// // // // //                                     color: Colors.grey,
// // // // //                                   ),
// // // // //                                 ),
// // // // //                               )
// // // // //                             : QuestionContent(
// // // // //                                 question: viewModel.currentQuestion,
// // // // //                                 onAnswerSelected: (answer) {
// // // // //                                   viewModel.setAnswer(
// // // // //                                       viewModel.currentQuestionIndex, answer);
// // // // //                                 },
// // // // //                                 selectedAnswer: viewModel
// // // // //                                     .getAnswer(viewModel.currentQuestionIndex),
// // // // //                               ),
// // // // //                       ),
// // // // //                     ),
// // // // //                     SubmitButton(
// // // // //                       viewModel: viewModel,
// // // // //                       allQuestionsAnswered: allQuestionsAnswered,
// // // // //                       onSubmit: () async {
// // // // //                         await viewModel.markAsCompleted(
// // // // //                             courseId, questionnaireId);
// // // // //                         onSubmit();
// // // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // // //                           SnackBar(
// // // // //                             content: const Row(
// // // // //                               children: [
// // // // //                                 Icon(Icons.check_circle, color: Colors.green),
// // // // //                                 SizedBox(width: 10),
// // // // //                                 Text(
// // // // //                                   'Answers submitted successfully!',
// // // // //                                   style: TextStyle(color: Colors.white),
// // // // //                                 ),
// // // // //                               ],
// // // // //                             ),
// // // // //                             backgroundColor: AppColors.primaryColor,
// // // // //                             duration: const Duration(seconds: 2),
// // // // //                             behavior: SnackBarBehavior.floating,
// // // // //                             shape: RoundedRectangleBorder(
// // // // //                               borderRadius: BorderRadius.circular(10),
// // // // //                             ),
// // // // //                           ),
// // // // //                         );
// // // // //                         Navigator.pop(context);
// // // // //                       },
// // // // //                     ),
// // // // //                     if (!allQuestionsAnswered && viewModel.questions.isNotEmpty)
// // // // //                       const Padding(
// // // // //                         padding: EdgeInsets.only(bottom: 8.0),
// // // // //                         child: Text(
// // // // //                           'Please answer all questions before submitting',
// // // // //                           style: TextStyle(
// // // // //                             color: Colors.red,
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                           ),
// // // // //                         ),
// // // // //                       ),
// // // // //                     Container(
// // // // //                       height: 80,
// // // // //                       padding: const EdgeInsets.symmetric(vertical: 10),
// // // // //                       color: Colors.grey.shade200,
// // // // //                       child: viewModel.questions.isEmpty
// // // // //                           ? const Center(
// // // // //                               child: Text(
// // // // //                                 'No questions yet',
// // // // //                                 style: TextStyle(color: Colors.grey),
// // // // //                               ),
// // // // //                             )
// // // // //                           : ListView.builder(
// // // // //                               scrollDirection: Axis.horizontal,
// // // // //                               itemCount: viewModel.questions.length,
// // // // //                               itemBuilder: (context, index) {
// // // // //                                 bool isAnswered =
// // // // //                                     viewModel.isQuestionAnswered(index);
// // // // //                                 return QuestionCard(
// // // // //                                   role: 'Student',
// // // // //                                   index: index,
// // // // //                                   isSelected:
// // // // //                                       viewModel.currentQuestionIndex == index,
// // // // //                                   isAnswered: isAnswered,
// // // // //                                   onTap: () {
// // // // //                                     viewModel.selectQuestion(index);
// // // // //                                   },
// // // // //                                   onDelete: () {},
// // // // //                                 );
// // // // //                               },
// // // // //                             ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //               );
// // // // //             },
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // // import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
// // // // import 'package:attendance_app/features/questionnaire/presentation/viewmodels/student_questionnaire_viewmode.dart';
// // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_card.dart';
// // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_content.dart';
// // // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/submit_button.dart';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:provider/provider.dart';

// // // // class StudentQuestionnaireView extends StatelessWidget {
// // // //   final String questionnaireId;
// // // //   final String courseId;
// // // //   final VoidCallback onSubmit;

// // // //   const StudentQuestionnaireView({
// // // //     Key? key,
// // // //     required this.questionnaireId,
// // // //     required this.courseId,
// // // //     required this.onSubmit,
// // // //   }) : super(key: key);

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final user = FirebaseAuth.instance.currentUser;
// // // //     if (user == null) {
// // // //       return const Scaffold(
// // // //         body: Center(child: Text('User not logged in')),
// // // //       );
// // // //     }

// // // //     return FutureBuilder<DocumentSnapshot>(
// // // //       future: FirebaseFirestore.instance
// // // //           .collection('Courses')
// // // //           .doc(courseId)
// // // //           .collection('questionnaires')
// // // //           .doc(questionnaireId)
// // // //           .collection('filledBy')
// // // //           .doc(user.uid)
// // // //           .get(),
// // // //       builder: (context, snapshot) {
// // // //         if (snapshot.connectionState == ConnectionState.waiting) {
// // // //           return const Scaffold(
// // // //             body: Center(
// // // //               child: CircularProgressIndicator(
// // // //                 color: AppColors.primaryColor,
// // // //               ),
// // // //             ),
// // // //           );
// // // //         }

// // // //         if (snapshot.hasError) {
// // // //           return const Scaffold(
// // // //             body: Center(child: Text('Error loading questionnaire')),
// // // //           );
// // // //         }

// // // //         bool isCompleted = snapshot.data?.exists ?? false;

// // // //         if (isCompleted) {
// // // //           return Scaffold(
// // // //             appBar: AppBar(
// // // //               iconTheme: const IconThemeData(color: Colors.white),
// // // //               title: const Text(
// // // //                 'Answer Questionnaire',
// // // //                 style: TextStyle(
// // // //                   color: Colors.white,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //               ),
// // // //               backgroundColor: AppColors.primaryColor,
// // // //             ),
// // // //             body: const Center(
// // // //               child: Text(
// // // //                 'You have already submitted this questionnaire.',
// // // //                 style: TextStyle(fontSize: 18, color: Colors.grey),
// // // //                 textAlign: TextAlign.center,
// // // //               ),
// // // //             ),
// // // //           );
// // // //         }

// // // //         return ChangeNotifierProvider(
// // // //           create: (_) {
// // // //             final viewModel = StudentQuestionnaireViewmodel();
// // // //             FirebaseFirestore.instance
// // // //                 .collection('Courses')
// // // //                 .doc(courseId)
// // // //                 .collection('questionnaires')
// // // //                 .doc(questionnaireId)
// // // //                 .get()
// // // //                 .then((doc) {
// // // //               if (doc.exists) {
// // // //                 final data = doc.data() as Map<String, dynamic>;
// // // //                 final questions = (data['questions'] as List)
// // // //                     .map((q) => QuestionModel.fromMap(q))
// // // //                     .toList();
// // // //                 viewModel.initializeQuestions(
// // // //                     questions.map((q) => q.toMap()).toList());
// // // //               }
// // // //             });
// // // //             return viewModel;
// // // //           },
// // // //           child: Consumer<StudentQuestionnaireViewmodel>(
// // // //             builder: (context, viewModel, child) {
// // // //               bool allQuestionsAnswered = viewModel.areAllQuestionsAnswered();

// // // //               return Scaffold(
// // // //                 appBar: AppBar(
// // // //                   iconTheme: const IconThemeData(color: Colors.white),
// // // //                   title: const Text(
// // // //                     'Answer Questionnaire',
// // // //                     style: TextStyle(
// // // //                       color: Colors.white,
// // // //                       fontWeight: FontWeight.bold,
// // // //                     ),
// // // //                   ),
// // // //                   backgroundColor: AppColors.primaryColor,
// // // //                 ),
// // // //                 body: Column(
// // // //                   children: [
// // // //                     Expanded(
// // // //                       child: SingleChildScrollView(
// // // //                         child: viewModel.questions.isEmpty
// // // //                             ? const Center(
// // // //                                 child: Text(
// // // //                                   'No questions available in this questionnaire.',
// // // //                                   style: TextStyle(
// // // //                                     fontSize: 18,
// // // //                                     color: Colors.grey,
// // // //                                   ),
// // // //                                 ),
// // // //                               )
// // // //                             : QuestionContent(
// // // //                                 question: viewModel.currentQuestion,
// // // //                                 onAnswerSelected: (answer) {
// // // //                                   viewModel.setAnswer(
// // // //                                       viewModel.currentQuestionIndex, answer);
// // // //                                 },
// // // //                                 selectedAnswer: viewModel
// // // //                                     .getAnswer(viewModel.currentQuestionIndex),
// // // //                               ),
// // // //                       ),
// // // //                     ),
// // // //                     SubmitButton(
// // // //                       viewModel: viewModel,
// // // //                       allQuestionsAnswered: allQuestionsAnswered,
// // // //                       onSubmit: () async {
// // // //                         await viewModel.markAsCompleted(
// // // //                             courseId, questionnaireId);
// // // //                         onSubmit();
// // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // //                           SnackBar(
// // // //                             content: const Row(
// // // //                               children: [
// // // //                                 Icon(Icons.check_circle, color: Colors.green),
// // // //                                 SizedBox(width: 10),
// // // //                                 Text(
// // // //                                   'Answers submitted successfully!',
// // // //                                   style: TextStyle(color: Colors.white),
// // // //                                 ),
// // // //                               ],
// // // //                             ),
// // // //                             backgroundColor: AppColors.primaryColor,
// // // //                             duration: const Duration(seconds: 2),
// // // //                             behavior: SnackBarBehavior.floating,
// // // //                             shape: RoundedRectangleBorder(
// // // //                               borderRadius: BorderRadius.circular(10),
// // // //                             ),
// // // //                           ),
// // // //                         );
// // // //                         Navigator.pop(context);
// // // //                       },
// // // //                     ),
// // // //                     if (!allQuestionsAnswered && viewModel.questions.isNotEmpty)
// // // //                       const Padding(
// // // //                         padding: EdgeInsets.only(bottom: 8.0),
// // // //                         child: Text(
// // // //                           'Please answer all questions before submitting',
// // // //                           style: TextStyle(
// // // //                             color: Colors.red,
// // // //                             fontWeight: FontWeight.bold,
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                     Container(
// // // //                       height: 80,
// // // //                       padding: const EdgeInsets.symmetric(vertical: 10),
// // // //                       color: Colors.grey.shade200,
// // // //                       child: viewModel.questions.isEmpty
// // // //                           ? const Center(
// // // //                               child: Text(
// // // //                                 'No questions yet',
// // // //                                 style: TextStyle(color: Colors.grey),
// // // //                               ),
// // // //                             )
// // // //                           : ListView.builder(
// // // //                               scrollDirection: Axis.horizontal,
// // // //                               itemCount: viewModel.questions.length,
// // // //                               itemBuilder: (context, index) {
// // // //                                 bool isAnswered =
// // // //                                     viewModel.isQuestionAnswered(index);
// // // //                                 return QuestionCard(
// // // //                                   role: 'Student',
// // // //                                   index: index,
// // // //                                   isSelected:
// // // //                                       viewModel.currentQuestionIndex == index,
// // // //                                   isAnswered: isAnswered,
// // // //                                   onTap: () {
// // // //                                     viewModel.selectQuestion(index);
// // // //                                   },
// // // //                                   onDelete: () {},
// // // //                                 );
// // // //                               },
// // // //                             ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               );
// // // //             },
// // // //           ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }
// // // // }

// // // import 'package:attendance_app/core/utils/app_colors.dart';
// // // import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
// // // import 'package:attendance_app/features/questionnaire/presentation/viewmodels/student_questionnaire_viewmode.dart';
// // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_card.dart';
// // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_content.dart';
// // // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/submit_button.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import '../viewmodels/home_questionnaires_viewmodel.dart'; // أضف هذا الاستيراد

// // // class StudentQuestionnaireView extends StatelessWidget {
// // //   final String questionnaireId;
// // //   final String courseId;
// // //   final VoidCallback onSubmit;

// // //   const StudentQuestionnaireView({
// // //     Key? key,
// // //     required this.questionnaireId,
// // //     required this.courseId,
// // //     required this.onSubmit,
// // //   }) : super(key: key);

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final user = FirebaseAuth.instance.currentUser;
// // //     if (user == null) {
// // //       return const Scaffold(
// // //         body: Center(child: Text('User not logged in')),
// // //       );
// // //     }

// // //     return FutureBuilder<DocumentSnapshot>(
// // //       future: FirebaseFirestore.instance
// // //           .collection('Courses')
// // //           .doc(courseId)
// // //           .collection('questionnaires')
// // //           .doc(questionnaireId)
// // //           .collection('filledBy')
// // //           .doc(user.uid)
// // //           .get(),
// // //       builder: (context, snapshot) {
// // //         if (snapshot.connectionState == ConnectionState.waiting) {
// // //           return const Scaffold(
// // //             body: Center(
// // //               child: CircularProgressIndicator(
// // //                 color: AppColors.primaryColor,
// // //               ),
// // //             ),
// // //           );
// // //         }

// // //         if (snapshot.hasError) {
// // //           return const Scaffold(
// // //             body: Center(child: Text('Error loading questionnaire')),
// // //           );
// // //         }

// // //         bool isCompleted = snapshot.data?.exists ?? false;

// // //         if (isCompleted) {
// // //           return Scaffold(
// // //             appBar: AppBar(
// // //               iconTheme: const IconThemeData(color: Colors.white),
// // //               title: const Text(
// // //                 'Answer Questionnaire',
// // //                 style: TextStyle(
// // //                   color: Colors.white,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //               backgroundColor: AppColors.primaryColor,
// // //             ),
// // //             body: const Center(
// // //               child: Text(
// // //                 'You have already submitted this questionnaire.',
// // //                 style: TextStyle(fontSize: 18, color: Colors.grey),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //             ),
// // //           );
// // //         }

// // //         return ChangeNotifierProvider(
// // //           create: (_) {
// // //             final viewModel = StudentQuestionnaireViewmodel();
// // //             FirebaseFirestore.instance
// // //                 .collection('Courses')
// // //                 .doc(courseId)
// // //                 .collection('questionnaires')
// // //                 .doc(questionnaireId)
// // //                 .get()
// // //                 .then((doc) {
// // //               if (doc.exists) {
// // //                 final data = doc.data() as Map<String, dynamic>;
// // //                 final questions = (data['questions'] as List)
// // //                     .map((q) => QuestionModel.fromMap(q))
// // //                     .toList();
// // //                 viewModel.initializeQuestions(
// // //                     questions.map((q) => q.toMap()).toList());
// // //               }
// // //             });
// // //             return viewModel;
// // //           },
// // //           child: Consumer<StudentQuestionnaireViewmodel>(
// // //             builder: (context, viewModel, child) {
// // //               bool allQuestionsAnswered = viewModel.areAllQuestionsAnswered();

// // //               return Scaffold(
// // //                 appBar: AppBar(
// // //                   iconTheme: const IconThemeData(color: Colors.white),
// // //                   title: const Text(
// // //                     'Answer Questionnaire',
// // //                     style: TextStyle(
// // //                       color: Colors.white,
// // //                       fontWeight: FontWeight.bold,
// // //                     ),
// // //                   ),
// // //                   backgroundColor: AppColors.primaryColor,
// // //                 ),
// // //                 body: Column(
// // //                   children: [
// // //                     Expanded(
// // //                       child: SingleChildScrollView(
// // //                         child: viewModel.questions.isEmpty
// // //                             ? const Center(
// // //                                 child: Text(
// // //                                   'No questions available in this questionnaire.',
// // //                                   style: TextStyle(
// // //                                     fontSize: 18,
// // //                                     color: Colors.grey,
// // //                                   ),
// // //                                 ),
// // //                               )
// // //                             : QuestionContent(
// // //                                 question: viewModel.currentQuestion,
// // //                                 onAnswerSelected: (answer) {
// // //                                   viewModel.setAnswer(
// // //                                       viewModel.currentQuestionIndex, answer);
// // //                                 },
// // //                                 selectedAnswer: viewModel
// // //                                     .getAnswer(viewModel.currentQuestionIndex),
// // //                               ),
// // //                       ),
// // //                     ),
// // //                     SubmitButton(
// // //                       viewModel: viewModel,
// // //                       allQuestionsAnswered: allQuestionsAnswered,
// // //                       onSubmit: () async {
// // //                         await viewModel.markAsCompleted(
// // //                             courseId, questionnaireId);
// // //                         // استدعاء تحديث حالة الإكمال في HomeQuestionnairesViewModel
// // //                         Provider.of<HomeQuestionnairesViewModel>(context,
// // //                                 listen: false)
// // //                             .markQuestionnaireAsCompleted(questionnaireId);
// // //                         onSubmit();
// // //                         ScaffoldMessenger.of(context).showSnackBar(
// // //                           SnackBar(
// // //                             content: const Row(
// // //                               children: [
// // //                                 Icon(Icons.check_circle, color: Colors.green),
// // //                                 SizedBox(width: 10),
// // //                                 Text(
// // //                                   'Answers submitted successfully!',
// // //                                   style: TextStyle(color: Colors.white),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                             backgroundColor: AppColors.primaryColor,
// // //                             duration: const Duration(seconds: 2),
// // //                             behavior: SnackBarBehavior.floating,
// // //                             shape: RoundedRectangleBorder(
// // //                               borderRadius: BorderRadius.circular(10),
// // //                             ),
// // //                           ),
// // //                         );
// // //                         Navigator.pop(context);
// // //                       },
// // //                     ),
// // //                     if (!allQuestionsAnswered && viewModel.questions.isNotEmpty)
// // //                       const Padding(
// // //                         padding: EdgeInsets.only(bottom: 8.0),
// // //                         child: Text(
// // //                           'Please answer all questions before submitting',
// // //                           style: TextStyle(
// // //                             color: Colors.red,
// // //                             fontWeight: FontWeight.bold,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     Container(
// // //                       height: 80,
// // //                       padding: const EdgeInsets.symmetric(vertical: 10),
// // //                       color: Colors.grey.shade200,
// // //                       child: viewModel.questions.isEmpty
// // //                           ? const Center(
// // //                               child: Text(
// // //                                 'No questions yet',
// // //                                 style: TextStyle(color: Colors.grey),
// // //                               ),
// // //                             )
// // //                           : ListView.builder(
// // //                               scrollDirection: Axis.horizontal,
// // //                               itemCount: viewModel.questions.length,
// // //                               itemBuilder: (context, index) {
// // //                                 bool isAnswered =
// // //                                     viewModel.isQuestionAnswered(index);
// // //                                 return QuestionCard(
// // //                                   role: 'Student',
// // //                                   index: index,
// // //                                   isSelected:
// // //                                       viewModel.currentQuestionIndex == index,
// // //                                   isAnswered: isAnswered,
// // //                                   onTap: () {
// // //                                     viewModel.selectQuestion(index);
// // //                                   },
// // //                                   onDelete: () {},
// // //                                 );
// // //                               },
// // //                             ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               );
// // //             },
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }

// // import 'package:attendance_app/core/utils/app_colors.dart';
// // import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
// // import 'package:attendance_app/features/questionnaire/presentation/viewmodels/student_questionnaire_viewmode.dart';
// // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_card.dart';
// // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_content.dart';
// // import 'package:attendance_app/features/questionnaire/presentation/views/widgets/submit_button.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../viewmodels/home_questionnaires_viewmodel.dart';

// // class StudentQuestionnaireView extends StatelessWidget {
// //   final String questionnaireId;
// //   final String courseId;
// //   final VoidCallback onSubmit;
// //   final HomeQuestionnairesViewModel? homeViewModel; // أضف هذا المعامل

// //   const StudentQuestionnaireView({
// //     Key? key,
// //     required this.questionnaireId,
// //     required this.courseId,
// //     required this.onSubmit,
// //     this.homeViewModel,
// //   }) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user == null) {
// //       return const Scaffold(
// //         body: Center(child: Text('User not logged in')),
// //       );
// //     }

// //     return FutureBuilder<DocumentSnapshot>(
// //       future: FirebaseFirestore.instance
// //           .collection('Courses')
// //           .doc(courseId)
// //           .collection('questionnaires')
// //           .doc(questionnaireId)
// //           .collection('filledBy')
// //           .doc(user.uid)
// //           .get(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(
// //               child: CircularProgressIndicator(
// //                 color: AppColors.primaryColor,
// //               ),
// //             ),
// //           );
// //         }

// //         if (snapshot.hasError) {
// //           return const Scaffold(
// //             body: Center(child: Text('Error loading questionnaire')),
// //           );
// //         }

// //         bool isCompleted = snapshot.data?.exists ?? false;

// //         if (isCompleted) {
// //           return Scaffold(
// //             appBar: AppBar(
// //               iconTheme: const IconThemeData(color: Colors.white),
// //               title: const Text(
// //                 'Answer Questionnaire',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               backgroundColor: AppColors.primaryColor,
// //             ),
// //             body: const Center(
// //               child: Text(
// //                 'You have already submitted this questionnaire.',
// //                 style: TextStyle(fontSize: 18, color: Colors.grey),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ),
// //           );
// //         }

// //         return ChangeNotifierProvider(
// //           create: (_) {
// //             final viewModel = StudentQuestionnaireViewmodel();
// //             FirebaseFirestore.instance
// //                 .collection('Courses')
// //                 .doc(courseId)
// //                 .collection('questionnaires')
// //                 .doc(questionnaireId)
// //                 .get()
// //                 .then((doc) {
// //               if (doc.exists) {
// //                 final data = doc.data() as Map<String, dynamic>;
// //                 final questions = (data['questions'] as List)
// //                     .map((q) => QuestionModel.fromMap(q))
// //                     .toList();
// //                 viewModel.initializeQuestions(
// //                     questions.map((q) => q.toMap()).toList());
// //               }
// //             });
// //             return viewModel;
// //           },
// //           child: Consumer<StudentQuestionnaireViewmodel>(
// //             builder: (context, viewModel, child) {
// //               bool allQuestionsAnswered = viewModel.areAllQuestionsAnswered();

// //               return Scaffold(
// //                 appBar: AppBar(
// //                   iconTheme: const IconThemeData(color: Colors.white),
// //                   title: const Text(
// //                     'Answer Questionnaire',
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   backgroundColor: AppColors.primaryColor,
// //                 ),
// //                 body: Column(
// //                   children: [
// //                     Expanded(
// //                       child: SingleChildScrollView(
// //                         child: viewModel.questions.isEmpty
// //                             ? const Center(
// //                                 child: Text(
// //                                   'No questions available in this questionnaire.',
// //                                   style: TextStyle(
// //                                     fontSize: 18,
// //                                     color: Colors.grey,
// //                                   ),
// //                                 ),
// //                               )
// //                             : QuestionContent(
// //                                 question: viewModel.currentQuestion,
// //                                 onAnswerSelected: (answer) {
// //                                   viewModel.setAnswer(
// //                                       viewModel.currentQuestionIndex, answer);
// //                                 },
// //                                 selectedAnswer: viewModel
// //                                     .getAnswer(viewModel.currentQuestionIndex),
// //                               ),
// //                       ),
// //                     ),
// //                     SubmitButton(
// //                       viewModel: viewModel,
// //                       allQuestionsAnswered: allQuestionsAnswered,
// //                       onSubmit: () async {
// //                         await viewModel.markAsCompleted(
// //                             courseId, questionnaireId);
// //                         // استخدم homeViewModel بدل Provider.of
// //                         homeViewModel
// //                             ?.markQuestionnaireAsCompleted(questionnaireId);
// //                         onSubmit();
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           SnackBar(
// //                             content: const Row(
// //                               children: [
// //                                 Icon(Icons.check_circle, color: Colors.green),
// //                                 SizedBox(width: 10),
// //                                 Text(
// //                                   'Answers submitted successfully!',
// //                                   style: TextStyle(color: Colors.white),
// //                                 ),
// //                               ],
// //                             ),
// //                             backgroundColor: AppColors.primaryColor,
// //                             duration: const Duration(seconds: 2),
// //                             behavior: SnackBarBehavior.floating,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                           ),
// //                         );
// //                         Navigator.pop(context);
// //                       },
// //                     ),
// //                     if (!allQuestionsAnswered && viewModel.questions.isNotEmpty)
// //                       const Padding(
// //                         padding: EdgeInsets.only(bottom: 8.0),
// //                         child: Text(
// //                           'Please answer all questions before submitting',
// //                           style: TextStyle(
// //                             color: Colors.red,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     Container(
// //                       height: 80,
// //                       padding: const EdgeInsets.symmetric(vertical: 10),
// //                       color: Colors.grey.shade200,
// //                       child: viewModel.questions.isEmpty
// //                           ? const Center(
// //                               child: Text(
// //                                 'No questions yet',
// //                                 style: TextStyle(color: Colors.grey),
// //                               ),
// //                             )
// //                           : ListView.builder(
// //                               scrollDirection: Axis.horizontal,
// //                               itemCount: viewModel.questions.length,
// //                               itemBuilder: (context, index) {
// //                                 bool isAnswered =
// //                                     viewModel.isQuestionAnswered(index);
// //                                 return QuestionCard(
// //                                   role: 'Student',
// //                                   index: index,
// //                                   isSelected:
// //                                       viewModel.currentQuestionIndex == index,
// //                                   isAnswered: isAnswered,
// //                                   onTap: () {
// //                                     viewModel.selectQuestion(index);
// //                                   },
// //                                   onDelete: () {},
// //                                 );
// //                               },
// //                             ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
// import 'package:attendance_app/features/questionnaire/presentation/viewmodels/student_questionnaire_viewmode.dart';
// import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_card.dart';
// import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_content.dart';
// import 'package:attendance_app/features/questionnaire/presentation/views/widgets/submit_button.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../viewmodels/home_questionnaires_viewmodel.dart';

// class StudentQuestionnaireView extends StatelessWidget {
//   final String questionnaireId;
//   final String courseId;
//   final VoidCallback onSubmit;
//   final HomeQuestionnairesViewModel? homeViewModel;

//   const StudentQuestionnaireView({
//     Key? key,
//     required this.questionnaireId,
//     required this.courseId,
//     required this.onSubmit,
//     this.homeViewModel,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text('User not logged in')),
//       );
//     }

//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('Courses')
//           .doc(courseId)
//           .collection('questionnaires')
//           .doc(questionnaireId)
//           .get(),
//       builder: (context, questionnaireSnapshot) {
//         if (questionnaireSnapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.primaryColor,
//               ),
//             ),
//           );
//         }
//         if (questionnaireSnapshot.hasError) {
//           return const Scaffold(
//             body: Center(child: Text('Error loading questionnaire')),
//           );
//         }
//         if (!questionnaireSnapshot.hasData || !questionnaireSnapshot.data!.exists) {
//           return const Scaffold(
//             body: Center(child: Text('Questionnaire not found')),
//           );
//         }

//         final questionnaireData =
//             questionnaireSnapshot.data!.data() as Map<String, dynamic>;
//         final currentVersion = questionnaireData['version'] as int? ?? 1;

//         return FutureBuilder<DocumentSnapshot>(
//           future: FirebaseFirestore.instance
//               .collection('Courses')
//               .doc(courseId)
//               .collection('questionnaires')
//               .doc(questionnaireId)
//               .collection('filledBy')
//               .doc(user.uid)
//               .get(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(
//                   child: CircularProgressIndicator(
//                     color: AppColors.primaryColor,
//                   ),
//                 ),
//               );
//             }
//             if (snapshot.hasError) {
//               return const Scaffold(
//                 body: Center(child: Text('Error loading questionnaire')),
//               );
//             }

//             bool isCompleted = snapshot.data?.exists ?? false;
//             bool isModified = false;

//             if (isCompleted) {
//               final filledData = snapshot.data!.data() as Map<String, dynamic>;
//               final completedVersion = filledData['completedVersion'] as int? ?? 1;
//               isModified = completedVersion < currentVersion;
//               isCompleted = completedVersion >= currentVersion;
//             }

//             if (isCompleted && !isModified) {
//               return Scaffold(
//                 appBar: AppBar(
//                   iconTheme: const IconThemeData(color: Colors.white),
//                   title: const Text(
//                     'Answer Questionnaire',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   backgroundColor: AppColors.primaryColor,
//                 ),
//                 body: const Center(
//                   child: Text(
//                     'You have already submitted this questionnaire.',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               );
//             }

//             return ChangeNotifierProvider(
//               create: (_) {
//                 final viewModel = StudentQuestionnaireViewmodel();
//                 FirebaseFirestore.instance
//                     .collection('Courses')
//                     .doc(courseId)
//                     .collection('questionnaires')
//                     .doc(questionnaireId)
//                     .get()
//                     .then((doc) {
//                   if (doc.exists) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final questions = (data['questions'] as List)
//                         .map((q) => QuestionModel.fromMap(q))
//                         .toList();
//                     viewModel.initializeQuestions(
//                         questions.map((q) => q.toMap()).toList());
//                   }
//                 });
//                 return viewModel;
//               },
//               child: Consumer<StudentQuestionnaireViewmodel>(
//                 builder: (context, viewModel, child) {
//                   bool allQuestionsAnswered = viewModel.areAllQuestionsAnswered();

//                   return Scaffold(
//                     appBar: AppBar(
//                       iconTheme: const IconThemeData(color: Colors.white),
//                       title: const Text(
//                         'Answer Questionnaire',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       backgroundColor: AppColors.primaryColor,
//                     ),
//                     body: Column(
//                       children: [
//                         if (isModified)
//                           const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text(
//                               'This questionnaire has been updated. Please submit your answers again.',
//                               style: TextStyle(
//                                 color: Colors.orange,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         Expanded(
//                           child: SingleChildScrollView(
//                             child: viewModel.questions.isEmpty
//                                 ? const Center(
//                                     child: Text(
//                                       'No questions available in this questionnaire.',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   )
//                                 : QuestionContent(
//                                     question: viewModel.currentQuestion,
//                                     onAnswerSelected: (answer) {
//                                       viewModel.setAnswer(
//                                           viewModel.currentQuestionIndex, answer);
//                                     },
//                                     selectedAnswer: viewModel
//                                         .getAnswer(viewModel.currentQuestionIndex),
//                                   ),
//                           ),
//                         ),
//                         SubmitButton(
//                           viewModel: viewModel,
//                           allQuestionsAnswered: allQuestionsAnswered,
//                           onSubmit: () async {
//                             await viewModel.markAsCompleted(
//                                 courseId, questionnaireId);
//                             homeViewModel?.markQuestionnaireAsCompleted(
//                                 questionnaireId);
//                             onSubmit();
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: const Row(
//                                   children: [
//                                     Icon(Icons.check_circle, color: Colors.green),
//                                     SizedBox(width: 10),
//                                     Text(
//                                       'Answers submitted successfully!',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   ],
//                                 ),
//                                 backgroundColor: AppColors.primaryColor,
//                                 duration: const Duration(seconds: 2),
//                                 behavior: SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             );
//                             Navigator.pop(context);
//                           },
//                         ),
//                         if (!allQuestionsAnswered &&
//                             viewModel.questions.isNotEmpty)
//                           const Padding(
//                             padding: EdgeInsets.only(bottom: 8.0),
//                             child: Text(
//                               'Please answer all questions before submitting',
//                               style: TextStyle(
//                                 color: Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         Container(
//                           height: 80,
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           color: Colors.grey.shade200,
//                           child: viewModel.questions.isEmpty
//                               ? const Center(
//                                   child: Text(
//                                     'No questions yet',
//                                     style: TextStyle(color: Colors.grey),
//                                   ),
//                                 )
//                               : ListView.builder(
//                                   scrollDirection: Axis.horizontal,
//                                   itemCount: viewModel.questions.length,
//                                   itemBuilder: (context, index) {
//                                     bool isAnswered =
//                                         viewModel.isQuestionAnswered(index);
//                                     return QuestionCard(
//                                       role: 'Student',
//                                       index: index,
//                                       isSelected:
//                                           viewModel.currentQuestionIndex == index,
//                                       isAnswered: isAnswered,
//                                       onTap: () {
//                                         viewModel.selectQuestion(index);
//                                       },
//                                       onDelete: () {},
//                                     );
//                                   },
//                                 ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/questionnaire/data/models/question_model.dart';
import 'package:attendance_app/features/questionnaire/presentation/viewmodels/student_questionnaire_viewmode.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_card.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/widgets/question_content.dart';
import 'package:attendance_app/features/questionnaire/presentation/views/widgets/submit_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_questionnaires_viewmodel.dart';

class StudentQuestionnaireView extends StatelessWidget {
  final String questionnaireId;
  final String courseId;
  final VoidCallback onSubmit;
  final HomeQuestionnairesViewModel? homeViewModel;

  const StudentQuestionnaireView({
    super.key,
    required this.questionnaireId,
    required this.courseId,
    required this.onSubmit,
    this.homeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .collection('questionnaires')
          .doc(questionnaireId)
          .get(),
      builder: (context, questionnaireSnapshot) {
        if (questionnaireSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          );
        }
        if (questionnaireSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading questionnaire')),
          );
        }
        if (!questionnaireSnapshot.hasData ||
            !questionnaireSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Questionnaire not found')),
          );
        }

        final questionnaireData =
            questionnaireSnapshot.data!.data() as Map<String, dynamic>;
        final currentVersion = questionnaireData['version'] as int? ?? 1;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Courses')
              .doc(courseId)
              .collection('questionnaires')
              .doc(questionnaireId)
              .collection('filledBy')
              .doc(user.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Error loading questionnaire')),
              );
            }

            bool isCompleted = snapshot.data?.exists ?? false;
            bool isModified = false;

            if (isCompleted) {
              final filledData = snapshot.data!.data() as Map<String, dynamic>;
              final completedVersion =
                  filledData['completedVersion'] as int? ?? 1;
              isModified = completedVersion < currentVersion;
              isCompleted = completedVersion >= currentVersion;
            }

            if (isCompleted && !isModified) {
              return Scaffold(
                appBar: AppBar(
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Text(
                    'Answer Questionnaire',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.primaryColor,
                ),
                body: const Center(
                  child: Text(
                    'You have already submitted this questionnaire.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ChangeNotifierProvider(
              create: (_) {
                final viewModel = StudentQuestionnaireViewmodel();
                FirebaseFirestore.instance
                    .collection('Courses')
                    .doc(courseId)
                    .collection('questionnaires')
                    .doc(questionnaireId)
                    .get()
                    .then((doc) {
                  if (doc.exists) {
                    final data = doc.data() as Map<String, dynamic>;
                    final questions = (data['questions'] as List)
                        .map((q) => QuestionModel.fromMap(q))
                        .toList();
                    viewModel.initializeQuestions(questions);
                  }
                });
                return viewModel;
              },
              child: Consumer<StudentQuestionnaireViewmodel>(
                builder: (context, viewModel, child) {
                  bool allQuestionsAnswered =
                      viewModel.areAllQuestionsAnswered();

                  return Scaffold(
                    appBar: AppBar(
                      iconTheme: const IconThemeData(color: Colors.white),
                      title: const Text(
                        'Answer Questionnaire',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    body: Column(
                      children: [
                        if (isModified)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'This questionnaire has been updated. Please submit your answers again.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: viewModel.questions.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No questions available in this questionnaire.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : QuestionContent(
                                    question: viewModel.currentQuestion,
                                    onAnswerSelected: (answer) {
                                      viewModel.setAnswer(
                                          viewModel.currentQuestionIndex,
                                          answer);
                                    },
                                    selectedAnswer: viewModel.getAnswer(
                                        viewModel.currentQuestionIndex),
                                  ),
                          ),
                        ),
                        SubmitButton(
                          viewModel: viewModel,
                          allQuestionsAnswered: allQuestionsAnswered,
                          onSubmit: () async {
                            await viewModel.markAsCompleted(
                                courseId, questionnaireId);
                            homeViewModel
                                ?.markQuestionnaireAsCompleted(questionnaireId);
                            onSubmit();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green),
                                    SizedBox(width: 10),
                                    Text(
                                      'Answers submitted successfully!',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.primaryColor,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          },
                        ),
                        if (!allQuestionsAnswered &&
                            viewModel.questions.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Please answer all questions before submitting',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.grey.shade200,
                          child: viewModel.questions.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No questions yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: viewModel.questions.length,
                                  itemBuilder: (context, index) {
                                    bool isAnswered =
                                        viewModel.isQuestionAnswered(index);
                                    return QuestionCard(
                                      role: 'Student',
                                      index: index,
                                      isSelected:
                                          viewModel.currentQuestionIndex ==
                                              index,
                                      isAnswered: isAnswered,
                                      onTap: () {
                                        viewModel.selectQuestion(index);
                                      },
                                      onDelete: () {},
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
