import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EmployeeVoice extends StatefulWidget {
  const EmployeeVoice({
    super.key,
  });

  @override
  State<EmployeeVoice> createState() => _EmployeeVoiceState();
}

class _EmployeeVoiceState extends State<EmployeeVoice>
    with SingleTickerProviderStateMixin {
  TextEditingController _voiceController = TextEditingController();
  late AnimationController controller;
  late Animation<double> flipAnim;
  String _selectedCategory = '';
  List voice = [];
  int _availablePoints = 0;
  bool _isTextInputActive = false; // Variable to track text input activity
  CollectionReference voiceRef = FirebaseFirestore.instance.collection('voice');
  late Stream<DocumentSnapshot> _userStream;

  getData() async {
    var responseBody = await voiceRef.get();
    responseBody.docs.forEach((element) {
      setState(() {
        voice.add(element.data());
      });
    });
  }


  Future<bool> containsHateSpeech(BuildContext context, String input) async {
    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/unitary/toxic-bert'),
      headers: {
        'Authorization': 'Bearer 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',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': input}),
    );

    try {
      final result = jsonDecode(response.body);

      if (result != null && result is List && result.isNotEmpty) {
        final predictions = result[0] as List;
        final toxicScore = predictions
            .firstWhere((e) => e['label'] == 'toxic', orElse: () => {'score': 0.0})['score'];

        final isHate = toxicScore > 0.7; // Adjust threshold as needed

        if (isHate && context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Toxic Content Detected"),
              content: Text("Please avoid using hateful or toxic language."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }

        return isHate;
      } else {
        print("Unexpected response: $result");
        return false;
      }
    } catch (e) {
      print("Error parsing response: $e");
      return false;
    }
  }


  Stream<DocumentSnapshot> getUserStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('Client')
          .doc(user.uid)
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  @override
  void initState() {
    getData();
    _userStream = getUserStream();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6), // Adjust the duration as needed
    )..repeat();

    flipAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.5, curve: Curves.linear),
      ),
    );

    // Add listener to the text input controller to track text input activity
    _voiceController.addListener(() {
      setState(() {
        _isTextInputActive = _voiceController.text.isNotEmpty;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _voiceController.dispose(); // Dispose of the text input controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Ideas', style: GoogleFonts.lato(),);
            } else {
              _availablePoints = snapshot.data?['availablePoints'] ?? 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voice',
                    style: GoogleFonts.lato(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight / 38.3), //20
                        child: Lottie.asset(
                          'assets/animation4.json',
                          height: screenHeight / 12.77, //60
                          width: screenWidth / 6, // 60
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top:screenHeight / 95.75), //8
                        child: Text(_availablePoints.toString(),
                            style: GoogleFonts.lato(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                      ),
                    ],
                  )
                ],
              );
            }
          },
        ),
      ),
      body: ScrollbarTheme(
        data: ScrollbarThemeData(
          trackVisibility: WidgetStateProperty.all<bool>(false),
          thumbColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onTertiary),
          thickness: WidgetStateProperty.all(1),
          radius: Radius.circular(10)
        ),
        child: Scrollbar(
          thumbVisibility: false,
          scrollbarOrientation: ScrollbarOrientation.right,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight / 51.1), //15
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onTertiary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    height: screenHeight / 15.32, //50
                    width: screenWidth / 1.06, //340
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal:  screenWidth / 45, vertical:  screenHeight/95.75), //8
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Category',
                            style: GoogleFonts.lato(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth / 20, //18
                            ),
                          ),
                          SizedBox(
                            width: screenWidth / 45, //8
                          ),
                          DropdownButton<String>(
                            iconEnabledColor:
                                Theme.of(context).colorScheme.secondary,
                            hint: Text(
                              'Select Category',
                              style: GoogleFonts.lato(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary),
                            ),
                            value: _selectedCategory.isNotEmpty
                                ? _selectedCategory
                                : null,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                            items: <String>[
                              'Integrity',
                              'Diligence',
                              'Honesty',
                              'Innovation',
                              'Punctuality',
                              'Teamwork'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            width: screenWidth / 24, //15
                          ),
                          // Lottie.asset(
                          //   'assets/animation4.json',
                          //   height: 30,
                          //   width: 30,
                          // ),
                          //Text(_availablePoints.toString())
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:  screenWidth /22.5, vertical: screenHeight/47.875), //16
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _voiceController,
                    style: GoogleFonts.lato(
                        color: Theme.of(context).colorScheme.onTertiary),
                    cursorColor: Theme.of(context).colorScheme.onTertiary,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.speaker_phone),
                      prefixIconColor: Theme.of(context).colorScheme.onTertiary,
                      labelText: 'Add your voice',
                      labelStyle: GoogleFonts.lato(
                          color: Theme.of(context).colorScheme.onTertiary),
                      hintText: 'Voice',
                      hintStyle: GoogleFonts.lato(
                          color: Theme.of(context).colorScheme.onTertiary),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onTertiary)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onTertiary),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  // onTap: _isTextInputActive ? () => _submitVoiceMesage() : null,
                  onTap: () async {
                    final containsHate = await containsHateSpeech(context, _voiceController.text);
                    if (!containsHate) {
                      // Proceed with normal flow
                      _isTextInputActive ? () => _submitVoiceMesage() : null;
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenHeight /63.83), //12
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: screenHeight /15.32, //50
                    decoration: BoxDecoration(
                        color: _isTextInputActive
                            ? Colors.white
                            : Theme.of(context).colorScheme.onTertiary,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text(
                      'Send',
                      style: GoogleFonts.lato(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth / 27.69), //13
                    )),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: screenHeight /95.75), //10
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface
                  ),
                  child: SizedBox(
                    height: screenHeight/1.5, //
                    child: Scrollbar(
                      thickness: 12,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: voice.length,
                        itemBuilder: (context, index) {
                          final message = voice[index]['staffVoice'];
                          final timestamp = voice[index]['timestamp'];
                          final messageCategory = voice[index]['category'];

                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal:  screenWidth / 45, vertical: screenHeight/95.75), //8
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onTertiary,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Scrollbar(
                                    child: ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message,
                                              style: GoogleFonts.lato(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Category:',
                                                  style: GoogleFonts.lato(
                                                    fontSize: screenWidth / 30, //12
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  messageCategory,
                                                  style: GoogleFonts.lato(fontSize: screenWidth / 30), //12
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        leading: ClipOval(
                                          child: Image.asset(
                                            'assets/anonymity.png',
                                            width: screenWidth / 12, //30
                                            height: screenHeight / 25.53, //30
                                          ),
                                        ),
                                        trailing: Text(
                                          timestamp
                                              .toString()
                                              .substring(0, timestamp.length - 6),
                                          style: GoogleFonts.lato(fontSize: screenWidth / 30), // 12
                                        )
                                        /*Column(
                                            children: [
                                              Text(timestamp.toString().substring(11)),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Sent: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    timestamp
                                                        .toString()
                                                        .substring(0, timestamp.length - 6),
                                                    style: TextStyle(fontSize: 11),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),*/
                                        ),
                                  ),
                                ),
                              ),

                              /*Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Divider(
                                  thickness: 3,
                                ),
                              )*/
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitVoiceMesage() async {
    try {
      if (_selectedCategory.isNotEmpty && _voiceController.text.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Client')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            int availablePoints = userDoc['availablePoints'] ?? 0;
            int pointsToDeduct = 5;

            if (availablePoints >= pointsToDeduct) {
              DateTime currentTime = DateTime.now();
              String formattedTime =
                  DateFormat('yyyy-MM-dd HH:mm').format(currentTime);

              await voiceRef.add({
                'staffVoice': _voiceController.text,
                'timestamp': formattedTime,
                'sentTime': formattedTime,
                'category': _selectedCategory,
              });

              _voiceController.clear();

              setState(() {
                _selectedCategory = '';
              });

              // Deduct points from user's available points
              int newAvailablePoints = availablePoints - pointsToDeduct;
              await FirebaseFirestore.instance
                  .collection('Client')
                  .doc(user.uid)
                  .update({'availablePoints': newAvailablePoints});

              // Add the deducted points back to the user's points field
              int newPoints = userDoc['points'] + pointsToDeduct;
              await FirebaseFirestore.instance
                  .collection('Client')
                  .doc(user.uid)
                  .update({'points': newPoints});

              setState(() {
                voice.add({
                  'staffVoice': _voiceController.text,
                  'timestamp': formattedTime,
                  'sentTime': currentTime,
                  'category': _selectedCategory,
                });
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'You do not have enough points to send your message!', style: GoogleFonts.lato(),),
                ),
              );
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message and category must not be empty', style: GoogleFonts.lato(),),
          ),
        );
      }
    } catch (error) {
      print(error);
    }
  }

  // Future<void> _submitVoiceMesage() async {
  //   try {
  //     if (_selectedCategory.isNotEmpty && _voiceController.text.isNotEmpty) {
  //       User? user = FirebaseAuth.instance.currentUser;
  //       if (user != null) {
  //         DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //             .collection('Client')
  //             .doc(user.uid)
  //             .get();

  //         if (userDoc.exists) {
  //           int availablePoints = userDoc['availablePoints'] ?? 0;
  //           int pointsToDeduct = 5;

  //           if (availablePoints >= pointsToDeduct) {
  //             DateTime currentTime = DateTime.now();
  //             String formattedTime =
  //                 DateFormat('yyyy-MM-dd HH:mm').format(currentTime);

  //             await voiceRef.add({
  //               'staffVoice': _voiceController.text,
  //               'timestamp': formattedTime,
  //               'sentTime': formattedTime,
  //               'category': _selectedCategory,
  //             });

  //             _voiceController.clear();

  //             setState(() {
  //               _selectedCategory = '';
  //             });

  //             await deductPoints(pointsToDeduct);

  //             setState(() {
  //               voice.add({
  //                 'staffVoice': _voiceController.text,
  //                 'timestamp': formattedTime,
  //                 'sentTime': currentTime,
  //                 'category': _selectedCategory,
  //               });
  //             });
  //           } else {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(
  //                 content: Text(
  //                     'You do not have enough points to send your message!'),
  //               ),
  //             );
  //           }
  //         }
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Message and category must not be empty'),
  //         ),
  //       );
  //     }
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  Future<void> deductPoints(int points) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Client')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          int availablePoints = userDoc['availablePoints'] ?? 0;
          if (availablePoints >= points) {
            int newPoints = availablePoints - points;
            await FirebaseFirestore.instance
                .collection('Client')
                .doc(user.uid)
                .update({'availablePoints': newPoints});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You do not have enough points!', style: GoogleFonts.lato(),)),
            );
          }
        }
      }
    } catch (error) {
      print(error);
    }
  }
}

// import 'dart:math';
// import 'dart:ui';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:gam_project/widgets/animate.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';

// class EmployeeVoice extends StatefulWidget {
//   const EmployeeVoice({super.key});

//   @override
//   State<EmployeeVoice> createState() => _EmployeeVoiceState();
// }

// class _EmployeeVoiceState extends State<EmployeeVoice>
//     with SingleTickerProviderStateMixin {
//   TextEditingController _voiceController = TextEditingController();
//   late AnimationController controller;
//   late Animation<double> flipAnim;
//   String _selectedCategory = '';
//   List voice = [];
//   int _availablePoints = 0;
//   bool _isTextInputActive = false; // Variable to track text input activity
//   CollectionReference voiceRef = FirebaseFirestore.instance.collection('voice');
//   late Stream<DocumentSnapshot> _userStream;

//   getData() async {
//     var resonsebody = await voiceRef.get();
//     resonsebody.docs.forEach((element) {
//       setState(() {
//         voice.add(element.data());
//         print(voice);
//       });
//     });
//   }

//   Stream<DocumentSnapshot> getUserStream() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       return FirebaseFirestore.instance
//           .collection('Client')
//           .doc(user.uid)
//           .snapshots();
//     } else {
//       return Stream.empty();
//     }
//   }

//   @override
//   void initState() {
//     getData();
//     _userStream = getUserStream();

//     controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3), // Adjust the duration as needed
//     )..repeat();

//     flipAnim = Tween(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: controller,
//         curve: Interval(0.0, 0.5, curve: Curves.linear),
//       ),
//     );
//   }

//  // _voiceController.addListener

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: StreamBuilder<DocumentSnapshot>(
//             stream: _userStream,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Text('Ideas');
//               } else {
//                 _availablePoints = snapshot.data?['availablePoints'] ?? 0;
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Ideas'),
//                     //SizedBox(width: 40, height: 40, child: Display()),
//                     // Text('Points: $_availablePoints'),
//                   ],
//                 );
//               }
//             },
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 500,
//                 child: Scrollbar(
//                   child: ListView.builder(
//                     shrinkWrap:
//                         true, // Ensure the ListView takes only the space it needs
//                     itemCount: voice.length,
//                     itemBuilder: (context, index) {
//                       final message = voice[index]['staffVoice'];
//                       final timestamp = voice[index]['timestamp'];
//                       final messageCategory = voice[index]['category'];

//                       return Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   color: Colors.green[50],
//                                   borderRadius: BorderRadius.circular(9)),
//                               child: Scrollbar(
//                                 child: ListTile(
//                                   title: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         message,
//                                         style: TextStyle(
//                                             fontStyle: FontStyle.italic),
//                                       ),
//                                       Row(
//                                         children: [
//                                           Text(
//                                             'Category:',
//                                             style: TextStyle(
//                                                 fontSize: 11,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                           Text(
//                                             messageCategory,
//                                             style: TextStyle(fontSize: 12),
//                                           ),
//                                         ],
//                                       )
//                                     ],
//                                   ),
//                                   leading: ClipOval(
//                                     child: Image.asset(
//                                       'assets/anonymity.png',
//                                       width: 30,
//                                       height: 30,
//                                     ),
//                                   ),
//                                   trailing:
//                                       Text(timestamp.toString().substring(11)),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Column(
//                             children: [
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.only(top: 0.2, right: 8),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     SizedBox(
//                                       width: 164,
//                                     ),
//                                     Text(
//                                       'Sent: ',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Text(
//                                       timestamp
//                                           .toString()
//                                           .substring(0, timestamp.length - 6),
//                                       style: TextStyle(fontSize: 11),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Divider(
//                               thickness: 3,
//                             ),
//                           )
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Container(
//                   decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(6)),
//                   height: 50,
//                   width: 340,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Category',
//                           style: TextStyle(
//                               color: Colors.red[300],
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18),
//                         ),
//                         SizedBox(
//                           width: 8,
//                         ),
//                         DropdownButton<String>(
//                           iconEnabledColor: Colors.red,
//                           hint: Text('Select Category'),
//                           value: _selectedCategory.isNotEmpty
//                               ? _selectedCategory
//                               : null,
//                           onChanged: (String? newValue) {
//                             setState(() {
//                               _selectedCategory = newValue!;
//                             });
//                           },
//                           items: <String>[
//                             'Integrity',
//                             'Diligence',
//                             'Honesty',
//                             'Punctuality',
//                             'Teamwork'
//                           ].map<DropdownMenuItem<String>>((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                         ),
//                         SizedBox(
//                           width: 15,
//                         ),
//                         Lottie.asset(
//                           'assets/animation4.json',
//                           height: 30, // Adjust the height as needed
//                           width: 30, // Adjust the width as needed
//                         ),
//                         Text(_availablePoints.toString())
//                       ],
//                     ),
//                   )),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: TextFormField(
//                   keyboardType: TextInputType.text,
//                   controller: _voiceController,
//                   decoration: InputDecoration(
//                       //iconColor: Colors.blue,
//                       prefixIcon: Icon(Icons.speaker_phone),
//                       labelText: 'Add your voice',
//                       hintText: 'voice',
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 12, horizontal: 15),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     _submitVoiceMesage(_voiceController.text);
//                   },
//                   child: Center(
//                       child: Text(
//                     'Send',
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15),
//                   )),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _submitVoiceMesage(String comment) async {
//     try {
//       print('_selectedCategory: $_selectedCategory');
//       print('comment: $comment');
//       if (_selectedCategory.isNotEmpty && comment.isNotEmpty) {
//         User? user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//           DocumentSnapshot userDoc = await FirebaseFirestore.instance
//               .collection('Client')
//               .doc(user.uid)
//               .get();

//           if (userDoc.exists) {
//             int availablePoints = userDoc['availablePoints'] ?? 0;
//             int pointsToDeduct = 2;

//             if (availablePoints >= pointsToDeduct) {
//               DateTime currentTime = DateTime.now();
//               String formattedTime =
//                   DateFormat('yyyy-MM-dd HH:mm').format(currentTime);

//               await voiceRef.add({
//                 'staffVoice': comment,
//                 'timestamp': formattedTime,
//                 'sentTime': formattedTime,
//                 'category': _selectedCategory, // Add the selected category
//               });
//               _voiceController.clear(); // Clear the text field after submission

//               // Deduct points from availablePoints
//               await deductPoints(pointsToDeduct);

//               setState(() {
//                 voice.add({
//                   'staffVoice': comment,
//                   'timestamp': formattedTime,
//                   'sentTime': currentTime,
//                   'category': _selectedCategory, // Add the selected category
//                 });
//               });
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                     content: Text(
//                         'You do not have enough points to send your message!')),
//               );
//             }
//           }
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Message and category must not be empty')),
//         );
//       }
//     } catch (error) {
//       print(error);
//       // Handle errors gracefully, e.g., show an error message to the user
//     }
//   }

//   Future<void> deductPoints(int points) async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('Client')
//             .doc(user.uid)
//             .get();

//         if (userDoc.exists) {
//           int availablePoints = userDoc['availablePoints'] ?? 0;
//           if (availablePoints >= points) {
//             int newPoints = availablePoints - points;
//             await FirebaseFirestore.instance
//                 .collection('Client')
//                 .doc(user.uid)
//                 .update({'availablePoints': newPoints});
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('You do not have enough points!')),
//             );
//           }
//         }
//       }
//     } catch (error) {
//       print(error);
//       // Handle errors gracefully, e.g., show an error message to the user
//     }
//   }
// }
