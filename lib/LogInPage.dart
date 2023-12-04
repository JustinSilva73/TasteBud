
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tastebud/MainPage.dart';
import '/CreateAccount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? storedEmail;
  bool isLoading = true;  // Add this to your _LoginPageState class

  @override
  void initState() {
    super.initState();
    _loadStoredEmail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndStorePosition();
    });
    isLoading = false;
  }

  // Function to save email to local storage
  _saveEmailToStorage(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('storedEmail', email);
  }

  // Function to load email from local storage and set it to _emailController
  _loadStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedEmail = prefs.getString('storedEmail');
    });
  }
  Future<void> _storeRestaurantsLocally(List<Restaurant> restaurants) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = restaurants.map((restaurant) => restaurant.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    await prefs.setString('restaurants', jsonString);
  }



  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position? currentPosition;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled."); // Logging
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied."); // Logging
      return Future.error(
          'Location permissions are permanently denied. We cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("Location permissions are denied: $permission"); // Logging
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    // If permissions are granted, get the current position
    currentPosition = await Geolocator.getCurrentPosition();
    print("Current Position: $currentPosition");
    return currentPosition;
  }

  Future<void> _savePositionToStorage(Position position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', position.latitude);
    await prefs.setDouble('longitude', position.longitude);
  }

  bool isValidEmail(String email) {
    final pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }
  bool isValidPassword(String password) {
    final pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    final regExp = RegExp(pattern);

    return regExp.hasMatch(password);
  }

  void _fetchAndStorePosition() async {
    try {
      Position? position = await determinePosition();
      if (position != null) {
        await _savePositionToStorage(position);
        print('Stored position: ${position.latitude}, ${position.longitude}');

        // Fetching restaurants after the position is stored
        LatLng currentLocation = LatLng(position.latitude, position.longitude);
        List<Restaurant> fetchedRestaurants = await fetchNearbyRestaurantsFromServer(currentLocation);
        if (fetchedRestaurants.isNotEmpty) {
          // Store fetched restaurants locally
          await _storeRestaurantsLocally(fetchedRestaurants);
        }
      }
    } catch (e) {
      print('Error obtaining location or fetching restaurants: $e');
    }
  }

  Future<List<Restaurant>> fetchNearbyRestaurantsFromServer(LatLng location) async {
    // Log just before making the HTTP request to ensure URL and parameters are correct.
    print('Fetching restaurants from: http://10.0.2.2:3000/googleAPI/restaurants?latitude=${location.latitude}&longitude=${location.longitude}');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/googleAPI/restaurants?latitude=${location.latitude}&longitude=${location.longitude}'),
    );

    // Log the raw server response for debugging unexpected data structures or values.
    print("Raw server response: ${response.body}");

    if (response.statusCode == 200) {
      print("Success pulling from server");

      // Parse the JSON based on your provided structure
      List<dynamic> jsonResponse = jsonDecode(response.body);

      // Convert JSON to a list of Restaurant objects
      List<Restaurant> fetchedRestaurants = jsonResponse
          .map((restaurant) => Restaurant.fromJson(restaurant))
          .toList();

      // Log after converting the raw JSON data to a list of `Restaurant` objects.
      print("Mapped ${fetchedRestaurants.length} restaurants from server response.");

      // Log and calculate the distance for each restaurant
      for (Restaurant restaurant in fetchedRestaurants) {
        // Log the imageUrl of the restaurant
        print("Restaurant imageUrl: ${restaurant.imageUrl}");

        double distanceInMeters = Geolocator.distanceBetween(
          location.latitude, location.longitude,
          restaurant.location.latitude, restaurant.location.longitude,
        );
        double distanceInMiles = distanceInMeters / 1609.34;  // Convert to miles
        restaurant.distance = double.parse(distanceInMiles.toStringAsFixed(1));
      }

      return fetchedRestaurants;
    } else {
      // Log if the server responds with a status code other than 200.
      print("Server responded with status code: ${response.statusCode}. Response: ${response.body}");

      print("Failed to fetch restaurants from server");
      return []; 
    }
  }

  Future<bool> _attemptLogin(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData != null && responseData['success'] == true) {
        if (responseData.containsKey('email')) {
          String email = responseData['email'];
          print("THE EMAIL IS ${email}");
          await _saveEmailToStorage(email);
          return true;
        } else {
          // Email not present in response
          print('Email not provided in the response');
          return false;
        }
      } else {
        // Login success flag is not true
        return false;
      }
    } else {
      // Server returned an error status
      return false;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/logo.png', height: 200), // Logo size increased to 200 pixels in height
            SizedBox(height: 40),

            // Username Input
            TextField(
              controller: _usernameController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Password Input
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                String username = _usernameController.text;
                String password = _passwordController.text;

                if (!isValidPassword(password)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid username or password format')),
                  );
                  return;
                }

                bool loginSuccess = await _attemptLogin(username, password);

                if (loginSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect login credentials')),
                  );
                }
              },
              child: Text("Log In"),
            ),

            SizedBox(height: 20),

            // Create Account Button
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CreateAccountPage()), // Assumes you have a CreateAccountPage widget
                );
              },
              child: Text("Create an Account"),
            ),
          ],
        ),
      ),
    );
  }
}