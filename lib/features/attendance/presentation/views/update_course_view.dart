// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/subject_text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class UpdateCoursePage extends StatefulWidget {
//   final String courseId;
//   final String courseName;
//   final String courseCode;
//   final String semester;
//   final String date;

//   const UpdateCoursePage({
//     Key? key,
//     required this.courseId,
//     required this.courseName,
//     required this.courseCode,
//     required this.semester,
//     required this.date,
//   }) : super(key: key);

//   @override
//   _UpdateCoursePageState createState() => _UpdateCoursePageState();
// }

// class _UpdateCoursePageState extends State<UpdateCoursePage> {
//   late TextEditingController _courseNameController;
//   late TextEditingController _courseCodeController;
//   late TextEditingController _dateController;
//   String? _selectedYear;

//   @override
//   void initState() {
//     super.initState();
//     // تهيئة الحقول بالبيانات الحالية
//     _courseNameController = TextEditingController(text: widget.courseName);
//     _courseCodeController = TextEditingController(text: widget.courseCode);
//     _dateController = TextEditingController(text: widget.date);
//     _selectedYear = widget.semester;
//   }

//   @override
//   void dispose() {
//     _courseNameController.dispose();
//     _courseCodeController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }

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

//   // دالة لتحديث بيانات المادة في Firestore
//   Future<void> _updateCourse() async {
//     if (_courseNameController.text.isEmpty ||
//         _courseCodeController.text.isEmpty ||
//         _selectedYear == null ||
//         _dateController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields')),
//       );
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance
//           .collection('Courses')
//           .doc(widget.courseId)
//           .update({
//         'courseName': _courseNameController.text,
//         'courseCode': _courseCodeController.text,
//         'semester': _selectedYear,
//         'date': _dateController.text,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Course updated successfully')),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating course: $e')),
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
//           'Update Course',
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
//                 controller: _courseNameController,
//                 labelText: 'Course Name',
//               ),
//               const SizedBox(height: 10),
//               SubjectTextField(
//                 controller: _courseCodeController,
//                 labelText: 'Course Code',
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
//                   onPressed: _updateCourse,
//                   child: const Text(
//                     'Update',
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

class UpdateCoursePage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String semester;
  final String date;

  const UpdateCoursePage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.semester,
    required this.date,
  });

  @override
  _UpdateCoursePageState createState() => _UpdateCoursePageState();
}

class _UpdateCoursePageState extends State<UpdateCoursePage> {
  late TextEditingController _courseNameController;
  late TextEditingController _courseCodeController;
  late TextEditingController _dateController;
  String? _selectedYear;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController(text: widget.courseName);
    _courseCodeController = TextEditingController(text: widget.courseCode);
    _dateController = TextEditingController(text: widget.date);
    _selectedYear = widget.semester;
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

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

  Future<void> _updateCourse() async {
    if (_courseNameController.text.isEmpty ||
        _courseCodeController.text.isEmpty ||
        _selectedYear == null ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // جلب الوثيقة القديمة
      DocumentReference oldDocRef =
          FirebaseFirestore.instance.collection('Courses').doc(widget.courseId);
      DocumentSnapshot oldDoc = await oldDocRef.get();

      if (!oldDoc.exists) {
        throw Exception('Course not found');
      }

      // بيانات الوثيقة القديمة
      Map<String, dynamic> oldData = oldDoc.data() as Map<String, dynamic>;

      // جلب المحاضرات (lectures) من الوثيقة القديمة
      QuerySnapshot lecturesSnapshot =
          await oldDocRef.collection('lectures').get();

      // إنشاء بيانات الوثيقة الجديدة
      Map<String, dynamic> newData = {
        'adminID': oldData['adminID'],
        'courseName': _courseNameController.text,
        'courseCode': _courseCodeController.text,
        'semester': _selectedYear,
        'date': _dateController.text,
      };

      // إنشاء وثيقة جديدة بالـ document ID الجديد
      DocumentReference newDocRef = FirebaseFirestore.instance
          .collection('Courses')
          .doc(_courseNameController.text);
      await newDocRef.set(newData);

      // نقل المحاضرات إلى الوثيقة الجديدة
      for (var lectureDoc in lecturesSnapshot.docs) {
        var lectureData = lectureDoc.data() as Map<String, dynamic>;
        await newDocRef
            .collection('lectures')
            .doc(lectureDoc.id)
            .set(lectureData);
      }

      // حذف الوثيقة القديمة
      await oldDocRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating course: $e')),
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
          'Update Course',
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
                controller: _courseNameController,
                labelText: 'Course Name',
              ),
              const SizedBox(height: 10),
              SubjectTextField(
                controller: _courseCodeController,
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
                  onPressed: _updateCourse,
                  child: const Text(
                    'Update',
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
