import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CeoMsgToAllUser extends StatefulWidget {
  const CeoMsgToAllUser({Key? key}) : super(key: key);

  @override
  _CeoMsgToAllUserState createState() => _CeoMsgToAllUserState();
}

class _CeoMsgToAllUserState extends State<CeoMsgToAllUser> {
  TextEditingController _enteredTextController = TextEditingController();
  bool _sendingMessage = false;

  void sendGeneralMessage(String message) {
    setState(() {
      _sendingMessage = true;
    });

    FirebaseFirestore.instance
        .collection('Announcement')
        .doc('GeneralMessage')
        .collection('messages')
        .add({
      'message': message,
      'timeSent': Timestamp.now(),
    }).then((_) {
      // Message sent successfully
      setState(() {
        _sendingMessage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your message has been successfully sent.'),
          duration: Duration(seconds: 2),
        ),
      );
      print('General message sent successfully');
      // Clear the text field
      _enteredTextController.clear();
    }).catchError((error) {
      // Handle errors
      setState(() {
        _sendingMessage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $error'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error sending general message: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text('Corporate Communication', style: GoogleFonts.lato(),),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight/95.75), //8
            child: Text('What would you like to tell your subordinates?', style: GoogleFonts.lato(fontSize: screenWidth/24),), //15
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 30, vertical: screenHeight/76.6), //12  & 10
            child: TextField(
              onChanged: (text) {
                // Your text field logic here
              },
              maxLines: null,
              controller: _enteredTextController,
              decoration: InputDecoration(
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                labelStyle: GoogleFonts.lato(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary),
                ),
                hintStyle: GoogleFonts.lato(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSurface),
                hintText: 'Enter your text here...',
                contentPadding: EdgeInsets.symmetric(vertical: screenWidth / 45, horizontal: screenHeight / 76.6), //12 & 10
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth/20, vertical: screenHeight/42.56), //18
            child: ElevatedButton(
              onPressed: () {
                String message = _enteredTextController.text;
                sendGeneralMessage(message);
              },
              style: ButtonStyle(
                backgroundColor:
                WidgetStateProperty.all<Color>(Color(0xFF006400)),
              ),
              child: _sendingMessage
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Center(
                      child: Text(
                        'Send',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth / 24, //15
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

















// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CeoMsgToAllUser extends StatefulWidget {
//   const CeoMsgToAllUser({Key? key}) : super(key: key);

//   @override
//   _CeoMsgToAllUserState createState() => _CeoMsgToAllUserState();
// }

// class _CeoMsgToAllUserState extends State<CeoMsgToAllUser> {
//   TextEditingController _enteredTextController = TextEditingController();
//   bool _sendingMessage = false;
//   bool _messageSent = false;

//   void sendGeneralMessage(String message) {
//     setState(() {
//       _sendingMessage = true;
//       _messageSent = false;
//     });

//     FirebaseFirestore.instance
//         .collection('Announcement')
//         .doc('GeneralMessage')
//         .collection('messages')
//         .add({
//       'message': message,
//       'timeSent': Timestamp.now(),
//     }).then((_) {
//       // Message sent successfully
//       setState(() {
//         _sendingMessage = false;
//         _messageSent = true;
//       });
//       print('General message sent successfully');
//     }).catchError((error) {
//       // Handle errors
//       setState(() {
//         _sendingMessage = false;
//       });
//       print('Error sending general message: $error');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('General Message'),
//       ),
//       body: Column(
//         children: [
//           Text('Message'),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
//             child: TextField(
//               onChanged: (text) {
//                 // Your text field logic here
//               },
//               maxLines: null,
//               controller: _enteredTextController,
//               decoration: InputDecoration(
//                 hintText: 'Enter your text here...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(18.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 String message = _enteredTextController.text;
//                 sendGeneralMessage(message);
//               },
//               style: ButtonStyle(
//                 backgroundColor:
//                     MaterialStateProperty.all<Color>(Colors.indigo),
//               ),
//               child: _sendingMessage
//                   ? CircularProgressIndicator(
//                       color: Colors.white,
//                     )
//                   : Center(
//                       child: Text(
//                         'Send',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//             ),
//           ),
//           if (_messageSent)
//             AlertDialog(
//               title: Text('Message Sent'),
//               content: Text('Your message has been successfully sent.'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       _messageSent = false;
//                     });
//                     Navigator.of(context).pop();
//                   },
//                   child: Text('OK'),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }





// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';

// // class CeoMsgToAllUser extends StatelessWidget {
// //   const CeoMsgToAllUser({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     TextEditingController _enteredTextController = TextEditingController();

// //     void sendGeneralMessage(String message) {
// //       FirebaseFirestore.instance
// //           .collection('Announcement')
// //           .doc('GeneralMessage')
// //           .collection('messages')
// //           .add({
// //         'message': message,
// //         'timeSent': Timestamp.now(),
// //       }).then((_) {
// //         // Message sent successfully
// //         print('General message sent successfully');
// //       }).catchError((error) {
// //         // Handle errors
// //         print('Error sending general message: $error');
// //       });
// //     }

// //     return Scaffold(
// //         appBar: AppBar(
// //           title: Text('General Message'),
// //         ),
// //         body: Column(
// //           children: [
// //             Text('Message'),
// //             Padding(
// //               padding:
// //                   const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
// //               child: TextField(
// //                 onChanged: (text) {
// //                   // Your text field logic here
// //                 },
// //                 maxLines: null,
// //                 controller: _enteredTextController,
// //                 decoration: InputDecoration(
// //                   hintText: 'Enter your text here...',
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(18.0),
// //               child: ElevatedButton(
// //                 onPressed: () {
// //                   String message = _enteredTextController.text;
// //                   sendGeneralMessage(message);
// //                 },
// //                 style: ButtonStyle(
// //                   backgroundColor:
// //                       MaterialStateProperty.all<Color>(Colors.indigo),
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     'Send',
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 15,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ));
// //   }
// // }
