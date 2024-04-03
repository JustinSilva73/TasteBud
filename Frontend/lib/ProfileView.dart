import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RestaurantItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<void>? loadDataFuture;
  String? storedEmail;
  String? username;
  List<Restaurant> recentRestaurants = [];
  List<Restaurant> likedRestaurants = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadDataFuture = _loadDataAndFetchRestaurants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDataAndFetchRestaurants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedEmail = prefs.getString('storedEmail');

    if (storedEmail != null) {
      username = await fetchUsername(storedEmail!);
      recentRestaurants = await fetchRecentRestaurants(storedEmail!);
      likedRestaurants = await fetchLikedRestaurants(storedEmail!);
    }
  }

  Future<List<Restaurant>> fetchRecentRestaurants(String email) async {
    final Uri recentRestaurantsUri = Uri.parse('http://10.0.2.2:3000/profile/recentVisited?email=$email');
    try {
      final response = await http.get(recentRestaurantsUri);
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        double? storedLatitude = prefs.getDouble('latitude');
        double? storedLongitude = prefs.getDouble('longitude');

        // Assuming you have a valid current position
        if (storedLatitude != null && storedLongitude != null) {
          Position currentPosition = Position(
              latitude: storedLatitude, longitude: storedLongitude, timestamp: DateTime.now(), altitude: 0, accuracy: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0, isMocked: false);

          // Handle both a List or a Map response from jsonDecode
          final jsonResponse = jsonDecode(response.body);
          List<dynamic> restaurantData;
          if (jsonResponse is List) {
            restaurantData = jsonResponse;
          } else if (jsonResponse is Map) {
            restaurantData = jsonResponse['keyHoldingRestaurantData'] ?? [];
          } else {
            print("Unexpected JSON structure");
            return [];
          }

          List<Restaurant> recentRestaurants = restaurantData.map((restaurant) {
            var rest = Restaurant.fromJson(restaurant as Map<String, dynamic>);
            // Calculate distance
            double distanceInMeters = Geolocator.distanceBetween(
              currentPosition.latitude,
              currentPosition.longitude,
              rest.location.latitude,
              rest.location.longitude,
            );
            double distanceInMiles = distanceInMeters / 1609.34; // Convert to miles
            rest.distance = double.parse(distanceInMiles.toStringAsFixed(1));
            return rest;
          }).toList();

          return recentRestaurants;
        } else {
          print("Current position is not available.");
          return []; // Handle this case as needed
        }
      } else {
        print("Failed to fetch recent restaurants from server");
        return [];
      }
    } catch (error) {
      print("Error fetching recent restaurants: $error");
      return [];
    }
  }


  Future<List<Restaurant>> fetchLikedRestaurants(String email) async {
    final Uri likedRestaurantsUri = Uri.parse('http://10.0.2.2:3000/profile/likedRestaurants?email=$email');
    try {
      final response = await http.get(likedRestaurantsUri);
      if (response.statusCode == 200) {
        // Handle both a List or a Map response from jsonDecode
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> restaurantData;
        if (jsonResponse is List) {
          // If the decoded response is already a List, use it directly
          restaurantData = jsonResponse;
        } else if (jsonResponse is Map) {
          // If it's a Map, extract the List if your JSON structure allows it
          // For example, if your JSON root object contains a key that holds the restaurant data
          restaurantData = jsonResponse['keyHoldingRestaurantData'];
        } else {
          print("Unexpected JSON structure");
          return [];
        }

        List<Restaurant> likedRestaurants = restaurantData.map((restaurant) {
          var rest = Restaurant.fromJson(restaurant as Map<String, dynamic>);
          // Calculate distance (rest of your logic)
          return rest;
        }).toList();

        return likedRestaurants;
      } else {
        print("Failed to fetch liked restaurants from server");
        return [];
      }
    } catch (error) {
      print("Error fetching liked restaurants: $error");
      return [];
    }
  }


  Future<String> fetchUsername(String email) async {
    final Uri url = Uri.parse('http://10.0.2.2:3000/profile/username?email=$email');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Assuming the backend sends a JSON object with the username.
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .toString(); // Or directly return jsonResponse if it's just a string
      } else {
        print("Failed to fetch username from server with status code: ${response
            .statusCode}");
        return 'Error: Could not fetch username';
      }
    } catch (e) {
      print("Exception when fetching username: $e");
      return 'Error: Exception occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future:
        loadDataFuture,
        builder: (context, snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFA30000),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading data')),
          );
        }
        return Scaffold(
          body: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                // This ensures the Container fills the screen width.
                color: const Color(0xFFA30000),
                // Hex color code for A30000
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  // Adjust the padding as needed
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 80.0, // Adjust the radius as needed
                        backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150'), // Replace with the actual image URL or asset
                      ),
                      const SizedBox(height: 10),
                      // Provides space between the avatar and the username
                      Text(
                        username ?? 'Loading...', // Provide a fallback string
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(icon: Image.asset(
                        'assets/VisitedRest.png', width: 50, height: 50)),
                    Tab(icon: Icon(Icons.thumb_up)),
                    Tab(icon: Icon(Icons.reviews)),
                  ],
                  indicatorColor: Colors.red,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Recent Restaurants Tab
                    _buildRestaurantList(recentRestaurants),
                    // Liked Restaurants Tab
                    _buildRestaurantList(likedRestaurants),
                    // Placeholder for the third tab
                    Center(child: Text('Future User Reviews Page')),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildRestaurantList(List<Restaurant> restaurants) {
    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (BuildContext context, int index) {
        return RestaurantItem(
          restaurant: restaurants[index],
          index: index,
          handleMarkerCallback: (LatLng location, String name) {
            // Implement your marker callback here, if necessary
          },
          allRestaurants: restaurants,
        );
      },
    );
  }
}