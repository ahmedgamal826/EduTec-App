// // import 'dart:io';
// // import 'package:attendance_app/core/utils/app_colors.dart';
// // import 'package:attendance_app/features/home/presentation/views/widgets/role_selection.dart';
// // import 'package:attendance_app/features/home/presentation/views/widgets/user_text_field.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_storage/firebase_storage.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';

// // class UserDetailsScreen extends StatefulWidget {
// //   final String userId;
// //   final String name;
// //   final String email;
// //   final String image;
// //   final String password;
// //   final String role;

// //   const UserDetailsScreen({
// //     Key? key,
// //     required this.userId,
// //     required this.name,
// //     required this.email,
// //     required this.image,
// //     required this.password,
// //     required this.role,
// //   }) : super(key: key);

// //   @override
// //   _UserDetailsScreenState createState() => _UserDetailsScreenState();
// // }

// // class _UserDetailsScreenState extends State<UserDetailsScreen> {
// //   late TextEditingController _nameController;
// //   late TextEditingController _emailController;
// //   late TextEditingController _passwordController;

// //   bool _isUpdating = false;
// //   bool _isUploadingImage = false;
// //   String? _imageUrl;
// //   File? _selectedImage;
// //   String _role = "Student";

// //   @override
// //   void initState() {
// //     super.initState();
// //     _nameController = TextEditingController(text: widget.name);
// //     _emailController = TextEditingController(text: widget.email);
// //     _passwordController = TextEditingController(text: widget.password);
// //     _imageUrl = widget.image;
// //     _role = widget.role.isNotEmpty ? widget.role : "Student";
// //     print("Initial role: $_role"); // تحقق من القيمة الأولية

// //     _loadUserRole();
// //   }

// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _pickImage() async {
// //     final ImagePicker picker = ImagePicker();
// //     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

// //     if (image != null) {
// //       File imageFile = File(image.path);

// //       setState(() {
// //         _selectedImage = imageFile;
// //         _isUploadingImage = true;
// //       });

// //       await _uploadImage(imageFile);
// //     }
// //   }

// //   Future<void> _uploadImage(File imageFile) async {
// //     try {
// //       String fileName = "profile_${widget.userId}.jpg";
// //       Reference ref = FirebaseStorage.instance
// //           .ref()
// //           .child("profile_pictures")
// //           .child(fileName);

// //       UploadTask uploadTask = ref.putFile(imageFile);
// //       TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

// //       String downloadUrl = await snapshot.ref.getDownloadURL();

// //       setState(() {
// //         _imageUrl = downloadUrl;
// //         _isUploadingImage = false;
// //       });

// //       await FirebaseFirestore.instance
// //           .collection("users")
// //           .doc(widget.userId)
// //           .update({
// //         "image": downloadUrl,
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _isUploadingImage = false;
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error uploading image: $e")),
// //       );
// //     }
// //   }

// //   Future<void> _loadUserRole() async {
// //     try {
// //       var docSnapshot = await FirebaseFirestore.instance
// //           .collection("users")
// //           .doc(widget.userId)
// //           .get();

// //       if (docSnapshot.exists) {
// //         var userRole = docSnapshot.data()?["role"] ?? "Student";
// //         setState(() {
// //           _role = userRole;
// //         });
// //         print("Loaded role: $_role");
// //       }
// //     } catch (e) {
// //       print("Error loading role: $e");
// //     }
// //   }

// //   // دالة لتحديث الـ role في Firebase
// //   Future<void> _updateUserRole(String newRole) async {
// //     try {
// //       await FirebaseFirestore.instance
// //           .collection("users")
// //           .doc(widget.userId)
// //           .update({
// //         "role": newRole,
// //       });

// //       setState(() {
// //         _role = newRole;
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Role updated successfully!")),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error updating role: $e")),
// //       );
// //     }
// //   }

// //   Future<void> _updateUserData() async {
// //     setState(() {
// //       _isUpdating = true;
// //     });

// //     try {
// //       await FirebaseFirestore.instance
// //           .collection("users")
// //           .doc(widget.userId)
// //           .update({
// //         "name": _nameController.text.trim(),
// //         "email": _emailController.text.trim(),
// //         "password": _passwordController.text.trim(),
// //         "role": _role, // تحديث role في Firebase
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("User data updated successfully!")),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error updating user: $e")),
// //       );
// //     }

// //     Navigator.pop(context);
// //     setState(() {
// //       _isUpdating = false;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         title: const Text(
// //           "User Details",
// //           style: TextStyle(
// //             fontSize: 25,
// //             color: Colors.white,
// //           ),
// //         ),
// //         centerTitle: true,
// //         backgroundColor: AppColors.primaryColor,
// //         elevation: 0,
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
// //           child: Column(
// //             children: [
// //               Stack(
// //                 alignment: Alignment.bottomRight,
// //                 children: [
// //                   CircleAvatar(
// //                     radius: 55,
// //                     backgroundColor: Colors.white,
// //                     backgroundImage: _selectedImage != null
// //                         ? FileImage(_selectedImage!)
// //                         : NetworkImage(_imageUrl!) as ImageProvider,
// //                   ),
// //                   if (_isUploadingImage)
// //                     const Positioned.fill(
// //                       child: Center(
// //                         child: CircularProgressIndicator(),
// //                       ),
// //                     ),
// //                   GestureDetector(
// //                     onTap: _pickImage,
// //                     child: Container(
// //                       padding: const EdgeInsets.all(6),
// //                       decoration: const BoxDecoration(
// //                         color: AppColors.primaryColor,
// //                         shape: BoxShape.circle,
// //                       ),
// //                       child:
// //                           const Icon(Icons.edit, color: Colors.white, size: 18),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 20),
// //               UserTextField(
// //                 controller: _nameController,
// //                 label: "Name",
// //                 icon: Icons.person,
// //               ),
// //               UserTextField(
// //                 controller: _emailController,
// //                 label: "Email",
// //                 icon: Icons.email,
// //               ),
// //               UserTextField(
// //                 controller: _passwordController,
// //                 label: "Password",
// //                 icon: Icons.lock,
// //               ),
// //               const SizedBox(height: 20),
// //               RoleSelection(
// //                 role: _role,
// //                 onChanged: (value) {
// //                   setState(() {
// //                     _role = value;
// //                   });
// //                 },
// //               ),
// //               const SizedBox(height: 30),
// //               _isUpdating
// //                   ? const CircularProgressIndicator(
// //                       color: AppColors.primaryColor,
// //                     )
// //                   : ElevatedButton(
// //                       onPressed: _updateUserData,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: AppColors.primaryColor,
// //                         padding: const EdgeInsets.symmetric(
// //                             horizontal: 40, vertical: 12),
// //                       ),
// //                       child: const Text(
// //                         "Save Changes",
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:io';
// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/role_selection.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/user_text_field.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class UserDetailsScreen extends StatefulWidget {
//   final String userId;
//   final String name;
//   final String email;
//   final String image;
//   final String password;
//   final String role;

//   const UserDetailsScreen({
//     Key? key,
//     required this.userId,
//     required this.name,
//     required this.email,
//     required this.image,
//     required this.password,
//     required this.role,
//   }) : super(key: key);

//   @override
//   _UserDetailsScreenState createState() => _UserDetailsScreenState();
// }

// class _UserDetailsScreenState extends State<UserDetailsScreen> {
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _passwordController;

//   bool _isUploadingImage = false;
//   String? _imageUrl;
//   File? _selectedImage;
//   String _role = "Student";

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.name);
//     _emailController = TextEditingController(text: widget.email);
//     _passwordController = TextEditingController(text: widget.password);
//     _imageUrl = widget.image;
//     _role = widget.role.isNotEmpty ? widget.role : "Student";
//     print("Initial role: $_role"); // تحقق من القيمة الأولية
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       File imageFile = File(image.path);

//       setState(() {
//         _selectedImage = imageFile;
//         _isUploadingImage = true;
//       });

//       await _uploadImage(imageFile);
//     }
//   }

//   Future<void> _uploadImage(File imageFile) async {
//     try {
//       String fileName = "profile_${widget.userId}.jpg";
//       Reference ref = FirebaseStorage.instance
//           .ref()
//           .child("profile_pictures")
//           .child(fileName);

//       UploadTask uploadTask = ref.putFile(imageFile);
//       TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

//       String downloadUrl = await snapshot.ref.getDownloadURL();

//       setState(() {
//         _imageUrl = downloadUrl;
//         _isUploadingImage = false;
//       });

//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(widget.userId)
//           .update({
//         "image": downloadUrl,
//       });
//     } catch (e) {
//       setState(() {
//         _isUploadingImage = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error uploading image: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "User Details",
//           style: TextStyle(
//             fontSize: 25,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: AppColors.primaryColor,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           child: Column(
//             children: [
//               Stack(
//                 alignment: Alignment.bottomRight,
//                 children: [
//                   CircleAvatar(
//                     radius: 55,
//                     backgroundColor: Colors.white,
//                     backgroundImage: _selectedImage != null
//                         ? FileImage(_selectedImage!)
//                         : NetworkImage(_imageUrl!) as ImageProvider,
//                   ),
//                   if (_isUploadingImage)
//                     const Positioned.fill(
//                       child: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//                   // GestureDetector(
//                   //   onTap: _pickImage,
//                   //   child: Container(
//                   //     padding: const EdgeInsets.all(6),
//                   //     decoration: const BoxDecoration(
//                   //       color: AppColors.primaryColor,
//                   //       shape: BoxShape.circle,
//                   //     ),
//                   //     child:
//                   //         const Icon(Icons.edit, color: Colors.white, size: 18),
//                   //   ),
//                   // ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               UserTextField(
//                 controller: _nameController,
//                 label: "Name",
//                 icon: Icons.person,
//                 enabled: false, // منع التعديل على الحقل
//               ),
//               UserTextField(
//                 controller: _emailController,
//                 label: "Email",
//                 icon: Icons.email,
//                 enabled: false, // منع التعديل على الحقل
//               ),
//               UserTextField(
//                 controller: _passwordController,
//                 label: "Password",
//                 icon: Icons.lock,
//                 enabled: false, // منع التعديل على الحقل
//               ),
//               const SizedBox(height: 20),
//               Text('Role : $_role'),
//               RoleSelection(
//                 role: _role,
//                 onChanged: (value) {
//                   setState(() {
//                     _role = value;
//                   });
//                 },
//                 enabled: false, // منع تعديل الدور
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/role_selection.dart';
// import 'package:attendance_app/features/home/presentation/views/widgets/user_text_field.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class UserDetailsScreen extends StatefulWidget {
//   final String userId;
//   final String name;
//   final String email;
//   final String image;
//   final String password;
//   final String role;

//   const UserDetailsScreen({
//     Key? key,
//     required this.userId,
//     required this.name,
//     required this.email,
//     required this.image,
//     required this.password,
//     required this.role,
//   }) : super(key: key);

//   @override
//   _UserDetailsScreenState createState() => _UserDetailsScreenState();
// }

// class _UserDetailsScreenState extends State<UserDetailsScreen> {
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _passwordController;

//   bool _isUploadingImage = false;
//   String? _imageUrl;
//   File? _selectedImage;
//   String _role = "Student";

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.name);
//     _emailController = TextEditingController(text: widget.email);
//     _passwordController = TextEditingController(text: widget.password);
//     _imageUrl = widget.image;
//     _role = widget.role.isNotEmpty ? widget.role : "Student";
//     print("Initial role: $_role"); // تحقق من القيمة الأولية
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       File imageFile = File(image.path);

//       setState(() {
//         _selectedImage = imageFile;
//         _isUploadingImage = true;
//       });

//       await _uploadImage(imageFile);
//     }
//   }

//   Future<void> _uploadImage(File imageFile) async {
//     try {
//       String fileName = "profile_${widget.userId}.jpg";
//       Reference ref = FirebaseStorage.instance
//           .ref()
//           .child("profile_pictures")
//           .child(fileName);

//       UploadTask uploadTask = ref.putFile(imageFile);
//       TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

//       String downloadUrl = await snapshot.ref.getDownloadURL();

//       setState(() {
//         _imageUrl = downloadUrl;
//         _isUploadingImage = false;
//       });

//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(widget.userId)
//           .update({
//         "image": downloadUrl,
//       });
//     } catch (e) {
//       setState(() {
//         _isUploadingImage = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error uploading image: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // تغيير خلفية الشاشة إلى الأسود
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "User Details",
//           style: TextStyle(
//             fontSize: 25,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: AppColors.primaryColor,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           child: Column(
//             children: [
//               Stack(
//                 alignment: Alignment.bottomRight,
//                 children: [
//                   CircleAvatar(
//                     radius: 55,
//                     backgroundColor: Colors.white,
//                     backgroundImage: _selectedImage != null
//                         ? FileImage(_selectedImage!)
//                         : NetworkImage(_imageUrl!) as ImageProvider,
//                   ),
//                   if (_isUploadingImage)
//                     const Positioned.fill(
//                       child: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//                   // إضافة زرين لتغيير الصورة عند الضغط عليها
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: const BoxDecoration(
//                         color: AppColors.primaryColor,
//                         shape: BoxShape.circle,
//                       ),
//                       child:
//                           const Icon(Icons.edit, color: Colors.white, size: 18),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               UserTextField(
//                 controller: _nameController,
//                 label: "Name",
//                 icon: Icons.person,
//                 enabled: false,
//               ),
//               UserTextField(
//                 controller: _emailController,
//                 label: "Email",
//                 icon: Icons.email,
//                 enabled: false,
//               ),
//               UserTextField(
//                 controller: _passwordController,
//                 label: "Password",
//                 icon: Icons.lock,
//                 enabled: false,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Role: $_role',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // عرض الدور بدون إمكانية التعديل
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.black12,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   _role,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
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

import 'dart:io';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/role_selection.dart';
import 'package:attendance_app/features/home/presentation/views/widgets/user_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String image;
  final String password;
  final String role;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.image,
    required this.password,
    required this.role,
  });

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isUploadingImage = false;
  String? _imageUrl;
  File? _selectedImage;
  String _role = "Student";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
    _imageUrl = widget.image;
    _role = widget.role.isNotEmpty ? widget.role : "Student";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);

      setState(() {
        _selectedImage = imageFile;
        _isUploadingImage = true;
      });

      await _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String fileName = "profile_${widget.userId}.jpg";
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("profile_pictures")
          .child(fileName);

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
        _isUploadingImage = false;
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({
        "image": downloadUrl,
      });
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : Colors.white, // White background for a clean look
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "User Details",
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60, // Increased size for better appearance
                    backgroundColor: Colors.white,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : NetworkImage(_imageUrl!) as ImageProvider,
                  ),
                  if (_isUploadingImage)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  // GestureDetector(
                  //   onTap: _pickImage,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(8),
                  //     decoration: const BoxDecoration(
                  //       color: AppColors.primaryColor,
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child:
                  //         const Icon(Icons.edit, color: Colors.white, size: 22),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              UserTextField(
                controller: _nameController,
                label: "Name",
                icon: Icons.person,
                enabled: false,
              ),
              const SizedBox(height: 12),
              UserTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                enabled: false,
              ),
              const SizedBox(height: 12),
              UserTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock,
                enabled: false,
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white
                      : AppColors
                          .primaryColor, // Soft background color for better contrast
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Role: $_role',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.black : Colors.white,
                    // Highlight role with primary color
                    fontWeight: FontWeight.bold,
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
