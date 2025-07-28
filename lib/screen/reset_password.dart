import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  //final FirebaseAuthServices _auth = FirebaseAuthServices();
  final TextEditingController _emailLinkController = TextEditingController();
  bool _passwordResetDialogShown = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _emailLinkController
  //       .clear(); // Clear text field value when page is initialized
  // }

  @override
  void dispose() {
    // Clear the text in the TextFormField when the page is disposed
    //_emailLinkController.clear();
    _emailLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        title: Text('Reset Password', style:  GoogleFonts.lato(
            fontWeight: FontWeight.bold,
           /* color: Theme
                .of(context)
                .colorScheme
                .onPrimary*/)),
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient:
              LinearGradient(colors: [Color(0xFF006400), Color(0xFF00A86B)])),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth/18, vertical:screenHeight/51.0 ), //`5
          child: Column(
            children: [
              Image.asset(
                "assets/cropped-cropped-NITDA-Logo-new-03.png",
                height: screenHeight / 9.5, // 40
                width: screenWidth / 2, //120
              ),
              SizedBox(
                height: screenHeight/51.0, //15
              ),
              Text(
                'Enter your registered email and we will send you a reset link',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Theme
                    .of(context)
                    .colorScheme
                    .onPrimary, fontSize: screenWidth/24), //15
              ),
              SizedBox(
                height: screenHeight/76.6, //10
              ),

              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailLinkController,
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
                  contentPadding: EdgeInsets.symmetric(vertical: screenHeight/63.83), //12
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
             /* TextFormFieldWidget(
                  contentPadding: EdgeInsets.all(10),
                  prefixIcon: Icons.mail,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailLinkController,
                  hintText: "email",
                  labelText: "Input your registerd email"),*/
              SizedBox(
                height: screenHeight/39.3, //20
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: passwordReset,
                  child: Center(
                      child: Text(
                    'Reset Password',
                    style: GoogleFonts.lato(
                        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  )))
            ],
          ),
        ),
      ),
    );
  }

  Future passwordReset() async {
    if (_passwordResetDialogShown) {
      // If the dialog has already been shown, return without showing it again
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Reset Pasword"),
            content: Text("Are you sure you want to reset your password?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: _emailLinkController.text.trim());
                    _passwordResetDialogShown = true; // Set the flag to true
                    Navigator.of(context)
                        .pop(); // Close the confirmation dialog
                    //   _emailLinkController.clear;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                                "password reset link has been sent to you email"),
                          );
                        }).then((_) {
                      // Clear text field value after dialog is dismissed
                      _emailLinkController.clear();
                    });
                    ;
                  } on FirebaseException catch (e) {
                    print(e);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(e.message.toString()),
                          );
                        });
                  }
                },
                child: Text("Yes"),
              )
            ],
          );
        });
  }
}
