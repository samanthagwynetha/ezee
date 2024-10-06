import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class BookingPage extends StatefulWidget {
  final double price;

  BookingPage({required this.price});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  XFile? imageFile; // For mobile
  Uint8List? imageBytes; // For web
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? (checkInDate ?? DateTime.now()) : (checkOutDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != (isCheckIn ? checkInDate : checkOutDate)) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _uploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile; // Keep for mobile
        imageBytes = null; // Clear web bytes for mobile
      });

      // Convert to Uint8List for web image handling
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          imageFile = null; // Clear the file for web usage
          imageBytes = bytes; // Store the bytes for display
        });
      }
    }
  }

  double _calculateTotalPrice() {
    if (checkInDate != null && checkOutDate != null) {
      int totalDays = checkOutDate!.difference(checkInDate!).inDays;
      return totalDays > 0 ? totalDays * widget.price : 0.0;
    }
    return 0.0;
  }

  Future<void> _confirmBooking() async {
    if (checkInDate != null && checkOutDate != null && (imageFile != null || imageBytes != null)) {
      // Calculate total price
      double totalPrice = _calculateTotalPrice();

      // Get the current user's ID
      User? user = FirebaseAuth.instance.currentUser;
      String? uid = user?.uid;

      // Generate a unique BookingID
      String bookingId = DateTime.now().millisecondsSinceEpoch.toString();

      // Prepare booking data
      Map<String, dynamic> bookingData = {
        'BookingID': bookingId,
        'UserID': uid,
        'CheckInDate': checkInDate,
        'CheckOutDate': checkOutDate,
        'TotalPrice': totalPrice,
        'Status': 'Pending',
        'ImagePath': imageFile != null ? imageFile!.path : null, // Store path for mobile
        // Consider additional logic for uploading web image and getting URL
      };

      try {
        // Save booking data to Firestore
        await FirebaseFirestore.instance.collection('Bookings').doc(bookingId).set(bookingData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Confirmed! Total Price: ₱${totalPrice.toStringAsFixed(2)}")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to confirm booking: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text("Book a Room"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Check-in Date", style: TextStyle(fontSize: 18)),
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  checkInDate == null ? 'Select date' : DateFormat('yyyy-MM-dd').format(checkInDate!),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Check-out Date", style: TextStyle(fontSize: 18)),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  checkOutDate == null ? 'Select date' : DateFormat('yyyy-MM-dd').format(checkOutDate!),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Upload Image", style: TextStyle(fontSize: 18)),
            GestureDetector(
              onTap: _uploadImage,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: imageFile == null && imageBytes == null
                    ? Text('Tap to upload an image', style: TextStyle(fontSize: 16))
                    : kIsWeb
                        ? Image.memory(imageBytes!, width: 100, height: 100) // For web
                        : Image.file(File(imageFile!.path), width: 100, height: 100), // For mobile
              ),
            ),
            SizedBox(height: 20),
            Text("Total Price: ₱${totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                child: Text("Confirm Booking"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
