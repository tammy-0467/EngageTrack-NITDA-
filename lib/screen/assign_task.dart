import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/view_task_given.dart';
import 'package:gam_project/widgets/custom_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignTask extends StatefulWidget {
  const AssignTask({super.key});

  @override
  State<AssignTask> createState() => _AssignTaskState();
}

class _AssignTaskState extends State<AssignTask> {
  final _AssignTask =
      FirebaseFirestore.instance.collection('Client').snapshots();
  late String? _currentUserId;
  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: StreamBuilder(
        stream: _AssignTask,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Connection error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Loading...'));
          }

          final List<DocumentSnapshot> employeeData = snapshot.data!.docs;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text('Assign Task to', style: GoogleFonts.lato(),),
              elevation: 0,
            ),
            body: ListView.builder(
                itemCount: employeeData.length,
                itemBuilder: (context, index) {
                  final userData =
                      employeeData[index].data() as Map<String, dynamic>;
                  final String userID = employeeData[index].id;
                  final String name = userData['name'] ?? '';
                  final String email = userData['email'] ?? '';
                  final dynamic points = userData['points'];

                  // Exclude current user from the list
                  if (_currentUserId != null && userID == _currentUserId) {
                    return SizedBox.shrink(); // Skip rendering the current user
                  }

                  return GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight/76.6, left: screenWidth/45, right: screenWidth/45), //10, 8 & 8
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onTertiary,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(name, style: GoogleFonts.lato(),),
                          // subtitle: Text(email),
                          // trailing: Text("${points.toString()} pts"),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          CustomNavigation(
                              child: ViewAssignedTask(
                                    currentUserID: userID,
                                  )));
                    },
                  );
                }),
          );
        },
      ),
    );
  }
}
