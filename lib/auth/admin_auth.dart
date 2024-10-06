import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/admin/admin_login.dart';
import 'package:homehunt/auth/admin_login_only.dart';
import 'package:homehunt/auth/login_or_register.dart';
import 'package:homehunt/pages/home.dart';
// import 'package:ventspace/auth/login_or_register.dart';
// import '../pages/home_page.dart';

class AdminAuth extends StatelessWidget {
  const AdminAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is logged in
         if (snapshot.hasData) {
          return Home(); // Or AdminDashboard() if logged in as admin
          } else {
          return const AdminLoginOnly(); // Change this to AdminLoginPage
        }
        },
      ),
    );
  }
}