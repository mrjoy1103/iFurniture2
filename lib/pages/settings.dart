/*
import 'package:flutter/material.dart';
import 'package:fw_demo/pages/login.dart';
import 'package:fw_demo/utils/bluetooth_manager.dart';
import 'package:fw_demo/utils/sharedprefutils.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '1.0.0';
  String _companyName = 'New Vision Information Systems';
  String _apiServerVersion = '2.2.3'; // Example value, you might want to fetch this from the server

  @override
  void initState() {
    super.initState();
  }

  // Start scanning for Bluetooth devices
  void _startScanning() {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    bluetoothManager.startScanning(); // Start scanning
  }

  // Logout and disconnect Bluetooth if connected
  void _logout() {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    if (bluetoothManager.isConnected) {
      bluetoothManager.disconnect();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.white70,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('App Version'),
              subtitle: Text(_appVersion),
            ),
            ListTile(
              title: Text('Build By'),
              subtitle: Text(_companyName),
            ),
            ListTile(
              title: Text('API Server Version'),
              subtitle: Text(_apiServerVersion),
            ),
            ListTile(
              title: Text('Barcode Scanner'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _startScanning, // Start Bluetooth scanning
                    child: Text('Connect'),
                  ),
                  SizedBox(width: 8),
                  Consumer<BluetoothManager>(
                    builder: (context, bluetoothManager, child) {
                      return Visibility(
                        visible: bluetoothManager.isConnected,
                        child: ElevatedButton(
                          onPressed: () {
                            bluetoothManager.disconnect(); // Disconnect Bluetooth
                          },
                          child: Text('Disconnect'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout, // Logout and disconnect Bluetooth if needed
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:fw_demo/pages/login.dart';
import 'package:fw_demo/utils/bluetooth_manager.dart';
import 'package:fw_demo/utils/sharedprefutils.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '1.0.0';
  String _companyName = 'New Vision Information Systems';
  String _apiServerVersion = '2.2.3'; // Example value, you might want to fetch this from the server

  @override
  void initState() {
    super.initState();
  }

  // Start scanning for Bluetooth devices
  void _startScanning() {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    bluetoothManager.startScanning(); // Start scanning
  }

  // Logout and disconnect Bluetooth if connected
  void logout(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    if (bluetoothManager.isConnected) {
      bluetoothManager.disconnect();
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text('App Version', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_appVersion),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text('Build By', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_companyName),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text('API Server Version', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_apiServerVersion),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text('Barcode Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _startScanning, // Start Bluetooth scanning
                      child: Text('Connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Consumer<BluetoothManager>(
                      builder: (context, bluetoothManager, child) {
                        return Visibility(
                          visible: bluetoothManager.isConnected,
                          child: ElevatedButton(
                            onPressed: () {
                              bluetoothManager.disconnect(); // Disconnect Bluetooth
                            },
                            child: Text('Disconnect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => logout(context), // Logout and disconnect Bluetooth if needed
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
