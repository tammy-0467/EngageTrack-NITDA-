import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class RatingPage extends StatefulWidget {
  final String userName;
  final String receiverUserId; // Add receiverUserId here
  const RatingPage(
      {Key? key, required this.userName, required this.receiverUserId})
      : super(key: key);

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  TextEditingController _dropdownController = TextEditingController();
  TextEditingController _enteredTextController = TextEditingController();
  int maxWordsPerLine = 5;
  late int availablePoints = 500; // Initialize available points
  late int lastResetMonth;
  late int pointsToDeduct = 0; // Variable to store points to deduct
  late Color buttonColor = Colors.white; // Default button color
  int? selectedCommendation;

  @override
  void initState() {
    super.initState();
    // Call function to retrieve available points when the widget initializes
    _retrieveAvailablePoints();
  }

  //get the current quarter
  String getCurrentQuarterKey() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    return "Q${quarter}_${now.year}";
  }

  // Function to retrieve available points from Firestore & reset points monthly
  Future<void> _retrieveAvailablePoints() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('Client').doc(user.uid);
      final userDoc = await userRef.get();

      int currentMonth = DateTime.now().month;

      if (userDoc.exists) {
        int storedMonth = userDoc.data()?['lastResetMonth'] ?? currentMonth;
        int storedPoints = userDoc.data()?['availablePoints'] ?? 500;

        if (storedMonth != currentMonth) {
          // New month → reset points
          await userRef.set({
            'availablePoints': 500,
            'lastResetMonth': currentMonth,
          }, SetOptions(merge: true));

          setState(() {
            availablePoints = 500;
          });
        } else {
          // Same month → use stored points
          setState(() {
            availablePoints = storedPoints;
          });
        }
      } else {
        // First-time user
        await userRef.set({
          'availablePoints': 500,
          'lastResetMonth': currentMonth,
        });

        setState(() {
          availablePoints = 500;
        });
      }
    }
  }

  /*Future<void> _retrieveAvailablePoints() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Client')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          availablePoints = userDoc['availablePoints'] ?? 0;
        });
      } else {
        // If the document doesn't exist, initialize the field with default value
        await FirebaseFirestore.instance
            .collection('Client')
            .doc(user.uid)
            .set({'availablePoints': 500});
        setState(() {
          availablePoints = 500;
        });
      }
    }
  }*/

  // Function to set points to deduct and change button color when a recognition level is selected
  void setPointsToDeductAndColor(int points, int index) {
    setState(() {
      pointsToDeduct = points;
      selectedCommendation = index;
    });
  }

  // Function to submit and deduct points
  /*Future<void> submitAndDeductPoints(String receiverUserId) async {
    if (pointsToDeduct > 0) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (availablePoints >= pointsToDeduct) {
          int newPoints = availablePoints - pointsToDeduct;
          await FirebaseFirestore.instance
              .collection('Client')
              .doc(user.uid)
              .update({'availablePoints': newPoints});

          // Fetch receiver's current points
          DocumentSnapshot receiverDoc = await FirebaseFirestore.instance
              .collection('Client')
              .doc(receiverUserId)
              .get();
          int receiverPoints = receiverDoc['points'] ?? 0;
          int updatedReceiverPoints = receiverPoints + pointsToDeduct;

          // Add points to the receiver's available points
          await FirebaseFirestore.instance
              .collection('Client')
              .doc(receiverUserId)
              .update({'points': updatedReceiverPoints});

          setState(() {
            availablePoints = newPoints;
            pointsToDeduct = 0; // Reset points to deduct after deduction
            buttonColor = Colors.white; // Reset button color after deduction
            _enteredTextController.clear(); // Clear entered text
            AudioPlayer player = AudioPlayer();
            player.play(AssetSource('sound1.wav'));
          });

          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              // Close the dialog after 2 seconds
              Future.delayed(Duration(seconds: 3), () {
                Navigator.of(context).pop();
              });

              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.transparent
                      //Colors.green[400],
                      ),
                  height: 180, // Set the desired height
                  // width: 200, // Set the desired width
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LottieBuilder.asset(
                        'assets/animation3.json',
                        repeat: false,
                        height: 150,
                        width: 150,
                        filterQuality: FilterQuality.high,
                      ),
                      Text(
                        'kudos sent 👍',
                        style: TextStyle(
                          color: Colors.yellow[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          // // Show a snackbar after deducting points
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Thanks for giving kudos!')),
          // );
        } else {
          // Show an error snackbar if the user doesn't have enough points
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You do not have enough points!')),
          );
        }
      }
    } else {
      // Show a reminder snackbar if the user hasn't selected a recognition level
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a recognition level!')),
      );
    }
  }
*/

  Future<void> submitAndDeductPoints(String receiverUserId) async {
    if (pointsToDeduct > 0) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (availablePoints >= pointsToDeduct) {
          int newPoints = availablePoints - pointsToDeduct;
          await FirebaseFirestore.instance
              .collection('Client')
              .doc(user.uid)
              .update({'availablePoints': newPoints});

          // Update receiver's points
          DocumentSnapshot receiverDoc = await FirebaseFirestore.instance
              .collection('Client')
              .doc(receiverUserId)
              .get();
          int receiverPoints = receiverDoc['points'] ?? 0;
          int updatedReceiverPoints = receiverPoints + pointsToDeduct;

          //update receiver points for this quarter
          final quarterKey = getCurrentQuarterKey();
          final receiverRef = FirebaseFirestore.instance.collection('Client').doc(receiverUserId);
          await receiverRef.set({
            'points': updatedReceiverPoints,
            'quarterlyPoints': {
              quarterKey: FieldValue.increment(pointsToDeduct)
            }
          }, SetOptions(merge: true));

          /*  await FirebaseFirestore.instance
              .collection('Client')
              .doc(receiverUserId)
              .update({'points': updatedReceiverPoints});*/

          await FirebaseFirestore.instance
              .collection('Client')
              .doc(receiverUserId)
              .update({
            'points': updatedReceiverPoints,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          // ➕ Save the kudos reason
          await FirebaseFirestore.instance.collection('Kudos').add({
            'senderId': user.uid,
            'receiverId': receiverUserId,
            'message': _enteredTextController.text.trim(),
            'points': pointsToDeduct,
            'timestamp': FieldValue.serverTimestamp(),
            'quarter': getCurrentQuarterKey(),
          });

          // Give the sender 1 point for giving kudos
          await FirebaseFirestore.instance
              .collection('Client')
              .doc(user.uid)
              .set({
            'points': FieldValue.increment(1),
            'quarterlyPoints': {
              quarterKey: FieldValue.increment(1)
            }
          }, SetOptions(merge: true));


          // Play audio & show animation
          setState(() {
            availablePoints = newPoints;
            pointsToDeduct = 0;
            _enteredTextController.clear();
            AudioPlayer player = AudioPlayer();
            player.play(AssetSource('sound1.wav'));
          });

          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 3), () {
                Navigator.of(context).pop();
              });

              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.transparent),
                  height: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LottieBuilder.asset(
                        'assets/animation3.json',
                        repeat: false,
                        height: 150,
                        width: 150,
                        filterQuality: FilterQuality.high,
                      ),
                      Text(
                        'kudos sent 👍',
                        style: GoogleFonts.lato(
                          color: Colors.yellow[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You do not have enough points!', style: GoogleFonts.lato(),)),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a recognition level!', style: GoogleFonts.lato(),)),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Kudos', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: screenWidth / 18),), //20
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight / 95.75, //8
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Image.asset('assets/recogn.png'),
                Text('Give Kudos to ${widget.userName}',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: screenWidth /17.14), //21
                      )
              ],
            ),
            SizedBox(
              height: screenHeight / 97.75, //8
            ),
            Divider(
              thickness: 0.7,
            ),
            Text(
              'Select a level',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: screenWidth / 20), //18
            ),
            SizedBox(
              height: screenHeight / 76.6, //10
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey, // Color of the border
                        width: 1, // Thickness of the border
                      ),
                      color: selectedCommendation == 0 ? Colors.white : Colors.grey[200], // Apply button color
                    ),
                    height: screenHeight/17.02, //45
                    width: screenWidth /2.25, //160
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth / 60, //6
                        ),
                        Image.asset(
                          'assets/star.png',
                          width: screenWidth /21.17, //17
                          height: screenHeight / 45.1, //17
                        ),
                        SizedBox(
                          width: screenWidth /45, //8
                        ),
                        Text(
                          'Thank You!',
                          style: GoogleFonts.lato(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth / 21.17), //17
                        ),
                        SizedBox(
                          width: screenWidth / 90, //4
                        ),
                        Text('5',
                            style: GoogleFonts.lato(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth / 21.17)) //17
                      ],
                    ),
                  ),
                  onTap: () {
                    setPointsToDeductAndColor(5, 0);
                  },
                ),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey, // Color of the border
                        width: 1, // Thickness of the border
                      ),
                      color: selectedCommendation == 1 ? Colors.white : Colors.grey[200], // Apply button color
                    ),
                    height: screenHeight / 17.02, //45
                    width: screenWidth/ 2.25, //160
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth / 60, //6
                        ),
                        Image.asset(
                          'assets/star.png',
                          width: screenWidth / 21.17, //17
                          height: screenHeight / 45.1, //17
                        ),
                        SizedBox(
                          width: screenWidth / 45, //8
                        ),
                        Text(
                          'Good Job!',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth / 21.17, //17
                              color: Colors.green[700]),
                        ),
                        SizedBox(
                          width: screenWidth / 90, //4
                        ),
                        Text('10',
                            style: GoogleFonts.lato(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth / 21.17)) //17
                      ],
                    ),
                  ),
                  onTap: () {
                    setPointsToDeductAndColor(10, 1);
                  },
                )
              ],
            ),
            SizedBox(
              height: screenHeight / 76.6, //10
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey, // Color of the border
                        width: 1, // Thickness of the border
                      ),
                      color: selectedCommendation == 2 ? Colors.white : Colors.grey[200], // Apply button color
                    ),
                    height: screenHeight / 17.02, //45
                    width: screenWidth / 2.25, //160
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth / 60, //6
                        ),
                        Image.asset(
                          'assets/star.png',
                          width: screenWidth / 21.17, //17
                          height: screenHeight / 45.1, //17
                        ),
                        SizedBox(
                          width: screenWidth/ 45, //8
                        ),
                        Text(
                          'Impressive!',
                          style: GoogleFonts.lato(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth / 21.17), //17
                        ),
                        SizedBox(
                          width: screenWidth / 90, // 4
                        ),
                        Text('20',
                            style: GoogleFonts.lato(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth / 21.17)) //17
                      ],
                    ),
                  ),
                  onTap: () {
                    setPointsToDeductAndColor(20, 2);
                  },
                ),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey, // Color of the border
                        width: 1, // Thickness of the border
                      ),
                      color:selectedCommendation == 3 ? Colors.white : Colors.grey[200], // Apply button color
                    ),
                    height: screenHeight / 17.02, // 45
                    width: screenWidth / 2.25, // 160
                    child: Row(
                      children: [
                         SizedBox(
                          width: screenWidth / 60, // 6
                        ),
                        Image.asset(
                          'assets/star.png',
                          width: screenWidth / 21.17, //17
                          height: screenHeight / 45.1, //17
                        ),
                         SizedBox(
                          width: screenWidth / 45, //8
                        ),
                        Text(
                          'Exceptional!',
                          style: GoogleFonts.lato(
                              color: Colors.yellow[800],
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth / 21.17), //17
                        ),
                        SizedBox(
                          width: screenWidth / 90, //4
                        ),
                        Text('50',
                            style: GoogleFonts.lato(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth / 21.17)) //17
                      ],
                    ),
                  ),
                  onTap: () {
                    setPointsToDeductAndColor(50, 3);
                  },
                )
              ],
            ),
            SizedBox(
              height: screenHeight / 76.6, //10
            ),
            Padding(
              padding:  EdgeInsets.only(right: screenWidth /27.7, left: screenWidth / 27.7), //13
              child: Container(
                height: screenHeight / 15.32, // 50
                width: screenWidth/1.06, //340
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(6)),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: screenWidth / 24, left: screenWidth / 24), //15
                    child: Text(
                      'You currently have $availablePoints points to give',
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: screenWidth / 22.5), //16
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight / 76.6, //10
            ),
            Padding(
              padding: EdgeInsets.only(right: screenWidth / 24, left: screenWidth/24), //15
              child: Text(
                'What would you like to say about his/her achievement?',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: screenWidth / 22.5), //16
              ),
            ),
            Padding(
              padding:
                   EdgeInsets.symmetric(horizontal: screenWidth / 24, vertical: screenWidth / 76.6), //15 & 10
              child: TextField(
                onChanged: (text) {
                  // Check if the text has more words than allowed per line
                  List<String> words = text.split(' ');
                  if (words.length > maxWordsPerLine) {
                    // If more words than allowed, insert a new line after the last allowed word
                    _enteredTextController.value = TextEditingValue(
                      text: words.sublist(0, maxWordsPerLine).join(' ') +
                          '\n', // Join the first n words with a space and add a new line
                      selection: TextSelection.collapsed(
                        offset: words
                                .sublist(0, maxWordsPerLine)
                                .join(' ')
                                .length +
                            1, // Set the cursor after the last allowed word and the new line
                      ),
                    );
                  }
                },
                maxLines: null,
                decoration:
                InputDecoration(
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
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                /*InputDecoration(
                    hintText: 'Enter your text here...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),*/
                controller: _enteredTextController,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: screenWidth/24, left: screenWidth / 24, top: screenHeight / 153.2), // 15 & 5
              child: ElevatedButton(
                onPressed: () {
                  submitAndDeductPoints(widget.receiverUserId);
                  // Call submitAndDeductPoints method with the receiver's user ID
                },
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Color(0xFF006400)),
                ),
                child: Center(
                    child: Text(
                  'Submit',
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth / 24), //15
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
