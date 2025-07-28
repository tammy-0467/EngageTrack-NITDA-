import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/dashboard_page.dart';
import 'package:gam_project/screen/home_page.dart';
import 'package:gam_project/screen/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HomePage(userRole: "CEO");
            } else {
              return LoginPage();
            }
          }),
    );
  }
}
