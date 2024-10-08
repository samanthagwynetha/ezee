import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/services/database.dart';
import 'package:homehunt/widget/support_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class EditRoomScreen extends StatefulWidget {
  final String collectionName;
  final String docID;
  final String images;
  final String title;
  final String description;
  final String address;
  final String price;
  final String maxGuests;
  final String status;

  EditRoomScreen({
    required this.collectionName,
    required this.docID,
    required this.images,
    required this.title,
    required this.description,
    required this.address,
    required this.price,
    required this.maxGuests,
    required this.status,
  });

  @override
  _EditRoomScreenState createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final maxGuestsController = TextEditingController();
  String? status;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage; // For mobile
  Uint8List? selectedImageBytes; // For web image storage

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with the current room details
    titleController.text = widget.title;
    descController.text = widget.description;
    addressController.text = widget.address;
    priceController.text = widget.price;
    maxGuestsController.text = widget.maxGuests;
    status = widget.status; // Set the initial status
  }

  Future<void> getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path); 
        selectedImageBytes = null; 
      });

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          selectedImage = null; 
          selectedImageBytes = bytes; 
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateRoom() async {
    Map<String, dynamic> updatedData = {
      "Title": titleController.text,
      "Description": descController.text,
      "Address": addressController.text,
      "Price": priceController.text,
      "MaxGuests": maxGuestsController.text,
      "Status": status,
    };

    if (selectedImage != null || selectedImageBytes != null) {
      String? downloadUrl;
      final firebaseStorageRef = FirebaseStorage.instance.ref().child("Image").child(widget.docID);
      try {
        // Upload the new image and get the download URL
        if (selectedImage != null) {
          // Mobile case
          final task = firebaseStorageRef.putFile(selectedImage!);
          downloadUrl = await (await task).ref.getDownloadURL();
        } else {
          // Web case
          final uploadTask = firebaseStorageRef.putData(selectedImageBytes!);
          downloadUrl = await (await uploadTask).ref.getDownloadURL();
        }

        // Update the image URL in the data
        updatedData["Image"] = downloadUrl;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
        return;
      }
    } else {
      // If no new image is selected, retain the old image URL
      updatedData["Image"] = widget.images;
    }

    try {
      // Update the document in Firestore
      await DatabaseMethods().updateRoomItem(widget.collectionName, widget.docID, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Room updated successfully.")));
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating room: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Room"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateRoom,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title"),
            TextField(controller: titleController),
            SizedBox(height: 10),
            Text("Description"),
            TextField(controller: descController),
            SizedBox(height: 10),
            Text("Address"),
            TextField(controller: addressController),
            SizedBox(height: 10),
            Text("Price"),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Text("Max Guests"),
            TextField(
              controller: maxGuestsController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Text("Status"),
            DropdownButton<String>(
              value: status,
              items: <String>['Available', 'Not Available'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  status = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            Text("Select New Image"),
            GestureDetector(
              onTap: getImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: selectedImageBytes == null && selectedImage == null
                    ? Icon(Icons.camera_alt_outlined)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? Image.memory(selectedImageBytes!, fit: BoxFit.cover) // For web
                            : Image.file(selectedImage!, fit: BoxFit.cover), // For mobile
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
