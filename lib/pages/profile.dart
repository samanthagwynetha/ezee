import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homehunt/auth/auth.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String email = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "No email found";
      });
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Delete user from Firebase Authentication
        await user.delete();

        // Optionally, delete user data from Firestore
        await _firestore.collection('Users').doc(user.uid).delete();

        // Log out the user
        await _auth.signOut();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account deleted successfully.")));
        Navigator.of(context).pop(); // Navigate back to the previous screen
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete account: $e")));
    }
  }
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Email
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.email, color: Colors.black),
                  SizedBox(width: 10.0),
                  Text(
                    "Email: $email",
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Terms and Conditions
            GestureDetector(
              onTap: () {
                // Navigate to terms and conditions page
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.black),
                    SizedBox(width: 10.0),
                    Text(
                      "Terms and Conditions",
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            // Delete Account
            GestureDetector(
              onTap: _deleteAccount,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 10.0),
                    Text(
                      "Delete Account",
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

        // Logout
            Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: ListTile(
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.inversePrimary),
                title: Text("L O G O U T"),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AuthPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
