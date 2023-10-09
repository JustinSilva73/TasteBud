// Required Flutter import.
import 'package:flutter/material.dart';
import 'RestaurantDetailPage.dart';
import 'Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

// MainPage is a stateful widget, meaning its state can change dynamically.
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

// _MainPageState holds the mutable state for MainPage.
class _MainPageState extends State<MainPage> {
  String? storedEmail;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _loadStoredEmail();
    _determinePosition();

  }

  _loadStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedEmail = prefs.getString('storedEmail');
    });
  }
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle location services being not enabled here
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // Handle this case: Permissions are denied forever
      return Future.error('Location permissions are permanently denied. We cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle permissions being denied
        return Future.error('Location permissions are denied (actual value: $permission).');
      }
    }

    // If permissions are granted, get the current position
    currentPosition = await Geolocator.getCurrentPosition();
    print(currentPosition);  // You can print or use the current position now
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
      body: ListView.builder(
        itemCount: restaurants.length,  // The number of items in the list.
        // Function that returns the widget for a specific item in the list.
        itemBuilder: (context, index) {
          return RestaurantItem(restaurant: restaurants[index]);
        },
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
