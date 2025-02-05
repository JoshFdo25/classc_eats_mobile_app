import 'dart:convert';
import 'package:classc_eats/Services/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await ApiService().fetchCategories();
      if (response.statusCode == 200) {
        setState(() {
          _categories = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          // Use the isLandscape flag to adjust dimensions where necessary.
          bool isLandscape = orientation == Orientation.landscape;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildBanner(context, isLandscape),
                _buildIntroText(context, isLandscape),
                _buildCategoriesTitle(context),
                _isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
                    : _buildCategoriesList(context, isLandscape),
                _buildNewProductsCard(context, isLandscape),
                _buildExclusiveOffers(context, isLandscape),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBanner(BuildContext context, bool isLandscape) {
    // Adjust the banner height based on orientation.
    final bannerHeight = isLandscape ? 200.0 : 250.0;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: bannerHeight,
            child: Image.asset(
              'lib/images/Banner.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            height: bannerHeight,
            color: Colors.black38,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome to Classic Eats',
              style: TextStyle(
                fontSize: isLandscape ? 22 : 24,
                fontFamily: 'PlaywriteCU',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroText(BuildContext context, bool isLandscape) {
    // You can adjust padding or font size based on orientation if needed.
    return Padding(
      padding: const EdgeInsets.all(23.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Experience Culinary Excellence in Every Bite. At Classic Eats, '
              'we blend innovation and tradition to bring you a diverse '
              'menu that delights the senses.',
          style: TextStyle(
            fontSize: isLandscape ? 15 : 16,
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCategoriesTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        'Categories',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  /// In portrait mode we use a horizontal ListView. In landscape mode,
  /// if there are only a few category cards, they are centered.
  Widget _buildCategoriesList(BuildContext context, bool isLandscape) {
    final listHeight = isLandscape ? 150.0 : 180.0;
    if (isLandscape) {
      // Build a centered row of category cards
      return SizedBox(
        height: listHeight,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _categories.map<Widget>((category) {
              return _buildCategoryCard(
                context,
                category['image'],
                category['name'],
                isLandscape,
              );
            }).toList(),
          ),
        ),
      );
    } else {
      // Portrait: use a scrollable horizontal list.
      return SizedBox(
        height: listHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(
              context,
              category['image'],
              category['name'],
              isLandscape,
            );
          },
        ),
      );
    }
  }

  Widget _buildCategoryCard(
      BuildContext context, String imageUrl, String title, bool isLandscape) {
    // Adjust the image dimensions for landscape if desired.
    final imageSize = isLandscape ? 100.0 : 110.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNewProductsCard(BuildContext context, bool isLandscape) {
    // Adjust card height based on orientation.
    final cardHeight = isLandscape ? 130.0 : 150.0;
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.asset(
          'lib/images/New-products.webp',
          width: double.infinity,
          height: cardHeight,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildExclusiveOffers(BuildContext context, bool isLandscape) {
    // Adjust image height based on orientation.
    final offerHeight = isLandscape ? 130.0 : 150.0;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exclusive Offers',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                'lib/images/food-coupons.jpg',
                width: double.infinity,
                height: offerHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
