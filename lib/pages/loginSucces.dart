import 'package:flutter/material.dart';
import 'package:fw_demo/pages/loadingPage.dart';
import 'package:fw_demo/pages/product_inventory.dart';
import 'package:fw_demo/utils/fade_page_route.dart'; // Ensure the correct import path for the FadePageRoute

class SuccessPage extends StatelessWidget {
  final String serverAddress;

  SuccessPage({required this.serverAddress});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        FadePageRoute(
          page: LoadingPage(serverAddress: serverAddress),
        ),
      );
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/fw_logo.png', height: screenHeight * 0.2), // Ensure the image exists in assets
                SizedBox(height: 20),
                Text(
                  'Success! You\'re logged in and ready to conquer the furniture world.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
