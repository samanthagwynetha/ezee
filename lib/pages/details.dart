import 'package:flutter/material.dart';
import 'package:homehunt/pages/booking.dart';
import 'package:homehunt/widget/support_widget.dart';

class Details extends StatefulWidget {
  String title, description, address, price, maxguests, images, status;
  Details({
    required this.title,
    required this.description,
    required this.address,
    required this.price,
    required this.maxguests,
    required this.images,
    required this.status,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
            ),
            Image.network(
              widget.images,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 15.0),
            Text(widget.title, style: Appwidget.semiboldtextfieldstyle()),
            SizedBox(height: 20.0),
            Text(widget.description, style: Appwidget.semiboldtextfieldstyle()),
            SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.black),
                    SizedBox(width: 8),
                    Text(widget.address, style: Appwidget.semiboldtextfieldstyle()),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.group, color: Colors.black),
                    SizedBox(width: 4),
                    Text(widget.maxguests, style: Appwidget.semiboldtextfieldstyle()),
                  ],
                ),
                SizedBox(height: 150.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Price", style: Appwidget.semiboldtextfieldstyle()),
                          Text("\₱ ${widget.price}", style: Appwidget.HeadlineTextfieldstyle()),
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to BookingPage when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingPage(price: double.tryParse(widget.price) ?? 0.0), // Convert price to double
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Book a room", style: TextStyle(color: Colors.white)),
                              SizedBox(width: 30.0),
                              Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.book),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
