// // import 'package:attendance_app/core/utils/app_colors.dart';
// // import 'package:attendance_app/features/home/presentation/views/widgets/subject_text_field.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class AddSubjectPage extends StatefulWidget {
// //   @override
// //   _AddSubjectPageState createState() => _AddSubjectPageState();
// // }

// // class _AddSubjectPageState extends State<AddSubjectPage> {
// //   final TextEditingController _subjectNameController = TextEditingController();
// //   final TextEditingController _subjectCodeController = TextEditingController();
// //   final TextEditingController _dateController = TextEditingController();

// //   String? _selectedYear;

// //   // void _pickDate() async {
// //   //   DateTime? pickedDate = await showDatePicker(
// //   //     context: context,
// //   //     initialDate: DateTime.now(),
// //   //     firstDate: DateTime(2000),
// //   //     lastDate: DateTime(3000),
// //   //   );
// //   //   if (pickedDate != null) {
// //   //     setState(() {
// //   //       _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
// //   //     });
// //   //   }
// //   // }

// //   void _pickDate() async {
// //     DateTime? pickedDate = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(3000),
// //       builder: (context, child) {
// //         return Theme(
// //           data: Theme.of(context).copyWith(
// //             colorScheme: const ColorScheme.light(
// //               primary: AppColors.primaryColor,
// //               onPrimary: Colors.white,
// //               onSurface: Colors.black,
// //             ),
// //             textButtonTheme: TextButtonThemeData(
// //               style: TextButton.styleFrom(
// //                 foregroundColor: AppColors.primaryColor,
// //               ),
// //             ),
// //           ),
// //           child: child!,
// //         );
// //       },
// //     );

// //     if (pickedDate != null) {
// //       setState(() {
// //         _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         backgroundColor: AppColors.primaryColor,
// //         centerTitle: true,
// //         title: const Text(
// //           'Add Subject',
// //           style: TextStyle(
// //             fontSize: 22,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.white,
// //           ),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               SubjectTextField(
// //                 controller: _subjectNameController,
// //                 labelText: 'Subject Name',
// //               ),
// //               const SizedBox(height: 10),
// //               SubjectTextField(
// //                 controller: _subjectCodeController,
// //                 labelText: 'Subject Code',
// //               ),
// //               const SizedBox(height: 10),
// //               Container(
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.grey.withOpacity(0.3),
// //                       blurRadius: 6,
// //                       offset: const Offset(0, 3),
// //                     )
// //                   ],
// //                 ),
// //                 child: DropdownButtonFormField<String>(
// //                   value: _selectedYear,
// //                   decoration: InputDecoration(
// //                     labelText: 'Year',
// //                     labelStyle: const TextStyle(color: Colors.black),
// //                     enabledBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide:
// //                           const BorderSide(color: Colors.grey, width: 1),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: const BorderSide(
// //                         color: AppColors.primaryColor,
// //                         width: 2,
// //                       ),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(
// //                       vertical: 15,
// //                       horizontal: 10,
// //                     ),
// //                   ),
// //                   isDense: true,
// //                   items: ['1 Year', '2 Year', '3 Year', '4 Year']
// //                       .map((year) => DropdownMenuItem(
// //                             value: year,
// //                             child: Container(
// //                               width: 100,
// //                               child: Text(year, textAlign: TextAlign.center),
// //                             ),
// //                           ))
// //                       .toList(),
// //                   onChanged: (value) {
// //                     setState(() {
// //                       _selectedYear = value;
// //                     });
// //                   },
// //                   menuMaxHeight: 200, // تحديد أقصى ارتفاع للقائمة المنسدلة
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               Container(
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.grey.withOpacity(0.3),
// //                       blurRadius: 6,
// //                       offset: const Offset(0, 3),
// //                     )
// //                   ],
// //                 ),
// //                 child: TextField(
// //                   controller: _dateController,
// //                   readOnly: true,
// //                   onTap: _pickDate,
// //                   decoration: InputDecoration(
// //                     labelText: 'Select Date',
// //                     labelStyle: const TextStyle(color: Colors.black),
// //                     enabledBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide:
// //                           const BorderSide(color: Colors.grey, width: 1),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: const BorderSide(
// //                           color: AppColors.primaryColor, width: 2),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(
// //                         vertical: 15, horizontal: 10),
// //                     suffixIcon: const Icon(Icons.calendar_today),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 30),
// //               Center(
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColors.primaryColor,
// //                     padding: const EdgeInsets.symmetric(
// //                         horizontal: 40, vertical: 15),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                   ),
// //                   onPressed: () {
// //                     // تنفيذ عملية الإضافة هنا
// //                   },
// //                   child: const Text(
// //                     'Add',
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/subject_text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // استيراد مكتبة Firestore

// class AddSubjectPage extends StatefulWidget {
//   @override
//   _AddSubjectPageState createState() => _AddSubjectPageState();
// }

// class _AddSubjectPageState extends State<AddSubjectPage> {
//   final TextEditingController _subjectNameController = TextEditingController();
//   final TextEditingController _subjectCodeController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();

//   String? _selectedYear;

//   // دالة لاختيار التاريخ
//   void _pickDate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(3000),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (pickedDate != null) {
//       setState(() {
//         _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//       });
//     }
//   }

//   // دالة لإضافة المادة إلى Firebase
//   Future<void> _addSubjectToFirebase() async {
//     if (_subjectNameController.text.isEmpty ||
//         _subjectCodeController.text.isEmpty ||
//         _selectedYear == null ||
//         _dateController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields')),
//       );
//       return;
//     }

//     try {
//       // إضافة وثيقة جديدة في مجموعة Courses
//       await FirebaseFirestore.instance
//           .collection('Courses')
//           .doc(_subjectNameController.text) // اسم الوثيقة هو اسم المادة
//           .set({
//         'adminId': 'admin123', // يمكنك تعديل هذا بناءً على احتياجاتك
//         'courseCode': _subjectCodeController.text,
//         'courseName': _subjectNameController.text,
//         'semester': _selectedYear,
//         'date': _dateController.text,
//       });

//       // عرض رسالة نجاح
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Subject added successfully')),
//       );

//       // العودة إلى الصفحة الرئيسية
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding subject: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: AppColors.primaryColor,
//         centerTitle: true,
//         title: const Text(
//           'Add Course',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SubjectTextField(
//                 controller: _subjectNameController,
//                 labelText: 'Subject Name',
//               ),
//               const SizedBox(height: 10),
//               SubjectTextField(
//                 controller: _subjectCodeController,
//                 labelText: 'Subject Code',
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: DropdownButtonFormField<String>(
//                   value: _selectedYear,
//                   decoration: InputDecoration(
//                     labelText: 'Year',
//                     labelStyle: const TextStyle(color: Colors.black),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Colors.grey, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: AppColors.primaryColor,
//                         width: 2,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 15,
//                       horizontal: 10,
//                     ),
//                   ),
//                   isDense: true,
//                   items: ['1 Year', '2 Year', '3 Year', '4 Year']
//                       .map((year) => DropdownMenuItem(
//                             value: year,
//                             child: Container(
//                               width: 100,
//                               child: Text(year, textAlign: TextAlign.center),
//                             ),
//                           ))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedYear = value;
//                     });
//                   },
//                   menuMaxHeight: 200,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: _dateController,
//                   readOnly: true,
//                   onTap: _pickDate,
//                   decoration: InputDecoration(
//                     labelText: 'Select Date',
//                     labelStyle: const TextStyle(color: Colors.black),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Colors.grey, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                           color: AppColors.primaryColor, width: 2),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 15, horizontal: 10),
//                     suffixIcon: const Icon(Icons.calendar_today),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Center(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: _addSubjectToFirebase, // استدعاء الدالة عند الضغط
//                   child: const Text(
//                     'Add',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/subject_text_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // استيراد Firebase Auth

class AddSubjectPage extends StatefulWidget {
  const AddSubjectPage({super.key});

  @override
  _AddSubjectPageState createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedYear;
  String? adminUid; // لتخزين uid الخاص بالـ admin

  @override
  void initState() {
    super.initState();
    _getAdminUid(); // استرجاع uid الخاص بالـ admin عند بدء الشاشة
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // دالة لاسترجاع uid الخاص بالـ admin بناءً على email
  Future<void> _getAdminUid() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String email = currentUser.email ?? '';
        if (email.isNotEmpty) {
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            setState(() {
              adminUid =
                  userSnapshot.docs.first.id; // تخزين uid الخاص بالـ admin
            });
          } else {
            print('No user found with this email');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No user found with this email')),
            );
          }
        } else {
          print('No user email found');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user email found')),
          );
        }
      } else {
        print('No user logged in');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in')),
        );
      }
    } catch (e) {
      print('Error fetching admin UID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching admin UID: $e')),
      );
    }
  }

  // دالة لاختيار التاريخ
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // دالة لإضافة المادة إلى Firebase
  Future<void> _addSubjectToFirebase() async {
    if (_subjectNameController.text.isEmpty ||
        _subjectCodeController.text.isEmpty ||
        _selectedYear == null ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (adminUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin ID not found. Please try again.')),
      );
      return;
    }

    try {
      // إضافة وثيقة جديدة في مجموعة Courses
      await FirebaseFirestore.instance
          .collection('Courses')
          .doc(_subjectNameController.text) // اسم الوثيقة هو اسم المادة
          .set({
        'adminID': adminUid, // استخدام uid الخاص بالـ admin
        'courseCode': _subjectCodeController.text,
        'courseName': _subjectNameController.text,
        'semester': _selectedYear,
        'date': _dateController.text,
      });

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject added successfully')),
      );

      // العودة إلى الصفحة الرئيسية
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding subject: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: const Text(
          'Add Course',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubjectTextField(
                controller: _subjectNameController,
                labelText: 'Course Name',
              ),
              const SizedBox(height: 10),
              SubjectTextField(
                controller: _subjectCodeController,
                labelText: 'Course Code',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    labelStyle: const TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                  ),
                  isDense: true,
                  items: ['1 Year', '2 Year', '3 Year', '4 Year']
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: SizedBox(
                              width: 100,
                              child: Text(year, textAlign: TextAlign.center),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                  menuMaxHeight: 200,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    labelStyle: const TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _addSubjectToFirebase, // استدعاء الدالة عند الضغط
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
