import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/staffRatingPage.dart';
import 'package:gam_project/widgets/custom_navigation.dart';
import 'package:gam_project/widgets/search_bar.dart';
import 'package:google_fonts/google_fonts.dart';


class kudosPage extends StatefulWidget {
  const kudosPage({super.key});

  @override
  State<kudosPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<kudosPage> {
  late String? currentUserId;
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    fetchUsers();
  }

  void getCurrentUserId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      currentUserId = currentUser.uid;
    }
  }

  void fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('Client').get();
    setState(() {
      allUsers = snapshot.docs;
      filteredUsers = allUsers;
    });
  }

  void updateSearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredUsers = allUsers.where((doc) {
        final name = (doc['name'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Who would you like to commend?", style: GoogleFonts.lato(fontSize: screenWidth / 18),), //20
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight / 12.77), //60
          child: CustomSearchBar(onChanged: updateSearch),
        ),
      ),
      body: filteredUsers.isEmpty
          ? const Center(child: Text("No staff found"))
          : ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final userData = filteredUsers[index].data() as Map<String, dynamic>;
          final String userId = filteredUsers[index].id;
          final String name = userData['name'] ?? '';

          if (userId == currentUserId) return SizedBox.shrink();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CustomNavigation(
                  child: RatingPage(
                    userName: name,
                    receiverUserId: userId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth / 24, vertical: screenHeight / 97.75), // 15 & 8
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name, style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onSurface,),),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/*class kudosPage extends StatefulWidget {
  const kudosPage({super.key});

  @override
  State<kudosPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<kudosPage> {
  late String? currentUserId; // Initialize with null

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
  }

  void getCurrentUserId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        currentUserId = currentUser.uid;
      });
    }
  }

  final _staffList =
      FirebaseFirestore.instance.collection('Client').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _staffList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Connection error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Loading...'));
          }
          // var userDoc = snapshot.data!.docs;
          final List<DocumentSnapshot> userDocs = snapshot.data!.docs;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text('Who would you like to commend?', style: TextStyle(fontSize: 18),),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: CustomSearchBar(),
              ),
            ),
            body: ListView.builder(
                itemCount: userDocs.length,
                itemBuilder: (context, index) {
                  final userData =
                      userDocs[index].data() as Map<String, dynamic>;
                  final String userId = userDocs[index].id;
                  final String name = userData['name'] ?? '';
                  final String email = userData['email'] ?? '';
                  final dynamic points = userData['points'];
                  //final dynamic receiverUserId = userData

                  // Exclude current user from the list
                  if (userId == currentUserId) {
                    return SizedBox.shrink();
                  }

                  return GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.onTertiary
                        ),
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(name),
                          // subtitle: Text(email),
                          // trailing: Text("${points.toString()} pts"),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RatingPage(
                                    userName: name,
                                    receiverUserId: userId,
                                  )));
                    },
                  );
                }),
          );
        },
      ),
    );
  }
}*/













// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:gam_project/screen/staffRatingPage.dart';

// class kudosPage extends StatefulWidget {
//   const kudosPage({super.key});

//   @override
//   State<kudosPage> createState() => _LeaderBoardPageState();
// }

// class _LeaderBoardPageState extends State<kudosPage> {
//   final _staffList =
//       FirebaseFirestore.instance.collection('Client').snapshots();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: _staffList,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Text('Connection error');
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: Text('Loading...'));
//           }
//           // var userDoc = snapshot.data!.docs;
//           final List<DocumentSnapshot> userDocs = snapshot.data!.docs;
//           return Scaffold(
//             appBar: AppBar(
//               backgroundColor: Colors.grey[100],
//               title: Text('Kudos to'),
//             ),
//             body: ListView.builder(
//                 itemCount: userDocs.length,
//                 itemBuilder: (context, index) {
//                   final userData =
//                       userDocs[index].data() as Map<String, dynamic>;
//                   final String name = userData['name'] ?? '';
//                   final String email = userData['email'] ?? '';
//                   final dynamic points = userData['points'];

//                   return GestureDetector(
//                     child: ListTile(
//                       leading: CircleAvatar(child: Icon(Icons.person)),
//                       title: Text(name),
//                       // subtitle: Text(email),
//                       // trailing: Text("${points.toString()} pts"),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => RatingPage()));
//                     },
//                   );
//                 }),
//           );
//         },
//       ),
//     );
//   }
// }
