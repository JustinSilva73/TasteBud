import 'package:flutter/material.dart';
import 'MainPage.dart';
import 'RestaurantDetailPage.dart';

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
          SizedBox(height: 60),
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 20.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  // The search bar takes all available space to its right
                  child: TextField(
                    onChanged: _updateSearchText,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Container(width: 40),
                // Replace Spacer with Container, adjust width as needed
              ],
            ),
          ),
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