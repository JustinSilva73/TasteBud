
import 'package:flutter/material.dart';
import 'MainPage.dart';  // Replace with the path to the file where the Restaurant class is defined.

class RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantDetailPage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Text(
              restaurant.name,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              restaurant.address,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            // Add more details or widgets as needed
          ],
        ),
      ),
    );
  }
}
