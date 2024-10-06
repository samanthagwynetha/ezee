import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/components/button.dart';
import 'package:homehunt/components/textfield.dart';
import 'package:homehunt/helper/helperfunction.dart';
import 'package:homehunt/admin/admin_home.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Admin login method using Firestore
  void adminLogin() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Fetch admin data from Firestore by matching the email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Admin')
            .where('email', isEqualTo: emailController.text.trim())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var adminDoc = querySnapshot.docs.first;
          var storedPassword = adminDoc['password'];

          // Check if the entered password matches the stored password
          if (passwordController.text.trim() == storedPassword) {
            // Password matches, navigate to admin dashboard
            Navigator.pop(context); // Close loading indicator
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          } else {
            // Password is incorrect
            Navigator.pop(context);
            displayMessageToUser(
              "Error",
              "Incorrect password. Please try again.",
              context,
            );
          }
        } else {
          // No admin with this email found
          Navigator.pop(context);
          displayMessageToUser(
            "Error",
            "No admin found with this email.",
            context,
          );
        }
      } catch (e) {
        // Print the actual error for debugging
        print("Error: $e");
        Navigator.pop(context);
        displayMessageToUser(
          "Error",
          "An error occurred. Please try again.\nError: $e", // Show actual error
          context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFededeb),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.house,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),

                // App name
                const Text(
                  "Admin",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),

                // Email text field
                MyTextfield(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(height: 10),

                // Password text field
                MyTextfield(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 20),

                // Sign in button
                MyButton(
                  text: "Login",
                  onTap: adminLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
