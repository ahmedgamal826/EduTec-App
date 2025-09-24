// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter/material.dart';
// import '../../../models/material_model_admin.dart';

// class MaterialItemAdmin extends StatefulWidget {
//   final MaterialFile file;
//   final int index;
//   final VoidCallback onDelete;
//   final VoidCallback onShare;
//   final VoidCallback onTap; // إضافة onTap
//   final BuildContext parentContext;

//   const MaterialItemAdmin({
//     super.key,
//     required this.file,
//     required this.index,
//     required this.onDelete,
//     required this.onShare,
//     required this.onTap,
//     required this.parentContext,
//   });

//   @override
//   _MaterialItemAdminState createState() => _MaterialItemAdminState();
// }

// class _MaterialItemAdminState extends State<MaterialItemAdmin> {
//   bool _isTapped = false;

//   void _showOptionsBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       backgroundColor: Colors.white,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Options',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF0D47A1),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 leading: const Icon(
//                   Icons.share,
//                   color: Color(0xFF1976D2),
//                 ),
//                 title: const Text(
//                   'Share',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Color(0xFF0D47A1),
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onShare();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.delete_outline,
//                   color: Colors.red,
//                 ),
//                 title: const Text(
//                   'Delete',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.red,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showDeleteConfirmationDialog();
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1976D2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showDeleteConfirmationDialog() {
//     AwesomeDialog(
//       context: widget.parentContext,
//       dialogType: DialogType.warning,
//       animType: AnimType.bottomSlide,
//       title: 'Confirm Delete',
//       desc: 'Are you sure you want to delete "${widget.file.name}"?',
//       dismissOnTouchOutside: false,
//       btnCancelOnPress: () {},
//       btnOkOnPress: () {
//         widget.onDelete();
//         ScaffoldMessenger.of(widget.parentContext).showSnackBar(
//           SnackBar(
//             content: Text('${widget.file.name} deleted'),
//             backgroundColor: const Color(0xFF1565C0),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       },
//       btnOkText: 'Delete',
//       btnCancelText: 'Cancel',
//       btnOkColor: Colors.red,
//       btnCancelColor: Colors.grey,
//     ).show();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // دالة جديدة لتحديد الأيقونة بناءً على نوع الملف
//     IconData getFileIcon(String? fileName) {
//       if (fileName == null || fileName.isEmpty) {
//         return Icons.insert_drive_file_outlined;
//       }

//       // استخراج الامتداد من الـ URL
//       final extension = fileName.split('.').last.toLowerCase();

//       // التحقق من نوع الملف
//       if (extension == 'pdf') {
//         return Icons.picture_as_pdf;
//       } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
//         return Icons.image;
//       } else {
//         return Icons
//             .insert_drive_file_outlined; // أيقونة افتراضية إذا كان نوع غير معروف
//       }
//     }

//     return GestureDetector(
//       onTapDown: (_) {
//         setState(() {
//           _isTapped = true;
//         });
//       },
//       onTapUp: (_) {
//         setState(() {
//           _isTapped = false;
//         });
//       },
//       onTapCancel: () {
//         setState(() {
//           _isTapped = false;
//         });
//       },
//       onTap: widget.onTap, // استخدام onTap الجديد
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Card(
//           elevation: 5,
//           color: Colors.white,
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//               child: Row(
//                 children: [
//                   Icon(
//                     getFileIcon(widget.file.name),
//                     // Icons.description_rounded,
//                     size: 40,
//                     color: const Color(0xFF1976D2),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(right: 10),
//                           child: Text(
//                             widget.file.name,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF0D47A1),
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           widget.file.size,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       _showOptionsBottomSheet(context);
//                     },
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: const Color(0xFF1976D2).withOpacity(0.1),
//                       ),
//                       child: const Icon(
//                         Icons.more_vert,
//                         color: Color(0xFF1976D2),
//                         size: 23,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../../models/material_model_admin.dart';
import '../../../cubits/cubit_admin/material_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaterialItemAdmin extends StatefulWidget {
  final MaterialFile file;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onTap; // إضافة onTap
  final BuildContext parentContext;

  const MaterialItemAdmin({
    Key? key,
    required this.file,
    required this.index,
    required this.onDelete,
    required this.onShare,
    required this.onTap,
    required this.parentContext,
  }) : super(key: key);

  @override
  _MaterialItemAdminState createState() => _MaterialItemAdminState();
}

class _MaterialItemAdminState extends State<MaterialItemAdmin> {
  bool _isTapped = false;
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.share,
                  color: Color(0xFF1976D2),
                ),
                title: const Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onShare();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Color(0xFF1976D2),
                ),
                title: const Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog();
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog() {
    _fileNameController.text = widget.file.name;

    AwesomeDialog(
      context: widget.parentContext,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Update File Name',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const Text(
              'Enter new file name:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      btnOkText: 'Update',
      btnCancelText: 'Cancel',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        String newName = _fileNameController.text.trim();
        if (newName.isNotEmpty && newName != widget.file.name) {
          final result = await context
              .read<MaterialCubit>()
              .updateFileName(widget.index, newName);

          if (result) {
            ScaffoldMessenger.of(widget.parentContext).showSnackBar(
              SnackBar(
                content: Text('File name updated to "$newName"'),
                backgroundColor: const Color(0xFF1565C0),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(widget.parentContext).showSnackBar(
              SnackBar(
                content: const Text('Failed to update file name'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      },
    ).show();
  }

  void _showDeleteConfirmationDialog() {
    AwesomeDialog(
      context: widget.parentContext,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Confirm Delete',
      desc: 'Are you sure you want to delete "${widget.file.name}"?',
      dismissOnTouchOutside: false,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        widget.onDelete();
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text('${widget.file.name} deleted'),
            backgroundColor: const Color(0xFF1565C0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      btnOkText: 'Delete',
      btnCancelText: 'Cancel',
      btnOkColor: Colors.red,
      btnCancelColor: Colors.grey,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    // دالة جديدة لتحديد الأيقونة بناءً على نوع الملف
    IconData _getFileIcon(String? fileName) {
      if (fileName == null || fileName.isEmpty)
        return Icons.insert_drive_file_outlined;

      // استخراج الامتداد من الـ URL
      final extension = fileName.split('.').last.toLowerCase();

      // التحقق من نوع الملف
      if (extension == 'pdf') {
        return Icons.picture_as_pdf;
      } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        return Icons.image;
      } else {
        return Icons
            .insert_drive_file_outlined; // أيقونة افتراضية إذا كان نوع غير معروف
      }
    }

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isTapped = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isTapped = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isTapped = false;
        });
      },
      onTap: widget.onTap, // استخدام onTap الجديد
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(widget.file.name),
                    // Icons.description_rounded,
                    size: 40,
                    color: Color(0xFF1976D2),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            widget.file.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.file.size,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _showOptionsBottomSheet(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF1976D2),
                        size: 23,
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
  }
}
