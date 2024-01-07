import 'package:flutter/material.dart';
import 'MainPage.dart';
import 'RestaurantDetailPage.dart';
import 'Startup.dart'; // Import the Startup page

class SearchPage extends StatefulWidget {
  final List<Restaurant> allRestaurants; // <-- Define the variable here

  // Modify the constructor to accept the named parameter
  SearchPage({required this.allRestaurants});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = "";
  late List<Restaurant> _allRestaurants;

  @override
  void initState() {
    super.initState();
    _allRestaurants = widget.allRestaurants; // Use the variable from the widget
  }
  void _updateSearchText(String text) {
    setState(() {
      _searchText = text;
    });
  }
  void _signOutAndRestartApp() {
    // Navigate to the Startup page and remove all routes beneath
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = _allRestaurants.where((restaurant) {
      return restaurant.name.toLowerCase().contains(
          _searchText.toLowerCase()) ||
          restaurant.cuisine.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // This Container will cover the entire top area behind the search bar.
          Container(
            color: Color(0xFFA30000), // Red background color
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, // This is for the status bar height
              bottom: 20, // Space below the search bar
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: _updateSearchText,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search, color: Colors.grey[800]),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Color(0xFFA30000)),
                    onPressed: _signOutAndRestartApp,
                    tooltip: 'Sign Out',
                  ),
                ],
              ),
            ),
          ),
          Container(color: Color(0xFFA30000)),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRestaurants.length,
              itemBuilder: (context, index) {
                var restaurant = filteredRestaurants[index];
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailPage(restaurant: restaurant),
                        ),
                      );
                    },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.black, width: 1.0), // Add this line
                  ),

                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: Image.network(
                          restaurant.imageUrl,
                          fit: BoxFit.cover,
                          height: 200.0,
                          width: double.infinity,
                        ),
                      ),
                      ListTile(
                        title: Center( // Center widget used here for horizontal centering
                          child: Text(
                            restaurant.name,
                            textAlign: TextAlign.center, // Center the text horizontally
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        subtitle: Center( // Center widget used here for horizontal centering
                          child: Text(
                            '${restaurant.cuisine} - ${restaurant.distance?.toStringAsFixed(1)} mi',
                            textAlign: TextAlign.center, // Center the text horizontally
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}