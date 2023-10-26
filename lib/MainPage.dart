
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
    _loadStoredEmail();
    positionFuture = _determinePosition(); // cache the future
  }

  _loadStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedEmail = prefs.getString('storedEmail');
    });
  }


  Future<List<Restaurant>> fetchNearbyRestaurantsFromServer(LatLng location) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/googleAPI/restaurants?latitude=${location.latitude}&longitude=${location.longitude}'),
    );
    if (response.statusCode == 200) {
      // Parse the JSON based on your provided structure
      List<dynamic> jsonResponse = jsonDecode(response.body);
      print("Success pulling from server");

      return jsonResponse.map((restaurant) => Restaurant.fromJson(restaurant)).toList();
    } else {
      print("Failed to fetch restaurants from server");
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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled."); // Logging
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied."); // Logging
      return Future.error('Location permissions are permanently denied. We cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("Location permissions are denied: $permission"); // Logging
        return Future.error('Location permissions are denied (actual value: $permission).');
      }
    }

    // If permissions are granted, get the current position
    currentPosition = await Geolocator.getCurrentPosition();
    print("Current Position: $currentPosition");  // Logging

    // Fetch nearby restaurants and set markers
    final fetchedRestaurants = await fetchNearbyRestaurantsFromServer(LatLng(currentPosition!.latitude, currentPosition!.longitude));
    _setRestaurantMarkers(fetchedRestaurants);

    // Add a circle overlay for the current position
    _circles.add(
      Circle(
        circleId: const CircleId("currentLocationCircle"),
        center: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        radius: 400,  // Adjust the radius as needed.
        fillColor: Colors.blue.withOpacity(0.5),  // Color for the circle fill.
        strokeWidth: 2,  // Width of the circle border.
        strokeColor: Colors.blue,  // Color of the circle border.
      ),
    );

    return currentPosition; // Return the position here
  }
  LatLngBounds _boundsOfRestaurants(List<Restaurant> restaurants) {
    double minLat = restaurants[0].location.latitude;
    double maxLat = restaurants[0].location.latitude;
    double minLng = restaurants[0].location.longitude;
    double maxLng = restaurants[0].location.longitude;
    double padding = 0.01;  // You can adjust the padding as needed

    for (var restaurant in restaurants) {
      if (restaurant.location.latitude - padding < minLat) minLat = restaurant.location.latitude - padding;
      if (restaurant.location.latitude + padding > maxLat) maxLat = restaurant.location.latitude + padding;
      if (restaurant.location.longitude - padding < minLng) minLng = restaurant.location.longitude - padding;
      if (restaurant.location.longitude + padding > maxLng) maxLng = restaurant.location.longitude + padding;
    }

    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
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
                        zoom: 14.4746,  // Initial zoom level. Adjust this based on preference.
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
  final bool? openingHours; // This can be nullable if not always available

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
    );
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
        title: Text(restaurant.name),  // Display the restaurant's name.
        subtitle: Text(restaurant.address),  // Display the restaurant's address.
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
