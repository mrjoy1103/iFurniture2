import 'package:flutter/material.dart';
import 'package:bluetooth_advanced/bluetooth_advanced.dart';
import '../services/api_services.dart';
import 'productdetails.dart';
import '../utils/sharedprefutils.dart';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final _bluetoothAdvanced = BluetoothAdvanced();
  bool isConnected = false;
  String? data;
  bool isData = false;
  bool isScanning = false;
  String? serverAddress;

  @override
  void initState() {
    super.initState();
    _loadServerAddress();
    listentoDeviceData();
  }

  Future<void> _loadServerAddress() async {
    serverAddress = await SharedPreferencesUtil.getServerAddress();
  }

  Future<void> listentoDeviceData() async {
    _bluetoothAdvanced.listenData().listen((event) {
      if (event.startsWith("DEVICE_GATT_AVAILABLE")) {
        setState(() {
          isData = true;
          data = event.toString();
          _handleScannedData(data!);
        });
      } else if (event == "DEVICE_GATT_DISCONNECTED") {
        setState(() {
          isData = false;
          isConnected = false;
        });
      }
    });
  }

  Future<void> _handleScannedData(String data) async {
    if (serverAddress == null) {
      _showProductNotFound();
      return;
    }
    final apiService = ApiService(baseUrl: serverAddress!);
    try {
      final itemNumber = int.tryParse(data);
      if (itemNumber != null) {
        final product = await apiService.getProductByNumber(itemNumber);
        if (product != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(itemNumber: itemNumber),
            ),
          );
        } else {
          _showProductNotFound();
        }
      } else {
        _showProductNotFound();
      }
    } catch (e) {
      _showProductNotFound();
    }
  }

  void _showProductNotFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product not found')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  isConnected && isData
                      ? Text('Data: $data')
                      : Text('Waiting for connection and data...'),
                  ElevatedButton(
                    onPressed: isConnected ? _startScanning : null,
                    child: Text('Start Scanning'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startScanning() {
    setState(() {
      isScanning = true;
    });
    _bluetoothAdvanced.scanDevices();
  }
}
