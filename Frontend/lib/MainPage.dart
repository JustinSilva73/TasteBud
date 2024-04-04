import 'dart:math';

import 'package:flutter/material.dart';
import 'CreateAccount.dart';
import 'RestaurantDetailPage.dart';
import 'Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tastebud/TodayPop.dart';
import 'SettingsView.dart';
import 'ProfileView.dart';
// MainPage is a stateful widget, meaning its state can change dynamically.
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  _MainPageState createState() => _MainPageState();
}

// _MainPageState holds the mutable state for MainPage.
class _MainPageState extends State<MainPage> {
  String? storedEmail;
  Position? _currentPosition;
  Key mapKey = const Key('mapKey');
  late Future<Position?> positionFuture;
  final Set<Circle> _circles = {}; // Initialize the set of circles here.
  Set<Marker> _restaurantMarkers = {};
  List<Restaurant> restaurants = [];
  GoogleMapController? mapController;
  final double maxDistance = 14000; // 5 kilometers in meters
  Set<Polyline> _polylines = {}; // Add this line to define _polylines
  bool profilePictureAvailable = false;
  @override
  void initState() {
    super.initState();
    _initializePositionFuture();
    _initializeData();
  }

  void _initializeData() async {
    await _loadPositionFromStorage();
    _initializePositionFuture();
    _loadStoredEmail();
    _loadStoredRestaurants();

    // Correctly await the asynchronous call to getPopup()
    bool popUpsEnabled = await getPopup();
    if (popUpsEnabled && await _checkTodayPop()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('todayPopShown', true);
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _showTodayPop(context));
      print("TodayPopUpShow");
    }
    print("TodayPopUpNotShown");
  }

  Future<bool> _checkTodayPop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownTodayPop = prefs.getBool('todayPopShown') ?? false;
    return !hasShownTodayPop;
  }

  void _showTodayPop(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return TodayPop(
            onCuisineSelected: (List<String> selectedCuisines) {
              // Assuming restaurants is your full list of restaurants.

              // Print the list before adding points and sorting.
              print("Before adding points:");
              for (var restaurant in restaurants) {
                print('${restaurant.name}: ${restaurant.totalPoints}');
              }

              for (var restaurant in restaurants) {
                // Check if the restaurant's cuisine is in the selected cuisines list.
                if (selectedCuisines.contains(restaurant.cuisine)) {
                  // If so, add 50 to its total points. Initialize totalPoints if null.
                  restaurant.totalPoints = (restaurant.totalPoints ?? 0) + 50;
                }
              }

              // Print the list after adding points but before sorting.
              print("After adding points, before sorting:");
              for (var restaurant in restaurants) {
                print('${restaurant.name}: ${restaurant.totalPoints}');
              }

              // Now sort the restaurants by totalPoints in descending order.
              List<Restaurant> sortedRestaurants = List.from(restaurants)
                ..sort((a, b) =>
                    (b.totalPoints ?? 0).compareTo(a.totalPoints ?? 0));

              // Print the list after sorting.
              print("After sorting:");
              for (var sortedRestaurant in sortedRestaurants) {
                print('${sortedRestaurant.name}: ${sortedRestaurant
                    .totalPoints}');
              }

              setState(() {
                restaurants = sortedRestaurants;
              });
            }
        );
      },
    );
  }

  void _initializePositionFuture() {
    positionFuture = _determinePosition();
  }

  _loadStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedEmail = prefs.getString('storedEmail');
    });
  }

  _loadStoredRestaurants() async {
    List<Restaurant>? fetchedRestaurants = await fetchStoredRestaurants();
    if (fetchedRestaurants != null && fetchedRestaurants.isNotEmpty) {
      setState(() {
        restaurants = fetchedRestaurants;
      });

      // Run fetchRestaurantPrio right after setting the restaurants from local storage.
      if (storedEmail != null) {
        List<Restaurant> priorityRestaurants = await fetchRestaurantPrio(
            restaurants, storedEmail!);
        if (priorityRestaurants.isNotEmpty) {
          setState(() {
            restaurants =
                priorityRestaurants; // Update the restaurants list with priority restaurants from the server
          });
        }
      }

      //_setRestaurantMarkers(restaurants); // Set markers based on the potentially updated restaurants list.
    }
  }

  Future<List<Restaurant>?> fetchStoredRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('restaurants');
    List<dynamic> jsonList = jsonDecode(jsonString!);
    List<Restaurant> fetchedRestaurants = jsonList.map((json) =>
        Restaurant.fromJson(json)).toList();
    return fetchedRestaurants;

  }

  Future<void> _loadPositionFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? storedLatitude = prefs.getDouble('latitude');
    double? storedLongitude = prefs.getDouble('longitude');

    if (storedLatitude != null && storedLongitude != null) {
      setState(() {
        _currentPosition = Position(
            latitude: storedLatitude,
            longitude: storedLongitude,
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            timestamp: DateTime
                .now() // Providing the current time as a dummy value
        );
      });
    }
  }

  Future<List<Restaurant>> fetchRestaurantPrio(List<Restaurant> restaurants,
      String email) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/priority/restaurantPrio'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'restaurants': restaurants.map((r) => r.toJson()).toList(),
        // Convert list of Restaurant objects to list of JSON
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      print("Success pulling priority restaurants from server");

      // Convert JSON to a list of Restaurant objects
      List<Restaurant> fetchedRestaurants = jsonResponse
          .map((restaurant) => Restaurant.fromJson(restaurant))
          .toList();

      return fetchedRestaurants;
    } else {
      print("Failed to fetch priority restaurants from server");
      return [];
    }
  }

  void _setRestaurantMarkers(List<Restaurant> fetchedRestaurants) {
    Set<Marker> tempMarkers = {};

    for (var restaurant in fetchedRestaurants) {
      final marker = Marker(
        markerId: MarkerId(restaurant.name),
        // Change this if you have unique IDs
        position: restaurant.location,
        infoWindow: InfoWindow(
            title: restaurant.name, snippet: restaurant.address),
        // You can also add other properties like icon, etc.
      );

      tempMarkers.add(marker);
    }

    setState(() {
      _restaurantMarkers = tempMarkers;
      restaurants = fetchedRestaurants; // Update the restaurants list
    });
    if (fetchedRestaurants.isNotEmpty) {
      LatLngBounds bounds = _boundsOfRestaurants(
          fetchedRestaurants, _currentPosition!, maxDistance);
      _updateCameraBounds(bounds);
    }
  }


  Future<Position?> _determinePosition() async {
    if (_currentPosition != null) {
      _circles.add(
        Circle(
          circleId: const CircleId("currentLocationCircle"),
          center: LatLng(
              _currentPosition!.latitude, _currentPosition!.longitude),
          radius: 400,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 2,
          strokeColor: Colors.blue,
        ),
      );
    }
    print("Current Position: $_currentPosition");
    return _currentPosition;
  }


  LatLngBounds _boundsOfRestaurants(List<Restaurant> restaurants,
      Position currentPosition, double maxDistance) {
    // Filter restaurants based on distance from the current position
    var filteredRestaurants = restaurants.where((restaurant) {
      var distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        restaurant.location.latitude,
        restaurant.location.longitude,
      );
      return distance <= maxDistance; // maxDistance in meters
    }).toList();

    // If no restaurants are within the max distance, return some default bounds or handle this scenario appropriately
    if (filteredRestaurants.isEmpty) {
      return LatLngBounds(
        southwest: LatLng(currentPosition.latitude, currentPosition.longitude),
        northeast: LatLng(currentPosition.latitude, currentPosition.longitude),
      );
    }

    // Initialize with the first restaurant's location
    double minLat = filteredRestaurants[0].location.latitude;
    double maxLat = filteredRestaurants[0].location.latitude;
    double minLng = filteredRestaurants[0].location.longitude;
    double maxLng = filteredRestaurants[0].location.longitude;

    for (var restaurant in filteredRestaurants) {
      if (restaurant.location.latitude < minLat) {
        minLat = restaurant.location.latitude;
      }
      if (restaurant.location.latitude > maxLat) {
        maxLat = restaurant.location.latitude;
      }
      if (restaurant.location.longitude < minLng) {
        minLng = restaurant.location.longitude;
      }
      if (restaurant.location.longitude > maxLng) {
        maxLng = restaurant.location.longitude;
      }
    }

    // Calculate the range of latitudes and longitudes
    double latRange = maxLat - minLat;
    double lngRange = maxLng - minLng;

    // Define a padding percentage
    double paddingPercentage = 0.05; // 5% for example

    // Calculate the actual padding values based on the percentage
    double latPadding = latRange * paddingPercentage;
    double lngPadding = lngRange * paddingPercentage;

    return LatLngBounds(
        southwest: LatLng(minLat - latPadding, minLng - lngPadding),
        northeast: LatLng(maxLat + latPadding, maxLng + lngPadding)
    );
  }


  Future<void> _updateCameraBounds(LatLngBounds bounds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    CameraUpdate zoomIn = CameraUpdate.zoomIn(); // A CameraUpdate to zoom in
    mapController?.animateCamera(zoomIn); // Apply the zoom in
    mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
            bounds, 11.25)); // Then apply the new bounds
  }


  // The build method describes the part of the UI represented by the widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA30000),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        leading: SizedBox(
          width: 60, // Fixed width to ensure consistent alignment
          child: Center(
            child: CircleAvatar(
              radius: 13,
              child: _buildProfileIcon(context),
            ),
          ),
        ),
        title: SizedBox(
          width: 280,
          height: 56, // Fixed height to ensure consistent alignment
          child: Center(
            child: Image.asset(
              'assets/logo.png',
              height: 56, // Adjust the height as needed
            ),
          ),
        ),
        // This should be directly inside AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.black,
            height: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200, // Setting a fixed height for the map.
            child: FutureBuilder<Position?>(
              future: positionFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<Position?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data != null) {
                  // If we have valid position data.
                  if (snapshot.hasData && snapshot.data != null) {
                    Position position = snapshot.data!;

                    return GoogleMap(
                      polylines: _polylines,
                      onMapCreated: (GoogleMapController controller) {
                        mapController =
                            controller; // Storing the map controller for future use.
                        // If there are any restaurants fetched before the map was created, we should set the bounds immediately.
                        if (restaurants.isNotEmpty &&
                            _currentPosition != null) {
                          LatLngBounds bounds = _boundsOfRestaurants(
                              restaurants, _currentPosition!, maxDistance);
                          _updateCameraBounds(bounds);
                        }
                      },
                      // Setting the initial position of the map to the user's current location.
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 11.25, // Initial zoom level. Adjust this based on preference.
                      ),
                      markers: _restaurantMarkers,
                      // Display all the restaurant markers on the map.
                      circles: _circles, // Display the circle around the user's current location.
                    );
                  } else {
                    // If there's no position data available, show an error message.
                    return const Center(child: Text("Location not available"));
                  }
                } else {
                  // While the Future is still running, show a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          // List of restaurants
          Expanded(
            child: ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                return RestaurantItem(
                  restaurant: restaurants[index],
                  index: index, // Pass the index here
                  handleMarkerCallback: (LatLng location, String name) {
                    _handleMarkerCallback(location, name, index);
                  },
                  allRestaurants: restaurants,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        // Initialize with the index of the currently selected item
        onTap: (index) {
          setState(() {
            // Update the current index to highlight the selected item
            // Replace this logic with your actual navigation logic
          });
          switch (index) {
            case 0:
            // Navigate to the current page (MainPage)
              break;
            case 1:
            // Navigate to the SettingsPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SettingsView(
                          currentIndex: 1, allRestaurants: restaurants),
                ),
              );
              break;
            case 2:
            // Navigate to the SearchPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    SearchPage(allRestaurants: restaurants)),
              );
              break;
          }
        },
        selectedItemColor: const Color(0xFFA30000),
        // Set the color for the selected item
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
  Widget _buildProfileIcon(BuildContext context) {
    // Check if the profile picture is available
    if (profilePictureAvailable) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileView()),
          );
        },
        child: CircleAvatar(
          backgroundColor: const Color(0xFFA30000),
          backgroundImage: AssetImage('assets/profile_picture.jpg'), // Replace with the path to your profile picture
          radius: 18, // Adjust the radius as needed
        ),
      );
    } else {
      // Return a default user icon if profile picture is not available
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileView()),
          );
        },
        child: CircleAvatar(
          backgroundColor: const Color(0xFFA30000), // Background color
          child: Icon(
            Icons.account_circle, // Default user icon
            size: 28, // Adjust the size as needed
            color: Colors.white, // Icon color
          ),
          radius: 18, // Adjust the radius as needed
        ),
      );
    }
  }

  void _handleMarkerCallback(LatLng location, String restaurantName, int index) async {
    print("Marker callback initiated for restaurant: $restaurantName");

    // Calculate the bounds to include both the user's and the restaurant's markers
    LatLngBounds bounds = _calculateBounds(location);

    // Update camera bounds to include the new bounds
    _updateCameraBounds(bounds);
    // Immediately clear existing markers and add the new one
    setState(() {
      print("Clearing existing markers.");
      _restaurantMarkers.clear(); // Clear existing markers

      print("Adding new marker for restaurant.");
      _restaurantMarkers.add(
        Marker(
          markerId: MarkerId(restaurantName),
          position: location,
          infoWindow: InfoWindow(
            title: restaurantName,
            snippet: 'Click to view details',
          ),
        ),
      );
    });

    // After adding the marker, directly fetch and display the route
    print("Fetching route.");
    await _fetchAndDisplayRoute(location);

    // Adjust camera zoom if necessary
    print("Camera zoom adjusted.");
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 11.25));

    // Debug print to confirm the state update and polyline addition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("setState completed.");
      print("Current polyline count: ${_polylines.length}");
    });
  }
  LatLngBounds _calculateBounds(LatLng restaurantLocation) {
    // Get the current position of the user
    LatLng currentPosition = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // Create LatLngBounds containing both the user's and the restaurant's locations
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(currentPosition.latitude, restaurantLocation.latitude),
        min(currentPosition.longitude, restaurantLocation.longitude),
      ),
      northeast: LatLng(
        max(currentPosition.latitude, restaurantLocation.latitude),
        max(currentPosition.longitude, restaurantLocation.longitude),
      ),
    );

    return bounds;
  }
  Future<void> _fetchAndDisplayRoute(LatLng destinationLocation) async {
    // Construct the request URL for your backend endpoint
    final Uri backendUri = Uri.parse("http://10.0.2.2:3000/routing/directions")
        .replace(queryParameters: {
      "originLat": _currentPosition?.latitude.toString(),
      "originLng": _currentPosition?.longitude.toString(),
      "destinationLat": destinationLocation.latitude.toString(),
      "destinationLng": destinationLocation.longitude.toString(),
    });

    print("Constructed URI for route: $backendUri");
    try {
      final response = await http.get(backendUri);
      print("Response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Successfully fetched route from backend.");
        final data = jsonDecode(response.body);
        final List<dynamic> points = data['points'];

        // Directly assign newPolyline within setState to ensure it's always assigned before use
        setState(() {
          _polylines.clear(); // Clear existing polylines
          var newPolyline = Polyline(
            polylineId: PolylineId('route'),
            points: points.map((p) => LatLng(p['lat'], p['lng'])).toList(),
            color: Colors.blue,
            width: 5,
          );
          _polylines.add(newPolyline);
          print("Polylines updated with new route. Polyline ID: ${newPolyline.polylineId}, Points Count: ${newPolyline.points.length}");

          // Since newPolyline is now within setState, call focus method here
          _focusCameraOnPolyline(newPolyline);
        });
      } else {
        print('Failed to fetch route from backend: ${response.body}');
      }
    } catch (e) {
      print('Exception caught when fetching route: $e');
    }
  }

  void _focusCameraOnPolyline(Polyline polyline) {
    final LatLngBounds bounds = _latLngBoundsFromPolyline(polyline);
    print("Focusing camera on polyline with bounds: ${bounds.toString()}");
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50))
        .then((_) => print("Camera animation completed."))
        .catchError((e) => print("Failed to animate camera: $e"));
  }
  LatLngBounds _latLngBoundsFromPolyline(Polyline polyline) {
    double? southwestLat = 90.0, southwestLng = 180.0;
    double? northeastLat = -90.0, northeastLng = -180.0;

    for (LatLng point in polyline.points) {
      if (point.latitude < southwestLat!) southwestLat = point.latitude;
      if (point.latitude > northeastLat!) northeastLat = point.latitude;
      if (point.longitude < southwestLng!) southwestLng = point.longitude;
      if (point.longitude > northeastLng!) northeastLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(southwestLat!, southwestLng!),
      northeast: LatLng(northeastLat!, northeastLng!),
    );
  }

}

// A simple Dart class to represent a restaurant's data.
class Restaurant {
  final String name;
  final String address;
  final String cuisine;
  final LatLng location;
  final String imageUrl;
  final String url;
  final double rating;
  final int priceLevel;
  final String icon;
  final bool? openingHours;
  double? distance;
  double? totalPoints;
  String? yelpID;

  Restaurant({
    required this.name,
    required this.address,
    required this.cuisine,
    required this.location,
    required this.imageUrl,
    required this.url,
    required this.rating,
    required this.priceLevel,
    required this.icon,
    this.openingHours,
    this.distance,
    this.totalPoints,
    this.yelpID
  });

  // Convert JSON to Restaurant object
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['business_name'],
      address: json['address'],
      cuisine: json['categories_of_cuisine'],
      location: LatLng(json['lat'], json['lng']),
      imageUrl: json['image_url'],
      url: json['url'],
      rating: json['rating'].toDouble(),
      priceLevel: json['price_level'] ?? 0,
      icon: json['icon'],
      openingHours: json['opening_hours'] as bool?,
      distance: json['distance']?.toDouble(),
      totalPoints: json['totalPoints']?.toDouble() ?? 0,
      yelpID: json['yelpID'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'business_name': name,
      'address': address,
      'categories_of_cuisine': cuisine,
      'lat': location.latitude,
      'lng': location.longitude,
      'image_url': imageUrl,
      'url' : url,
      'rating': rating,
      'price_level': priceLevel,
      'icon': icon,
      'opening_hours': openingHours,
      'distance': distance,
      'totalPoints': totalPoints,
      'yelpID': yelpID
    };
  }
}
class HeaderWidget extends StatelessWidget {
  final double height;

  const HeaderWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: primaryColor, // Replace with your desired color or gradient
      child: Center(
        child: Image.asset('assets/logo.png'), // Replace with your logo asset path
      ),
    );
  }
}


class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;
  final int index;
  final Function(LatLng, String) handleMarkerCallback;
  final List<Restaurant> allRestaurants; // Add this

  const RestaurantItem({
    Key? key,
    required this.restaurant,
    required this.index,
    required this.handleMarkerCallback,
    required this.allRestaurants, // Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: const Color(0xFFA30000)),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                restaurant.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(restaurant.address),
        trailing: const Icon(Icons.keyboard_arrow_down, color:const Color(0xFFA30000)),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Image.network(
                      restaurant.imageUrl,
                      width: 80,
                      height: 80,
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_dining, color: const Color(0xFFA30000)),
                          const SizedBox(width: 4.0),
                          Text('Cuisine: ${restaurant.cuisine}',
                              style: const TextStyle(fontSize: 12.0)),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: const Color(0xFFA30000)),
                          const SizedBox(width: 4.0),
                          Text('Price: ${restaurant.priceLevel}',
                              style: const TextStyle(fontSize: 12.0)),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Icon(Icons.directions, color: const Color(0xFFA30000)),
                          const SizedBox(width: 4.0),
                          Text('Distance: ${restaurant.distance?.toString() ??
                              'Unknown'} miles', style: const TextStyle(
                              fontSize: 12.0)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailPage(
                                restaurant: restaurant,
                                allRestaurants: allRestaurants,
                                currentIndex: 0,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                            'More Info', style: TextStyle(fontSize: 12.0, color: Color(0xFFA30000))),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          handleMarkerCallback(
                              restaurant.location, restaurant.name);
                        },
                        child: const Text(
                            'Display on Map', style: TextStyle(fontSize: 10.0, color: Color(0xFFA30000))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
