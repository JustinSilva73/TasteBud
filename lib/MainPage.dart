
import 'package:flutter/material.dart';
import 'RestaurantDetailPage.dart';
import 'Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// MainPage is a stateful widget, meaning its state can change dynamically.
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  _MainPageState createState() => _MainPageState();
}

// _MainPageState holds the mutable state for MainPage.
class _MainPageState extends State<MainPage> {
  String? storedEmail;
  Position? currentPosition;
  Key mapKey = const Key('mapKey');
  late Future<Position?> positionFuture;
  final Set<Circle> _circles = {};  // Initialize the set of circles here.
  Set<Marker> _restaurantMarkers = {};
  List<Restaurant> restaurants = [];
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  _initializeData() async {
    await _loadPositionFromStorage();
    positionFuture = _determinePosition();
    _loadStoredEmail();
    _loadStoredRestaurants();
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
      if(storedEmail != null) {
        List<Restaurant> priorityRestaurants = await fetchRestaurantPrio(restaurants, storedEmail!);
        if (priorityRestaurants.isNotEmpty) {
          setState(() {
            restaurants = priorityRestaurants;  // Update the restaurants list with priority restaurants from the server
          });
        }
      }

      _setRestaurantMarkers(restaurants);  // Set markers based on the potentially updated restaurants list.
    }
  }

  Future<List<Restaurant>?> fetchStoredRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('restaurants');

    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Restaurant> fetchedRestaurants = jsonList.map((json) => Restaurant.fromJson(json)).toList();
      return fetchedRestaurants;
    }
    return null;
  }
  Future<void> _loadPositionFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? storedLatitude = prefs.getDouble('latitude');
    double? storedLongitude = prefs.getDouble('longitude');

    if (storedLatitude != null && storedLongitude != null) {
      setState(() {
        currentPosition = Position(
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
  Future<List<Restaurant>> fetchRestaurantPrio(List<Restaurant> restaurants, String email) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/priority/restaurantPrio'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'restaurants': restaurants.map((r) => r.toJson()).toList(), // Convert list of Restaurant objects to list of JSON
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
        markerId: MarkerId(restaurant.name), // Change this if you have unique IDs
        position: restaurant.location,
        infoWindow: InfoWindow(title: restaurant.name, snippet: restaurant.address),
        // You can also add other properties like icon, etc.
      );

      tempMarkers.add(marker);
    }

    setState(() {
      _restaurantMarkers = tempMarkers;
      restaurants = fetchedRestaurants;  // Update the restaurants list
    });
    if (fetchedRestaurants.isNotEmpty) {
      LatLngBounds bounds = _boundsOfRestaurants(fetchedRestaurants);
      _updateCameraBounds(bounds);
    }
  }


  Future<Position?> _determinePosition() async {

    // Add a circle overlay for the current position
    if (currentPosition != null) {
      _circles.add(
        Circle(
          circleId: const CircleId("currentLocationCircle"),
          center: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          radius: 400,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 2,
          strokeColor: Colors.blue,
        ),
      );
    }
    print("Current Position: $currentPosition");
    return currentPosition; // Return the position here
  }

  LatLngBounds _boundsOfRestaurants(List<Restaurant> restaurants) {
    double minLat = restaurants[0].location.latitude;
    double maxLat = restaurants[0].location.latitude;
    double minLng = restaurants[0].location.longitude;
    double maxLng = restaurants[0].location.longitude;

    for (var restaurant in restaurants) {
      if (restaurant.location.latitude < minLat) minLat = restaurant.location.latitude;
      if (restaurant.location.latitude > maxLat) maxLat = restaurant.location.latitude;
      if (restaurant.location.longitude < minLng) minLng = restaurant.location.longitude;
      if (restaurant.location.longitude > maxLng) maxLng = restaurant.location.longitude;
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
    CameraUpdate zoomIn = CameraUpdate.zoomIn();  // A CameraUpdate to zoom in
    mapController?.animateCamera(zoomIn);  // Apply the zoom in
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));  // Then apply the new bounds
  }


  // The build method describes the part of the UI represented by the widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(allRestaurants: restaurants),
              ));
            },
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,  // Setting a fixed height for the map.
            child: FutureBuilder<Position?>(
              future: positionFuture,  // This is the future that gets the user's location.
              builder: (BuildContext context, AsyncSnapshot<Position?> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                // Check if the Future is complete.
                if (snapshot.connectionState == ConnectionState.done) {

                  // If we have valid position data.
                  if (snapshot.hasData && snapshot.data != null) {
                    Position position = snapshot.data!;

                    return GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;  // Storing the map controller for future use.

                        // If there are any restaurants fetched before the map was created, we should set the bounds immediately.
                        if (restaurants.isNotEmpty) {
                          LatLngBounds bounds = _boundsOfRestaurants(restaurants);
                          _updateCameraBounds(bounds);
                        }
                      },
                      // Setting the initial position of the map to the user's current location.
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 10,  // Initial zoom level. Adjust this based on preference.
                      ),
                      markers: _restaurantMarkers,  // Display all the restaurant markers on the map.
                      circles: _circles,  // Display the circle around the user's current location.
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
                return RestaurantItem(restaurant: restaurants[index]);
              },
            ),
          ),
        ],
      ),
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
  final double rating;
  final int priceLevel;
  final String icon;
  final bool? openingHours;
  double? distance;
  double? totalPoints;

  Restaurant({
    required this.name,
    required this.address,
    required this.cuisine,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.priceLevel,
    required this.icon,
    this.openingHours,
    this.distance,
    this.totalPoints,
  });

  // Convert JSON to Restaurant object
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['business_name'],
      address: json['address'],
      cuisine: json['categories_of_cuisine'],
      location: LatLng(json['lat'], json['lng']),
      imageUrl: json['image_url'],
      rating: json['rating'].toDouble(),
      priceLevel: json['price_level'] ?? 0,
      icon: json['icon'],
      openingHours: json['opening_hours'] as bool?,
      distance: json['distance']?.toDouble(),
      totalPoints: null,
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
      'rating': rating,
      'price_level': priceLevel,
      'icon': icon,
      'opening_hours': openingHours,
      'distance': distance,
      'totalPoints': totalPoints,    };
  }
}


// Stateless widget to represent a single restaurant item.
class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;

  // Constructor to initialize the RestaurantItem widget with a Restaurant object.
  const RestaurantItem({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4.0),  // Outer spacing for the card.
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(restaurant.icon), // Assuming 'icon' is a URL to the restaurant's icon image.
        ),
        title: Text(restaurant.name),  // Display the restaurant's name.
        subtitle: Text('${restaurant.address} - ${restaurant.distance?.toStringAsFixed(1)} mi'),  // Display the restaurant's address and distance.
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RestaurantDetailPage(restaurant: restaurant),
            ),
          );
        },
      ),
    );
  }
}
