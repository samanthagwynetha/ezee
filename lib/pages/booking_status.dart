import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importing for date formatting

class BookingStatusPage extends StatefulWidget {
  @override
  _BookingStatusPageState createState() => _BookingStatusPageState();
}

class _BookingStatusPageState extends State<BookingStatusPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> bookingStream;

  @override
  void initState() {
    super.initState();
    fetchBookingStatus();
  }

  void fetchBookingStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not logged in.");
      return;
    }

    String userId = user.uid;
    print("Current User ID: $userId");

    bookingStream = FirebaseFirestore.instance
        .collection('Bookings') // Ensure this matches your Firestore collection
        .where('UserID', isEqualTo: userId)
        .snapshots();
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(bookingId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking canceled successfully.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to cancel booking: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Status'),
        backgroundColor: Colors.teal, // AppBar color
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: bookingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "No bookings found.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> booking = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4, // Shadow effect
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          "Booking ID: ${booking['BookingID']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Check-in: ${DateFormat('yyyy-MM-dd').format(booking['CheckInDate'].toDate())}"),
                              Text("Check-out: ${DateFormat('yyyy-MM-dd').format(booking['CheckOutDate'].toDate())}"),
                              Text("Total Price: ₱${booking['TotalPrice'].toStringAsFixed(2)}"),
                              Text("Status: ${booking['Status']}"),
                            ],
                          ),
                        ),
                      ),
                      // Conditional rendering of the cancel button
                      if (booking['Status'] == 'Pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _cancelBooking(booking.id);
                              },
                              child: Text("Cancel"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Set button color to red
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
