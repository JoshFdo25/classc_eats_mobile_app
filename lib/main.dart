import 'package:classc_eats/Cart/cart_screen.dart';
import 'package:classc_eats/Home/home_screen.dart';
import 'package:classc_eats/LoginRegistration/login_screen.dart';
import 'package:classc_eats/Products/products_screen.dart';
import 'package:classc_eats/Services/api_service.dart';
import 'package:classc_eats/Profile/profile_screen.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassicEats',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/login', // Start with login screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => MainScreen(
              toggleDarkMode: toggleDarkMode,
              isDarkMode: _isDarkMode,
            ),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final Function(bool) toggleDarkMode;
  final bool isDarkMode;

  const MainScreen({
    super.key,
    required this.toggleDarkMode,
    required this.isDarkMode,
  });


  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userProfile;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ProductsScreen(),
    const CartScreen(),
  ];

  final Battery _battery = Battery();
  int _batteryLevel = 100; // Default value

  Future<void> _getBatteryLevel() async {
    final level = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = level;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _fetchUserProfile();
    _getBatteryLevel();
  }

  Future<void> _checkAuthStatus() async {
    String? token = await _apiService.getToken();
    if (token == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    final response = await _apiService.fetchProfile();
    if (response.statusCode == 200) {
      setState(() {
        _userProfile = jsonDecode(response.body);
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double appBarHeight = isLandscape ? 40 : kToolbarHeight;

    Widget content = isLandscape
        ? Row(
            children: [
              Expanded(child: _pages[_currentIndex]),
              const VerticalDivider(thickness: 1, width: 1),
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.selected,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book),
                    label: Text('Menu'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Cart'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text('Profile'),
                  ),
                ],
              ),
            ],
          )
        : _pages[_currentIndex];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo[900],
        toolbarHeight: appBarHeight,
        title: const Text(
          'ClassicEats',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Playwrite',
            color: Colors.white,
          ),
        ),
      ),
      body: content,
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              if (_userProfile != null) ...[
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.indigo[900],
                    ),
                    accountName: Text(
                      _userProfile!['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    accountEmail: Text(_userProfile!['email']),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: _userProfile!['profile_picture'] != null
                          ? NetworkImage("https://classiceats.online/storage/" +
                          _userProfile!['profile_picture'])
                          : null,
                      child: _userProfile!['profile_picture'] == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.battery_full),
                title: Text('Battery Level: $_batteryLevel%'),
                onTap: _getBatteryLevel, // Refresh battery level on tap
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: widget.isDarkMode,
                onChanged: widget.toggleDarkMode,
                secondary: const Icon(Icons.brightness_6),
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text('Contact Us'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact Us tapped')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isLandscape
          ? null
          : ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), // Set the top-left radius
                topRight: Radius.circular(20), // Set the top-right radius
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.grey[300],
                selectedItemColor: Colors.indigo[600],
                unselectedItemColor: Theme.of(context).iconTheme.color,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book),
                    label: 'Menu',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
    );
  }
}