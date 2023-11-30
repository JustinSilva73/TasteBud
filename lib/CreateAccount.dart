import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tastebud/LogInPage.dart';
import 'package:tastebud/Survey.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
const Color primaryColor = Color(0xFFA30000);

// Customize your theme data
final ThemeData themeData = ThemeData(
  primaryColor: primaryColor,
  buttonTheme: const ButtonThemeData(
    buttonColor: primaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.grey, // Color for the label when not focused
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFA30000), width: 2.0),
    ),
    floatingLabelStyle: TextStyle(
      color: Color(0xFFA30000), // Color for the label when focused
    ),
  ),
);

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _UsernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? storedEmail;

  @override
  void initState() {
    super.initState();
    _loadStoredEmail();
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

  Future<void> pushCreateAccount(String userName, String email,
      String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/pushAccount'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': userName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        print('Server error: ${response.statusCode}');
        throw Exception(
            'Failed to create account: Server responded with status code ${response
                .statusCode}');
      }
    } catch (e) {
      print('Error creating account: $e');
      throw Exception('Failed to create account: $e');
    }
  }


  Future<Map<String, dynamic>> checkUserDetails(String userName,
      String email) async {
    final uri = Uri.parse('http://10.0.2.2:3000/auth/checkUserDetails')
        .replace(queryParameters: {
      'username': userName,
      'email': email,
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parse the JSON response
        return json.decode(response.body);
      } else {
        // Handle non-200 responses
        print('Server error: ${response.statusCode}');
        throw Exception(
            'Failed to check user details: Server responded with status code ${response
                .statusCode}');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error checking user details: $e');
      throw Exception('Failed to check user details: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    double screenHeight = MediaQuery.of(context).size.height;
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0, // Ensures the AppBar takes up no space
          elevation: 0, // Removes the shadow
          backgroundColor: Theme.of(context).primaryColor, // Sets the AppBar's background color to the theme's primary color
        ),
        body: SafeArea( // SafeArea is applied here to avoid the status bar
          top: true, // Apply padding to the top of SafeArea
          child: Column(
            children: [
              HeaderWidget(
                height: isKeyboardOpen ? screenHeight * 0.15 : screenHeight * 0.3 + 20,
              ),
              Expanded(
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _UsernameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        labelStyle: TextStyle(
                          // Set the color of the label text when it's not focused
                          color: Colors.grey, // Use a neutral color when the field is not focused
                        ),
                        // When the field is focused, use the focusedBorder to change the underline color
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2.0),
                        ),
                        // Set the TextStyle for the label when the field is focused
                        floatingLabelStyle: TextStyle(
                          color: primaryColor, // Use your primary color when the field is focused
                        ),
                      ),
                    ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      // Set the color of the label text when it's not focused
                      color: Colors.grey, // Use a neutral color when the field is not focused
                    ),
                    // When the field is focused, use the focusedBorder to change the underline color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                    // Set the TextStyle for the label when the field is focused
                    floatingLabelStyle: TextStyle(
                      color: primaryColor, // Use your primary color when the field is focused
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword, // Appropriate for passwords
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      // Set the color of the label text when it's not focused
                      color: Colors.grey, // Use a neutral color when the field is not focused
                    ),
                    // When the field is focused, use the focusedBorder to change the underline color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                    // Set the TextStyle for the label when the field is focused
                    floatingLabelStyle: TextStyle(
                      color: primaryColor, // Use your primary color when the field is focused
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                onPressed: () async {
                  // Get input values
                  String username = _UsernameController.text;
                  String email = _emailController.text;
                  String password = _passwordController.text;

                  if (!isValidEmail(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid email!')),
                    );
                    return;
                  }

                  if (!isValidPassword(password)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password should be at least 8 characters long, contain an uppercase letter, a lowercase letter, a number, and a special character!')),
                    );
                    return;
                  }

                  if (username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields!')),
                    );
                    return;
                  }

                  var userDetails = await checkUserDetails(username, email);
                  if (userDetails['usernameExists'] || userDetails['emailExists']) {
                    // If username or email exists, show a message
                    String message = '';
                    if (userDetails['usernameExists']) {
                      message += 'Username already exists. ';
                    }
                    if (userDetails['emailExists']) {
                      message += 'Email already exists.';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  } else {
                    await pushCreateAccount(username, email, password);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SurveyPage()),
                    );
                  }
                },
                child: Text(
                  "Create Account",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(
                  primary: primaryColor,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text("Log In"),
                ),
                  ],
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class HeaderWidget extends StatelessWidget {
  final double height;

  HeaderWidget({required this.height});
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        width: double.infinity, // Forces the container to fill the screen width
        height: height, // Adjust the height as needed
        color: primaryColor, // Replace with your desired color or gradient
        child: Center(
          child: Image.asset('assets/logo.png'), // Replace with your logo asset path
        ),
      ),
    );
  }
}


// WaveClipper remains the same, as you provided
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height - 20); // Start from the left bottom corner

    // Create the first wave
    var firstControlPoint = Offset(size.width / 4, size.height -10);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Increase the `dy` value of the control point to push the curve down
    var secondControlPoint =
    Offset(size.width - (size.width / 3.25), size.height - 55); // decreased by 10
    // Decrease the `dy` value of the end point to pull the end of the wave down
    var secondEndPoint = Offset(size.width, size.height - 50); // increased by 10
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // Finish the path by reaching the right bottom corner
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0); // Continue to the top right corner
    path.close(); // Close the path, going back to the starting point (0,0)
    return path;
  }


  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}