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
      home: MainScreen(toggleDarkMode: toggleDarkMode, isDarkMode: _isDarkMode),
      routes: {
        '/login': (context) => const LoginScreen(),
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

  // Current index for navigation.
  // For bottom nav: 0: Home, 1: Menu, 2: Cart, 3: Profile (opens drawer)
  int _currentIndex = 0;

  // Dummy user data.
  final String _userName = "John Doe";
  final String _userEmail = "johndoe@example.com";
  final String _profileImageUrl = "https://via.placeholder.com/150";

  final ApiService _apiService = ApiService();

  // List of pages for the first three navigation items.
  final List<Widget> _pages = [
    const HomeScreen(),
    const ProductsScreen(),
    // Uncomment or add your CartScreen when available.
    const Center(child: Text('Cart Screen')), // Placeholder for CartScreen.
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      // Open profile drawer
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double appBarHeight = isLandscape ? 40 : kToolbarHeight;

    // In landscape mode, move the NavigationRail to the right.
    Widget content;
    if (isLandscape) {
      content = Row(
        children: [
          // Expanded content area on the left.
          Expanded(child: _pages[_currentIndex]),
          const VerticalDivider(thickness: 1, width: 1),
          // NavigationRail on the right.
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
      );
    } else {
      // In portrait mode, use the current page.
      content = _pages[_currentIndex];
    }

    return Scaffold(
      key: _scaffoldKey,
      // Remove any automatically implied leading button.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo[900],
        toolbarHeight: appBarHeight,
        centerTitle: true,
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
                onTap: () async {
                  await _logout();
                },
              ),
            ],
          ),
        ),
      ),
      // In portrait mode, show the bottom navigation bar.
      bottomNavigationBar: isLandscape
          ? null
          : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
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
    );
  }
}

extension on ThemeData {
  get bottomAppBarColor => null;
}
