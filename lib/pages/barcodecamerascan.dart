import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:fw_demo/utils/slidingbar.dart';
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    _scanBarcode;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
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
               //Text('Scanned Code: $scannedBarcode'),
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
