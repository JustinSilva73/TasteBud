import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Restaurant {
  final String name;
  final String address;
  final String cuisine;
  final LatLng location;
  final String imageUrl;
  final String url;
  final double rating;
  final int priceLevel;
  final String icon;
  final bool? openingHours;
  double? distance;
  double? totalPoints;
  String? yelpID;

  Restaurant({
    required this.name,
    required this.address,
    required this.cuisine,
    required this.location,
    required this.imageUrl,
    required this.url,
    required this.rating,
    required this.priceLevel,
    required this.icon,
    this.openingHours,
    this.distance,
    this.totalPoints,
    this.yelpID
  });

  // Convert JSON to Restaurant object
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['business_name'],
      address: json['address'],
      cuisine: json['categories_of_cuisine'],
      location: LatLng(json['lat'], json['lng']),
      imageUrl: json['image_url'],
      url: json['url'],
      rating: json['rating'].toDouble(),
      priceLevel: json['price_level'] ?? 0,
      icon: json['icon'],
      openingHours: json['opening_hours'] as bool?,
      distance: json['distance']?.toDouble(),
      totalPoints: json['totalPoints']?.toDouble() ?? 0,
      yelpID: json['yelpID'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'business_name': name,
      'address': address,
      'categories_of_cuisine': cuisine,
      'lat': location.latitude,
      'lng': location.longitude,
      'image_url': imageUrl,
      'url' : url,
      'rating': rating,
      'price_level': priceLevel,
      'icon': icon,
      'opening_hours': openingHours,
      'distance': distance,
      'totalPoints': totalPoints,
      'yelpID': yelpID
    };
  }
}
class HeaderWidget extends StatelessWidget {
  final double height;

  const HeaderWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: Color(0xFFA30000), // Replace with your desired color or gradient
      child: Center(
        child: Image.asset('assets/logo.png'), // Replace with your logo asset path
      ),
    );
  }
}


class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;
  final int index;
  final Function(LatLng, String) handleMarkerCallback;
  final List<Restaurant> allRestaurants; // Add this

  const RestaurantItem({
    Key? key,
    required this.restaurant,
    required this.index,
    required this.handleMarkerCallback,
    required this.allRestaurants, // Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.restaurant, color: Color(0xFFA30000)), // Change color here
            SizedBox(width: 8.0),
            Text(restaurant.name),
          ],
        ),
        subtitle: Text(restaurant.address),
        trailing: Icon(Icons.keyboard_arrow_down, color: Color(0xFFA30000)), // Change color here
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Image.network(
                      restaurant.imageUrl,
                      width: 80,
                      height: 80,
                    ),
                  ],
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_dining, color: Color(0xFFA30000)), // Change color here
                          SizedBox(width: 4.0),
                          Text('Cuisine: ${restaurant.cuisine}', style: TextStyle(fontSize: 12.0)),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Color(0xFFA30000)), // Change color here
                          SizedBox(width: 4.0),
                          Text('Price: ${restaurant.priceLevel}', style: TextStyle(fontSize: 12.0)),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(Icons.directions, color: Color(0xFFA30000)), // Change color here
                          SizedBox(width: 4.0),
                          Text('Distance: ${restaurant.distance?.toString() ?? 'Unknown'} miles', style: TextStyle(fontSize: 12.0)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {

                        },
                        child: Text('More Info', style: TextStyle(fontSize: 12.0, color: Color(0xFFA30000))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}