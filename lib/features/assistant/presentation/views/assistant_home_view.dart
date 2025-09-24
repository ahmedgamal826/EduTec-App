// // import 'package:attendance_app/features/auth/presentations/views/add_user_screen.dart';
// // import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
// // import 'package:attendance_app/features/assistant/presentation/views/widgets/assistant_drawer.dart';
// // import 'package:awesome_dialog/awesome_dialog.dart';
// // import 'package:flutter/material.dart';
// // import 'package:attendance_app/features/home/presentation/views/user_details_view.dart';
// // import 'package:attendance_app/core/utils/app_colors.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:provider/provider.dart';
// //
// // class AssistantHomeView extends StatefulWidget {
// //   const AssistantHomeView({Key? key}) : super(key: key);
// //
// //   @override
// //   State<AssistantHomeView> createState() => _AssistantHomeViewState();
// // }
// //
// // class _AssistantHomeViewState extends State<AssistantHomeView> {
// //   List<QueryDocumentSnapshot> accounts = [];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
// //
// //     return Scaffold(
// //       backgroundColor: isDarkMode ? Colors.black : AppColors.whiteColor,
// //       drawer: const AssistantDrawer(),
// //       appBar: AppBar(
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         // leading: const Text(''),
// //         title: const Text(
// //           "Accounts Screen",
// //           style: TextStyle(
// //             fontSize: 25,
// //             color: Colors.white,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         centerTitle: true,
// //         backgroundColor: isDarkMode ? Colors.grey[900] : AppColors.primaryColor,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: StreamBuilder<QuerySnapshot>(
// //           stream: FirebaseFirestore.instance.collection("users").snapshots(),
// //           builder: (context, snapshot) {
// //             if (snapshot.connectionState == ConnectionState.waiting) {
// //               return const Center(
// //                   child: CircularProgressIndicator(
// //                 color: AppColors.primaryColor,
// //               ));
// //             }
// //             if (snapshot.hasError) {
// //               return const Center(child: Text("Error loading data"));
// //             }
// //             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //               return const Center(child: Text("No accounts available"));
// //             }
// //
// //             // تخزين الحسابات في المتغير
// //             accounts = snapshot.data!.docs;
// //
// //             return ListView.builder(
// //               itemCount: accounts.length,
// //               itemBuilder: (context, index) {
// //                 var account = accounts[index];
// //                 String userId = account.id;
// //                 String name = account["name"];
// //                 String email = account["email"];
// //                 String role = account["role"];
// //                 String image = account["image"];
// //
// //                 return Dismissible(
// //                   key: Key(userId),
// //                   direction: DismissDirection.endToStart,
// //                   confirmDismiss: (direction) async {
// //                     await AwesomeDialog(
// //                       context: context,
// //                       dialogType: DialogType.warning,
// //                       animType: AnimType.topSlide,
// //                       title: 'Delete User',
// //                       desc: 'Are you sure you want to delete $name?',
// //                       btnCancelOnPress: () {},
// //                       btnOkOnPress: () async {
// //                         // Perform deletion from Firestore
// //                         await FirebaseFirestore.instance
// //                             .collection('users')
// //                             .doc(userId)
// //                             .delete();
// //
// //                         setState(() {
// //                           accounts.removeAt(index);
// //                         });
// //
// //                         // ScaffoldMessenger.of(context).showSnackBar(
// //                         //   const SnackBar(content: Text('User deleted')),
// //                         // );
// //                       },
// //                     ).show();
// //
// //                     return false;
// //                   },
// //                   background: Container(
// //                     color: Colors.red,
// //                     alignment: Alignment.centerRight,
// //                     child: const Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: 20.0),
// //                       child: Icon(Icons.delete, color: Colors.white),
// //                     ),
// //                   ),
// //                   child: GestureDetector(
// //                     onTap: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (context) => UserDetailsScreen(
// //                             userId: userId,
// //                             name: name,
// //                             email: email,
// //                             image: image,
// //                             role: role,
// //                             password: account["password"] ?? "Not Available",
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                     child: Card(
// //                       color: Colors.white,
// //                       elevation: 7,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       margin: const EdgeInsets.symmetric(vertical: 8),
// //                       child: Padding(
// //                         padding: const EdgeInsets.all(16.0),
// //                         child: Row(
// //                           children: [
// //                             CircleAvatar(
// //                               radius: 25,
// //                               backgroundImage: NetworkImage(image),
// //                             ),
// //                             const SizedBox(width: 12),
// //                             Expanded(
// //                               child: Padding(
// //                                 padding:
// //                                     const EdgeInsets.symmetric(horizontal: 15),
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(
// //                                       name,
// //                                       maxLines: 1,
// //                                       overflow: TextOverflow.ellipsis,
// //                                       style: const TextStyle(
// //                                         fontSize: 16,
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                     ),
// //                                     Text(
// //                                       email,
// //                                       maxLines: 1,
// //                                       overflow: TextOverflow.ellipsis,
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                             Text(
// //                               role,
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             );
// //           },
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (context) => const AddUserScreen(),
// //             ),
// //           );
// //         },
// //         backgroundColor: isDarkMode ? Colors.white : AppColors.primaryColor,
// //         child: Icon(
// //           Icons.add,
// //           color: isDarkMode ? Colors.black : Colors.white,
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:attendance_app/features/auth/presentations/views/add_user_screen.dart';
// import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
// import 'package:attendance_app/features/assistant/presentation/views/widgets/assistant_drawer.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:attendance_app/features/home/presentation/views/user_details_view.dart';
// import 'package:attendance_app/core/utils/app_colors.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';

// class AssistantHomeView extends StatefulWidget {
//   const AssistantHomeView({super.key});

//   @override
//   State<AssistantHomeView> createState() => _AssistantHomeViewState();
// }

// class _AssistantHomeViewState extends State<AssistantHomeView> {
//   List<QueryDocumentSnapshot> accounts = [];
//   String filterRole = 'All'; // متغير لتتبع نوع الفلتر

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

//     return Scaffold(
//       backgroundColor: isDarkMode ? Colors.black : AppColors.whiteColor,
//       drawer: const AssistantDrawer(),
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "Accounts Screen",
//           style: TextStyle(
//             fontSize: 25,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: isDarkMode ? Colors.grey[900] : AppColors.primaryColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Radio Buttons للفلتر
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Radio<String>(
//                   value: 'All',
//                   groupValue: filterRole,
//                   onChanged: (value) {
//                     setState(() {
//                       filterRole = value!;
//                     });
//                   },
//                 ),
//                 const Text('All', style: TextStyle(fontSize: 16)),
//                 const SizedBox(width: 20),
//                 Radio<String>(
//                   value: 'student',
//                   groupValue: filterRole,
//                   onChanged: (value) {
//                     setState(() {
//                       filterRole = value!;
//                     });
//                   },
//                 ),
//                 const Text('Student', style: TextStyle(fontSize: 16)),
//                 const SizedBox(width: 20),
//                 Radio<String>(
//                   value: 'Admin',
//                   groupValue: filterRole,
//                   onChanged: (value) {
//                     setState(() {
//                       filterRole = value!;
//                     });
//                   },
//                 ),
//                 const Text('Admin', style: TextStyle(fontSize: 16)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // قائمة الحسابات
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: filterRole == 'All'
//                     ? FirebaseFirestore.instance.collection("users").snapshots()
//                     : FirebaseFirestore.instance
//                     .collection("users")
//                     .where("role", isEqualTo: filterRole)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(
//                         child: CircularProgressIndicator(
//                           color: AppColors.primaryColor,
//                         ));
//                   }
//                   if (snapshot.hasError) {
//                     return const Center(child: Text("Error loading data"));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text("No accounts available"));
//                   }

//                   // تخزين الحسابات في المتغير
//                   accounts = snapshot.data!.docs;

//                   return ListView.builder(
//                     itemCount: accounts.length,
//                     itemBuilder: (context, index) {
//                       var account = accounts[index];
//                       String userId = account.id;
//                       String name = account["name"];
//                       String email = account["email"];
//                       String role = account["role"];
//                       String image = account["image"];

//                       return Dismissible(
//                         key: Key(userId),
//                         direction: DismissDirection.endToStart,
//                         confirmDismiss: (direction) async {
//                           await AwesomeDialog(
//                             context: context,
//                             dialogType: DialogType.warning,
//                             animType: AnimType.topSlide,
//                             title: 'Delete User',
//                             desc: 'Are you sure you want to delete $name?',
//                             btnCancelOnPress: () {},
//                             btnOkOnPress: () async {
//                               // Perform deletion from Firestore
//                               await FirebaseFirestore.instance
//                                   .collection('users')
//                                   .doc(userId)
//                                   .delete();

//                               setState(() {
//                                 accounts.removeAt(index);
//                               });
//                             },
//                           ).show();

//                           return false;
//                         },
//                         background: Container(
//                           color: Colors.red,
//                           alignment: Alignment.centerRight,
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 20.0),
//                             child: Icon(Icons.delete, color: Colors.white),
//                           ),
//                         ),
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => UserDetailsScreen(
//                                   userId: userId,
//                                   name: name,
//                                   email: email,
//                                   image: image,
//                                   role: role,
//                                   password: account["password"] ?? "Not Available",
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 7,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Row(
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 25,
//                                     backgroundImage: NetworkImage(image),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 15),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             name,
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           Text(
//                                             email,
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     role,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AddUserScreen(),
//             ),
//           );
//         },
//         backgroundColor: isDarkMode ? Colors.white : AppColors.primaryColor,
//         child: Icon(
//           Icons.add,
//           color: isDarkMode ? Colors.black : Colors.white,
//         ),
//       ),
//     );
//   }
// }

import 'package:attendance_app/features/auth/presentations/views/add_user_screen.dart';
import 'package:attendance_app/features/home/presentation/manager/provider/dark_mode_provider.dart';
import 'package:attendance_app/features/assistant/presentation/views/widgets/assistant_drawer.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/features/home/presentation/views/user_details_view.dart';
import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class AssistantHomeView extends StatefulWidget {
  const AssistantHomeView({super.key});

  @override
  State<AssistantHomeView> createState() => _AssistantHomeViewState();
}

class _AssistantHomeViewState extends State<AssistantHomeView> {
  List<QueryDocumentSnapshot> accounts = [];
  String filterRole = 'All'; // متغير لتتبع نوع الفلتر

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    return DefaultTabController(
      length: 3, // عدد الـ tabs
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : AppColors.whiteColor,
        drawer: const AssistantDrawer(),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Accounts Screen",
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor:
              isDarkMode ? Colors.grey[900] : AppColors.primaryColor,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Student'),
              Tab(text: 'Admin'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: All
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No accounts available"));
                  }

                  accounts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      var account = accounts[index];
                      String userId = account.id;
                      String name = account["name"];
                      String email = account["email"];
                      String role = account["role"];
                      String image = account["image"];

                      return Dismissible(
                        key: Key(userId),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          await AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.topSlide,
                            title: 'Delete User',
                            desc: 'Are you sure you want to delete $name?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .delete();
                              setState(() {
                                accounts.removeAt(index);
                              });
                            },
                          ).show();
                          return false;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserDetailsScreen(
                                  userId: userId,
                                  name: name,
                                  email: email,
                                  image: image,
                                  role: role,
                                  password:
                                      account["password"] ?? "Not Available",
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 7,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(image),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    role,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Tab 2: Student
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("role", isEqualTo: "student")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No accounts available"));
                  }

                  accounts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      var account = accounts[index];
                      String userId = account.id;
                      String name = account["name"];
                      String email = account["email"];
                      String role = account["role"];
                      String image = account["image"];

                      return Dismissible(
                        key: Key(userId),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          await AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.topSlide,
                            title: 'Delete User',
                            desc: 'Are you sure you want to delete $name?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .delete();
                              setState(() {
                                accounts.removeAt(index);
                              });
                            },
                          ).show();
                          return false;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserDetailsScreen(
                                  userId: userId,
                                  name: name,
                                  email: email,
                                  image: image,
                                  role: role,
                                  password:
                                      account["password"] ?? "Not Available",
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 7,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(image),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    role,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Tab 3: Admin
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("role", isEqualTo: "Admin")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No accounts available"));
                  }

                  accounts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      var account = accounts[index];
                      String userId = account.id;
                      String name = account["name"];
                      String email = account["email"];
                      String role = account["role"];
                      String image = account["image"];

                      return Dismissible(
                        key: Key(userId),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          await AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.topSlide,
                            title: 'Delete User',
                            desc: 'Are you sure you want to delete $name?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .delete();
                              setState(() {
                                accounts.removeAt(index);
                              });
                            },
                          ).show();
                          return false;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserDetailsScreen(
                                  userId: userId,
                                  name: name,
                                  email: email,
                                  image: image,
                                  role: role,
                                  password:
                                      account["password"] ?? "Not Available",
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 7,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(image),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    role,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddUserScreen(),
              ),
            );
          },
          backgroundColor: isDarkMode ? Colors.white : AppColors.primaryColor,
          child: Icon(
            Icons.add,
            color: isDarkMode ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
