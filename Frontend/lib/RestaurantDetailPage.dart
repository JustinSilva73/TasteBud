import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'MainPage.dart';  // Replace with the path to the file where the Restaurant class is defined.
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:core';
import 'dart:io';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

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

  Future<void> _launchWebsiteUrl(String urlString) async {
    String chromeSchemeUrl = urlString.replaceFirst('http://', 'googlechrome://').replaceFirst('https://', 'googlechrome://');
    String browserFallbackUrl = urlString;  // Regular HTTP/HTTPS URL for fallback

    try {
      // Try launching the URL with the custom scheme first (for Google Chrome on Android)
      if (Platform.isAndroid && await canLaunchUrlString(chromeSchemeUrl)) {
        await launchUrlString(chromeSchemeUrl);
      }
      // Fallback to the regular HTTP/HTTPS URL if custom scheme fails or on non-Android platforms
      else if (await canLaunchUrlString(browserFallbackUrl)) {
        await launchUrlString(browserFallbackUrl);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      print('Failed to launch URL: $e');
    }
  }




  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA30000), // Updated property for button color
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
                    duration: const Duration(milliseconds: 300),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  const SizedBox(height: 8.0),
                  Text(
                    priceLevelToString(widget.restaurant.priceLevel),
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${widget.restaurant.distance?.toString() ?? 'Unknown'} miles away',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
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
                      _buildButton(
                        'Share',
                        Icons.share,
                            () => Share.share(widget.restaurant.url, subject: 'Check out this restaurant!'),
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