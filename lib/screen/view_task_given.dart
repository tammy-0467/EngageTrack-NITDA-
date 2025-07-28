import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gam_project/screen/send_task_page.dart';
import 'package:gam_project/widgets/custom_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ViewAssignedTask extends StatefulWidget {
  final String currentUserID;

  ViewAssignedTask({required this.currentUserID});

  @override
  _ViewAssignedTaskState createState() => _ViewAssignedTaskState();
}

class _ViewAssignedTaskState extends State<ViewAssignedTask> {
  Future<void> _updateTaskStatus(String taskId, int index) async {
    try {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('Client')
          .doc(widget.currentUserID)
          .collection('tasks')
          .doc(taskId)
          .get();

      var taskStatus = docSnapshot.data()?['status'];

      if (taskStatus == 1 || taskStatus == 2) {
        // Update status to 3 only if the current status is 1
        await FirebaseFirestore.instance
            .collection('Client')
            .doc(widget.currentUserID)
            .collection('tasks')
            .doc(taskId)
            .update({'status': 3});
        print('Task status updated successfully.');
      }
    } catch (e) {
      print('Error updating task status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Tasks', style: GoogleFonts.lato(),),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth / 45), //8
            child: GestureDetector(
              child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onTertiary,
                      borderRadius: BorderRadius.circular(6)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal:  screenWidth / 45, vertical: screenHeight / 95.75), //8
                    child: Text(
                      'Add task +',
                      style: GoogleFonts.lato(fontSize: screenWidth/22.5, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), //16
                    ),
                  )),
              onTap: () {
                Navigator.push(
                    context,
                    CustomNavigation(
                        child: SendTaskpage(
                          userID: widget.currentUserID,
                          taskId: '',
                        )));
              },
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Client')
            .doc(widget.currentUserID) // Use the userID passed as a parameter
            .collection('tasks')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var messageData = doc.data() as Map<String, dynamic>;
                var message = messageData['messages']['tasks1'];
                // Format timestamp to include day, month, year, hour, minute, and second
                var sentDateTime = (messageData['sentDateTime'] as Timestamp)
                    .toDate(); // Convert Firestore Timestamp to DateTime
                var formattedDateTime =
                    DateFormat('dd MMMM yyyy HH:mm:ss').format(sentDateTime);
                var taskId = doc.id;
                var taskStatus = messageData['status'];
                String buttonText;
                Color? buttonColor;

                switch (taskStatus) {
                  case 1:
                    buttonText = 'Pending';
                    buttonColor = Colors.red[400];
                    break;
                  case 2:
                    buttonText = 'Approve';
                    buttonColor = Colors.green[400];
                    break;
                  case 3:
                  case 4:
                    buttonText = 'Completed';
                    buttonColor = Colors.grey;
                    break;
                  default:
                    buttonText = 'Unknown';
                    buttonColor = Colors.black;
                }

                bool isButtonEnabled = taskStatus == 2;
                return Padding(
                  padding: EdgeInsets.only(top: screenHeight / 95.75, left: screenWidth /45, right: screenWidth / 45), //12 & 8
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onTertiary,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(message, style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onSurface),),
                          subtitle: Text(formattedDateTime, style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onSecondary),),
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/default_photo.jpg'),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                                color: buttonColor,
                                borderRadius: BorderRadius.circular(5)),
                            height: screenHeight / 27.35, // 28
                            width: screenWidth / 5.3, //68
                            child: IgnorePointer(
                              ignoring: !isButtonEnabled,
                              child: GestureDetector(
                                child: Center(
                                    child: Text(
                                  buttonText,
                                  style: GoogleFonts.lato(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                )),
                                onTap: () {
                                  _updateTaskStatus(taskId, index);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No messages found.', style: GoogleFonts.lato(),),
            );
          }
        },
      ),
    );
  }
}
