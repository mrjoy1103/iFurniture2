import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fw_demo/pages/barcodecamerascan.dart'; // Import the new BarcodeScannerCameraPage
import 'lists_page.dart';
import 'login.dart';
import 'product_inventory.dart';
import '../utils/sharedprefutils.dart';
import 'package:fw_demo/utils/bluetooth_manager.dart';
import 'package:fw_demo/pages/barcodeScanner.dart';

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
              MaterialPageRoute(builder: (context) => LoginPage()),
            ),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Menu'),
          actions: [
            if (bluetoothManager.isConnected)
              IconButton(
                icon: Icon(Icons.bluetooth_disabled),
                onPressed: () => bluetoothManager.disconnect(),
              ),
          ],
        ),
        body: Center(
          child: _serverAddress == null
              ? CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Log Out'),
              ),
              ElevatedButton(
                onPressed: () {

                },
                child: Text('Connect Barcode Scanner'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BarcodeScannerPage()),
                  );
                },
                child: Text('Open Barcode Scanner'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BarcodeScannerCameraPage()),
                  );
                },
                child: Text('Scan Barcode with Camera'),
              ),
              if (bluetoothManager.isConnected)
                Text('Connected to ${bluetoothManager.connectedDevice?.name}'),
              if (bluetoothManager.isConnected && bluetoothManager.data != null)
                Text('Data: ${bluetoothManager.data}'),
            ],
          ),
        ),
      ),
    );
  }
}
