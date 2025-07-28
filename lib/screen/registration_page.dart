import 'dart:io';

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:gam_project/model/user_model2.dart';
import 'package:gam_project/screen/login_page.dart';

import 'package:gam_project/services/auth_services.dart';
import 'package:gam_project/widgets/custom_drop_down.dart';
import 'package:gam_project/widgets/loading_indicator.dart';
import 'package:gam_project/widgets/text_box_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:firebase_storage/firebase_storage.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  XFile? _newImageFromPhone;
  late Uint8List _imagePhoto = Uint8List(0);
  String? _selectedRole;
  String? _selectedDept;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImageFromPhone = pickedFile;
      });
    }
  }

  Future<void> _uploadImageAndCreateData(String userId) async {
    Future<void> _uploadImageAndCreateData(String userId) async {
      try {
        // Updated code: Store empty string as imageUrl in Firestore
        await FirebaseFirestore.instance.collection('Client').doc(userId).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'username': _userNameController.text,
          'createdAt': DateTime.now(),
          'imageUrl': 'noImage', // Store empty string initially
        });
      } catch (e) {
        showToast('Error creating user data: $e');
      }
    }
  }

  Future<void> _createData2() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _uploadImageAndCreateData(currentUser.uid);
        final uid = currentUser.uid;
        CollectionReference collRef =
        FirebaseFirestore.instance.collection('Client');

        ClientModel client = ClientModel(
          name: _nameController.text.toString(),
          email: _emailController.text.toString(),
          username: _userNameController.text.toString(),
          createdAT: DateTime.now(),
          imageUrl: 'noImage',
          userPoint: 0,
          availablePoints: 500,
          lastResetMonth: DateTime.now(),
          userRole: _selectedRole ?? '',
          department: _selectedDept ?? '',

          // Assuming this aligns with your model
        );
        Map<String, dynamic> data = client.toJson();
        DocumentReference docRef = collRef.doc(uid);
        await docRef.set(data); // Wait for write completion
        Navigator.pop(
            context); // Assuming this is desired after successful data storage
        showToast("Account Created Successfully");
      } else {
        // Handle the case where no user is currently signed in
        print("Error: No user currently signed in");
      }
    } catch (e) {
      showToast('Error creating user data: $e');
    }
  }

  void _signup() async {
    // Check if role is selected
    if (_selectedRole == null) {
      // Show error message and return
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Role Required"),
            content: Text("Please select a role to proceed."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // check if department is entered

    if (_selectedDept == null) {
      // Show error message and return
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Department Required"),
            content: Text("Please select a department to proceed."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if username is entered
    if (_userNameController.text.isEmpty) {
      // Show error message and return
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Username Required"),
            content: Text("Please enter your username."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if password is at least 6 characters long
    if (_passwordController.text.length < 6) {
      // Show error message and return
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Invalid Password"),
            content: Text("Password must be at least 6 characters long."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Authenticate user
    String email = _emailController.text;
    String password = _passwordController.text;
    String username = _userNameController.text;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          Center(
            child: Padding(
              padding:
              const EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
              child: Custom_circular_Indicator(),
            ),
          ),
    );

    try {
      User? user = await createUserWithEmailAndPassword(email, password);
      if (user != null) {
        await _createData2();
        // Update user data with image URL after sign up
        final userId = user.uid;
        final imageUrl = await _uploadImageAndGetUrl(userId);
        await FirebaseFirestore.instance
            .collection('Client')
            .doc(userId)
            .update({'imageUrl': imageUrl, 'username': username});
        Navigator.pop(context);
        // showToast("Account Created Successfully");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Account Created Successfully"),
              content: Text("Thank you....Have fun From Amos Udok!!!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/dashboard");
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.pop(context);
        showToast('Some error occurred');
      }
    } on FirebaseAuthException catch (e) {
      showToast('Error during sign up: $e');
    }
  }

  // void _signup() async {
  //   // Check if role is selected
  //   if (_selectedRole == null) {
  //     // Show error message and return
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text("Role Required"),
  //           content: Text("Please select a role to proceed."),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Text("OK"),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //     return;
  //   }

  //   //authenticate user
  //   String email = _emailController.text;
  //   String password = _passwordController.text;
  //   //String username = _userNameController.text;
  //   showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (context) => Center(
  //             child: Padding(
  //               padding: const EdgeInsets.only(
  //                   top: 15, bottom: 15, left: 30, right: 30),
  //               child: Custom_circular_Indicator(),
  //             ),
  //           ));

  //   try {
  //     User? user = await createUserWithEmailAndPassword(email, password);
  //     if (user != null) {
  //       await _createData2();
  //       // Update user data with image URL after sign up
  //       final userId = user.uid;
  //       final imageUrl = await _uploadImageAndGetUrl(userId);
  //       await FirebaseFirestore.instance
  //           .collection('Client')
  //           .doc(userId)
  //           .update({'imageUrl': imageUrl});
  //       Navigator.pop(context);
  //       showToast("Account Created Successfully");
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text("Account Created Successfully"),
  //             content: Text("Thank you....Have fun!!!"),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pushNamed(context, "/dashboard");
  //                 },
  //                 child: Text("OK"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     } else {
  //       Navigator.pop(context);
  //       showToast('Some error occurred');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     showToast('Error during sign up: $e');
  //   }
  // }

  bool _isEyeIconClicked = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient:
            LinearGradient(colors: [Color(0xFF006400), Color(0xFF00A86B)])),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal:  screenWidth / 20, vertical: 42.6), // 18
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight /21.88, //35
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Image.asset(
                        "assets/cropped-cropped-NITDA-Logo-new-03.png",
                        height: screenHeight / 19.5, // 40
                        width: screenWidth / 6, //60
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight/38.3, //20
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Register',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth / 12, //30
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onPrimary),
                  ),
                ),
                SizedBox(
                  height: screenHeight / 51.1, //15
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  style:
                  TextStyle(color: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary),
                  cursorColor: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  decoration: InputDecoration(
                    iconColor: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary,
                    prefixIconColor: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary,
                    fillColor: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary,
                    labelStyle: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onPrimary),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onPrimary)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimary),
                    ),
                    hintStyle: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onPrimary),
                    prefixIcon: Icon(Icons.email),
                    labelText: 'Input your email',
                    hintText: 'Email',
                    contentPadding: EdgeInsets.symmetric(vertical: screenHeight/63.8), //12
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenHeight / 30.64, // 30
                ),
                TextFormFieldWidget(
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.person,
                  cursorColor: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  hintText: 'Name',
                  labelText: 'Name',
                  controller: _nameController,
                  contentPadding: EdgeInsets.symmetric(vertical: screenHeight/76.6), //10
                ),
                SizedBox(
                  height: screenHeight / 30.64,//30
                ),
                DropdownButtonFormField<String>(
                  value: _selectedDept,
                  isExpanded: false,
                  items: ["HRA", "ITIS", "CPS", "R&C", "FMC", "CS", "EG&DED", "R&D", "DLCD", "CC&MR", "SMP", "A&IC",]
                      .map((department) =>
                      DropdownMenuItem<String>(
                        value: department,
                        child: Container(
                            width: screenWidth / 3, //120
                            child: Text(
                              department,
                              style: TextStyle(
                                color:
                                Theme
                                    .of(context)
                                    .colorScheme
                                    .onPrimary,
                              ),
                            )),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDept = value;
                    });
                  },
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Color(0xFF00A86B),
                  iconEnabledColor: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  iconDisabledColor: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  decoration: InputDecoration(
                      fillColor: Theme
                          .of(context)
                          .colorScheme
                          .onPrimary,
                      labelStyle: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimary),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .onPrimary)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onPrimary),
                      ),
                      labelText: 'Select Department',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0)),
                ),
                SizedBox(
                  height: screenHeight/30.64, //25
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  isExpanded: false,
                  items: ["General Staff", "Supervisor", "Manager", "CEO", "Director", "Deputy Director", "Assistant Director", "Senior Manager", "Manager", "Deputy Manager", "Assistant Manager", "Officer 1", "Officer 11"]
                      .map((role) =>
                      DropdownMenuItem<String>(
                        value: role,
                        child: Container(
                            width: screenWidth / 3, //120
                            child: Text(
                              role,
                              style: TextStyle(
                                color:
                                Theme
                                    .of(context)
                                    .colorScheme
                                    .onPrimary,
                              ),
                            )),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Color(0xFF00A86B),
                  iconEnabledColor: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  iconDisabledColor: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  decoration: InputDecoration(
                      fillColor: Theme
                          .of(context)
                          .colorScheme
                          .onPrimary,
                      labelStyle: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimary),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .onPrimary)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onPrimary),
                      ),
                      labelText: 'Select Role',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0)),
                ),
                SizedBox(
                  height: screenHeight / 30.64, //25
                ),
                TextFormFieldWidget(
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.person,
                  hintText: 'Username',
                  cursorColor: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  labelText: 'username',
                  controller: _userNameController,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                SizedBox(
                  height: screenHeight/30.64, //25
                ),
                TextFormField(
                  controller: _passwordController,
                  style:
                  TextStyle(color: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary),
                  obscureText: _isEyeIconClicked,
                  cursorColor: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        icon: _isEyeIconClicked
                            ? Icon(
                          Icons.visibility,
                          color: Colors.white,
                        )
                            : Icon(
                          Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isEyeIconClicked = !_isEyeIconClicked;
                          });
                        }),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    labelText: 'password',
                    hintText: 'Input your password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    iconColor: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary,
                    prefixIconColor: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary,
                    fillColor: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary,
                    labelStyle: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onPrimary),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onPrimary)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimary),
                    ),
                    hintStyle: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onPrimary),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenHeight / 25.53, //30
                ),
                GestureDetector(
                    child: Container(
                      height: screenHeight / 15.32, //50
                      width: screenWidth / 1.2, //300
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimary),
                      child: Center(
                          child: Text(
                            'Register',
                            style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary),
                          )),
                    ),
                    onTap: _signup),
                SizedBox(
                  height: screenHeight / 76.6, //10
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(color: Colors.black, fontSize: screenWidth/24)), //15
                    SizedBox(
                      width: screenWidth/51.42, // 7
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimary,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _uploadImageAndGetUrl(String userId) async {
    try {
      if (_newImageFromPhone != null) {
        String fileName = _newImageFromPhone!
            .path
            .split('/')
            .last;
        File imageFile = File(_newImageFromPhone!.path);

        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('user_images/$userId/$fileName'); // Include userId in path
        // Upload the image to Firebase Storage
        await storageReference.putFile(imageFile);
        // Get the download URL of the uploaded image
        String imageUrl = await storageReference.getDownloadURL();

        return imageUrl;
      } else {
        return ''; // Return empty string if no image selected
      }
    } catch (e) {
      showToast('Error uploading image: $e');
      return ''; // Return empty string in case of error
    }
  }
}

Future<User?> createUserWithEmailAndPassword(String email,
    String password) async {
  try {
    UserCredential userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    print('Error creating user: $e');
    return null;
  }
}
