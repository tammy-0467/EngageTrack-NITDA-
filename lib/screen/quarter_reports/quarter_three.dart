import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuarterThree extends StatefulWidget {
  const QuarterThree({super.key});

  @override
  State<QuarterThree> createState() => _QuarterThreeState();
}

class _QuarterThreeState extends State<QuarterThree> {
  String getCurrentQuarterKey() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    return "Q${quarter}_${now.year}";
  }

  Future<String> summarizeWithBart(List<String> messages) async {
    const String apiUrl = "https://api-inference.huggingface.co/models/philschmid/bart-large-cnn-samsum";
    const String apiToken = "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"; // Replace with your token

    final formattedInput = formatKudosForSummarization(messages);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "inputs": formattedInput,
          "parameters": {
            "max_length": 120,
            "min_length": 30,
            "do_sample": false
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result[0]['summary_text'];
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return "Summary could not be generated.";
      }
    } catch (e) {
      print("Exception: $e");
      return "Summary generation failed.";
    }
  }

  List<String> cleanMessages(List<String> messages) {
    return messages
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty && m.length > 5)
        .toList();
  }

  String formatKudosForSummarization(List<String> messages) {
    final prompt = StringBuffer();
    for (final msg in messages) {
      prompt.writeln("- $msg");
    }
    return prompt.toString();
  }

  Future<String> generateSummaryForTopUser(String userId, String quarterKey) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Kudos')
        .where('receiverId', isEqualTo: userId)
        .where('quarter', isEqualTo: quarterKey)
        .get();

    if (querySnapshot.docs.isEmpty) return "No kudos received this quarter.";

    final messages = querySnapshot.docs
        .map((doc) => doc['message']?.toString() ?? '')
        .where((msg) => msg.isNotEmpty)
        .toList();

    final cleaned = cleanMessages(messages);
    return await summarizeWithBart(cleaned);
  }

  Future<List<Map<String, dynamic>>> fetchTop10UsersForQ3() async {
    final now = DateTime.now();
    final q3Start = DateTime(now.year, 7, 1);
    final q3End = DateTime(now.year, 9, 30, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('Client')
        .where('lastUpdated', isGreaterThanOrEqualTo: q3Start)
        .where('lastUpdated', isLessThanOrEqualTo: q3End)
        .orderBy('points', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      'name': doc['name'] ?? 'Unknown',
      'points': doc['points'] ?? 0,
      'photoUrl': doc['imageUrl'] ?? '',
      'department': doc['department'] ?? 'Unknown',
      'staffRole': doc['role'] ?? 'Unknown',
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
              Text(
                'Tap on a name to view their summary.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchTop10UsersForQ3(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.isEmpty) {
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
                            final summary = await generateSummaryForTopUser(
                                user['id'], getCurrentQuarterKey());
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("This is the report for ${user['name']}",
                                    style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: user['photoUrl'] != ''
                                            ? NetworkImage(user['photoUrl'])
                                            : const AssetImage('assets/default_photo.jpg') as ImageProvider,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text("Name: ${user['name']}", style: GoogleFonts.lato()),
                                    Text("Department: ${user['department']}", style: GoogleFonts.lato()),
                                    Text("Role: ${user['staffRole']}", style: GoogleFonts.lato()),
                                    Text("Points: ${user['points']}", style: GoogleFonts.lato()),
                                    const SizedBox(height: 12),
                                    Text("Summary:", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(summary, style: GoogleFonts.lato()),
                                  ],
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
