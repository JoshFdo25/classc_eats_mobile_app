import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:classc_eats/Services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSigningUp = false;
  bool _isLoading = false;
  String? _emailError;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isSigningUp = !_isSigningUp;
      _animationController.forward(from: 0.0);
    });
  }

  Future<void> _authenticateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isSigningUp) {
      if (password != _confirmPasswordController.text.trim()) {
        _showSnackbar('Passwords do not match. Please try again.');
        setState(() => _isLoading = false);
        return;
      }
      try {
        final response = await _apiService.register(
          _nameController.text.trim(),
          email,
          password,
          password,
        );

        if (response.statusCode == 201) {
          _showSnackbar('Registration successful!');
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else if (response.statusCode == 422) {
          // Handle the 422 error for duplicate email
          final responseData = jsonDecode(response.body);
          if (responseData['errors'] != null && responseData['errors']['email'] != null) {
            setState(() {
              _emailError = 'Email is already registered. Please use a different email.';
            });
          } else {
            // Handle other errors
            _showSnackbar('Registration failed: ${response.body}');
          }
        } else {
          _showSnackbar('Registration failed: ${response.body}');
        }
      } catch (e) {
        _showSnackbar('Error during registration: $e');
      }
    } else {
      try {
        final response = await _apiService.login(email, password);
        if (response.statusCode == 200) {
          _showSnackbar('Login successful!');
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else if (response.statusCode == 401 && response.body.contains('email')) {
          // Check if the email is already registered for login failure
          _showSnackbar('Email is already registered. Please use a different email.');
        } else {
          _showSnackbar('Login failed: ${response.body}');
        }
      } catch (e) {
        _showSnackbar('Error during login: $e');
      }
    }

    setState(() => _isLoading = false);
  }



  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildCard(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/images/restaurant_images.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitle(),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: _buildForm(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(),
                const SizedBox(height: 10),
                _buildToggleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "ClassicEats",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.indigo[900],
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'PlaywriteCU',
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        key: ValueKey<bool>(_isSigningUp),
        children: [
          if (_isSigningUp)
            _buildInputField(_nameController, "Name", false),
          const SizedBox(height: 10),
          _buildInputField(_emailController, "Email", false),
          const SizedBox(height: 10),
          _buildInputField(_passwordController, "Password", true),
          if (_isSigningUp) const SizedBox(height: 10),
          if (_isSigningUp)
            _buildInputField(
                _confirmPasswordController, "Confirm Password", true),
        ],
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, bool obscureText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        errorText: label == "Email" ? _emailError : null,
      ),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == "Email" && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        if (label == "Password" && value.length < 8) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
        WidgetStateProperty.all<Color>(Colors.indigo.shade900),
      ),
      onPressed: _authenticateUser,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
        _isSigningUp ? "Register" : "Login",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: _toggleForm,
      child: Text(
        _isSigningUp
            ? "Already have an account? Login"
            : "Don't have an account? Sign Up",
      ),
    );
  }
}
