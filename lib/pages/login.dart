import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fw_demo/services/api_services.dart';
import 'package:fw_demo/pages/loginSucces.dart';
import '../utils/sharedprefutils.dart'; // Ensure the correct import path

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  ApiService? _apiService;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    String? serverAddress = await SharedPreferencesUtil.getServerAddress();

    if (serverAddress == null) {
      setState(() {
        _errorMessage = 'Server address not found. Please set it in settings.';
      });
    } else {
      setState(() {
        _apiService = ApiService(baseUrl: serverAddress);
      });
    }
  }

  // Handle the login action
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final username = _usernameController.text;
      final password = _passwordController.text;

      final user = await _apiService?.login(username, password);
      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        _errorMessage = null;
        // Store user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', user.username);
        await prefs.setString('email', user.email);
        await prefs.setString('token', user.token);
        await prefs.setString('user', user.user);
        await prefs.setBool('isActive', user.isActive);
        await prefs.setString('salesman', user.salesman);

        print('Login successful!');
        // Navigate to the SuccessPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(serverAddress: _apiService!.baseUrl),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid login! Did you forget the secret handshake?';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/fw_logo.png', height: screenHeight * 0.2), // Ensure the image exists in assets
                const SizedBox(height: 20),
                const Text(
                  'Hey, you are back :)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_isLoading) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'your_username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'abcd1234',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          ),
                          child: const Text(
                            'Sign in with username',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ready to chair-ish another great day of sales?',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[900],
                  ),
                  child: const Text('Forget Your Password? Contact Your Admin'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
