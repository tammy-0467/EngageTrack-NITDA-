import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageMarqueePage extends StatefulWidget {
  const ManageMarqueePage({super.key});

  @override
  State<ManageMarqueePage> createState() => _ManageMarqueePageState();
}

class _ManageMarqueePageState extends State<ManageMarqueePage> {
  final TextEditingController _controller = TextEditingController();
  String? _editingDocId;

  Future<void> _addOrUpdateMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_editingDocId != null) {
      // Edit existing message
      await FirebaseFirestore.instance
          .collection('marquee_messages')
          .doc(_editingDocId)
          .update({'text': text});
    } else {
      // Add new message
      await FirebaseFirestore.instance.collection('marquee_messages').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'expiry': Timestamp.fromDate(DateTime.now().add(Duration(days: 30))),
      });
    }

    _controller.clear();
    setState(() => _editingDocId = null);
  }

  Future<void> _deleteMessage(String docId) async {
    await FirebaseFirestore.instance.collection('marquee_messages').doc(docId).delete();
  }

  void _editMessage(String docId, String currentText) {
    setState(() {
      _controller.text = currentText;
      _editingDocId = docId;
    });
  }

  Future<void> _deleteExpiredMessages() async {
    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('marquee_messages')
        .where('expiry', isLessThan: Timestamp.fromDate(now))
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  void initState() {
    super.initState();
    _deleteExpiredMessages();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Dashboard Messages", style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal:  screenWidth / 22.5, vertical: screenHeight/47.875), //16
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: _editingDocId == null ? "New dashboard message" : "Edit dashboard message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth / 360), //10
                ElevatedButton(
                  onPressed: _addOrUpdateMessage,
                  child: Text(_editingDocId == null ? "Add" : "Update"),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('marquee_messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final text = data['text'] ?? '';
                    final timestamp = data['timestamp']?.toDate();
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 360/22.5, vertical: screenHeight / 191.5), // 16 & 4
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onTertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                          padding: EdgeInsets.symmetric(horizontal: screenWidth / 36, vertical: screenHeight/76.6), //10
                        child: ListTile(
                          title: Text(text),
                          subtitle: timestamp != null
                              ? Text("Posted on: ${timestamp.toLocal().toString().split(' ')[0]}")
                              : null,
                          trailing: Wrap(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                                onPressed: () => _editMessage(docs[index].id, text),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onSurface),
                                onPressed: () => _deleteMessage(docs[index].id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
