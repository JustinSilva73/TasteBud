import 'package:flutter/material.dart';
import 'package:tastebud/MainPage.dart';
import '/CreateAccount.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

            // Email Input
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Password Input
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text;
                String password = _passwordController.text;

                if (!isValidEmail(email)) {
                  // Show some feedback to the user about invalid email
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

                print('Email: $email');
                print('Password: $password');

                await _saveEmailToStorage(email);
                print('Stored email: $email');

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()), // Assumes you have a CreateAccountPage widget
                );

                // Now you can use these values for your login logic, like making an API call, etc.
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