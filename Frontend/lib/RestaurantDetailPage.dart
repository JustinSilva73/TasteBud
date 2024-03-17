import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tastebud/SettingsView.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'MainPage.dart';  // Replace with the path to the file where the Restaurant class is defined.
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:core';
import 'dart:async'; // Import the async library for Timer
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Search.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  final List<Restaurant> allRestaurants; // Add this line
  final int currentIndex; // Add this line

  const RestaurantDetailPage({
    Key? key,
    required this.restaurant,
    required this.allRestaurants,
    required this.currentIndex, // Modify the constructor
  }) : super(key: key);

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

    // Call _checkLikeStatus and handle its result to update UI
    _checkLikeStatus().then((likedStatus) {
      if (likedStatus == 1) {
        setState(() {
          likeButton = true;
          dislikeButton = false;
          // Optionally, trigger an animation if liked
          _animationController?.forward();
        });
      } else if (likedStatus == -1) {
        setState(() {
          likeButton = false;
          dislikeButton = true;
        });
      } // No need for an else block; if likedStatus is null or 2, we do nothing.
    }).catchError((error) {
      // Handle any errors here
      print('Error in _checkLikeStatus: $error');
    });
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

  _loadStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('storedEmail');
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
  Future<int?> _checkLikeStatus() async {
    print('Starting to check like status...');

    // Attempt to load stored email
    final String? email = await _loadStoredEmail(); // Ensure nullability matches the method signature
    if (email == null) {
      print('No email found in shared preferences.');
      return null; // Indicate inability to determine like status
    }
    print('Email loaded: $email');

    // Construct the request URI
    final yelpID = widget.restaurant.yelpID; // Yelp ID of the current restaurant
    final uri = Uri.parse('http://10.0.2.2:3000/restaurant/status?yelpID=$yelpID&email=$email');
    print('Request URI: $uri');

    try {
      // Make the HTTP GET request
      final response = await http.get(uri);
      print('HTTP GET request made.');

      // Check the response status code
      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final result = json.decode(response.body);
        return result['liked'] as int?; // Directly return the like status
      } else {
        print('Failed to fetch like status with status code: ${response.statusCode}');
        return null; // Indicate failure to determine like status
      }
    } catch (e) {
      print('Error fetching like status: $e');
      return null; // Indicate failure due to an exception
    }
  }



  Future<void> setLikeOrDislike() async {
    String email = await _loadStoredEmail(); // Replace this with the actual user ID from your user model or state
    final restaurantName = widget.restaurant.name;
    final yelpID = widget.restaurant.yelpID; // Ensure your Restaurant model includes a Yelp ID field
    print('yelpID:  $yelpID');
    // Determine the like status
    int likeStatus = 0; // Default to 0 (neither liked nor disliked)
    if (likeButton == true) {
      likeStatus = 1; // Liked
    } else if (dislikeButton == true) {
      likeStatus = -1; // Disliked
    }

    // Construct and send the HTTP request with the like status
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/restaurant/like'), // Adjust the URL as needed
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'restaurant_name': restaurantName,
          'yelp_id': yelpID,
          'liked': likeStatus,
        }),
      );

      if (response.statusCode == 200) {
        print("Successfully updated like/dislike status");
        // Handle successful response
      } else {
        print("Failed to update like/dislike status: ${response.body}");
        // Handle error response
      }
    } catch (e) {
      print("Failed to connect to the server: $e");
      // Handle exception
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
      setLikeOrDislike();
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
      setLikeOrDislike();
      print("Disliked restaurant");
    });
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
      body: FutureBuilder<int?>(
          future: _checkLikeStatus(),
          builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
            // Waiting for the future to complete
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFA30000), // Change this color to whatever you want
                ),
              );
            }
            // Future complete - data is available
            bool likeButton = snapshot.data == 1;
            bool dislikeButton = snapshot.data == -1;
            return SingleChildScrollView(
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
                                  () => _launchWebsiteUrl(widget.restaurant.url),
                            ),
                          ],
                        ),
                        Center(
                          // Use Center to align the 'Share' button if desired
                          child: _buildButton(
                            'Share',
                            Icons.share,
                                () => Share.share(
                              widget.restaurant.url,
                              subject: 'Check out this restaurant!',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            height: 40, // Reduced vertical padding
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(4), // Smaller border radius for less rounded corners
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center, // Use the minimum space needed by children
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
                                  icon: const Icon(Icons.thumb_down_outlined, size: 18),
                                  color: dislikeButton ? Color(0xFFA30000) : Theme.of(context).iconTheme.color,
                                  onPressed: () => _DislikedRestaurant(),
                                  padding: EdgeInsets.zero, // No padding inside the button
                                  constraints: BoxConstraints(), // Apply constraints to reduce the button size
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
            );
          },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
            // Navigate to the Main Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
              break;
            case 1:
            // Navigate to the Settings Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsView(currentIndex: 1, allRestaurants: widget.allRestaurants),
                ),
              );
              break;
            case 2:
            // Navigate to the Search Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage(allRestaurants: widget.allRestaurants)),
              );
              break;
          }
        },
        selectedItemColor: Color(0xFFA30000),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}