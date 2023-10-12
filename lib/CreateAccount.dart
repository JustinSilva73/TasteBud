import 'package:flutter/material.dart';
import 'package:tastebud/Survey.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
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
            // First Name Input
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Last Name Input
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

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

            // Create Account Button
            ElevatedButton(
              onPressed: () async {
                // Get input values
                String firstName = _firstNameController.text;
                String lastName = _lastNameController.text;
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

                if (firstName == "" || lastName == ""){
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields!')),
                  );
                }else {
                  print("First Name: $firstName");
                  print("Last Name: $lastName");
                  print("Email: $email");
                  print("Password: $password");
                  await _saveEmailToStorage(email);

                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SurveyPage()), // Assumes you have a CreateAccountPage widget
                  );
                }
                // Handle create account logic here. For now, we'll print the values.
                               // Maybe reroute to a confirmation page, or back to login, etc.
              },
              child: Text("Create Account"),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // This reroutes back to the login page.
              },
              child: Text("Log In"),
            ),

          ],
        ),
      ),
    );
  }
}