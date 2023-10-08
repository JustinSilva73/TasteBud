import 'package:flutter/material.dart';
import 'RestaurantDetailPage.dart';
import 'MainPage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = "";
  late List<Restaurant> _allRestaurants;

  @override
  void initState() {
    super.initState();
    _allRestaurants = [
      Restaurant("Joe's Diner", '123 Main St', 'American'),
      Restaurant("Tasty Treats", '456 Elm St', 'Italian'),
      Restaurant("New Restaurant 1", '789 Maple St', 'Cuisine Type'),
      Restaurant("New Restaurant 2", '012 Oak St', 'Cuisine Type'),
      // ... Add other new restaurants specific to SearchPage
    ];
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
          decoration: InputDecoration(
            hintText: 'Search...',
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
