
import 'package:flutter/material.dart';
import 'RestaurantDetailPage.dart';
import 'Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// MainPage is a stateful widget, meaning its state can change dynamically.
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

// _MainPageState holds the mutable state for MainPage.
class _MainPageState extends State<MainPage> {
  String? storedEmail;
  Position? currentPosition;
  Key mapKey = Key('mapKey');
  late Future<Position?> positionFuture;

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

    // Rebuild the widget now that we have a position.

    return currentPosition; // Return the position here

  }



  List<Restaurant> restaurants = [
    Restaurant("Joe's ", '123 Main St', 'American'),
    Restaurant("Tasty Treats", '456 Elm St', 'Italian'),
    // ... Add more restaurants as needed
  ];


  // The build method describes the part of the UI represented by the widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(),
              ));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            child: FutureBuilder<Position?>(
              future: positionFuture, // use the cached future
              builder: (BuildContext context, AsyncSnapshot<Position?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                        zoom: 14.4746,
                      ),
                    );
                  } else {
                    return Center(child: Text("Location not available"));
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
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
  final String name;  // Restaurant's name.
  final String address;  // Restaurant's address.
  final String cuisine;  // URL to the restaurant's image.

  // Constructor to initialize the Restaurant object.
  Restaurant(this.name, this.address, this.cuisine);
}

// Stateless widget to represent a single restaurant item.
class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;

  // Constructor to initialize the RestaurantItem widget with a Restaurant object.
  RestaurantItem({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4.0),  // Outer spacing for the card.
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
