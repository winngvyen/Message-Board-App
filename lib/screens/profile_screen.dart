import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool _isLoading = true;

  void _loadUserData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    firstNameController.text = doc['first_name'];
    lastNameController.text = doc['last_name'];
    setState(() => _isLoading = false);
  }

  void _saveChanges() async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: "First Name"),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: "Last Name"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}
