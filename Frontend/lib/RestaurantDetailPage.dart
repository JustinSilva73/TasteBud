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
import 'MenuItem.dart';

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
  Future<int?>? _likeStatusFuture;
  List<MenuItem> _menuItems = [];
  bool _isLoadingMenuItems = true;
  String defaultImageUrl = 'https://s3-media0.fl.yelpcdn.com/assets/2/www/img/dca54f97fb84/default_avatars/menu_medium_square.png';

  @override
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(_animationController!);
    _likeStatusFuture = _checkLikeStatus();
    _setInitialLikeStatus();
    fetchMenuItems(widget.restaurant.yelpID).then((menuItems) {
      setState(() {
        _menuItems = menuItems;
        _isLoadingMenuItems = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoadingMenuItems = false;
      });
      // Handle errors, such as by displaying an error message
    });
  }

  Future<void> _setInitialLikeStatus() async {
    final int? likeStatus = await _likeStatusFuture;
    setState(() {
      if (likeStatus == 1) {
        likeButton = true;
        dislikeButton = false;
      } else if (likeStatus == -1) {
        likeButton = false;
        dislikeButton = true;
      } else {
        likeButton = false;
        dislikeButton = false;
      }
    });
  }


  @override
  void dispose() {
    _likeDebounce?.cancel();
    _dislikeDebounce?.cancel();
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
        if (likeButton && dislikeButton){
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

  Future<List<MenuItem>> fetchMenuItems(String? yelpID) async {
    final uri = Uri.parse('http://10.0.2.2:3000/menu/getMenu?yelpID=$yelpID');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> menuItemsJson = jsonDecode(response.body);
      return menuItemsJson.map((json) => MenuItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          primary: Color(0xFFA30000), // Button background color
          onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Button with rounded corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0), // Padding around the text
        textStyle: TextStyle(
          fontSize: 16.0, // Text size
          fontWeight: FontWeight.bold, // Bold text
        ),
        elevation: 4.0, // Shadow under the button
      ),
    );
  }
  Widget _menuItemCard(MenuItem menuItem, bool isLastItem) {
    String priceText = (menuItem.price == 'Price not listed' || menuItem.price.isEmpty)
        ? 'PNL'
        : menuItem.price;

    String imageUrl = (menuItem.imageURL == 'No image available' || menuItem.imageURL.isEmpty)
        ? defaultImageUrl
        : menuItem.imageURL;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10), // Spacing between image and text
              // Name and Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name
                        Expanded(
                          child: Text(
                            menuItem.itemName,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // Prevents long names from breaking the layout
                          ),
                        ),
                        // Price
                        Text(
                          priceText,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    // Description
                    Text(
                      menuItem.itemDescription.isNotEmpty ? menuItem.itemDescription : 'No description available',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLastItem)
          Divider(
            color: Colors.grey,
            height: 1,
            thickness: 0.5,
            indent: 8.0,
            endIndent: 8.0,
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    List<String> foodImageUrls = _menuItems
        .where((item) =>
    item.imageURL != 'No image available' &&
        item.imageURL.isNotEmpty &&
        item.imageURL != defaultImageUrl &&
        item.imageURL != 'No menu items found') // Add this line
        .map((item) => item.imageURL)
        .toList();


    String mainImageUrl = widget.restaurant.imageUrl;
    List<String> allImageUrls = [mainImageUrl, ...foodImageUrls];

    return Scaffold(
        body: FutureBuilder<int?>(
          future: _likeStatusFuture, // Use the future that was created in initState
          builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Optionally, return a loading spinner if the future is still loading
          return Center(child: CircularProgressIndicator(color: Color(0xFFA30000)));
        } else if (snapshot.hasError) {
          // Handle the error state
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          bool likeButton = snapshot.data == 1;
          bool dislikeButton = snapshot.data == -1;
        }
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
                        height: _imageHeight,
                        child: allImageUrls.isNotEmpty
                            ? PageView.builder(
                          itemCount: allImageUrls.length,
                          itemBuilder: (context, index) {
                            // Use each image URL to build a PageView
                            return Image.network(
                              allImageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        )
                            : const Center(child: CircularProgressIndicator(color: Color(0xFFA30000))), // Show a loading indicator if images are not loaded yet
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
                    ],
                  ),
                ),
                Container(
                  color: Colors.white, // Background color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Open Now ',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '· ${widget.restaurant.cuisine} · ${priceLevelToString(widget.restaurant.priceLevel)} · ${widget.restaurant.distance?.toString() ?? 'Unknown'} miles away',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildButton('Share', Icons.share, () {
                            Share.share('Check out this restaurant: ${widget.restaurant.url}');
                          }),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              height: 40, // Reduced vertical padding
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center, // Use the minimum space needed by children
                                children: [
                                  IconButton(
                                    icon: ScaleTransition(
                                      scale: _scaleAnimation!,
                                      child: Icon(
                                        likeButton ? Icons.thumb_up : Icons.thumb_up_outlined,
                                        size: 18,
                                        color: likeButton ? Color(0xFFA30000) : Theme.of(context).iconTheme.color,
                                      ),
                                    ),
                                    onPressed: _LikedRestaurant,
                                    padding: EdgeInsets.zero,
                                  ),
                                  Container(
                                    height: 30, // Height of the divider
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      dislikeButton ? Icons.thumb_down : Icons.thumb_down_outlined,
                                      size: 18,
                                      color: dislikeButton ? Color(0xFFA30000) : Theme.of(context).iconTheme.color,
                                    ),
                                    onPressed: _DislikedRestaurant,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(), // Apply constraints to reduce the button size
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildButton('Website', Icons.public, () {
                            _launchWebsiteUrl(widget.restaurant.url);
                          }),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust vertical padding as needed
                        child: Divider(
                          color: Colors.grey[400], // Color of the divider
                          thickness: 1, // Thickness of the line
                          indent: 5, // Starting space of the line
                          endIndent: 5, // Ending space of the line
                        ),
                      ),

                      Container(
                        height: 200, // Set height for the map
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(widget.restaurant.location.latitude, widget.restaurant.location.longitude),
                            zoom: 14.0,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(widget.restaurant.name),
                              position: LatLng(widget.restaurant.location.latitude, widget.restaurant.location.longitude),
                            ),
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0), // Adjust vertical padding as needed
                              child: Text(
                                widget.restaurant.address,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.directions),
                            onPressed: () => _launchMapsUrl(widget.restaurant.location),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                        indent: 5, // Reduced starting space
                        endIndent: 5, // Reduced ending space
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _isLoadingMenuItems
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA30000)))
                          : _menuItems.length <= 1
                          ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(
                          'No menu provided. Check the website for more details.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.zero, // Add this line to remove default padding
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(), // to disable ListView's scrolling
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          return _menuItemCard(_menuItems[index], index == _menuItems.length - 1);
                        },
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
            // Pop the current route first if you want to close the current page.
            // Navigator.pop(context);

            switch (index) {
              case 0:
              // Replace the current page with the Main Page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
                break;
              case 1:
              // Replace the current page with the Settings Page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsView(currentIndex: 1, allRestaurants: widget.allRestaurants),
                  ),
                );
                break;
              case 2:
              // Replace the current page with the Search Page
                Navigator.pushReplacement(
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