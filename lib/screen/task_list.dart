import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
//import 'package:flutter_flushbar/flutter_flushbar.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late Stream<QuerySnapshot> _taskStream;
  List<DocumentSnapshot> _tasks = [];
  bool _acceptButtonEnabled = true;
  bool _doneButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _taskStream = _fetchTasks();
    _loadButtonStateFromFirestore();
  }

  //get the current quarter
  String getCurrentQuarterKey() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    return "Q${quarter}_${now.year}";
  }
  Stream<QuerySnapshot> _fetchTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('Client')
          .doc(user.uid)
          .collection('tasks')
          .orderBy('sentDateTime', descending: true)
          .snapshots();
    }
    throw Exception('User is not logged in.');
  }

  dynamic _getClientPoints(AsyncSnapshot<QuerySnapshot> snapshot) {
    final clientData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
    return clientData['points'] ?? 1;
  }

  Color _getCardColor(int status) {
    switch (status) {
      case 1:
        return Colors.red.shade50; // New task
      case 2:
        return Colors.yellow.shade100; // Awaiting approval
      case 3:
        return Colors.green.shade50; // Ready to claim
      case 4:
        return Colors.grey.shade300; // Completed
      default:
        return Colors.white;
    }
  }

  Color _getShadowColor (int status){
    switch (status){
      case 1:
        return Colors.red.shade300; // New task
      case 2:
        return Colors.yellow.shade400; // Awaiting approval
      case 3:
        return Colors.green.shade400; // Ready to claim
      case 4:
        return Colors.grey.shade400; // Completed
      default:
        return Colors.white;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 1:
        return Icons.assignment_late; // New task
      case 2:
        return Icons.hourglass_top; // Waiting
      case 3:
        return Icons.card_giftcard; // Claim
      case 4:
        return Icons.check_circle; // Done
      default:
        return Icons.info;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return "Task needs acceptance";
      case 2:
        return "Awaiting approval";
      case 3:
        return "Claim your points";
      case 4:
        return "Task completed";
      default:
        return "Unknown status";
    }
  }

  Color _getStatusTextColor(int status) {
    switch (status) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 4:
        return Colors.black54;
      default:
        return Colors.grey;
    }
  }

  //udpate user points and keep track of quarter
  void _updateUserPoints(int pointsToAdd) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final quarterKey = getCurrentQuarterKey();
        final clientDocRef = FirebaseFirestore.instance.collection('Client').doc(user.uid);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(clientDocRef);
          final currentPoints = (snapshot.data()?['points'] ?? 0) as int;
          final newPoints = currentPoints + pointsToAdd;

          transaction.update(clientDocRef, {
            'points': newPoints,
            'quarterlyPoints.$quarterKey': FieldValue.increment(pointsToAdd),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        });
      } catch (e) {
        print('Error updating user points: $e');
      }
    }
  }

/*  void _updateUserPoints(int pointsToAdd) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final clientDocRef =
            FirebaseFirestore.instance.collection('Client').doc(user.uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final clientDocSnapshot = await transaction.get(clientDocRef);
          final currentPoints =
              (clientDocSnapshot.data() as Map<String, dynamic>)['points'] ?? 0;
          final newPoints = currentPoints + pointsToAdd;
          transaction.update(clientDocRef, {'points': newPoints});
        });
      } catch (e) {
        print('Error updating user points: $e');
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onTertiary,
      appBar: AppBar(
        title: Text("Your tasks", style: GoogleFonts.lato(),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _taskStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _tasks = snapshot.data!.docs;
            return _buildTaskWidget(_tasks);
          }
        },
      ),
    );
  }

  Widget _buildTaskWidget(List<DocumentSnapshot> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Text('No tasks available.', style: GoogleFonts.lato(),),
      );
    } else {
      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final taskData = tasks[index].data() as Map<String, dynamic>;
          final taskTextMap = taskData['messages'];
          final totalPoints = taskData['points'] ?? 0;
          final taskId = taskData['taskId'] ?? '';
          var status = taskData['status'] ?? 1;
          final sentTimestamp = taskData['sentDateTime'] as Timestamp?;
          final sentDateTime =
              sentTimestamp != null ? sentTimestamp.toDate() : null;
          String formattedSentDateTime = '';
          if (sentDateTime != null) {
            formattedSentDateTime =
                DateFormat('yyyy-MM-dd HH:mm:ss').format(sentDateTime);
          }

          // Check if 'tasks1' is not null and is a Map
          final taskText = (taskTextMap != null && taskTextMap is Map)
              ? taskTextMap.values.toList().isNotEmpty
                  ? taskTextMap.values.toList()[0].toString()
                  : ''
              : '';

          return _buildSingleTaskWidget(taskText, totalPoints, taskId, status,
              (newStatus) {
            setState(() {
              status = newStatus;
            });
          }, sentDateTime);
        },
        // reverse: true,
      );
    }
  }



  Widget _buildSingleTaskWidget(
    String taskText,
    dynamic totalPoints,
    String taskId,
    int status,
    Function(int) setStatus,
    DateTime? sentDateTime,
  ) {
    totalPoints ??= 0;
    //status ??= 0;
    final formattedSentDateTime = sentDateTime != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(sentDateTime) // Format the DateTime object here
        : '';
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth/24, vertical: screenHeight/51.1), // 15
      child: Card(
        color: _getCardColor(status),
        elevation: 10,
        shadowColor: _getShadowColor(status),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight / 95.75, left: screenWidth/45), //8
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Task: ", style: GoogleFonts.lato(fontSize: screenWidth / 18),), //20
                  Expanded(
                    child: Text(taskText.isNotEmpty ? taskText : 'No task available', style: GoogleFonts.lato(fontSize: screenWidth / 18),
                      overflow: TextOverflow.ellipsis, maxLines: 3,
                    ),
                  ) //20
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight / 95.75, left: screenWidth / 45), //8
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Date: ", style: GoogleFonts.lato(fontSize: screenWidth / 24),), //15
                  Text(formattedSentDateTime.substring(0, formattedSentDateTime.length - 9), style: GoogleFonts.lato(fontSize: screenWidth / 24),) //15
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight / 95.75, left: screenWidth / 45), //8
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Time: ", style: GoogleFonts.lato(fontSize: screenWidth / 24),), //15
                  Text(formattedSentDateTime.substring(11), style: GoogleFonts.lato(fontSize: screenWidth / 24),) //15
                ],
              ),
            ),
            if (status == 4)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth / 45, vertical: screenHeight / 95.75), //8
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      color: _getStatusTextColor(status),
                    ),
                    SizedBox(width: screenWidth/45), //8
                    Text(
                      _getStatusText(status),
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(status),
                      ),
                    ),
                  ],
                ),
              ),

            /*Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusTextColor(status),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _getStatusText(status),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: _getStatusTextColor(status),
                        ),
                      ),
                    ],
                  ),
                ),*/
            if (status == 1)
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusTextColor(status),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _getStatusText(status),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: _getStatusTextColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  _handleAccept(taskId);
                  setState(() {
                    setStatus(2);
                  });
                },
              ),
            if (status == 2)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth/45, vertical:screenHeight/95.75), //8
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      color: _getStatusTextColor(status),
                    ),
                    SizedBox(width: screenWidth/45), //8
                    Text(
                      _getStatusText(status),
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(status),
                      ),
                    ),
                  ],
                ),
              ),
            if (status == 3)
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth/45, vertical: screenHeight/95.75),//8
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusTextColor(status),
                      ),
                      SizedBox(width: screenWidth/45), //8
                      Text(
                        _getStatusText(status),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: _getStatusTextColor(status),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth/9, //45
                        height: screenHeight/25.53, //30
                        child: Image.asset('assets/treasure.png'),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  _handleClaimPoints(taskId);
                },
              ),

            /*GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(7)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'Claim your points',
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 40, // Specify your desired width
                            height: 30, // Specify your desired height
                            child: Image.asset('assets/treasure.png'),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _handleClaimPoints(taskId);
                    },
                  ),*/

            /*Padding(
                  padding: const EdgeInsets.all(8.0),

                  child:

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.done),
                      Text("Completed", style: GoogleFonts.lato(fontSize: 15),)
                    ],
                  ),
                ),*/

          ],
        ),
      ),
    );

      /*Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.only(top: 25, bottom: 30),
          height: 250,
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 8, right: 8),
                  child: Text(
                    'Task Board',
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ),
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onTertiary,
                      borderRadius: BorderRadius.circular(7)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      taskText.isNotEmpty ? taskText : 'No task available',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${formattedSentDateTime.substring(0, formattedSentDateTime.length - 9)} ',
                          style: GoogleFonts.lato(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Time: ${formattedSentDateTime.substring(11)}",
                          style: GoogleFonts.lato(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (status == 4)
                  Container(
                    height: 40,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(7)),
                    child: Center(
                        child: Text(
                      'Task Completed',
                      style: GoogleFonts.lato(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                if (status == 1)
                  GestureDetector(
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(7)),
                      child: Center(
                          child: Text(
                        'Accept',
                        style: GoogleFonts.lato(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                    ),
                    onTap: () {
                      _handleAccept(taskId);
                      setState(() {
                        setStatus(2);
                      });
                    },
                  ),
                if (status == 2)
                  Container(
                      height: 40,
                      width: 200,
                      decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(4)),
                      child: Center(
                          child: Text(
                        'await Supervisor Approval',
                        style: GoogleFonts.lato(color: Colors.black),
                      ))),
                if (status == 3)
                  GestureDetector(
                    child: Container(
                      height: 40,
                      width: 170,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(7)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'Claim your point',
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 40, // Specify your desired width
                            height: 30, // Specify your desired height
                            child: Image.asset('assets/treasure.png'),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _handleClaimPoints(taskId);
                    },
                  ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),


      ],
    );*/
  }

  void _handleAccept(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Get reference to the existing task document
        final taskRef = FirebaseFirestore.instance
            .collection('Client')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId);

        // Retrieve the taskId from the document
        final taskData = await taskRef.get();
        final taskIdFromFirestore = taskData.data()?['taskId'];

        // Ensure taskIdFromFirestore is not null
        if (taskIdFromFirestore != null) {
          // Update the existing task document with the new status
          await taskRef.update({
            'status': 2, // Set the status to 2 (accepted)
            'acceptButtonEnabled': false, // Disable the Accept button
            // Add other fields to update as needed
          });
          //  setState(() {});

          //print('Task with ID: $taskIdFromFirestore status updated to "2"');
          _updateUserPoints(1); // Award points for accepting the task

          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              // Close the dialog after 2 seconds
              Future.delayed(Duration(seconds: 2), () {
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
                        'assets/animation2.json',
                        repeat: false,
                        height: 150,
                        width: 150,
                        filterQuality: FilterQuality.high,
                      ),
                      Text(
                        'Bonus Point +1',
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

          // Play audio after points have been added
          AudioPlayer player = AudioPlayer();
          player.play(AssetSource('sound1.wav'));
          print('User points updated after accepting task.');
          setState(() {
            _acceptButtonEnabled = false;
          });
        } else {
          print('Task ID not found in Firestore document');
        }
      } catch (e) {
        print('Error updating task: $e');
      }
    }
  }

  void _handleClaimPoints(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Client')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .update({'status': 4});
        _updateUserPoints(2);

        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            // Close the dialog after 2 seconds
            Future.delayed(Duration(seconds: 2), () {
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
                      'assets/animation2.json',
                      repeat: false,
                      height: 150,
                      width: 150,
                      filterQuality: FilterQuality.high,
                    ),
                    Text(
                      'Bonus Point +2',
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

        // Play audio after points have been added
        AudioPlayer player = AudioPlayer();
        player.play(AssetSource('sound1.wav'));
      } catch (e) {
        print('Error updating task status: $e');
      }
    }
  }

  void _updateButtonStateInFirestore(String taskId,
      {required bool acceptButtonEnabled, bool pendingApproval = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Client')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .update({
          'acceptButtonEnabled': acceptButtonEnabled,
          'pendingApproval': pendingApproval
        });
      } catch (e) {
        print('Error updating button state in Firestore: $e');
      }
    }
  }

  void _loadButtonStateFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final tasksSnapshot = await FirebaseFirestore.instance
            .collection('Client')
            .doc(user.uid)
            .collection('tasks')
            .get();
        tasksSnapshot.docs.forEach((taskDoc) {
          final taskData = taskDoc.data() as Map<String, dynamic>;
          final taskId = taskDoc.id;
          final acceptButtonEnabled = taskData['acceptButtonEnabled'] ?? true;
          setState(() {
            _acceptButtonEnabled = acceptButtonEnabled;
          });
        });
      } catch (e) {
        print('Error loading button state from Firestore: $e');
      }
    }
  }

  void _handleDone(String taskId) {
    _updateUserPoints(
      2,
    );
  }
}
