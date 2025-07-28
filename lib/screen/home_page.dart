import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/admin_page.dart';
import 'package:gam_project/screen/dashboard_page.dart';
import 'package:gam_project/screen/leader_board_page.dart';
import 'package:gam_project/screen/notificationMsg.dart';
import 'package:gam_project/screen/profile_page.dart';
import 'package:gam_project/screen/quarterly_report_page.dart';
import 'package:gam_project/screen/questionnaire_page.dart';
import 'package:gam_project/screen/settings.dart';
import 'package:gam_project/screen/task_list.dart';
import 'package:gam_project/services/auth_services.dart';
import 'package:gam_project/widgets/custom_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final String userRole; // Add userRole as a parameter
  const HomePage({super.key, required this.userRole});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentUserId = '';
  Widget? _currentPage;

  int _selectedIndex = 0;
  List<Widget> pages = []; // Define pages as a list of Widgets
  @override
  void initState() {
    super.initState();
    // Fetch the current user's ID from FirebaseAuth
    _getCurrentUserId();
    _currentPage = DashBoardPage();
    // // Fetch the user's role from Firestore based on the user's ID
    // _fetchUserRole();
  }

  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _clientsCollection =
      FirebaseFirestore.instance.collection('Client');

  void _handleLogout() {
    // Implement your logout logic here
    print('Logging out...');
    showToast('Logged out successfully');
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/login");

    // Navigate to login page or perform any necessary logout operations
    // Navigator.pushNamed(context, "/login");
  }

  void _fetchUserRole(String userId) async {
    try {
      // Fetch the user's role from Firestore
      String userRole = await _getUserRoleFromFirestore(userId);
      setState(() {
        if (userRole == 'CEO') {
          pages = [
            DashBoardPage(),
            NotificationToAllUser(),
            // Assuming AllUsersPage is the page to display to all users
            LeaderBoardPage(),
            ProfilePage(),
          ];
        } else {
          pages = [
            DashBoardPage(),
            TaskScreen(),
            LeaderBoardPage(),
            ProfilePage(),
          ];
        }
      });
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> _getCurrentUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
      });
      // Once you have the current user's ID, fetch the user's role
      _fetchUserRole(_currentUserId);
    }
  }

  Future<String> _getUserRoleFromFirestore(String userId) async {
    try {
      // Fetch the user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('Client')
          .doc(userId)
          .get();

      // Check if the user document exists and contains the 'role' field
      if (userDoc.exists &&
          userDoc.data() != null &&
          userDoc.data()!.containsKey('role')) {
        // Return the user's role
        return userDoc.data()!['role'];
      } else {
        // If the user document doesn't exist or doesn't contain the 'role' field, return an empty string
        return '';
      }
    } catch (e) {
      // Handle any errors that occur during the fetch operation
      print('Error fetching user role: $e');
      // Return an empty string in case of error
      return '';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              final String userRole = profileInfo['role'];
              // Check user's role to determine if the "Assign Task" button should be displayed
              final bool isGeneralRole = userRole == 'General Staff';
              final bool isSupervisor = userRole == 'Supervisor';
              final bool isManager = userRole == 'Manager';
              final bool isCEO = userRole == 'CEO'; // New: Check if user is CEO
              final bool isAdmin = userRole == 'Administrator';


              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                appBar: AppBar(
                    title: Text(
                      'Gamified Engagement System',
                      style: GoogleFonts.lato(fontSize: screenWidth/18, color: Theme.of(context).colorScheme.onSurface), //20
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    elevation: 0,
                    leading: Builder(
                      builder: (context) => IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: Padding(
                            padding: EdgeInsets.only(left: screenWidth/45), //8
                            child: Icon(Icons.menu),
                          )),
                    )),
                drawer: Drawer(
                  backgroundColor: Theme.of(context).colorScheme.onTertiary,

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          DrawerHeader(
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.primary),
                              child: Image.asset(
                                'assets/cropped-cropped-NITDA-Logo-new-03.png',
                                height: screenHeight/19.5, //40
                              )),

                          Padding(
                            padding:
                                 EdgeInsets.symmetric(horizontal: 14.4), //25
                            child: Divider(
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),

                          //other pages
                        /*  GestureDetector(
                            onTap: ,
                            child: Row(

                            ),
                          ),*/
                          drawerTile(
                              () => Navigator.push(
                                  context,
                                  CustomNavigation(
                                      child: ProfilePage())),
                              "P R O F I L E",
                              Icons.person),

                          isCEO ? SizedBox() :
                          drawerTile(
                              () => Navigator.push(
                                  context,
                                  CustomNavigation(
                                      child: TaskScreen())),
                              'T A S K S',
                              Icons.task),

                          isAdmin ? drawerTile(
                                  () => Navigator.push(
                                  context,
                                  CustomNavigation(
                                     child:  AdminPage())),
                              'A D M I N  S E T T I N G S',
                              Icons.settings_accessibility) : SizedBox(),

                          isCEO? SizedBox():
                          drawerTile(
                                  () => Navigator.push(
                                  context,
                                      CustomNavigation(
                                          child: QuestionnairePage())),
                              'S U R V E Y',
                              Icons.assignment),

                          drawerTile(
                              () => Navigator.push(
                                  context,
                                  CustomNavigation(
                                      child:
                                          QuarterlyReportPage())),
                              'Q U A R T E R L Y  R E P O R T',
                              Icons.insert_chart),
                          drawerTile(() =>
                            Navigator.push(context,  CustomNavigation(
                                child: LeaderBoardPage())), 'L E A D E R B O A R D', Icons.leaderboard),
                         /* drawerTile(
                              () => Navigator.push(
                                  context,
                                  CustomNavigation(
                                      child: SettingsPage())),
                              'S E T T I N G S',
                              Icons.settings),*/
                        ],
                      ),
                      drawerTile(_handleLogout, 'L O G O U T', Icons.logout),
                    ],
                  ),
                ),
                body: DashBoardPage(),
              );
            }));

    /*return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onTertiary,
        appBar: AppBar(
            title: Text('Gamified Engagement System', style: GoogleFonts.lato(fontSize: 20),),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.menu),
                  )),
            )),
        drawer: Drawer(
          backgroundColor: Theme.of(context).colorScheme.onTertiary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  DrawerHeader(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary),
                      child: Image.asset(
                        'assets/cropped-cropped-NITDA-Logo-new-03.png',
                        height: 40,
                      )),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Divider(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),

                  //other pages
                  drawerTile(
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage())),
                      'P R O F I L E',
                      Icons.person),
                  drawerTile(
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TaskScreen())),
                      'T A S K S',
                      Icons.task),

                  drawerTile( () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuarterlyReportPage())), 'Q U A R T E R L Y  R E P O R T', Icons.insert_chart),
                  drawerTile(
                      () { Navigator.pop(context);
                        Navigator.pushNamed(context, '/leaderboard');
                        },
                      'L E A D E R B O A R D',
                      Icons.leaderboard),
                  drawerTile(
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage())),
                      'S E T T I N G S',
                      Icons.settings),
                ],
              ),
              drawerTile(_handleLogout, 'L O G O U T', Icons.logout),
            ],
          ),
        ),
        */

    /*bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          //  backgroundColor: Colors.red,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: 'Favourite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          //unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.indigo[900],
          selectedFontSize: 0,
          unselectedFontSize: 0,
          //elevation: 0,
          showSelectedLabels: true,
          // showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),*/ /*
        body: DashBoardPage()

        */ /*pages.isNotEmpty
            ? pages[_selectedIndex]
            : Center(child: CircularProgressIndicator())*/ /*
        );*/
  }

  GestureDetector drawerTile(
      void Function()? onTap, String title, IconData? icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: screenWidth/24), //15
        child: ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            title,
            style: GoogleFonts.lato(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
