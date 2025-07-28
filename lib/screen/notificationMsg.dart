import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationToAllUser extends StatelessWidget {
  const NotificationToAllUser({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Corporate Communication',
        style: GoogleFonts.lato(fontSize: screenWidth / 18.95, fontWeight: FontWeight.bold), //19
      )),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Announcement')
              .doc('GeneralMessage')
              .collection('messages')
              .orderBy('timeSent', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final List<DocumentSnapshot> messages = snapshot.data!.docs;

            if (messages.isEmpty) {
              return Center(child: Text('No messages available'));
            }

            return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final messageData =
                      messages[index].data() as Map<String, dynamic>;
                  final String message = messageData['message'] ?? '';
                  final Timestamp timestamp =
                      messageData['timeSent'] ?? Timestamp.now();

                  // Format the date and time
                  final DateFormat dateFormat =
                      DateFormat('y MMMM d'); // Year, Month, Day
                  final DateFormat timeFormat =
                      DateFormat('h:mm a'); // Hour, Minute, AM/PM

                  final String formattedDate =
                      dateFormat.format(timestamp.toDate());
                  final String formattedTime =
                      timeFormat.format(timestamp.toDate());

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight / 76.6, left: screenWidth / 36, right: screenWidth / 36), //10
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            trailing: Text(formattedTime, style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onPrimary),),
                            leading: ClipOval(
                              child: Image.asset(
                                'assets/working.png',
                                width: screenWidth / 9, // 40
                                height: screenHeight / 19.15, // 40
                                // fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(message, style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onPrimary),),
                            subtitle: Text(formattedDate, style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onPrimary),),
                          ),
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }
}
