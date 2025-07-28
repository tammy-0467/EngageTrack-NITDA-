import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/marquee_edit_page.dart';
import 'package:gam_project/widgets/custom_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isSurveyEnabled = false;

  @override
  void initState() {
    super.initState();
    fetchToggleValue();
  }

  Future<void> fetchToggleValue() async {
    final doc = await FirebaseFirestore.instance
        .collection('AdminSettings')
        .doc('surveyControl')
        .get();
    if (doc.exists) {
      setState(() {
        isSurveyEnabled = doc['isEnabled'] ?? false;
      });
    }
  }

  Future<void> updateToggleValue(bool value) async {
    await FirebaseFirestore.instance
        .collection('AdminSettings')
        .doc('surveyControl')
        .set({
      'isEnabled': value,
    });
    setState(() {
      isSurveyEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Admin Settings',
            style: GoogleFonts.lato(
                color: Theme.of(context).colorScheme.onPrimary)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal:  screenWidth/22.5, vertical: screenHeight/ 47.88), //16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onTertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal:  screenWidth / 36, vertical: screenHeight/76.6), //10
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Enable Survey Submission",
                      style: GoogleFonts.lato(fontSize: screenWidth / 20)), //18
                  Switch(
                    value: isSurveyEnabled,
                    onChanged: (value) => updateToggleValue(value),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight / 51.1), // 15
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CustomNavigation(
                      child: ManageMarqueePage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onTertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal:  screenWidth / 36, vertical: screenHeight / 76.6), //10
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Manage Dashboard Messages", style: GoogleFonts.lato(fontSize: screenWidth / 20)), //20
                    Icon(Icons.arrow_forward_ios_outlined, size: screenWidth / 10.3, color: Colors.grey,) //35
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
