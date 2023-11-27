import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tastebud/MainPage.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/testing.dart';

void main() {
  group('getNumberTrivia', () {
    test('returns list of Resturant when http response is successful',
        () async {
      final page = MainPage();

      // Mock the API call to return a json response with http status 200 Ok //
      final mockHTTPClient = MockClient((request) async {
        // Create sample response of the HTTP call //
        final response = [
          {
            "business_name": "Perch",
            "address": "448 South Hill Street, Los Angeles",
            "lat": 34.0489961,
            "lng": -118.2514107,
            "rating": 4.4,
            "price_level": 3,
            "icon":
                "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png",
            "opening_hours": true,
            "categories_of_cuisine": "Chinese",
            "image_url":
                "https://plus.unsplash.com/premium_photo-1683121324272-90f4b4084ac9?auto=format&fit=crop&q=60&w=500&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8YW1lcmljYW4lMjBmb29kfGVufDB8fDB8fHww"
          },
          {
            "business_name": "Cole's French Dip",
            "address": "118 East 6th Street, Los Angeles",
            "lat": 34.0447898,
            "lng": -118.2495086,
            "rating": 4.5,
            "price_level": 2,
            "icon":
                "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png",
            "opening_hours": true,
            "categories_of_cuisine": "Italian",
            "image_url":
                "https://plus.unsplash.com/premium_photo-1668202961193-4c5a66a2d68d?auto=format&fit=crop&q=60&w=500&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8QmFyJTIwZm9vZHxlbnwwfHwwfHx8MA%3D%3D"
          }
        ];
        return Response(jsonEncode(response), 200);
      });
      // Check whether getNumberTrivia function returns
      // number trivia which will be a String
      expect(
          await page.createState().fetchRestaurantPrio(
              mockHTTPClient, LatLng(34.052235, -118.243683)),
          isA<List<Restaurant>>());
    });

    test('return error message when http response is unsuccessful',
        () async {
      final page = MainPage();

      final mockHTTPClient = MockClient((request) async { 
        final response = {}; 
        return Response(jsonEncode(response), 404); 
      }); 
      // Check whether getNumberTrivia function returns
      // number trivia which will be a String
      expect(
          await page.createState().fetchNearbyRestaurantsFromServer(
              mockHTTPClient, LatLng(0, 0)),
          isA<List<Restaurant>>());
    });
  });
}