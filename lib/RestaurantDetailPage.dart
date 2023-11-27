import 'package:flutter/material.dart';
import 'MainPage.dart';  // Replace with the path to the file where the Restaurant class is defined.

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  RestaurantDetailPage({required this.restaurant});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final double _initialImageHeight = 300;
  double _imageHeight = 300; // Default image height

  void _handleVerticalUpdate(DragUpdateDetails details) {
    setState(() {
      // Decrease the height when dragging down, increase when dragging up.
      _imageHeight += details.primaryDelta ?? 0;

      // Clamp the height to a minimum and maximum value.
      _imageHeight = _imageHeight.clamp(100.0, MediaQuery.of(context).size.height);
    });
  }



  void _handleVerticalEnd(DragEndDetails details) {
    setState(() {
      _imageHeight = _initialImageHeight; // Reset to default height
    });
  }

  String priceLevelToString(int priceLevel) {
    switch (priceLevel) {
      case 1:
        return '\$';
      case 2:
        return '\$\$';
      case 3:
        return '\$\$\$';
      case 4:
        return '\$\$\$\$';
      default:
        throw ArgumentError('Invalid price level: $priceLevel');
    }
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // Button color
        onPrimary: Colors.white, // Text color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onVerticalDragUpdate: _handleVerticalUpdate,
              onVerticalDragEnd: _handleVerticalEnd,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    height: _imageHeight,
                    child: Image.network(
                      widget.restaurant.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 40, // Adjust the position as needed
                    left: 2,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement navigation logic
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100, // Height of the gradient
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8), // Opaque black
                            Colors.transparent, // Fully transparent
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, // Position from bottom
                    left: 16, // Position from left
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.name,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.restaurant.address,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open Now', // Dynamic value placeholder
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    widget.restaurant.cuisine,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    priceLevelToString(widget.restaurant.priceLevel),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '${widget.restaurant.distance?.toString() ?? 'Unknown'} miles away',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        'Directions',
                        Icons.directions,
                            () {
                          // TODO: Implement your logic for directions
                        },
                      ),
                      _buildButton(
                        'Visit Website',
                        Icons.public,
                            () {
                          // TODO: Implement your logic for visiting the website
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}