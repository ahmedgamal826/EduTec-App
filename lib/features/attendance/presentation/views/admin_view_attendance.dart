import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/features/attendance/presentation/views/update_attendance_view.dart';

class AdminViewAttendance extends StatefulWidget {
  final DateTime date;

  const AdminViewAttendance({super.key, required this.date});

  @override
  _AdminViewAttendanceState createState() => _AdminViewAttendanceState();
}

class _AdminViewAttendanceState extends State<AdminViewAttendance> {
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String formattedDate = DateFormat('EEEE, d MMM').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Students Attendance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff70ACF4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with date
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Date header tapped!")),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Color(0xff70ACF4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Student List from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("role", isEqualTo: "student")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No students found."));
                  }
                  final studentDocs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: studentDocs.length,
                    itemBuilder: (context, index) {
                      final studentData =
                          studentDocs[index].data() as Map<String, dynamic>;
                      final name = studentData['name'] ?? '';
                      final email = studentData['email'] ?? '';
                      final imageUrl = studentData['image'] ?? '';
                      final attendance = studentData['attendance'] ?? '';
                      bool isCurrentUser = email == currentUser?.email;

                      return Card(
                        color: isCurrentUser
                            ? Colors.orange
                            : const Color(0xff70ACF4),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          side: isCurrentUser
                              ? const BorderSide(
                                  color: Colors.yellowAccent, width: 3)
                              : BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row with avatar, name and email
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl)
                                        : null,
                                    child: imageUrl.isEmpty
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Row with update and delete icons (centered) and Present chip at right end
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.white),
                                          onPressed: () {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.warning,
                                              animType: AnimType.scale,
                                              title: 'Confirm Delete',
                                              desc:
                                                  'Are you sure you want to delete this student?',
                                              btnOkOnPress: () {
                                                // حذف الطالب من Firestore
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(studentDocs[index].id)
                                                    .delete();
                                              },
                                              btnCancelOnPress: () {
                                                // إغلاق الحوار دون حذف
                                              },
                                            ).show();
                                          },
                                        ),
                                        const SizedBox(width: 20),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.white),
                                          onPressed: () async {
                                            Map<String, dynamic>?
                                                updatedStudent =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateStudentPage(
                                                        studentId:
                                                            studentDocs[index]
                                                                .id,
                                                        student: studentData),
                                              ),
                                            );
                                            if (updatedStudent != null) {
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(studentDocs[index].id)
                                                  .update(updatedStudent);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Present chip at the right end
                                  Chip(
                                    label: Text(
                                      attendance,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: attendance == 'Absent'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}
