import 'package:classc_eats/Home/home_screen.dart';
import 'package:classc_eats/LoginRegistration/login_screen.dart';
import 'package:classc_eats/Products/products_screen.dart';
import 'package:classc_eats/Services/api_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Manage dark mode here.
  bool _isDarkMode = false;

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
      // For simplicity, we set MainScreen as the home route.
      home: MainScreen(toggleDarkMode: toggleDarkMode, isDarkMode: _isDarkMode),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

/// MainScreen holds the top app bar, bottom navigation bar, and page body.
class MainScreen extends StatefulWidget {
  final Function(bool) toggleDarkMode;
  final bool isDarkMode;

  const MainScreen({super.key, required this.toggleDarkMode, required this.isDarkMode});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Global key for our Scaffold in order to open the end drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Current index for the bottom navigation (0: Home, 1: Menu, 2: Cart).
  // Note: We do not assign a page to index 3 (Profile) since that opens the drawer.
  int _currentIndex = 0;

  // Dummy user data. In a real app, retrieve this from your API.
  final String _userName = "John Doe";
  final String _userEmail = "johndoe@example.com";
  final String _profileImageUrl =
      "https://via.placeholder.com/150"; // Replace with your own image URL.

  // Instantiate your ApiService so you can call logout.
  final ApiService _apiService = ApiService();

  // List of pages for the first three tabs.
  final List<Widget> _pages = [
    const HomeScreen(),
    const ProductsScreen(),
    // const CartScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 3) {
      // Profile tab tapped: Open the end drawer.
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      // Update the current index.
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    // After logout, navigate to the login screen.
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Top navigation bar with title.
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: const Text(
          'ClassicEats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Playwrite'
          ),
        ),
      ),
      // Body displays the selected page (Home, Menu, or Cart).
      body: _pages[_currentIndex],
      // End drawer for profile information.
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Profile header.
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(_profileImageUrl),
                ),
                accountName: Text(_userName),
                accountEmail: Text(_userEmail),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // Dark mode switch.
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: widget.isDarkMode,
                onChanged: widget.toggleDarkMode,
                secondary: const Icon(Icons.brightness_6),
              ),
              // Contact Us option.
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text('Contact Us'),
                onTap: () {
                  // TODO: Implement your contact functionality.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact Us tapped')),
                  );
                },
              ),
              // Logout option.
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await _logout();
                },
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,),
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
    );
  }
}
