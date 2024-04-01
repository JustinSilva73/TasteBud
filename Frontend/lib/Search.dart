import 'package:flutter/material.dart';
import 'package:tastebud/SettingsView.dart';
import 'MainPage.dart';
import 'RestaurantDetailPage.dart';
import 'main.dart'; // Import the Startup page

class SearchPage extends StatefulWidget {
  final List<Restaurant> allRestaurants; // <-- Define the variable here

  // Modify the constructor to accept the named parameter
  const SearchPage({super.key, required this.allRestaurants});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = "";
  late List<Restaurant> _allRestaurants;
  int _currentIndex = 2; // Assuming "Search" is the third item

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
      MaterialPageRoute(builder: (context) => const MyApp()),
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
            color: const Color(0xFFA30000), // Red background color
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, // This is for the status bar height
              bottom: 20, // Space below the search bar
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
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
                ],
              ),
            ),
          ),
          Container(color: const Color(0xFFA30000)),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRestaurants.length,
              itemBuilder: (context, index) {
                var restaurant = filteredRestaurants[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantDetailPage(restaurant: restaurant, allRestaurants: filteredRestaurants, currentIndex: 2),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                          color: Colors.black, width: 1.0), // Add this line
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
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
                          title: Center(
                            // Center widget used here for horizontal centering
                            child: Text(
                              restaurant.name,
                              textAlign: TextAlign.center,
                              // Center the text horizontally
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          subtitle: Center(
                            // Center widget used here for horizontal centering
                            child: Text(
                              '${restaurant.cuisine} - ${restaurant.distance?.toStringAsFixed(1)} mi',
                              textAlign: TextAlign.center,
                              // Center the text horizontally
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Use the _currentIndex variable here
        onTap: (index) {
          // Update the state with the new index when an item is tapped
          setState(() {
            _currentIndex = index; // Update the current index
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsView(currentIndex: 1, allRestaurants: _allRestaurants),
                ),
              );
              break;
            case 2:
            // If the "Search" item is tapped again, you might not need to do anything
            // or refresh the search page, depending on your app's navigation logic
              break;
          }
        },
        selectedItemColor: const Color(0xFFA30000),
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