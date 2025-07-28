import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/quarter_reports/final_quarter.dart';
import 'package:gam_project/screen/quarter_reports/quarter_one.dart';
import 'package:gam_project/screen/quarter_reports/quarter_three.dart';
import 'package:gam_project/screen/quarter_reports/quarter_two.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class QuarterlyReportPage extends StatefulWidget {
  const QuarterlyReportPage({super.key});

  @override
  State<QuarterlyReportPage> createState() => _QuarterlyReportPageState();
}

class _QuarterlyReportPageState extends State<QuarterlyReportPage> {
  final CollectionReference _clientsCollection =
  FirebaseFirestore.instance.collection('Client');
  final _currentUser = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0;
  final List<Widget> _screens = [
    QuarterOne(),
    QuarterTwo(),
    QuarterThree(),
    FinalQuarter(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Quarterly Report", style: GoogleFonts.lato()),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 22.5, vertical: screenHeight/63.8), // 16 & 12
            child: GNav(
              gap: 8,
              backgroundColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.onPrimary,
              activeColor: Theme.of(context).colorScheme.onTertiary,
              tabBackgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
              padding: EdgeInsets.symmetric(horizontal: screenWidth / 18, vertical:screenHeight/63.8), //20 & 12
              textStyle: GoogleFonts.lato(color: Theme.of(context).colorScheme.onTertiary),
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: const [
                GButton(icon: Icons.looks_one, text: 'Q1'),
                GButton(icon: Icons.looks_two, text: 'Q2'),
                GButton(icon: Icons.looks_3, text: 'Q3'),
                GButton(icon: Icons.flag, text: 'Q4/Final'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

