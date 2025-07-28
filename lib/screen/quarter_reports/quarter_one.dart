import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuarterOne extends StatefulWidget {
  const QuarterOne({super.key});

  @override
  State<QuarterOne> createState() => _QuarterOneState();
}

class _QuarterOneState extends State<QuarterOne> {
  String getCurrentQuarterKey() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    return "Q${quarter}_${now.year}";
  }


  Future<String> summarizeWithT5(String inputText) async {
    final url = Uri.parse('https://api-inference.huggingface.co/models/t5-small');
    final headers = {
      'Authorization': 'Bearer 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',
      'Content-Type': 'application/json'
    };

    final body = jsonEncode({
      "inputs": "summarize: $inputText"
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded[0]["summary_text"];
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return "Summary could not be generated.";
    }
  }

  Future<String> generateSummaryForTopUser(String userId, String quarterKey) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Kudos')
        .where('receiverId', isEqualTo: userId)
        .where('quarter', isEqualTo: quarterKey)
        .get();

    if (querySnapshot.docs.isEmpty) return "No kudos received this quarter.";

    final messages = querySnapshot.docs
        .map((doc) => doc['message'] as String)
        .join(". ");

    return await summarizeWithT5(messages);
  }

  Future<List<Map<String, dynamic>>> fetchTop10UsersForQ1() async {
    final now = DateTime.now();
    final q1Start = DateTime(now.year, 1, 1);
    final q1End = DateTime(now.year, 3, 31, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('Client')
        .where('lastUpdated', isGreaterThanOrEqualTo: q1Start)
        .where('lastUpdated', isLessThanOrEqualTo: q1End)
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
                future: fetchTop10UsersForQ1(),
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
                          onTap: () async {
                            final summary = await generateSummaryForTopUser(user['id'], getCurrentQuarterKey());
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Kudos Summary', style: GoogleFonts.lato()),
                                content: Text(summary, style: GoogleFonts.lato()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Close", style: GoogleFonts.lato()),
                                  )
                                ],
                              ),
                            );
                          },
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
                        "Quarter 1",
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
