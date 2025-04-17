import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String boardName;
  const ChatScreen({super.key, required this.boardName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser!;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final displayName = "${userDoc['first_name']} ${userDoc['last_name']}";

    await _firestore.collection('boards/${widget.boardName}/messages').add({
      'text': _messageController.text.trim(),
      'created_at': Timestamp.now(),
      'user_id': user.uid,
      'user_name': displayName,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = _firestore
        .collection('boards/${widget.boardName}/messages')
        .orderBy('created_at', descending: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading messages."));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return ListTile(
                      title: Text(msg['text']),
                      subtitle: Text("${msg['user_name']} • ${msg['created_at'].toDate()}"),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
