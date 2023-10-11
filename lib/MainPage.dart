
import 'package:flutter/material.dart';
import 'RestaurantDetailPage.dart';
import 'Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

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

  final places = GoogleMapsPlaces(apiKey: 'AIzaSyBU_QERfJ4gRBq7o0dTNel-bbNUu9uyirc');

  Future<List<PlacesSearchResult>> fetchNearbyRestaurants(LatLng location) async {
    final response = await places.searchNearbyWithRadius(
      Location(lat: location.latitude, lng: location.longitude),
      24140,  // 15 miles in meters
      type: 'restaurant',
    );

    if (response.status == "OK") {
      return response.results;
    } else {
      print("Failed to fetch places: ${response.errorMessage}");
      return [];
    }
  }

  void _setRestaurantMarkers(List<PlacesSearchResult> fetchedRestaurants) {
    Set<Marker> tempMarkers = {};
    List<Restaurant> tempRestaurants = [];

    for (var restaurant in fetchedRestaurants) {
      final marker = Marker(
        markerId: MarkerId(restaurant.placeId),
        position: LatLng(restaurant.geometry!.location.lat, restaurant.geometry!.location.lng),
        infoWindow: InfoWindow(title: restaurant.name, snippet: restaurant.vicinity),
      );

      tempMarkers.add(marker);
      tempRestaurants.add(
        Restaurant(
          restaurant.name,
          restaurant.vicinity!,
          "Cuisine type not provided by API",  // Modify as per API data, if available.
          LatLng(restaurant.geometry!.location.lat, restaurant.geometry!.location.lng),
        ),
      );
    }

    setState(() {
      _restaurantMarkers = tempMarkers;
      restaurants = tempRestaurants;
    });
    if (restaurants.isNotEmpty) {
      LatLngBounds bounds = _boundsOfRestaurants(restaurants);
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
    final fetchedRestaurants = await fetchNearbyRestaurants(LatLng(currentPosition!.latitude, currentPosition!.longitude));
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

    for (var restaurant in restaurants) {
      if (restaurant.location.latitude < minLat) minLat = restaurant.location.latitude;
      if (restaurant.location.latitude > maxLat) maxLat = restaurant.location.latitude;
      if (restaurant.location.longitude < minLng) minLng = restaurant.location.longitude;
      if (restaurant.location.longitude > maxLng) maxLng = restaurant.location.longitude;
    }

    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  Future<void> _updateCameraBounds(LatLngBounds bounds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
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

  Restaurant(this.name, this.address, this.cuisine, this.location);
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
