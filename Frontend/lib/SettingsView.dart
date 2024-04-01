import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LogInPage.dart';
import 'MainPage.dart';
import 'Search.dart';
Future<bool> getNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notifications') ?? true; // default to true
}
Future<bool> getPopup() async {
  final prefs = await SharedPreferences.getInstance();
  bool popupsEnabled = prefs.getBool('popups') ?? true;
  print("Popups enabled: $popupsEnabled");
  return popupsEnabled;
}


Future<bool> getRememberLog() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('rememberLog') ?? true; // default to true
}

Future<bool> getLocationServ() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('locationServ') ?? true; // default to true
}

Color? activeColorSwitch = Colors.green[300];
bool notificationsOn = getNotifications() as bool;
bool popUpsOn = getPopup() as bool;
bool rememberLoginOn = getRememberLog() as bool;
bool locationServicesOn = getLocationServ() as bool;


void onTileTap(String tileType) {
  switch (tileType) {
    case 'Email':
      EmailTap();
      break;
    case 'Username':
      UsernameTap();
      break;
    case 'Password':
      PasswordTap();
      break;
  }
}

bool getPopUpState(){
  return popUpsOn;
}

void onSwitchTap(String tileType){
  switch (tileType){
    case 'Notifications':
      break;
    case 'Pop-ups':
      break;
    case 'Remember Log in':
      break;
    case 'Location Services':
      break;
  }
}

Future<void> saveNotificationsEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('notifications', enabled);
}

Future<void> savePopUpEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  print("savePopUpEnabled called with value: $enabled");
  await prefs.setBool('popups', enabled);
}


Future<void> saveRememberLogEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('rememberLog', enabled);
}

Future<void> saveLocationServEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('locationServ', enabled);
}

void setNotificationsTap(){
  saveNotificationsEnabled(notificationsOn);
}

void setPopupsTap(){
  savePopUpEnabled(popUpsOn);
}

void setRemeberLogTap(){
  saveRememberLogEnabled(rememberLoginOn);
}

void setLocationServTap(){
  saveLocationServEnabled(locationServicesOn);
}

void EmailTap() {
  // Navigate to email settings
}

void UsernameTap() {
  // Navigate to username settings
}

void PasswordTap() {
  // Navigate to password settings
}

Future<void> resetPreferencesToDefaults() async {
  final prefs = await SharedPreferences.getInstance();
  // Resetting each preference to its default value
  await prefs.setBool('notifications', true);
  await prefs.setBool('popups', true);
  await prefs.setBool('rememberLog', false);
  await prefs.setBool('locationServ', false);
  // Add any other preferences that need to be reset
}


Future<void> clearAllPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}


void LogoutTap(BuildContext context) async {
  // Either reset to defaults or clear all preferences
  await clearAllPreferences();
  await resetPreferencesToDefaults();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginPage()), // Assuming LoginPage is your login page class
        (Route<dynamic> route) => false,
  );
}


class SettingsView extends StatefulWidget {
  final int currentIndex;
  final List<Restaurant> allRestaurants; // Add this line

  const SettingsView({Key? key, this.currentIndex = 1, required this.allRestaurants}) : super(key: key); // Modify this line

  @override
  _SettingsViewState createState() => _SettingsViewState();
}
class _SettingsViewState extends State<SettingsView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text('Settings and Privacy'),
        centerTitle: true, // This centers the title in the AppBar.
        backgroundColor: const Color(0xFFEDEDED),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: <Widget>[
          CategoryGroup(
            title: 'Account Settings',
            children: [
              ListTileTheme(
                dense: true,
                  child: ListTile(
                    title: const Text('Email', style:TextStyle(fontSize: 15)),
                    leading: const Icon(Icons.email),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => onTileTap('Email'),
                  )
              ),
              ListTileTheme(
                dense: true,
                  child: ListTile(
                    title: const Text('Username', style:TextStyle(fontSize: 15)),
                    leading: const Icon(Icons.person),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => onTileTap('Username'),
                  ),
              ),
              ListTileTheme(
                dense: true,
                  child: ListTile(
                    title: const Text('Password', style:TextStyle(fontSize: 15)),
                    leading: const Icon(Icons.lock),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => onTileTap('Password'),
                  ),
              ),
            ],
          ),
          const SizedBox(height: 10), // To add space between sections
          CategoryGroup(
            title: 'App Settings',
            children: [
              FutureBuilder<bool>(
                future: getNotifications(),
                builder: (context, snapshot) {
                  bool switchValue = snapshot.data ?? true; // Default to true or current state
                  return SwitchListTile(
                    title: const Text('Notifications', style: TextStyle(fontSize: 15)),
                    secondary: const Icon(Icons.notifications),
                    value: switchValue,
                    activeTrackColor: activeColorSwitch,
                    onChanged: (newValue) async {
                      await saveNotificationsEnabled(newValue); // Save preference asynchronously
                      setState(() {
                        // This ensures UI is updated after the preference is saved
                        notificationsOn = newValue; // Consider removing if you move to local state management
                      });
                    },
                  );
                },
              ),
              FutureBuilder<bool>(
                future: getPopup(),
                builder: (context, snapshot) {
                  bool switchValue = snapshot.data ?? true; // Default to true or current state
                  return SwitchListTile(
                    title: const Text('Pop-ups', style: TextStyle(fontSize: 15)),
                    secondary: const Icon(Icons.podcasts_outlined),
                    value: switchValue,
                    activeTrackColor: activeColorSwitch,
                    onChanged: (newValue) async {
                      await savePopUpEnabled(newValue); // Save preference asynchronously
                      setState(() {
                        popUpsOn = newValue;
                      });
                    },
                  );
                },
              ),
              FutureBuilder<bool>(
                future: getRememberLog(),
                builder: (context, snapshot) {
                  bool switchValue = snapshot.data ?? true; // Default to true or current state
                  return SwitchListTile(
                    title: const Text('Remember Log in', style: TextStyle(fontSize: 15)),
                    secondary: const Icon(Icons.memory),
                    value: switchValue,
                    activeTrackColor: activeColorSwitch,
                    onChanged: (newValue) async {
                      await saveRememberLogEnabled(newValue); // Save preference asynchronously
                      setState(() {
                        rememberLoginOn = newValue;
                      });
                    },
                  );
                },
              ),
              FutureBuilder<bool>(
                future: getLocationServ(),
                builder: (context, snapshot) {
                  bool switchValue = snapshot.data ?? true; // Default to true or current state
                  return SwitchListTile(
                    title: const Text('Location Services', style: TextStyle(fontSize: 15)),
                    secondary: const Icon(Icons.location_on),
                    value: switchValue,
                    activeTrackColor: activeColorSwitch,
                    onChanged: (newValue) async {
                      await saveLocationServEnabled(newValue); // Save preference asynchronously
                      setState(() {
                        locationServicesOn = newValue;
                      });
                    },
                  );
                },
              )
            ],
          ),
          CategoryGroup(
              children: [
                ListTileTheme(
                    child: ListTile(
                      title: const Text(
                        'Log out',
                        style: TextStyle(
                          color: Colors.red, // This sets the text color to red.
                        ),
                      ),
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xFFFF0000), // Custom red color using hexadecimal color code.
                      ),
                      onTap: () => LogoutTap(context),
                    ),
                )
              ]
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex, // Use the currentIndex
        onTap: (index) {
          // Update this function to navigate based on 'index'
          if (index == widget.currentIndex) return; // Do nothing if the current tab is tapped

          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
              break;
            case 1:
            // Already on Settings, do nothing or perhaps refresh the page
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchPage(allRestaurants: widget.allRestaurants))); // Make sure to pass the correct arguments
              break;
          }
        },
        selectedItemColor: const Color(0xFFA30000), // Set the color for the selected item
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

class CategoryGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const CategoryGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: title != null ? Text(
            title!, // No need for the bang operator if your method parameter is already null-checked.
            style: const TextStyle(
              color: Color(0xFF4D4D4D),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ) : const SizedBox.shrink(), // Use an empty widget like SizedBox.shrink() when title is null.
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000), // 25% opacity black color
                blurRadius: 4,
                offset: Offset(0, 2), // X offset is 0, Y offset is 2
                spreadRadius: 1, // Spread radius is 1
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              int index = entry.key;
              Widget child = Padding(
                padding: const EdgeInsets.only(top: 0.0, bottom: 0.0), // Reduce padding as needed
                child: entry.value,
              );
              return Stack(
                children: [
                  child,
                  Positioned(
                    left: 55, // Adjust this value to align with the end of your icon or desired start point
                    right: 0,
                    bottom: 0,
                    child: index != children.length - 1 ? Container(
                      height: 1,
                      color: const Color(0xFFC3C3C3),
                    ) : Container(),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Maintain horizontal padding
        child: Container(
          height: 40, // Or any other height that fits your design
          padding: const EdgeInsets.symmetric(vertical: 4.0), // Reduced vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon),
              Text(title),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

