import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LogInPage.dart';
Future<bool> getNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notifications') ?? true; // default to true
}
Future<bool> getPopup() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('popups') ?? true; // default to true
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
Future<bool> notificationsOn = getNotifications();
Future<bool> popUpsOn = getPopup();
Future<bool> rememberLoginOn = getRememberLog();
Future<bool> locationServicesOn = getLocationServ();


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

Future<bool> getPopUpState(){
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
  saveNotificationsEnabled(notificationsOn as bool);
}

void setPopupsTap(){
  savePopUpEnabled(popUpsOn as bool);
}

void setRemeberLogTap(){
  saveRememberLogEnabled(rememberLoginOn as bool);
}

void setLocationServTap(){
  saveLocationServEnabled(locationServicesOn as bool);
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
    MaterialPageRoute(builder: (context) => LoginPage()), // Assuming LoginPage is your login page class
        (Route<dynamic> route) => false,
  );
}


class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDEDED),
      appBar: AppBar(
        title: Text('Settings and Privacy'),
        centerTitle: true, // This centers the title in the AppBar.
        backgroundColor: Color(0xFFEDEDED),
      ),
      body: ListView(
        children: <Widget>[
          CategoryGroup(
            title: 'Account Settings',
            children: [
              ListTileTheme(
                dense: true,
                  child: ListTile(
                    title: Text('Email', style:TextStyle(fontSize: 15)),
                    leading: Icon(Icons.email),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => onTileTap('Email'),
                  )
              ),
              ListTileTheme(
                dense: true,
                  child: ListTile(
                    title: Text('Username', style:TextStyle(fontSize: 15)),
                    leading: Icon(Icons.person),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => onTileTap('Username'),
                  ),
              ),
              ListTileTheme(
                dense: true,
                  child: ListTile(
                    title: Text('Password', style:TextStyle(fontSize: 15)),
                    leading: Icon(Icons.lock),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => onTileTap('Password'),
                  ),
              ),
            ],
          ),
          SizedBox(height: 10), // To add space between sections
          CategoryGroup(
            title: 'App Settings',
            children: [
              FutureBuilder<bool>(
                future: getNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SwitchListTile(
                      title: Text('Notifications',style: TextStyle(fontSize: 15)),
                      secondary: Icon(Icons.notifications),
                      value: true, // Default value while waiting
                      activeTrackColor: activeColorSwitch,
                      onChanged: null, // Disable the switch while loading
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return SwitchListTile(
                      title: Text('Notifications',style: TextStyle(fontSize: 15)),
                      secondary: Icon(Icons.notifications),
                      value: snapshot.data ?? true, // Default value if null
                      activeTrackColor: activeColorSwitch,
                      onChanged: (newValue) {
                        setState(() {
                          notificationsOn = Future.value(newValue); // Update the future value
                        });
                        onSwitchTap('Notifications');
                      },
                    );
                  }
                },
              ),
              FutureBuilder<bool>(
                future: getPopup(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // or some placeholder
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return SwitchListTile(
                      title: Text('Pop-ups', style: TextStyle(fontSize: 15)),
                      secondary: Icon(Icons.podcasts_outlined),
                      value: snapshot.data ?? true,
                      activeColor: activeColorSwitch,
                      onChanged: (newValue) {
                        setState(() {
                          popUpsOn = newValue as Future<bool>;
                        });
                        onSwitchTap('Pop-ups');
                      },
                    );
                  }
                },
              ),
              FutureBuilder<bool>(
                future: getRememberLog(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // or some placeholder
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return SwitchListTile(
                      title: Text('Remember Log in', style: TextStyle(fontSize: 15)),
                      secondary: Icon(Icons.login_sharp),
                      value: snapshot.data ?? true,
                      activeColor: activeColorSwitch,
                      onChanged: (newValue) {
                        setState(() {
                          rememberLoginOn = newValue as Future<bool>;
                        });
                        onSwitchTap('Remember Log in');
                      },
                    );
                  }
                },
              ),
              FutureBuilder<bool>(
                future: getLocationServ(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // or some placeholder
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return SwitchListTile(
                      title: Text('Location Services', style: TextStyle(fontSize: 15)),
                      secondary: Icon(Icons.location_disabled),
                      value: snapshot.data ?? true,
                      activeColor: activeColorSwitch,
                      onChanged: (newValue) {
                        setState(() {
                          locationServicesOn = newValue as Future<bool>;
                        });
                        onSwitchTap('Location Services');
                      },
                    );
                  }
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
                      leading: Icon(
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
    );
  }
}

class CategoryGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  CategoryGroup({this.title, required this.children});

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
                      color: Color(0xFFC3C3C3),
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
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

