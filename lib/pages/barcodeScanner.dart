import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../services/api_services.dart';
import 'productdetails.dart';
import '../utils/sharedprefutils.dart';
import 'package:fw_demo/utils/bluetooth_manager.dart';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String? serverAddress;

  @override
  void initState() {
    super.initState();
    _loadServerAddress();
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    bluetoothManager.startScanning();
  }

  Future<void> _loadServerAddress() async {
    serverAddress = await SharedPreferencesUtil.getServerAddress();
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
      if (itemNumber != null && inventoryProvider.containsItemNumber(itemNumber)) {
        final product = await apiService.getProductByNumber(itemNumber);
        if (product != null) {
          Navigator.pushReplacement(
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
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
        actions: [
          IconButton(
            icon: Icon(bluetoothManager.isScanning ? Icons.stop : Icons.refresh),
            onPressed: bluetoothManager.isScanning ? null : bluetoothManager.startScanning,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: bluetoothManager.scanResults.length,
                itemBuilder: (context, index) {
                  ScanResult result = bluetoothManager.scanResults[index];
                  return ExpansionTile(
                    title: Text(result.device.name.isEmpty ? 'Unknown Device' : result.device.name),
                    subtitle: Text(result.device.id.toString()),
                    children: _buildServiceList(result.device),
                    trailing: ElevatedButton(
                      onPressed: () {
                        bluetoothManager.connectToDevice(result.device);
                      },
                      child: Text('Connect'),
                    ),
                  );
                },
              ),
            ),
            if (bluetoothManager.isConnected && bluetoothManager.data != null)
              Text('Data: ${bluetoothManager.data}')
            else
              Text('Waiting for connection and data...'),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildServiceList(BluetoothDevice device) {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);

    if (!bluetoothManager.deviceServices.containsKey(device)) {
      return [Text('No services found')];
    }
    List<Widget> serviceWidgets = [];
    for (BluetoothService service in bluetoothManager.deviceServices[device]!) {
      List<Widget> characteristicWidgets = [];
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicWidgets.add(
          ListTile(
            title: Text('Characteristic: ${characteristic.uuid}'),
            subtitle: Text('Properties: ${characteristic.properties}'),
          ),
        );
      }
      serviceWidgets.add(
        ExpansionTile(
          title: Text('Service: ${service.uuid}'),
          children: characteristicWidgets,
        ),
      );
    }
    return serviceWidgets;
  }
}
