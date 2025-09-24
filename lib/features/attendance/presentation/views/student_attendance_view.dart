import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentAttendanceView extends StatelessWidget {
  final DateTime date;

  const StudentAttendanceView({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String formattedDate = DateFormat('EEEE, d MMM').format(date);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Attendance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff70ACF4),
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff70ACF4),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: CircularProgressIndicator());
                }

                var studentData = snapshot.data!.data() as Map<String, dynamic>;
                String name = studentData['name'] ?? "Unknown";
                String email = studentData['email'] ?? "No Email";
                String? imageUrl = studentData['image'];
                String attendance = studentData['attendance'] ?? '';

                return Center(
                  child: Card(
                    color: Colors.orange,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.yellowAccent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                (imageUrl != null && imageUrl.isNotEmpty)
                                    ? NetworkImage(imageUrl)
                                    : null,
                            child: (imageUrl == null || imageUrl.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 35, color: Colors.blueAccent)
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Chip(
                            label: Text(
                              attendance,
                              style: const TextStyle(
                                fontSize: 16,
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
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
