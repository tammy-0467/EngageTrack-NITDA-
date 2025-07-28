import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final staffList = FirebaseFirestore.instance.collection('Client').snapshots();



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('LeaderBoard', style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onPrimary),),
          /*actions: [
            LottieBuilder.asset(
              'assets/ladder.json',
              repeat: true,
              height: 70,
              width: 70,
              filterQuality: FilterQuality.high,
            ),
          ],*/
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: staffList,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Connection error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final List<DocumentSnapshot> userDocs = snapshot.data!.docs;
            // Sort userDocs by points in descending order
            userDocs.sort((a, b) {
              final int pointsA = int.tryParse(a['points'].toString()) ?? 0;
              final int pointsB = int.tryParse(b['points'].toString()) ?? 0;
              return pointsB.compareTo(pointsA);
            });


            return ListView.builder(
              itemCount: userDocs.length,
              itemBuilder: (context, index) {
                final userData = userDocs[index].data() as Map<String, dynamic>;
                final String name = userData['name'] ?? '';
                final String email = userData['email'] ?? '';
                final dynamic points =
                    userData['points']; // Parse points into a numeric type
                final int userPoints =
                    points is int ? points : int.tryParse(points) ?? 0;

                // Assign badge based on leaderboard position
                Widget badge = SizedBox();
                if (index == 0) {
                  badge = Image.asset('assets/award3.png', height: screenHeight / 25.33, width: screenWidth / 12); // 30
                } else if (index == 1) {
                  badge = Image.asset('assets/award2.png', height: screenHeight / 25.33, width: screenWidth / 12); //30
                } else if (index == 2) {
                  badge = Image.asset('assets/award1.png', height: screenHeight / 25.53, width: screenWidth / 12); //30 & 30
                }
                /* // Check if points is not null and can be parsed as an integer
                if (points != null && int.tryParse(points.toString()) != null) {
                  final int userPoints = int.parse(points.toString());

                  // Badge logic based on userPoints
                  if (userPoints >= 50 && userPoints <= 100) {
                    badge = Image.asset('assets/award_1.png');
                  } else if (userPoints >= 101 && userPoints <= 150) {
                    badge = Image.asset('assets/award2.png');
                  } else if (userPoints >= 151 && userPoints <= 500) {
                    badge = Image.asset('assets/award3.png');
                  } else {
                    // If points do not fall into any of the specified ranges, show no badge
                    badge =
                        SizedBox(); // or any other widget representing no badge
                  }
                } else {
                  // If points is null or not a valid integer, show no badge
                  badge =
                      SizedBox(); // or any other widget representing no badge
                }*/

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Client')
                      .doc(userDocs[index].id)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SizedBox(); // You can show a loading indicator here if needed
                    }
                    if (userSnapshot.hasError) {
                      return SizedBox(); // You can handle the error here
                    }

                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    final String photoUrl = userData['imageUrl'] ??
                        ''; // Assuming 'photoUrl' is the field name for the image URL

                    return Padding(
                      padding: EdgeInsets.only(top: screenHeight /95.75, left: screenWidth / 45, right: screenWidth / 45), //8
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onTertiary,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: photoUrl != ''
                                              ? NetworkImage(photoUrl)
                                              : Image.asset(
                                                      'assets/default_photo.jpg')
                                                  .image)),
                                ),
                              ),
                              title: Text(name, style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onSurface),),
                              subtitle: Text('Points: ${userPoints}', style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onSurface),),
                              trailing:
                                  Container(height: screenHeight / 25.33, width: screenWidth / 12, child: badge), //
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}





// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class LeaderBoardPage extends StatefulWidget {
//   const LeaderBoardPage({Key? key});

//   @override
//   State<LeaderBoardPage> createState() => _LeaderBoardPageState();
// }

// class _LeaderBoardPageState extends State<LeaderBoardPage> {
//   final staffList = FirebaseFirestore.instance.collection('Client').snapshots();

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text('Leader Board'),
//         ),
//         body: StreamBuilder<QuerySnapshot>(
//           stream: staffList,
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Text('Connection error');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }

//             final List<DocumentSnapshot> userDocs = snapshot.data!.docs;
//             // Sort userDocs by points in descending order
//             userDocs.sort((a, b) {
//               final int pointsA = int.tryParse(a['points'].toString()) ?? 0;
//               final int pointsB = int.tryParse(b['points'].toString()) ?? 0;
//               return pointsB.compareTo(pointsA);
//             });

//             return ListView.builder(
//               itemCount: userDocs.length,
//               itemBuilder: (context, index) {
//                 final userData = userDocs[index].data() as Map<String, dynamic>;
//                 final String name = userData['name'] ?? '';
//                 final String email = userData['email'] ?? '';
//                 final dynamic points =
//                     userData['points']; // Parse points into a numeric type
//                 final int userPoints =
//                     points is int ? points : int.tryParse(points) ?? 0;

//                 Widget badge;

//                 // Check if points is not null and can be parsed as an integer
//                 if (points != null && int.tryParse(points.toString()) != null) {
//                   final int userPoints = int.parse(points.toString());

//                   // Badge logic based on userPoints
//                   if (userPoints >= 10 && userPoints <= 29) {
//                     badge = Image.asset('assets/award1.png');
//                   } else if (userPoints >= 30 && userPoints <= 49) {
//                     badge = Image.asset('assets/award2.png');
//                   } else if (userPoints >= 50 && userPoints <= 600) {
//                     badge = Image.asset('assets/award3.png');
//                   } else {
//                     // If points do not fall into any of the specified ranges, show no badge
//                     badge =
//                         SizedBox(); // or any other widget representing no badge
//                   }
//                 } else {
//                   // If points is null or not a valid integer, show no badge
//                   badge =
//                       SizedBox(); // or any other widget representing no badge
//                 }

//                 return Column(
//                   children: [
//                     ListTile(
//                       leading: CircleAvatar(child: Icon(Icons.person)),
//                       title: Text(name),
//                       subtitle: Text('Score: ${userPoints}'),
//                       trailing: Container(height: 30, width: 30, child: badge),
//                     ),
//                     Divider(
//                       thickness: 0.5,
//                     )
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
