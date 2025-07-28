import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuarterTwo extends StatefulWidget {
  const QuarterTwo({super.key});

  @override
  State<QuarterTwo> createState() => _QuarterTwoState();
}

class _QuarterTwoState extends State<QuarterTwo> {
  Future<List<Map<String, dynamic>>> fetchTop10UsersForQ2() async {
    final now = DateTime.now();
    final q2Start = DateTime(now.year, 4, 1);
    final q2End = DateTime(now.year, 6, 30, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('Client')
        .where('lastUpdated', isGreaterThanOrEqualTo: q2Start)
        .where('lastUpdated', isLessThanOrEqualTo: q2End)
        .orderBy('points', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => {
      'name': doc['name'] ?? 'Unknown',
      'points': doc['points'] ?? 0,
      'photoUrl': doc['imageUrl'] ?? '',
    })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("These are the best 10 performers of this quarter",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchTop10UsersForQ2(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No data available for this quarter.");
                  }

                  final users = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['photoUrl'] != ''
                                ? NetworkImage(user['photoUrl'])
                                : const AssetImage('assets/default_photo.jpg')
                            as ImageProvider,
                          ),
                          title: Text(user['name'],
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w600)),
                          subtitle:
                          Text("Points: ${user['points'].toString()}"),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Quarter 2",
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap on a name to view their summary.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
