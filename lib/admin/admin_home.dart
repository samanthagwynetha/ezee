import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/admin/add_room.dart';
import 'package:homehunt/admin/edit_room.dart';
import 'package:homehunt/auth/auth.dart';
import 'package:homehunt/pages/home.dart';
import 'package:homehunt/services/database.dart';
import 'package:homehunt/widget/support_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Stream<QuerySnapshot>? roomItemStream;
  String selectedCategory = "Standard"; // Default category

  @override
  void initState() {
    super.initState();
    _loadRoomItems();
  }

  void _loadRoomItems() async {
    roomItemStream = await DatabaseMethods().getRoomItem(selectedCategory);
    setState(() {}); // Refresh UI
  }

  Widget _buildRoomItemList() {
    return StreamBuilder<QuerySnapshot>(
      stream: roomItemStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No items found."));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildRoomItemCard(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildRoomItemCard(DocumentSnapshot ds) {
    return Container(
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
                    Text("₱${ds["Price"]}", style: Appwidget.semiboldtextfieldstyle()),
                  ],
                ),
              ),
              _buildEditIcon(ds),
              _buildDeleteIcon(ds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditIcon(DocumentSnapshot ds) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        String collectionName = selectedCategory; // Use selected category directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditRoomScreen(
              collectionName: collectionName,
              docID: ds.id,
              images: ds["Image"],
              title: ds["Title"],
              description: ds["Description"],
              address: ds["Address"],
              price: (ds["Price"]),
              maxGuests: (ds["MaxGuests"]),
              status: ds["Status"],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteIcon(DocumentSnapshot ds) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () async {
        bool confirm = await _showDeleteConfirmationDialog();
        if (confirm) {
          await DatabaseMethods().deleteRoomItem(selectedCategory, ds.id);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Room item deleted successfully.")));
          _loadRoomItems(); // Refresh the list after deletion
        }
      },
    );
  }

  Future<bool> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Room Item"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Delete")),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  // Method to create category buttons
  Widget _buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category; // Update selected category
          _loadRoomItems(); // Fetch new data for the selected category
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
                Text("Admin Dashboard", style: Appwidget.boldtextfieldstyle()),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10.0)),
                    child: Icon(Icons.house, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton("Standard"),
                _buildCategoryButton("Deluxe"),
                _buildCategoryButton("Suites"),
                _buildCategoryButton("Specialty"),
              ],
            ),
            SizedBox(height: 30.0),
            Expanded(child: _buildRoomItemList()), // Display vertical list of room items
            SizedBox(height: 30.0),
            _buildLogoutTile(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddRoom())); // Navigate to AddRoom
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _buildLogoutTile() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0),
      child: ListTile(
        leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.inversePrimary),
        title: Text("L O G O U T"),
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthPage()));
        },
      ),
    );
  }
}
