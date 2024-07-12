import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:fw_demo/pages/productdetails.dart';
import 'package:fw_demo/pages/serverConnect.dart';
import 'package:fw_demo/pages/settings.dart';
import 'package:fw_demo/utils/routes.dart';
import 'package:fw_demo/utils/slidingbar.dart';
import 'package:provider/provider.dart';
import 'package:fw_demo/pages/barcodecamerascan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/inventory_provider.dart';
import '../services/api_services.dart';
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
  String? scannedBarcode;

  @override
  void initState() {
    super.initState();
    _loadServerAddress();
  }

  Future<void> _initializeBluetoothManager() async {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    bluetoothManager.setContext(context);
    String? serverAddress = await SharedPreferencesUtil.getServerAddress();
    bluetoothManager.setServerAddress(serverAddress!);
    bluetoothManager.startScanning();
  }

  Future<void> _loadServerAddress() async {
    String? serverAddress = await SharedPreferencesUtil.getServerAddress();
    setState(() {
      _serverAddress = serverAddress;
    });
  }
  Future<void> _scanBarcode() async {
    var result = await BarcodeScanner.scan();
    setState(() {
      scannedBarcode = result.rawContent;
    });
    if (scannedBarcode != null && scannedBarcode!.isNotEmpty) {
      _handleScannedData(scannedBarcode!);
    }
  }

  Future<void> _handleScannedData(String data) async {
    if (_serverAddress == null) {
      _showProductNotFound();
      return;
    }
    final apiService = ApiService(baseUrl: _serverAddress!);
    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      final itemNumber = int.tryParse(data);
      print("Here is the parsed data  $itemNumber");
      if (itemNumber != null && inventoryProvider.containsItemNumber(itemNumber)) {
        final product = await apiService.getProductByNumber(itemNumber);
        if (product != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(itemNumber: itemNumber),
            ),
          );
        } else {
          showSlidingBar(context, 'Product not found', isError: true);
        }
      } else {
        showSlidingBar(context, 'Product not found', isError: true);
      }
    } catch (e) {
      print("Error handling scanned data: $e");
      showSlidingBar(context, 'Product not found', isError: true);
    }
  }
  void showSlidingBar(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SlidingBar(
          message: message,
          isError: isError,
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _showProductNotFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Server Address Error')),
    );
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
            onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ServerAddressPage()),
                ModalRoute.withName('/')
            ),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    String serverAddress = _serverAddress!;
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    bluetoothManager.setContext(context);
    bluetoothManager.setServerAddress(serverAddress);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
          automaticallyImplyLeading: false,  // Remove the back arrow
          actions: [
            if (bluetoothManager.isConnected)
              IconButton(
                icon: Icon(Icons.bluetooth_disabled),
                onPressed: () => bluetoothManager.disconnect(),
              ),
          ],
        ),
        body: _serverAddress == null
            ? Center(child: CircularProgressIndicator())
            : GridView.count(
          crossAxisCount: 2,
          children: [
            _buildMenuItem(
              context,
              'assets/products.png',
              'Inventory',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductInventoryPage(serverAddress: _serverAddress!),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'assets/list.png',
              'Lists',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListsPage(serverAddress: _serverAddress!),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'assets/barcode.png',
              'Scan',
                  () { _scanBarcode();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => BarcodeScannerCameraPage(),
                //   ),
                //);
              },
            ),
            _buildMenuItem(
              context,
              'assets/settings.png',
              'Settings',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String iconPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: 80.0,
              width: 80.0,
            ),
            SizedBox(height: 10.0),
            Text(
              label,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
