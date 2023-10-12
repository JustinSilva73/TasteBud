import 'package:flutter/material.dart';
import 'MainPage.dart';

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


  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = _allRestaurants.where((restaurant) {
      return restaurant.name.toLowerCase().contains(_searchText.toLowerCase()) ||
          restaurant.cuisine.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(color: Colors.white), // This line sets the text color to white
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white), // This sets the hint text color to a slightly transparent white
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
        ),
      ),
      body: ListView.builder(
        itemCount: filteredRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = filteredRestaurants[index];
          return RestaurantItem(restaurant: restaurant);
        },
      ),
    );
  }
}
