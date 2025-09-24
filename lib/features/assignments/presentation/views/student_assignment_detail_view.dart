// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/assignments/data/models/question_model_student.dart';
// import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignment_detail_viewmodel.dart';
// import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignments_viewmodel.dart';
// import 'file_preview_view.dart';

// class StudentAssignmentDetailView extends StatefulWidget {
//   final String courseId;
//   final String assignmentId;
//   final String assignmentTitle;

//   const StudentAssignmentDetailView({
//     super.key,
//     required this.courseId,
//     required this.assignmentId,
//     required this.assignmentTitle,
//   });

//   @override
//   State<StudentAssignmentDetailView> createState() =>
//       _StudentAssignmentDetailViewState();
// }

// class _StudentAssignmentDetailViewState
//     extends State<StudentAssignmentDetailView> {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => StudentAssignmentDetailViewModel(
//         courseId: widget.courseId,
//         assignmentId: widget.assignmentId,
//       ),
//       child: Consumer<StudentAssignmentDetailViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.successMessage.isNotEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(viewModel.successMessage),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//               viewModel.clearMessages();
//             });
//           }

//           if (viewModel.errorMessage.isNotEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(viewModel.errorMessage),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//               viewModel.clearMessages();
//             });
//           }

//           return Scaffold(
//             backgroundColor: const Color(0xFFF0F7FF),
//             appBar: AppBar(
//               title: Text(
//                 widget.assignmentTitle,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Colors.white,
//                 ),
//               ),
//               backgroundColor: AppColors.primaryColor,
//               elevation: 0,
//               centerTitle: true,
//             ),
//             body: viewModel.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : viewModel.questions.isEmpty
//                     ? const Center(
//                         child: Text('No questions in this assignment'))
//                     : _buildQuestionPage(context, viewModel),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildQuestionPage(
//       BuildContext context, StudentAssignmentDetailViewModel viewModel) {
//     final currentQuestion = viewModel.currentQuestion;
//     if (currentQuestion == null) {
//       return const Center(child: Text('Error loading question'));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           key: ValueKey('question_${viewModel.currentQuestionIndex}'),
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(bottom: 8),
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Text(
//                     'Question ${viewModel.currentQuestionIndex + 1} of ${viewModel.questions.length}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                   const Spacer(),
//                   if (!viewModel.allQuestionsAnswered)
//                     const Text(
//                       'Please answer all questions',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.orange,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//               child: Text(
//                 currentQuestion.question,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             if (currentQuestion.type == 'Upload File' &&
//                 currentQuestion.fileUrl != null &&
//                 currentQuestion.fileUrl!.isNotEmpty)
//               Container(
//                 margin: const EdgeInsets.only(bottom: 24),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Question Attachment',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         _getFileIcon(
//                             currentQuestion.fileName ?? '', Colors.blue),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 currentQuestion.fileName ?? 'File',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 15,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               if (currentQuestion.fileSize != null)
//                                 Text(
//                                   _formatFileSize(currentQuestion.fileSize!),
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           icon:
//                               const Icon(Icons.visibility, color: Colors.blue),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => FilePreviewView(
//                                   fileUrl: currentQuestion.fileUrl!,
//                                   firebaseFileName: currentQuestion.fileName,
//                                   fileSize: currentQuestion.fileSize,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             _buildQuestionResponseWidget(currentQuestion, viewModel),
//             Column(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: viewModel.allQuestionsAnswered &&
//                             !viewModel.isSubmitting
//                         ? () async {
//                             final success = await viewModel.submitAssignment();
//                             if (success && context.mounted) {
//                               try {
//                                 final parentViewModel =
//                                     Provider.of<StudentAssignmentsViewModel>(
//                                         context,
//                                         listen: false);
//                                 await parentViewModel.refreshAssignments();
//                               } catch (e) {
//                                 print("Could not refresh assignments list: $e");
//                               }

//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                       'Assignment submitted successfully!'),
//                                   backgroundColor: Colors.green,
//                                   duration: Duration(seconds: 2),
//                                 ),
//                               );

//                               Navigator.pop(context);
//                             }
//                           }
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: viewModel.allQuestionsAnswered
//                           ? AppColors.primaryColor
//                           : const Color(0xFFBDBDBD),
//                       disabledBackgroundColor: const Color(0xFFBDBDBD),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: viewModel.isSubmitting
//                         ? const CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           )
//                         : const Text(
//                             'Submit',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//                 if (!viewModel.allQuestionsAnswered)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 8.0),
//                     child: Center(
//                       child: Text(
//                         'Please answer all questions before submitting',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 45,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: viewModel.questions.length,
//                     itemBuilder: (context, index) {
//                       final question = viewModel.questions[index];
//                       final isActive = index == viewModel.currentQuestionIndex;
//                       final isAnswered = question.isQuestionAnswered();

//                       return GestureDetector(
//                         key: ValueKey(
//                             'q_indicator_${index}_${isAnswered}_$isActive'),
//                         onTap: () {
//                           viewModel.goToQuestion(index);
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 4),
//                           width: 100,
//                           decoration: BoxDecoration(
//                             color: isActive
//                                 ? AppColors.primaryColor
//                                 : (isAnswered
//                                     ? const Color(0xFFCDF1CD)
//                                     : Colors.white),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: isActive
//                                   ? AppColors.primaryColor
//                                   : isAnswered
//                                       ? const Color(0xFFCDF1CD)
//                                       : Colors.grey.shade300,
//                               width: 1,
//                             ),
//                           ),
//                           child: Stack(
//                             children: [
//                               Center(
//                                 child: Text(
//                                   'Question ${index + 1}',
//                                   style: TextStyle(
//                                     color:
//                                         isActive ? Colors.white : Colors.black,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               if (isAnswered)
//                                 const Positioned(
//                                   top: 1,
//                                   right: 1,
//                                   child: Icon(
//                                     Icons.check_circle,
//                                     color: Colors.green,
//                                     size: 18,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuestionResponseWidget(
//       StudentQuestion question, StudentAssignmentDetailViewModel viewModel) {
//     if (question.type == 'multiple_choice' || question.type == 'MCQ') {
//       return _buildMultipleChoiceOptions(question, viewModel);
//     } else if (question.type == 'true_false' || question.type == 'TrueFalse') {
//       return _buildTrueFalseOptions(question, viewModel);
//     } else if (question.type == 'Upload File') {
//       return _buildFileUpload(question, viewModel);
//     } else {
//       return Center(
//         child: Text(
//           'Unsupported question type: ${question.type}',
//           style: const TextStyle(color: Colors.red),
//         ),
//       );
//     }
//   }

//   Widget _buildMultipleChoiceOptions(
//       StudentQuestion question, StudentAssignmentDetailViewModel viewModel) {
//     return Column(
//       children: List.generate(question.options.length, (index) {
//         final bool isSelected = question.selectedOption == index;

//         return Container(
//           width: double.infinity,
//           margin: const EdgeInsets.only(bottom: 12),
//           child: InkWell(
//             onTap: () {
//               viewModel.updateSelectedOption(
//                   viewModel.currentQuestionIndex, index);
//               setState(() {});
//             },
//             borderRadius: BorderRadius.circular(24),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: isSelected ? AppColors.primaryColor : Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 2,
//                     spreadRadius: 0,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       question.options[index],
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: isSelected ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   ),
//                   if (isSelected)
//                     Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check,
//                         color: AppColors.primaryColor,
//                         size: 18,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildTrueFalseOptions(
//       StudentQuestion question, StudentAssignmentDetailViewModel viewModel) {
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           margin: const EdgeInsets.only(bottom: 12),
//           child: InkWell(
//             onTap: () {
//               viewModel.updateSelectedOption(viewModel.currentQuestionIndex, 0);
//               setState(() {});
//             },
//             borderRadius: BorderRadius.circular(24),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: question.selectedOption == 0
//                     ? AppColors.primaryColor
//                     : Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 2,
//                     spreadRadius: 0,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'True',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: question.selectedOption == 0
//                           ? Colors.white
//                           : Colors.black,
//                     ),
//                   ),
//                   if (question.selectedOption == 0)
//                     Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check,
//                         color: AppColors.primaryColor,
//                         size: 18,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Container(
//           width: double.infinity,
//           margin: const EdgeInsets.only(bottom: 12),
//           child: InkWell(
//             onTap: () {
//               viewModel.updateSelectedOption(viewModel.currentQuestionIndex, 1);
//               setState(() {});
//             },
//             borderRadius: BorderRadius.circular(24),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: question.selectedOption == 1
//                     ? AppColors.primaryColor
//                     : Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 2,
//                     spreadRadius: 0,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'False',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: question.selectedOption == 1
//                           ? Colors.white
//                           : Colors.black,
//                     ),
//                   ),
//                   if (question.selectedOption == 1)
//                     Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check,
//                         color: AppColors.primaryColor,
//                         size: 18,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFileUpload(
//       StudentQuestion question, StudentAssignmentDetailViewModel viewModel) {
//     // تحقق مما إذا كان هناك ملف مرفوع بالفعل
//     bool hasUploadedFile = question.uploadedFileUrl != null &&
//         question.uploadedFileUrl!.isNotEmpty;

//     // إنشاء متحكم للنص
//     final TextEditingController textController =
//         TextEditingController(text: question.textAnswer ?? '');

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // عنوان الإجابة
//         const Padding(
//           padding: EdgeInsets.only(left: 8, bottom: 16),
//           child: Text(
//             "Answer the question",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryColor,
//             ),
//           ),
//         ),

//         // Text input field
//         Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: TextField(
//             controller: textController,
//             maxLines: 3,
//             decoration: InputDecoration(
//               hintText: "Type your answer here...",
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: AppColors.primaryColor),
//               ),
//             ),
//             onChanged: (value) {
//               viewModel.updateTextAnswer(viewModel.currentQuestionIndex, value);
//             },
//           ),
//         ),

//         // File upload heading
//         const Padding(
//           padding: EdgeInsets.only(left: 8, bottom: 16),
//           child: Text(
//             "Or upload a file",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryColor,
//             ),
//           ),
//         ),

//         // عرض الملف المرفوع إذا وجد
//         if (hasUploadedFile)
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.green),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.green.withOpacity(0.1),
//                   blurRadius: 4,
//                   spreadRadius: 1,
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green),
//                     SizedBox(width: 8),
//                     Text(
//                       'Uploaded File',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     _getFileIcon(question.uploadedFileName ?? '', Colors.green),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             question.uploadedFileName ?? 'File uploaded',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 15,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.visibility, color: Colors.blue),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => FilePreviewView(
//                               fileUrl: question.uploadedFileUrl!,
//                               firebaseFileName: question.uploadedFileName,
//                               fileSize: null,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         viewModel
//                             .resetFileUpload(viewModel.currentQuestionIndex);
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           )
//         else
//           // واجهة رفع الملف
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 10),
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: viewModel.isUploading
//                 ? Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           width: 40,
//                           height: 40,
//                           child: CircularProgressIndicator(
//                             value: viewModel.uploadProgress,
//                             strokeWidth: 3,
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                                 AppColors.primaryColor),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           'Uploading... ${(viewModel.uploadProgress * 100).toStringAsFixed(0)}%',
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   )
//                 : InkWell(
//                     onTap: () async {
//                       await _pickFile(context, viewModel);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 40),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade200,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.cloud_upload,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             "Click to upload file",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "PDF, JPG, PNG, or document files",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//           ),
//       ],
//     );
//   }

//   Future<void> _pickFile(
//       BuildContext context, StudentAssignmentDetailViewModel viewModel) async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
//       );

//       if (result != null && result.files.single.path != null) {
//         PlatformFile file = result.files.single;
//         File fileToUpload = File(file.path!);
//         String fileName = file.name;

//         await viewModel.uploadFile(
//           viewModel.currentQuestionIndex,
//           fileToUpload,
//           fileName,
//         );
//       } else {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('No file selected'),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error picking file: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Widget _getFileIcon(String fileName, Color color) {
//     IconData iconData;

//     if (fileName.endsWith('.pdf')) {
//       iconData = Icons.picture_as_pdf;
//     } else if (fileName.endsWith('.jpg') ||
//         fileName.endsWith('.jpeg') ||
//         fileName.endsWith('.png')) {
//       iconData = Icons.image;
//     } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
//       iconData = Icons.description;
//     } else {
//       iconData = Icons.insert_drive_file;
//     }

//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(
//         iconData,
//         color: color,
//         size: 24,
//       ),
//     );
//   }

//   String _formatFileSize(int sizeInBytes) {
//     if (sizeInBytes < 1024) {
//       return '$sizeInBytes B';
//     } else if (sizeInBytes < 1048576) {
//       return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
//     } else {
//       return '${(sizeInBytes / 1048576).toStringAsFixed(1)} MB';
//     }
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/assignments/data/models/question_model_student.dart';
import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignment_detail_viewmodel.dart';
import 'package:attendance_app/features/assignments/presentation/viewmodels/student_assignments_viewmodel.dart';
import 'file_preview_view.dart';

class StudentAssignmentDetailView extends StatefulWidget {
  final String courseId;
  final String assignmentId;
  final String assignmentTitle;

  const StudentAssignmentDetailView({
    super.key,
    required this.courseId,
    required this.assignmentId,
    required this.assignmentTitle,
  });

  @override
  State<StudentAssignmentDetailView> createState() =>
      _StudentAssignmentDetailViewState();
}

class _StudentAssignmentDetailViewState
    extends State<StudentAssignmentDetailView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StudentAssignmentDetailViewModel(
        courseId: widget.courseId,
        assignmentId: widget.assignmentId,
      ),
      child: Consumer<StudentAssignmentDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.successMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.successMessage),
                  backgroundColor: Colors.green,
                ),
              );
              viewModel.clearMessages();
            });
          }

          if (viewModel.errorMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
              viewModel.clearMessages();
            });
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                widget.assignmentTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              centerTitle: true,
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.questions.isEmpty
                    ? const Center(
                        child: Text('No questions in this assignment'))
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  key: ValueKey(
                                      'question_${viewModel.currentQuestionIndex}'),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Question ${viewModel.currentQuestionIndex + 1} of ${viewModel.questions.length}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (!viewModel.allQuestionsAnswered)
                                            const Text(
                                              'Please answer all questions',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 8),
                                      child: Text(
                                        viewModel.currentQuestion?.question ??
                                            '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (viewModel.currentQuestion?.type ==
                                            'Upload File' &&
                                        viewModel.currentQuestion?.fileUrl !=
                                            null &&
                                        viewModel.currentQuestion!.fileUrl!
                                            .isNotEmpty)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 24),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Question Attachment',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _getFileIcon(
                                                    viewModel.currentQuestion!
                                                            .fileName ??
                                                        '',
                                                    Colors.blue),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        viewModel
                                                                .currentQuestion!
                                                                .fileName ??
                                                            'File',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      if (viewModel
                                                              .currentQuestion!
                                                              .fileSize !=
                                                          null)
                                                        Text(
                                                          _formatFileSize(viewModel
                                                              .currentQuestion!
                                                              .fileSize!),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.visibility,
                                                      color: Colors.blue),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FilePreviewView(
                                                          fileUrl: viewModel
                                                              .currentQuestion!
                                                              .fileUrl!,
                                                          firebaseFileName:
                                                              viewModel
                                                                  .currentQuestion!
                                                                  .fileName,
                                                          fileSize: viewModel
                                                              .currentQuestion!
                                                              .fileSize,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    _buildQuestionResponseWidget(
                                        viewModel.currentQuestion!, viewModel),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Fixed bottom section for Submit button and question navigation
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: viewModel.allQuestionsAnswered &&
                                            !viewModel.isSubmitting
                                        ? () async {
                                            final success = await viewModel
                                                .submitAssignment();
                                            if (success && context.mounted) {
                                              try {
                                                final parentViewModel = Provider
                                                    .of<StudentAssignmentsViewModel>(
                                                        context,
                                                        listen: false);
                                                await parentViewModel
                                                    .refreshAssignments();
                                              } catch (e) {
                                                print(
                                                    "Could not refresh assignments list: $e");
                                              }
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Assignment submitted successfully!'),
                                                  backgroundColor: Colors.green,
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                              Navigator.pop(context);
                                            }
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          viewModel.allQuestionsAnswered
                                              ? AppColors.primaryColor
                                              : const Color(0xFFBDBDBD),
                                      disabledBackgroundColor:
                                          const Color(0xFFBDBDBD),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: viewModel.isSubmitting
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          )
                                        : const Text(
                                            'Submit',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                if (!viewModel.allQuestionsAnswered)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Center(
                                      child: Text(
                                        'Please answer all questions before submitting',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 45,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: viewModel.questions.length,
                                    itemBuilder: (context, index) {
                                      final question =
                                          viewModel.questions[index];
                                      final isActive = index ==
                                          viewModel.currentQuestionIndex;
                                      final isAnswered =
                                          question.isQuestionAnswered();

                                      return GestureDetector(
                                        key: ValueKey(
                                            'q_indicator_${index}_${isAnswered}_$isActive'),
                                        onTap: () {
                                          viewModel.goToQuestion(index);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.primaryColor
                                                : (isAnswered
                                                    ? const Color(0xFFCDF1CD)
                                                    : Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isActive
                                                  ? AppColors.primaryColor
                                                  : isAnswered
                                                      ? const Color(0xFFCDF1CD)
                                                      : Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Text(
                                                  'Question ${index + 1}',
                                                  style: TextStyle(
                                                    color: isActive
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              if (isAnswered)
                                                const Positioned(
                                                  top: 1,
                                                  right: 1,
                                                  child: Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 18,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionResponseWidget(
      StudentQuestion question, StudentAssignmentDetailViewModel viewModel) {
    if (question.type == 'multiple_choice' || question.type == 'MCQ') {
      return _buildMultipleChoiceOptions(question, viewModel);
    } else if (question.type == 'true_false' || question.type == 'TrueFalse') {
      return _buildTrueFalseOptions(question, viewModel);
    } else if (question.type == 'Upload File') {
      return _buildFileUpload(question, viewModel);
    } else {
      return Center(
        child: Text(
          'Unsupported question type: ${question.type}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  Widget _buildMultipleChoiceOptions(
      StudentQuestion question, StudentAssignmentDetailViewModel viewModel) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final bool isSelected = question.selectedOption == index;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              viewModel.updateSelectedOption(
                  viewModel.currentQuestionIndex, index);
              setState(() {});
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      question.options[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTrueFalseOptions(
      StudentQuestion question, StudentAssignmentDetailViewModel viewModel) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              viewModel.updateSelectedOption(viewModel.currentQuestionIndex, 0);
              setState(() {});
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: question.selectedOption == 0
                    ? AppColors.primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'True',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: question.selectedOption == 0
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  if (question.selectedOption == 0)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              viewModel.updateSelectedOption(viewModel.currentQuestionIndex, 1);
              setState(() {});
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: question.selectedOption == 1
                    ? AppColors.primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'False',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: question.selectedOption == 1
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  if (question.selectedOption == 1)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(
      StudentQuestion question, StudentAssignmentDetailViewModel viewModel) {
    bool hasUploadedFile = question.uploadedFileUrl != null &&
        question.uploadedFileUrl!.isNotEmpty;

    final TextEditingController textController =
        TextEditingController(text: question.textAnswer ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            "Answer the question",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Type your answer here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
            ),
            onChanged: (value) {
              viewModel.updateTextAnswer(viewModel.currentQuestionIndex, value);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            "Or upload a file",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        if (hasUploadedFile)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Uploaded File',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _getFileIcon(question.uploadedFileName ?? '', Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.uploadedFileName ?? 'File uploaded',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilePreviewView(
                              fileUrl: question.uploadedFileUrl!,
                              firebaseFileName: question.uploadedFileName,
                              fileSize: null,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        viewModel
                            .resetFileUpload(viewModel.currentQuestionIndex);
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: viewModel.isUploading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: viewModel.uploadProgress,
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Uploading... ${(viewModel.uploadProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      await _pickFile(context, viewModel);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_upload,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Click to upload file",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "PDF, JPG, PNG, or document files",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
      ],
    );
  }

  Future<void> _pickFile(
      BuildContext context, StudentAssignmentDetailViewModel viewModel) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.single;
        File fileToUpload = File(file.path!);
        String fileName = file.name;

        await viewModel.uploadFile(
          viewModel.currentQuestionIndex,
          fileToUpload,
          fileName,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No file selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _getFileIcon(String fileName, Color color) {
    IconData iconData;

    if (fileName.endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf;
    } else if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png')) {
      iconData = Icons.image;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      iconData = Icons.description;
    } else {
      iconData = Icons.insert_drive_file;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1048576) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeInBytes / 1048576).toStringAsFixed(1)} MB';
    }
  }
}
