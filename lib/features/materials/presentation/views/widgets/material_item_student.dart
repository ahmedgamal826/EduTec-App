// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_bloc/flutter_bloc.dart';
// // // import 'package:share_plus/share_plus.dart';
// // // import 'package:open_file/open_file.dart';

// // // import '../../../cubits/cubit_student/student_material_cubit.dart';
// // // import '../../../models/material_model_student.dart';
// // // // import '../../cubits/material_cubit.dart';
// // // // import '../../models/material_model.dart';

// // // class MaterialItemStudent extends StatelessWidget {
// // //   final MaterialModel material;

// // //   const MaterialItemStudent({
// // //     Key? key,
// // //     required this.material,
// // //   }) : super(key: key);

// // //   IconData _getIconForType(String type) {
// // //     switch (type.toLowerCase()) {
// // //       case 'pdf':
// // //         return Icons.picture_as_pdf;
// // //       case 'doc':
// // //       case 'docx':
// // //         return Icons.description;
// // //       case 'jpg':
// // //       case 'png':
// // //       case 'jpeg':
// // //         return Icons.image;
// // //       case 'mp4':
// // //       case 'avi':
// // //         return Icons.video_file;
// // //       default:
// // //         return Icons.insert_drive_file;
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final materialCubit = context.read<StudentMaterialCubit>();

// // //     return Padding(
// // //       padding: const EdgeInsets.only(bottom: 16),
// // //       child: GestureDetector(
// // //         onTap: () async {
// // //           final filePath = await materialCubit.prepareFileForOpen(
// // //             material.url,
// // //             material.name,
// // //           );
// // //           if (filePath != null) {
// // //             final result = await OpenFile.open(filePath);
// // //             if (result.type != ResultType.done) {
// // //               ScaffoldMessenger.of(context).showSnackBar(
// // //                 SnackBar(
// // //                   content: Text('Could not open file: ${result.message}'),
// // //                   backgroundColor: Colors.red,
// // //                 ),
// // //               );
// // //             }
// // //           }
// // //         },
// // //         child: Container(
// // //           decoration: BoxDecoration(
// // //             color: Colors.white,
// // //             borderRadius: BorderRadius.circular(16),
// // //             border: Border.all(color: Colors.black, width: 1),
// // //           ),
// // //           padding: const EdgeInsets.all(16),
// // //           child: Column(
// // //             children: [
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     _getIconForType(material.type),
// // //                     size: 40,
// // //                     color: const Color(0xFF1565C0),
// // //                   ),
// // //                   const SizedBox(width: 16),
// // //                   Expanded(
// // //                     child: Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Text(
// // //                           material.name,
// // //                           style: const TextStyle(
// // //                             fontSize: 16,
// // //                             fontWeight: FontWeight.bold,
// // //                           ),
// // //                         ),
// // //                         const SizedBox(height: 4),
// // //                         Text(
// // //                           material.size,
// // //                           style: TextStyle(
// // //                             fontSize: 14,
// // //                             color: Colors.grey[600],
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 16),
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   // Share Icon
// // //                   IconButton(
// // //                     icon: const Icon(
// // //                       Icons.share,
// // //                       color: Color(0xFF1565C0),
// // //                     ),
// // //                     onPressed: () async {
// // //                       final filePath = await materialCubit.shareFile(
// // //                         material.url,
// // //                         material.name,
// // //                       );
// // //                       if (filePath != null) {
// // //                         final xFile = XFile(filePath);
// // //                         await Share.shareXFiles(
// // //                           [xFile],
// // //                           text: 'Sharing ${material.name}',
// // //                         );
// // //                       }
// // //                     },
// // //                   ),
// // //                   // Download Icon
// // //                   IconButton(
// // //                     icon: const Icon(
// // //                       Icons.download,
// // //                       color: Color(0xFF1565C0),
// // //                     ),
// // //                     onPressed: () {
// // //                       materialCubit.downloadFile(
// // //                         material.url,
// // //                         material.name,
// // //                       );
// // //                     },
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:attendance_app/features/materials/cubits/cubit_student/student_material_cubit.dart';
// // import 'package:attendance_app/features/materials/presentation/views/pdf_material_view.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:share_plus/share_plus.dart';
// // import 'package:open_file/open_file.dart';
// // import '../../../models/material_model_student.dart';

// // class MaterialItemStudent extends StatelessWidget {
// //   final MaterialModel material;

// //   const MaterialItemStudent({
// //     Key? key,
// //     required this.material,
// //   }) : super(key: key);

// //   IconData _getIconForType(String type) {
// //     switch (type.toLowerCase()) {
// //       case 'pdf':
// //         return Icons.picture_as_pdf;
// //       case 'doc':
// //       case 'docx':
// //         return Icons.description;
// //       case 'jpg':
// //       case 'png':
// //       case 'jpeg':
// //         return Icons.image;
// //       case 'mp4':
// //       case 'avi':
// //         return Icons.video_file;
// //       default:
// //         return Icons.insert_drive_file;
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final materialCubit = context.read<StudentMaterialCubit>();

// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: Colors.black, width: 1),
// //         ),
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Icon(
// //                   _getIconForType(material.type),
// //                   size: 40,
// //                   color: const Color(0xFF1565C0),
// //                 ),
// //                 const SizedBox(width: 16),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         material.name,
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         material.size,
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: Colors.grey[600],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 // Open File Icon
// //                 IconButton(
// //                   icon: const Icon(
// //                     Icons.open_in_new,
// //                     color: Color(0xFF1565C0),
// //                   ),
// //                   onPressed: () async {
// //                     if (material.type.toLowerCase() == 'pdf') {
// //                       // Open PDF using PdfMaterialViewer
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (context) => PdfMaterialViewer(
// //                             fileUrl: material.url,
// //                             fileName: material.name,
// //                           ),
// //                         ),
// //                       );
// //                     } else {
// //                       // Open other file types using OpenFile
// //                       final filePath = await materialCubit.prepareFileForOpen(
// //                         material.url,
// //                         material.name,
// //                       );
// //                       if (filePath != null) {
// //                         final result = await OpenFile.open(filePath);
// //                         if (result.type != ResultType.done) {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(
// //                               content: Text('Could not open file: ${result.message}'),
// //                               backgroundColor: Colors.red,
// //                             ),
// //                           );
// //                         }
// //                       }
// //                     }
// //                   },
// //                 ),
// //                 // Share Icon
// //                 IconButton(
// //                   icon: const Icon(
// //                     Icons.share,
// //                     color: Color(0xFF1565C0),
// //                   ),
// //                   onPressed: () async {
// //                     final filePath = await materialCubit.shareFile(
// //                       material.url,
// //                       material.name,
// //                     );
// //                     if (filePath != null) {
// //                       final xFile = XFile(filePath);
// //                       await Share.shareXFiles(
// //                         [xFile],
// //                         text: 'Sharing ${material.name}',
// //                       );
// //                     }
// //                   },
// //                 ),
// //                 // Download Icon
// //                 IconButton(
// //                   icon: const Icon(
// //                     Icons.download,
// //                     color: Color(0xFF1565C0),
// //                   ),
// //                   onPressed: () {
// //                     materialCubit.downloadFile(
// //                       material.url,
// //                       material.name,
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:open_file/open_file.dart';
// import '../../../cubits/cubit_student/student_material_cubit.dart';
// import '../../../models/material_model_student.dart';
// import '../../views/pdf_material_view.dart';

// class MaterialItemStudent extends StatelessWidget {
//   final MaterialModel material;

//   const MaterialItemStudent({
//     Key? key,
//     required this.material,
//   }) : super(key: key);

//   IconData _getIconForType(String type) {
//     switch (type.toLowerCase()) {
//       case 'pdf':
//         return Icons.picture_as_pdf;
//       case 'doc':
//       case 'docx':
//         return Icons.description;
//       case 'jpg':
//       case 'png':
//       case 'jpeg':
//         return Icons.image;
//       case 'mp4':
//       case 'avi':
//         return Icons.video_file;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final materialCubit = context.read<StudentMaterialCubit>();

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: GestureDetector(
//         onTap: () async {
//           // Handle opening the file when the card is tapped
//           if (material.type.toLowerCase() == 'pdf') {
//             // Open PDF using PdfMaterialViewer
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PdfMaterialViewer(
//                   fileUrl: material.url,
//                   fileName: material.name,
//                 ),
//               ),
//             );
//           } else {
//             // Open other file types using OpenFile
//             final filePath = await materialCubit.prepareFileForOpen(
//               material.url,
//               material.name,
//             );
//             if (filePath != null) {
//               final result = await OpenFile.open(filePath);
//               if (result.type != ResultType.done) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Could not open file: ${result.message}'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             }
//           }
//         },
//         child: Card(
//           elevation: 6,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white,
//                   Colors.blue[50]!,
//                 ],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     // File Icon with subtle animation
//                     AnimatedScale(
//                       duration: const Duration(milliseconds: 200),
//                       scale: 1.0,
//                       child: Icon(
//                         _getIconForType(material.type),
//                         size: 40,
//                         color: const Color(0xFF1565C0),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             material.name,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             material.size,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Share Icon with hover effect
//                     AnimatedScale(
//                       duration: const Duration(milliseconds: 200),
//                       scale: 1.0,
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.share,
//                           color: Color(0xFF1565C0),
//                           //size: 28,
//                         ),
//                         onPressed: () async {
//                           final filePath = await materialCubit.shareFile(
//                             material.url,
//                             material.name,
//                           );
//                           if (filePath != null) {
//                             final xFile = XFile(filePath);
//                             await Share.shareXFiles(
//                               [xFile],
//                               text: 'Sharing ${material.name}',
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     // Download Icon with hover effect
//                     AnimatedScale(
//                       duration: const Duration(milliseconds: 200),
//                       scale: 1.0,
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.download,
//                           color: Color(0xFF1565C0),
//                           //size: 28,
//                         ),
//                         onPressed: () {
//                           materialCubit.downloadFile(
//                             material.url,
//                             material.name,
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:mime/mime.dart';
import '../../../cubits/cubit_student/student_material_cubit.dart';
import '../../../models/material_model_student.dart';
import '../../views/pdf_material_view.dart';

class MaterialItemStudent extends StatelessWidget {
  final MaterialModel material;

  const MaterialItemStudent({
    super.key,
    required this.material,
  });

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'png':
      case 'jpeg':
        return Icons.image;
      case 'mp4':
      case 'avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialCubit = context.read<StudentMaterialCubit>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          if (material.type.toLowerCase() == 'pdf') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfMaterialViewer(
                  fileUrl: material.url,
                  fileName: material.name,
                ),
              ),
            );
          } else {
            final filePath = await materialCubit.prepareFileForOpen(
              material.url,
              material.name,
            );
            if (filePath != null) {
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not open file: ${result.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     Colors.white,
              //     Colors.blue[50]!,
              //   ],
              // ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.blue.withOpacity(0.2),
              //     blurRadius: 10,
              //     offset: const Offset(0, 4),
              //   ),
              // ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: 1.0,
                      child: Icon(
                        _getIconForType(material.type),
                        size: 40,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            material.size,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: 1.0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Color(0xFF1565C0),
                        ),
                        onPressed: () async {
                          final filePath = await materialCubit.shareFile(
                            material.url,
                            material.name,
                          );
                          if (filePath != null) {
                            final mimeType = lookupMimeType(filePath) ??
                                'application/octet-stream';
                            final xFile = XFile(filePath, mimeType: mimeType);
                            await Share.shareXFiles(
                              [xFile],
                              text: 'Sharing ${material.name}',
                              subject: 'Share ${material.name}',
                            );
                            // Delete the temporary file after sharing
                            final file = File(filePath);
                            if (await file.exists()) {
                              await file.delete();
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: 1.0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Color(0xFF1565C0),
                        ),
                        onPressed: () {
                          // Show SnackBar when the download starts
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File saved to Downloads'),
                              duration: Duration(
                                  seconds:
                                      2), // SnackBar will show for 2 seconds
                              backgroundColor: Colors.blue,
                              margin: EdgeInsets.only(
                                  bottom: 20,
                                  left: 10,
                                  right:
                                      10), // Add padding from bottom and sides
                              behavior: SnackBarBehavior
                                  .floating, // Make the SnackBar float so margin works
                            ),
                          );

                          // Start the file download
                          materialCubit.downloadFile(
                            material.url,
                            material.name,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
