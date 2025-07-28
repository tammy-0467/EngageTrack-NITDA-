import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/view_task_given.dart';
import 'package:gam_project/widgets/custom_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> getCurrentUserId() async {
  String? userId;
  try {
    // Check if a user is currently signed in
    if (FirebaseAuth.instance.currentUser != null) {
      // Get the current user ID
      userId = FirebaseAuth.instance.currentUser!.uid;
    }
  } catch (e) {
    print('Error getting current user ID: $e');
  }
  return userId;
}

class SendTaskpage extends StatefulWidget {
  final String userID;
  final String taskId;

  const SendTaskpage({Key? key, required this.userID, required this.taskId})
      : super(key: key);

  @override
  State<SendTaskpage> createState() => _SendTaskpageState();
}

class _SendTaskpageState extends State<SendTaskpage> {
  TextEditingController _enteredTextController = TextEditingController();
  TextEditingController _dropdownController = TextEditingController();
  int maxWordsPerLine = 5;
  bool _sendingMessage = false; // Flag to track if sending message

  String? currentUserId;

  final CollectionReference _clientsCollection =
      FirebaseFirestore.instance.collection('Client');
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUserId().then((userId) {
      setState(() {
        currentUserId = userId;
      });
    });
  }

  Future<void> addPoint() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Client')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          int currentPoints = userDoc['points'] ?? 0;
          int newPoints = currentPoints + 1;

          await FirebaseFirestore.instance
              .collection('Client')
              .doc(user.uid)
              .update({'points': newPoints});
        }
      }
    } catch (error) {
      print(error);
    }
  }

  void sendMessage(String userID, String message) {
    setState(() {
      _sendingMessage = true; // Set sending flag to true
    });

    // Create a new document reference without an ID
    DocumentReference newDocRef = FirebaseFirestore.instance
        .collection('Client')
        .doc(userID)
        .collection('tasks')
        .doc();

    // Get the document ID as a string
    String taskId = newDocRef.id;

    // Add the document with the message, timestamp, and taskId
    newDocRef.set({
      'taskId': taskId,
      'messages': {
        'tasks1': message,
      },
      'sentDateTime': Timestamp.now(), // Add a timestamp
      'status': 1
    }).then((_) {
      // Document added successfully
      print('Message sent successfully with task ID: $taskId');
      // Deduct points from the current user's available points
      addPoint();

      setState(() {
        _sendingMessage = false; // Set sending flag to false
      });

      // Navigate to ViewAssignedTask
      Navigator.pushReplacement(
        context,
        CustomNavigation(
            child: ViewAssignedTask(currentUserID: userID)),
      );
    }).catchError((error) {
      // Handle errors
      print('Error sending message: $error');
      setState(() {
        _sendingMessage = false; // Set sending flag to false
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
        stream: _clientsCollection.doc(widget.userID).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Connection error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Loading...'));
          }

          final clientData = snapshot.data!.data() as Map<String, dynamic>;
          final String uname = clientData['username'] ?? '';
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text("Assign Task", style: GoogleFonts.lato(),),
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              body: Padding(
                padding: EdgeInsets.only(top: screenHeight / 95.75), //8
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Enter task for $uname here',
                      style: GoogleFonts.lato(
                        fontSize: screenWidth/18, //20
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth / 30, vertical: screenHeight / 76.6), // 12 & 10
                      child: TextField(
                        onChanged: (text) {
                          // Your text field logic here
                        },
                        maxLines: null,
                        controller: _enteredTextController,
                        decoration: InputDecoration(
                          fillColor: Theme.of(context).colorScheme.primary,
                          labelStyle: GoogleFonts.lato(
                              color: Theme.of(context).colorScheme.primary),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          hintStyle: GoogleFonts.lato(
                              color: Theme.of(context).colorScheme.onSurface,),
                          hintText: 'Enter your text here...',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: screenWidth/30, horizontal: screenHeight/76.6), //12 & 10
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth/20, vertical: screenHeight/42.55), //18
                      child: _sendingMessage
                          ? CircularProgressIndicator() // Show progress indicator
                          : ElevatedButton(
                              onPressed: () {
                                String userID =
                                    widget.userID; // Get userID from widget
                                String message = _enteredTextController
                                    .text; // Get message from text field
                                sendMessage(userID, message);
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Color(0xFFFFFFFF)),
                              ),
                              child: Center(
                                child: Text(
                                  'Send',
                                  style: GoogleFonts.lato(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth /24, //15
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:gam_project/screen/view_task_given.dart';

// Future<String?> getCurrentUserId() async {
//   String? userId;
//   try {
//     // Check if a user is currently signed in
//     if (FirebaseAuth.instance.currentUser != null) {
//       // Get the current user ID
//       userId = FirebaseAuth.instance.currentUser!.uid;
//     }
//   } catch (e) {
//     print('Error getting current user ID: $e');
//   }
//   return userId;
// }

// class SendTaskpage extends StatefulWidget {
//   final String userID;
//   final String taskId;

//   const SendTaskpage({Key? key, required this.userID, required this.taskId})
//       : super(key: key);

//   @override
//   State<SendTaskpage> createState() => _SendTaskpageState();
// }

// class _SendTaskpageState extends State<SendTaskpage> {
//   TextEditingController _enteredTextController = TextEditingController();
//   TextEditingController _dropdownController = TextEditingController();
//   int maxWordsPerLine = 5;
// bool _sendingMessage = false; // Flag to track if sending message

//   String? currentUserId;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentUserId().then((userId) {
//       setState(() {
//         currentUserId = userId;
//       });
//     });
//   }

//   void sendMessage(String userID, String message) {
//      setState(() {
//       _sendingMessage = true; // Set sending flag to true
//     });
//     // Create a new document reference without an ID
//     DocumentReference newDocRef = FirebaseFirestore.instance
//         .collection('Client')
//         .doc(userID)
//         .collection('tasks')
//         .doc();

//     // Get the document ID as a string
//     String taskId = newDocRef.id;

//     // Add the document with the message, timestamp, and taskId
//     newDocRef.set({
//       'taskId': taskId,
//       'messages': {
//         'tasks1': message,
//       },
//       'sentDateTime': Timestamp.now(), // Add a timestamp
//       'status': 1
//     }).then((_) {
//       // Document added successfully
//       print('Message sent successfully with task ID: $taskId');
//       setState(() {
//         _sendingMessage = false; // Set sending flag to false
//       });

//       // Navigate to ViewAssignedTask
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) => ViewAssignedTask(currentUserID: userID)),
//       );
//       ;
//     }).catchError((error) {
//       // Handle errors
//       print('Error sending message: $error');
//       setState(() {
//         _sendingMessage = false; // Set sending flag to false
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             Text('Message'),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
//               child: TextField(
//                 onChanged: (text) {
//                   // Your text field logic here
//                 },
//                 maxLines: null,
//                 controller: _enteredTextController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your text here...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(18.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   String userID = widget.userID; // Get userID from widget
//                   String message = _enteredTextController
//                       .text; // Get message from text field
//                   sendMessage(userID, message);
//                 },
//                 style: ButtonStyle(
//                   backgroundColor:
//                       MaterialStateProperty.all<Color>(Colors.indigo),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Send',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
