import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'MainPage.dart';  // Replace with the path to the file where the Restaurant class is defined.
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';
import 'dart:async'; // Import the async library for Timer
import 'package:http/http.dart' as http;

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  RestaurantDetailPage({required this.restaurant});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> with SingleTickerProviderStateMixin {
  final double _initialImageHeight = 300;
  double _imageHeight = 300; // Default image height
  Timer? _likeDebounce; // Timer for debouncing like requests
  Timer? _dislikeDebounce; // Timer for debouncing dislike requests
  bool likeButton = false;
  bool dislikeButton = false;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_animationController!);
  }
  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

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
      case 0:
        return 'Not available';
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
  Future<void> _launchMapsUrl(LatLng location) async {
    try {
      final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Failed to launch URL: $e');
    }
  }
  Future<void> _LikedRestaurant() async {
    if (_likeDebounce?.isActive ?? false) _likeDebounce!.cancel(); // Cancel previous timer if active
    _likeDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() { // This will trigger the UI to rebuild with the new state
        likeButton = !likeButton;
        if (likeButton) {
          _animationController?.forward();
        } else {
          _animationController?.reverse();
        }
        if (likeButton == true && dislikeButton == true){
          dislikeButton = false;
        }
      });
      // Replace this comment with your logic to handle a "like" action
      print("Liked restaurant");
    });
  }


  Future<void> _DislikedRestaurant() async {
    if (_dislikeDebounce?.isActive ?? false) _dislikeDebounce!.cancel(); // Cancel previous timer if active
    _dislikeDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() { // This will trigger the UI to rebuild with the new state
        dislikeButton = !dislikeButton;
        if (likeButton == true && dislikeButton == true){
          likeButton = false;
          _animationController?.reverse();
        }
      });

      // Replace this comment with your logic to handle a "dislike" action
      print("Disliked restaurant");
    });
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFA30000), // Updated property for button color
        foregroundColor: Colors.white, // Updated property for text color
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
                          style: const TextStyle(
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
                  const Text(
                    'Open Now', // Dynamic value placeholder
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.restaurant.cuisine,
                    style: const TextStyle(
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
                            () => _launchMapsUrl(widget.restaurant.location),
                      ),
                      _buildButton(
                        'Visit Website',
                        Icons.public,
                            () => launchUrlString(widget.restaurant.url),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      height: 40,// Reduced vertical padding
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4), // Smaller border radius for less rounded corners
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,// Use the minimum space needed by children
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation!,
                            child: IconButton(
                              icon: Icon(Icons.thumb_up_outlined, size: 18),
                              color: likeButton ? Color(0xFFA30000) : Theme.of(context).iconTheme.color,
                              onPressed: () => _LikedRestaurant(),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Container(
                            height: 30, // Height of the divider
                            width: 1,
                            color: Colors.black,
                          ),
                          IconButton(
                            icon: const Icon(Icons.thumb_down_outlined, size: 18), // Smaller icon size
                            onPressed: () => _DislikedRestaurant(),
                            color: dislikeButton ? Color(0xFFA30000) :Theme.of(context).iconTheme.color, // Use theme color when likeButton is false
                            padding: EdgeInsets.zero, // No padding inside the button
                            constraints: BoxConstraints(), // Apply constraints to reduce the button size
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}