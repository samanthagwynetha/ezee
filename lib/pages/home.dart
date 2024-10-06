import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/auth/auth.dart';
import 'package:homehunt/pages/details.dart';
import 'package:homehunt/services/database.dart';
import 'package:homehunt/widget/support_widget.dart';
import 'package:homehunt/components/bottompagenav.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? roomItemStream;
  String selectedCategory = "Standard"; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  onLoad() async {
    // Load initial data for the selected category
    roomItemStream = await DatabaseMethods().getRoomItem(selectedCategory);
    setState(() {}); // Refresh UI
  }

  Widget allItemsVertically() {
    return StreamBuilder(
      stream: roomItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(child: Text("No items found."));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Details(
                      title: ds["Title"],
                      description: ds["Description"],
                      address: ds["Address"],
                      price: ds["Price"],
                      maxguests: ds["MaxGuests"],
                      images: ds["Image"],
                      status: ds["Status"],
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          ds["Image"],
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 20.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ds["Title"], style: Appwidget.semiboldtextfieldstyle()),
                              SizedBox(height: 10),
                              // Convert Price to String if it is an int
                              Text("\₱" + ds["Price"].toString(), style: Appwidget.semiboldtextfieldstyle()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget allItems() {
    return StreamBuilder(
      stream: roomItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(child: Text("No items found."));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Details(
                      title: ds["Title"],
                      description: ds["Description"],
                      address: ds["Address"],
                      price: ds["Price"],
                      maxguests: ds["MaxGuests"],
                      images: ds["Image"],
                      status: ds["Status"],
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(5),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            ds["Image"],
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(ds["Title"], style: Appwidget.semiboldtextfieldstyle()),
                        // Convert Price to String if it is an int
                        Text("\₱" + ds["Price"].toString(), style: Appwidget.semiboldtextfieldstyle()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Method to create category buttons
  Widget buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category; // Update selected category
          onLoad(); // Fetch new data for the selected category
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedCategory == category ? Colors.black : Colors.grey[350],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          category,
          style: Appwidget.categorytextfieldstyle().copyWith(
            color: selectedCategory == category ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hello Madi,", style: Appwidget.boldtextfieldstyle()),
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10.0)),
                  child: Icon(Icons.house, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text("Cozy Corner", style: Appwidget.HeadlineTextfieldstyle()),
            Text("Rent a Room", style: Appwidget.lighttextfieldstyle()),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildCategoryButton("Standard"),
                buildCategoryButton("Deluxe"),
                buildCategoryButton("Suites"),
                buildCategoryButton("Specialty"),
              ],
            ),
            SizedBox(height: 30.0),
            Container(height: 280, child: allItems()),

            SizedBox(height: 30.0),
            Expanded(child: allItemsVertically()), // Use Expanded for vertical list
           
            SizedBox(height: 30.0),
        
          ],
        ),
      ),
      bottomNavigationBar: Bottompagenav(), // Use Bottompagenav here
    );
  }
}
