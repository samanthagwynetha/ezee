import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:homehunt/pages/booking.dart'; 
import 'package:homehunt/pages/booking_status.dart';
import 'package:homehunt/pages/home.dart'; 
import 'package:homehunt/pages/profile.dart';

class Bottompagenav extends StatefulWidget {
  const Bottompagenav({Key? key}) : super(key: key);

  @override
  State<Bottompagenav> createState() => _BottompagenavState();
}

class _BottompagenavState extends State<Bottompagenav> {
  late List<Widget> pages;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    pages = [
      Home(), // Change this to your home widget or create an instance
      BookingStatusPage(),
      Profile(), // Ensure this is defined
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      height: 65,
      backgroundColor: Colors.white,
      color: Color.fromARGB(255, 0, 0, 0),
      animationDuration: Duration(milliseconds: 300),
      index: currentTabIndex,
      items: <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.book_online, size: 30, color: Colors.white),
        Icon(Icons.person, size: 30, color: Colors.white),
      ],
      onTap: (index) {
        setState(() {
          currentTabIndex = index;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => pages[currentTabIndex]),
          );
        });
      },
    );
  }
}
