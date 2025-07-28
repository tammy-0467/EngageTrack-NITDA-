import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/edit_profile_page.dart';
import 'package:gam_project/widgets/custom_navigation.dart';
import 'package:gam_project/widgets/data_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _uploadingImage = false; // Track the state of image upload
  final _currentUser = FirebaseAuth.instance.currentUser;

  final CollectionReference _clientsCollection =
      FirebaseFirestore.instance.collection('Client');


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onTertiary,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.lato(),
        ),
       /* actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onTertiary,
                      borderRadius: BorderRadius.circular(6)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.lato(fontSize: 16, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                  )),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          name: name,
                          email: email,
                          username: uname,
                          imageUrl: photoImg,
                        )));
              },
            ),
          )
        ],*/
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _clientsCollection.doc(_currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Connection error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text('Loading...'));
            }

            final clientData = snapshot.data!.data() as Map<String, dynamic>;
            final String uname = clientData['username'] ?? '';
            final String photoImg = clientData['imageUrl'] ?? '';
            final String name = clientData['name'] ?? '';
            final String email = clientData['email'] ?? '';
            final dynamic points = clientData['points'];
            final dynamic bonusPoint = clientData['availablePoints'];
            final String staffRole = clientData['role'];
            final String department = clientData['department'];
            double screenHeight = MediaQuery.of(context).size.height;

            /*return SingleChildScrollView(
              child: Center(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[400],
                            radius: 90,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
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
                            right: 1,
                            bottom: 17,
                            child: GestureDetector(
                              onTap: pickAndUploadImage,
                              child: LottieBuilder.asset(
                                'assets/uploadPhoto.json',
                                height: 50,
                                width: 50,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    // Divider(),
                    UserInfoWidget(
                        title: name,
                        leading: Text('NAME:', style:  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),),
                        trailing: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    UserInfoWidget(
                        title: email,
                        leading: Text('EMAIL:' , style:  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),),
                        trailing: Icon(
                          Icons.mail,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    UserInfoWidget(
                        title: uname,
                        leading: Text('USERNAME:' , style:  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),),
                        trailing: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    UserInfoWidget(
                        title: points.toString(),
                        leading: Text('POINTS EARNED:', style:  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),),
                        trailing: Icon(
                          Icons.numbers,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    UserInfoWidget(
                        title: bonusPoint.toString(),
                        leading: Text('BONUS POINTS:', style:  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),),
                        trailing: Icon(
                          Icons.mail,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    UserInfoWidget(
                        title: department,
                        leading: Text('DEPARTMENT', style:  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),),
                        trailing: Icon(
                          Icons.group,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    UserInfoWidget(
                        title: staffRole,
                        leading: Text('STAFF ROLE', style:  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),),
                        trailing: Icon(
                          Icons.work,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );*/
            return Scaffold(
              floatingActionButton: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(30)
                ),
                child: IconButton(
                  onPressed: () { Navigator.push(
                      context,
                      CustomNavigation(
                          child: EditProfilePage(
                            name: name,
                            email: email,
                            username: uname,
                            imageUrl: photoImg,
                            points: points,
                            bPoints: bonusPoint,
                            role: staffRole,
                            dept: department,
                          ))); }, icon: Icon(Icons.edit),
                  color: Theme.of(context).colorScheme.onPrimary,

                ),
              ),
              body: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Background
                  Column(
                    children: [
                      Container(
                        height: screenHeight * 0.20,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF006400), Color(0xFF00A86B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      /*Expanded(
                        child: Container(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),*/
                    ],
                  ),

                  Positioned(
                      top: MediaQuery.of(context).size.height * 0.25 + 70,

                      child: Text(
                        name,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold, fontSize: screenWidth / 27.7, color: Colors.black), //13
                      )),

                  // White Info Card
                  Positioned(
                    top: screenHeight * 0.25 + 120,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth / 18, vertical:  screenHeight/38.3 ), // 20
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _infoRow("Username", uname),
                          _infoRow("Mail", email),
                          _infoRow("Points Earned", points.toString()),
                          _infoRow("Bonus Points", bonusPoint.toString()),
                          _infoRow("Department", department),
                          _infoRow("Staff Role", staffRole),
                        ],
                      ),
                    ),
                  ),

                  // Profile Picture
                  Positioned(
                    top: screenHeight * 0.20 - 90,
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 85,
                        backgroundImage: photoImg.isNotEmpty
                            ? NetworkImage(photoImg)
                            : const AssetImage('assets/default_photo.jpg')
                                as ImageProvider,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Future<String?> pickAndUploadImage() async {
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
  }

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

  Widget _infoRow(String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight / 127.6), //6
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  GoogleFonts.lato(color: Colors.grey.shade500, fontSize: screenWidth / 22.5)), //16
          Text(value,
              style: GoogleFonts.lato(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth / 22.5, //16
              ), maxLines: 2, overflow: TextOverflow.ellipsis,
            softWrap: true ,
          ),
        ],
      ),
    );
  }
}
