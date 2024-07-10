import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import 'productdetails.dart';
import '../utils/sharedprefutils.dart';
import 'package:fw_demo/providers/inventory_provider.dart';

class BarcodeScannerCameraPage extends StatefulWidget {
  @override
  _BarcodeScannerCameraPageState createState() => _BarcodeScannerCameraPageState();
}

class _BarcodeScannerCameraPageState extends State<BarcodeScannerCameraPage> {
  String? serverAddress;
  String? scannedBarcode;

  @override
  void initState() {
    super.initState();
    _loadServerAddress();
  }

  Future<void> _loadServerAddress() async {
    serverAddress = await SharedPreferencesUtil.getServerAddress();
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
    if (serverAddress == null) {
      _showProductNotFound();
      return;
    }
    final apiService = ApiService(baseUrl: serverAddress!);
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
          _showProductNotFound();
        }
      } else {
        _showProductNotFound();
      }
    } catch (e) {
      print("Error handling scanned data: $e");
      _showProductNotFound();
    }
  }

  void _showProductNotFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product not found')),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner Camera'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanBarcode,
              child: Text('Start Scanning'),
            ),
            if (scannedBarcode != null)
              Text('Scanned Code: $scannedBarcode'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Return to the previous page
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
