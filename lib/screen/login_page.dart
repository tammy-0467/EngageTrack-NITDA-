import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:gam_project/screen/home_page.dart';
import 'package:gam_project/screen/registration_page.dart';
import 'package:gam_project/screen/reset_password.dart';
import 'package:gam_project/services/auth_services.dart';
import 'package:gam_project/widgets/loading_indicator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEyeIconClicked = true;
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  TextEditingController _useremailController = TextEditingController();
  TextEditingController _userpasswordController = TextEditingController();
  @override
  // void dispose() {
  //   _useremailController.dispose();
  //   _userpasswordController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF006400), Color(0xFF00A86B)])),
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight / 12.77, left: screenWidth / 24), // 60 & 15
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight / 15.32), //50
                      child: Text(
                        'Welcome Back!\nLog in',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth / 12, //30
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(

                      child: Image.asset(
                        "assets/cropped-cropped-NITDA-Logo-new-03.png",
                        height: screenHeight /19.15, //40
                        width: screenWidth / 6, //60
                      ),
                    ),


                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight /3.83), //200
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth / 20, right: screenWidth / 20), //18
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _useremailController,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.mail,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              label: Text(
                                'Email',
                                style: TextStyle(
                                    color: Color(0xFF006400),
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                        TextField(
                          obscureText: _isEyeIconClicked,
                          controller: _userpasswordController,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: _isEyeIconClicked
                                      ? Icon(Icons.visibility,  color: Theme.of(context).colorScheme.primary,)
                                      : Icon(
                                          Icons.visibility_off,  color: Theme.of(context).colorScheme.primary,
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      _isEyeIconClicked = !_isEyeIconClicked;
                                    });
                                  }),
                              label: Text(
                                'Password',
                                style: TextStyle(
                                    color: Color(0xFF006400),
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                        SizedBox(
                          height: screenHeight / 38.3, //20
                        ),
                        GestureDetector(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth / 25.71,
                                  color: Color(0xFF00A86B)),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResetPasswordPage()),
                              // (route) => false,
                            );
                          },
                        ),
                        SizedBox(height: screenHeight/25.53), //30
                        GestureDetector(
                          child: Container(
                            height: screenHeight / 15.32, //50
                            width: screenWidth /1.2, //200
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(colors: [
                                  Color(0xFF006400),
                                  Color(0xFF00A86B)
                                ])),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                    color: Colors.white, fontSize: screenWidth / 24),//15
                              ),
                            ),
                          ),
                          onTap: _signin,
                        ),
                        SizedBox(
                          height: screenHeight / 76.6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have account?",
                                style: TextStyle(
                                    color: Colors.black, fontSize: screenWidth / 24)), //15
                            SizedBox(
                              width: screenWidth / 51.43, //7
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegistrationPage()),
                                  // (route) => false,
                                );
                              },
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
            )
          ],
        )
    );
  }

  void _signin() async {
    if (_formKey.currentState!.validate()) {
      String email = _useremailController.text;
      String password = _userpasswordController.text;

      try {
        // Delay showing the dialog for 5 second
        // await Future.delayed(Duration(seconds: 5));
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => Center(
                  child: Custom_circular_Indicator(),
                ));

        User? user = await _auth.SignInWithEmailAndPassword(email, password);
        Navigator.pop(context);
        if (user != null) {
          showToast("Login Succesful");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        userRole: 'CEO',
                      )));
        } else if (user == null) {
          showToast('invalid email or password');
        }
      } catch (e) {
        throw Exception('somthing occureed');
      }
    }
  }
}
