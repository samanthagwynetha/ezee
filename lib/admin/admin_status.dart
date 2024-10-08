import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminBookingStatus extends StatefulWidget {
  @override
  _AdminBookingStatusState createState() => _AdminBookingStatusState();
}

class _AdminBookingStatusState extends State<AdminBookingStatus> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> bookingStream;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  // Fetch all bookings
  void fetchBookings() {
    bookingStream = FirebaseFirestore.instance
        .collection('Bookings')
        .snapshots();
  }

  // Update or delete booking based on the status
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      if (newStatus == 'Rejected') {
        // Delete booking if rejected
        await FirebaseFirestore.instance
            .collection('Bookings')
            .doc(bookingId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Booking has been rejected and removed.")));
      } else {
        // Update status for other cases
        await FirebaseFirestore.instance
            .collection('Bookings')
            .doc(bookingId)
            .update({'Status': newStatus});
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Booking status updated to $newStatus")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Booking Status'),
        backgroundColor: Colors.teal,
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
              DocumentSnapshot<Map<String, dynamic>> booking =
                  snapshot.data!.docs[index];

              // Convert Firestore Timestamp to DateTime
              DateTime checkInDate = (booking['CheckInDate'] as Timestamp).toDate();
              DateTime checkOutDate = (booking['CheckOutDate'] as Timestamp).toDate();

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Booking ID: ${booking['BookingID']}", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Check-in: ${DateFormat('yyyy-MM-dd').format(checkInDate)}"), // Format date
                      Text("Check-out: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}"), // Format date
                      Text("Total Price: ₱${booking['TotalPrice']}"),
                      Text("Current Status: ${booking['Status']}"),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Dropdown to change status
                          DropdownButton<String>(
                            value: booking['Status'],
                            items: <String>['Pending', 'Approved', 'Rejected']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null && newValue != booking['Status']) {
                                // Call update function when status is changed
                                updateBookingStatus(booking.id, newValue);
                              }
                            },
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
