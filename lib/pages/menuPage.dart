import 'package:flutter/material.dart';
import 'package:fw_demo/pages/lists_page.dart';
import 'package:fw_demo/pages/login.dart';
import 'package:fw_demo/pages/product_inventory.dart';

import '../utils/sharedprefutils.dart';
import 'barcodeScanner.dart';
import 'bluetoothScanner.dart'; // Import the new lists page

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? _serverAddress;

  @override
  void initState() {
    super.initState();
    _loadServerAddress();
  }

  Future<void> _loadServerAddress() async {
    String? serverAddress = await SharedPreferencesUtil.getServerAddress();
    setState(() {
      _serverAddress = serverAddress;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Would you like to log out and move to the server configuration page?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()), // Update with the correct path
            ),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Menu'),
        ),
        body: Center(
          child: _serverAddress == null
              ? CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to Product Inventory Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductInventoryPage(serverAddress: _serverAddress!),
                    ),
                  );
                },
                child: Text('Product Inventory'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Lists Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListsPage(serverAddress: _serverAddress!),
                    ),
                  );
                },
                child: Text('Lists'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Log out and navigate to Login Page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()), // Update with the correct path
                  );
                },
                child: Text('Log Out'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BluetoothScannerPage()),
                  );
                },
                child: Text('Connect Barcode Scanner'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BarcodeScannerPage(),
                    ),
                  );
                },
                child: Text('Open Barcode Scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
