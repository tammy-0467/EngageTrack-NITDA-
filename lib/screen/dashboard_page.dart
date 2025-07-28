import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/assign_task.dart';
import 'package:gam_project/screen/ceoMsg.dart';
import 'package:gam_project/screen/kudos.dart';

import 'package:gam_project/screen/notificationMsg.dart';
import 'package:gam_project/screen/settings.dart';
import 'package:gam_project/screen/task_list.dart';

import 'package:gam_project/screen/voice.dart';
import 'package:gam_project/services/auth_services.dart';
import 'package:gam_project/services/storage/storage_service.dart';
import 'package:gam_project/widgets/custom_navigation.dart';
import 'package:gam_project/widgets/search_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _MyHomePageBarState();
}

class _MyHomePageBarState extends State<DashBoardPage> {
  bool _uploadingImage = false; // Track the state of image upload
  final CollectionReference _announcementCollection =
      FirebaseFirestore.instance.collection('announcement');
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _clientsCollection =
      FirebaseFirestore.instance.collection('Client');

  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final topRank = FirebaseFirestore.instance.collection('Client').snapshots();

  Future<void> saveImageUrlToUserCollection(String imageUrl) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get a reference to the user's document in Firestore
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('Client').doc(user.uid);

        // Update the imageUrl field in the user's document
        await userDocRef.update({'imageUrl': imageUrl});
      } else {
        // No user signed in
        throw Exception('No user signed in');
      }
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error saving image URL to user collection: $error');
    }
  }

  /*Future<String?> pickAndUploadImage() async {
    setState(() {
      _uploadingImage = true; // Set to true when starting upload
    });
    try {
      // Pick an image from the gallery
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) {
        setState(() {
          _uploadingImage = false; // Set back to false if no image picked
        });
        // No image picked
        return null;
      }

      File imageFile = File(pickedImage.path);

      // Create a reference to the location you want to upload to in Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('photos/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Await the completion of the upload task and return the download URL
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Save the download URL to the user's collection in Firestore
      await saveImageUrlToUserCollection(downloadUrl);
      setState(() {
        _uploadingImage = false; // Set back to false after upload completes
      });
      return downloadUrl;
    } catch (error) {
      setState(() {
        _uploadingImage = false; // Set back to false if error occurs
      });
      // Handle any errors that occur during the upload process
      print('Error uploading image: $error');
      return null; // Return null if upload fails
    }
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> fetchImages() async {
    await Provider.of<StorageService>(context, listen: false).fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: _clientsCollection.doc(_currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Connection error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text('Loading...'));
            }

            final profileInfo = snapshot.data!.data() as Map<String, dynamic>;
            final String uname = profileInfo['username'] ?? '';
            final String photoImg = profileInfo['imageUrl'] ?? '';
            final String name = profileInfo['name'] ?? '';
            final String email = profileInfo['email'] ?? '';
            final dynamic points = profileInfo['points'];
            print('Points from Firestore: $points');
            final String userRole = profileInfo['role'];
            // Check user's role to determine if the "Assign Task" button should be displayed
            final bool isGeneralRole = userRole == 'General Staff';
            final bool isSupervisor = userRole == 'Supervisor';
            final bool isManager = userRole == 'Manager';
            final bool isCEO = userRole == 'CEO'; // New: Check if user is CEO
            final int userPoints =
                points is int ? points : int.tryParse(points.toString()) ?? 0;

            // Convert points to an integer for comparison
            // final int userPoints = int.parse(points);
            Widget badge;
            if (userPoints >= 20 && userPoints <= 50) {
              badge = Image.asset(
                  'assets/award1.png'); // Replace 'assets/badge1.png' with your image path
            } else if (userPoints >= 51 && userPoints <= 150) {
              badge = Image.asset(
                  'assets/award2.png'); // Replace 'assets/badge2.png' with your image path
            } else if (userPoints >= 151 && userPoints <= 500) {
              badge = Image.asset(
                  'assets/award3.png'); // Replace 'assets/badge3.png' with your image path
            } else {
              // If points do not fall into any of the specified ranges, show no badge
              badge = SizedBox(); // or any other widget representing no badge
            }

            //final List<DocumentSnapshot> userdataInfo = snapshot.data!.docs;
            return Consumer<StorageService>(
                builder: (context, storageService, child) {
              final List<String> imageUrls = storageService.imageUrls;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight /76.6, horizontal: screenWidth / 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome ${uname}',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: screenWidth/18),
                      ),
                      SizedBox(
                        height: screenHeight / 95.75,
                      ),

                      Container(
                        height: screenHeight / 36.5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('marquee_messages')
                                .where('timestamp', isGreaterThan: DateTime.now().subtract(Duration(days: 30)))
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError){
                                return Marquee(
                                  text: "No Update Available",
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 50.0,
                                  velocity: 50.0,
                                  pauseAfterRound: Duration(seconds: 1),
                                  startPadding: 10.0,
                                  accelerationDuration: Duration(seconds: 1),
                                  decelerationDuration: Duration(milliseconds: 500),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Marquee(
                                text: "No Update Available",
                                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 50.0,
                                velocity: 50.0,
                                startPadding: 10.0,
                                accelerationDuration: Duration(seconds: 1),
                              );
                              }

                              final messages = snapshot.data!.docs.map((doc) => doc['text']).join("     ");


                              return Marquee(
                                text: messages,
                                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 50.0,
                                velocity: 50.0,
                                pauseAfterRound: Duration(seconds: 1),
                                startPadding: 10.0,
                                accelerationDuration: Duration(seconds: 1),
                                decelerationDuration: Duration(milliseconds: 500),
                              );
                            },
                          )
                          ,
                        ),
                      ),

                      SizedBox(
                        height: screenHeight / 95.75,
                      ),
                      // new dash board
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: screenWidth/45, right: screenWidth/45 , top: screenHeight / 97.75, bottom: screenHeight / 97.75),
                              child:
                                  Text(
                                    'Check or assign tasks here',
                                    style: GoogleFonts.lato(
                                        height: 1.2,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenHeight / 47.875
                                    ),
                                  ),),
                                 /* Padding(
                                    padding: EdgeInsets.only(left: 250),
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          radius: 30,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: photoImg != ''
                                                        ? NetworkImage(photoImg)
                                                        : Image.asset(
                                                                'assets/default_photo.jpg')
                                                            .image)),
                                          ),
                                        ),
                                        Positioned(
                                          top: 28,
                                          left: 25,
                                          child: GestureDetector(
                                            onTap: () =>
                                                storageService.uploadImage(),
                                            // pickAndUploadImage,
                                            child: LottieBuilder.asset(
                                              'assets/uploadPhoto.json',
                                              height: 50,
                                              width: 50,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),*/


                            isCEO
                                ? SizedBox()
                                : Padding(
                                    padding: EdgeInsets.only(left: screenWidth / 1.8, right: screenWidth/45),
                                    child: Container(
                                        width: screenWidth / 2,
                                        // margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: EdgeInsets.all(screenWidth / 60),
                                            child: Row(
                                              children: [
                                                Text(
                                                    'Total Points: ',
                                                    style: GoogleFonts.lato(
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary)),
                                                Text(
                                                    '$userPoints',
                                                    style: GoogleFonts.lato(
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(
                                                            0xFFFFD93D))),
                                              ],
                                            ),
                                          ),
                                        ),
                                  ),
                            isCEO
                                ? Padding(
                                    padding: EdgeInsets.only(left: screenWidth / 45, bottom: screenHeight / 95.75),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: screenWidth / 2.11,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CustomNavigation(
                                                child:
                                                    CeoMsgToAllUser()),
                                            // (route) => false,
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(screenWidth / 45),
                                          child: Text(
                                            'Send message to employees',
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: screenWidth / 5.14,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CustomNavigation(
                                                child:
                                                    TaskScreen()),
                                            // (route) => false,
                                          );
                                        },
                                        child: Padding(
                                          padding:
                                               EdgeInsets.all(screenWidth / 45),
                                          child: Text(
                                            'My Task',
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: screenHeight / 766,
                            ),
                            isGeneralRole
                                ? SizedBox()
                                : Padding(
                                  padding: EdgeInsets.only(left: screenWidth / 45, bottom: screenHeight / 97.75),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    width: screenWidth / 2.57,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CustomNavigation(
                                              child:
                                                  AssignTask()),
                                          // (route) => false,
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(screenWidth / 45),
                                        child: Text(
                                          'Assign/Approve task',
                                          style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),
                                        )
                                      ),
                                    ),
                                  ),
                                )
                          ],
                        ),
                      ),

                      //end of new dashboard
                      SizedBox(
                        height: screenHeight / 76.6,
                      ),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth / 45),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: screenWidth / 60),
                                    child: Text(
                                      'Top Ranking',
                                      style: GoogleFonts.lato(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              // SizedBox(
                              //   height: 10,
                              // ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Client')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  final List<DocumentSnapshot> ranksBoard =
                                      snapshot.data!.docs;
                                  print(
                                      'Number of documents: ${ranksBoard.length}');
                                  for (var doc in ranksBoard) {
                                    print('Document ID: ${doc.id}');
                                    print('Document data: ${doc.data()}');
                                  }
                                  return Container(
                                    //color: Colors.green,
                                    height: MediaQuery.of(context).size.height *
                                        0.09,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: ranksBoard.length > 3
                                          ? 3
                                          : ranksBoard.length,
                                      itemBuilder: (context, index) {
                                        ranksBoard.sort((a, b) {
                                          // Convert 'points' to integers if they are strings
                                          final pointsA = a['points'] is int
                                              ? a['points']
                                              : int.parse(a['points']);
                                          final pointsB = b['points'] is int
                                              ? b['points']
                                              : int.parse(b['points']);
                                          return pointsB.compareTo(pointsA);
                                        });
                                        final userData = ranksBoard[index]
                                            .data() as Map<String, dynamic>;
                                        final String name =
                                            userData['name'] ?? '';
                                        final dynamic userScore =
                                            userData['points'];
                                        final String userId =
                                            ranksBoard[index].id;
                                        return StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('Client')
                                                .doc(userId)
                                                .snapshots(),
                                            builder: (context, userSnapshot) {
                                              if (userSnapshot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                              if (userSnapshot.hasError) {
                                                return Text(
                                                    'Error: ${userSnapshot.error}');
                                              }

                                              final userData =
                                                  userSnapshot.data!.data()
                                                      as Map<String, dynamic>;
                                              final String photoImg = userData[
                                                      'imageUrl'] ??
                                                  ''; // Assuming 'photoUrl' is the field name for the image URL
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    left: screenWidth / 90),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                           EdgeInsets
                                                              .only(
                                                              bottom: screenHeight / 95.75,
                                                              top: screenHeight / 95.75,
                                                              right: screenWidth / 45),
                                                      child: SizedBox(
                                                          height: screenHeight / 32.9,
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                            radius: 16,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          20),
                                                                  image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: photoImg !=
                                                                              ''
                                                                          ? NetworkImage(photoImg)
                                                                          : Image.asset('assets/default_photo.jpg').image)),
                                                            ),
                                                          )

                                                          // CircleAvatar(
                                                          //   backgroundImage:
                                                          //       NetworkImage(photoImg),
                                                          // )
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                           EdgeInsets
                                                              .only(
                                                        right: screenWidth / 45,
                                                      ),
                                                      child: Text(
                                                        userScore.toString(),
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenHeight / 76.6,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                  child: Container(
                                    height: screenHeight / 3.8,
                                    width: screenWidth / 2.4,
                                    child: /*ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'assets/kudos.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),*/
                                    SwipeImageSwitcher()
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        CustomNavigation(
                                            child: kudosPage()));
                                  }),
                              Positioned(
                                left: 12,
                                bottom: 4,
                                child: Container(
                                  height: screenHeight / 38.3,
                                  width: screenWidth / 3,
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Text(
                                      'Give kudos to',
                                      style: GoogleFonts.lato(
                                          fontSize: screenWidth / 25.7,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 11,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                child: Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/voice_2.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  height: screenHeight / 3.8,
                                  width: screenWidth / 2.4,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CustomNavigation(
                                          child:
                                              EmployeeVoice()));
                                },
                              ),
                              Positioned(
                                left: 12,
                                bottom: 4,
                                child: Container(
                                  height: screenHeight / 38.3,
                                  width: screenWidth / 3.5,
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Text(
                                      'Employee Voice',
                                      style: GoogleFonts.lato(
                                          fontSize: screenWidth / 25.7,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),

                      SizedBox(
                        height: screenHeight / 76.6,
                      ),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFA390EE),
                        ),
                        child: Stack(
                          children: [
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Director General's Message",
                                      style: GoogleFonts.lato(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: screenWidth / 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    CircleAvatar(
                                        child:
                                            Image.asset('assets/bell.png')),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CustomNavigation(
                                      child:
                                          NotificationToAllUser()), // Navigate to the new page
                                );
                              },
                            ),
                            Positioned(
                              right: 25,
                              child: CircleAvatar(
                                child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Announcement')
                                        .doc('GeneralMessage')
                                        .collection('messages')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child:
                                                CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError ||
                                          !snapshot.hasData) {
                                        return Text('Error');
                                      }
                                      final List<DocumentSnapshot> messages =
                                          snapshot.data!.docs;
                                      return Center(
                                          child: Text(
                                        messages.length.toString(),
                                        style: TextStyle(fontSize: 10),
                                      ));
                                    }),
                                backgroundColor: Colors.green[400],
                                radius: 7,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
    );
  }
}

class RollingImage extends StatefulWidget {
  const RollingImage({super.key});

  @override
  State<RollingImage> createState() => _RollingImageState();
}

class _RollingImageState extends State<RollingImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _showFirst = true;
  int _showImg = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Optional: auto-switch
    Timer.periodic(const Duration(seconds: 4), (timer) {
      _flip();
    });
  }

  void _flip() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0).then((_) {
      setState(() {
        _showFirst = !_showFirst;
        _showImg = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final rotationValue = _animation.value;
          final angle = rotationValue * pi;

          // Switch image halfway through
          final isFirstHalf = rotationValue < 0.5;
          final currentImage = _showFirst == isFirstHalf
              ? 'assets/kudos_1.jpg'
              : 'assets/kudos.jpg';

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            child: Image.asset(
              currentImage,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}



class SwipeImageSwitcher extends StatefulWidget {
  const SwipeImageSwitcher({Key? key}) : super(key: key);

  @override
  State<SwipeImageSwitcher> createState() => _SwipeImageSwitcherState();
}

class _SwipeImageSwitcherState extends State<SwipeImageSwitcher> {
  bool _showFirst = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _showFirst = !_showFirst;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Always cancel timers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
        child: Image.asset(
          _showFirst ? 'assets/kudos_1.jpg' : 'assets/kudos.jpg',
          key: ValueKey(_showFirst),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}


