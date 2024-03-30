import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity, // This ensures the Container fills the screen width.
            color: Color(0xFFA30000), // Hex color code for A30000
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0), // Adjust the padding as needed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 80.0, // Adjust the radius as needed
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with the actual image URL or asset
                  ),
                  SizedBox(height: 10), // Provides space between the avatar and the username
                  Text(
                    'Justin_S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0, // Adjust the font size as needed
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Image.asset('assets/VisitedRest.png', width: 50, height: 50)),
                Tab(icon: Icon(Icons.thumb_up)),
                Tab(icon: Icon(Icons.reviews)),
              ],
              indicatorColor: Colors.red, // Color for the underline of the selected tab
            ),
          ),
          Expanded(
            // Use a TabBarView to allow swiping between tabs
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(child: Text('Dashboard Page')),
                Center(child: Text('Likes Page')),
                Center(child: Text('Add Page')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

