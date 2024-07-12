import 'package:flutter/material.dart';
import 'package:fw_demo/pages/login.dart';
import 'package:fw_demo/pages/menuPage.dart';
import 'package:fw_demo/utils/bluetooth_manager.dart';
import 'package:fw_demo/utils/sharedprefutils.dart';
import 'package:provider/provider.dart';
//import 'package:package_info_plus/package_info_plus.dart';
import '../providers/inventory_provider.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '1.0.0';
  String _companyName = 'New Vision Information Systems';
  String _apiServerVersion = '2.2.3'; // Example value, you might want to fetch this from the server
  //bool _serverHealth = false;


  @override
  void initState() {
    super.initState();
    //_loadAppVersion();
  }

  Future<void> _initializeBluetoothManager() async {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    bluetoothManager.setContext(context);
    // Set the server address here if needed
    String? _serverAddress = await SharedPreferencesUtil.getServerAddress();
    bluetoothManager.setServerAddress(_serverAddress!);

    // Retrieve your condition to start scanning
    bluetoothManager.startScanning();
    // Check the condition before starting scanning

  }

  // Future<void> _loadAppVersion() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   setState(() {
  //     _appVersion = packageInfo.version;
  //   });
  // }

  // Future<void> _checkServerHealth() async {
  //   // Add your logic to check server health here
  //   setState(() {
  //     _serverHealth = true; // Example: Set to true if the server is healthy
  //   });
  // }

  void _connectBarcodeScanner() {
    // Add your logic to connect the barcode scanner here
  }

  void _disconnectBarcodeScanner() {
    // Add your logic to disconnect the barcode scanner here
  }



  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);

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
            // ListTile(
            //   title: Text('Server Health'),
            //   subtitle: Text(_serverHealth ? 'Healthy' : 'Unhealthy'),
            //   trailing: ElevatedButton(
            //     onPressed: _checkServerHealth,
            //     child: Text('Check Server Health'),
            //   ),
            // ),
            ListTile(
              title: Text('Barcode Scanner'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _initializeBluetoothManager,
                    child: Text('Connect'),
                  ),
                  SizedBox(width: 8),
                  Consumer<BluetoothManager>(
                    builder: (context, bluetoothManager, child) {
                      return Visibility(
                        visible: bluetoothManager.isConnected,
                        child: ElevatedButton(
                          onPressed: () {
                            bluetoothManager.disconnect();
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

              onPressed: (){
                if (bluetoothManager.isConnected)
                  bluetoothManager.disconnect();
                _logout();
              },
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
