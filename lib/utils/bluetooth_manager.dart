import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:fw_demo/pages/productdetails.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../providers/inventory_provider.dart';

class BluetoothManager extends ChangeNotifier {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();

  bool isConnected = false;
  bool isScanning = false;
  BluetoothDevice? connectedDevice;
  BuildContext? _context;
  String? _serverAddress;
  final String targetDeviceKeyword = "OPN2006";
  final Guid serviceUUID = Guid("46409BE5-6967-4557-8E70-784E1E55263B");
  final Guid characteristicUUID = Guid("720330f4-1db7-4fd7-ae5a-87e5bd942880");

  List<ScanResult> _scanResults = [];
  Map<BluetoothDevice, List<BluetoothService>> _deviceServices = {};
  Map<Guid, StreamSubscription<List<int>>> _characteristicSubscriptions = {};

  List<ScanResult> get scanResults => _scanResults;
  Map<BluetoothDevice, List<BluetoothService>> get deviceServices => _deviceServices;

  void setContext(BuildContext context) {
    _context = context;
  }

  void setServerAddress(String serverAddress) {
    _serverAddress = serverAddress;
  }

  void startScanning() {
    if (isConnected || isScanning) return;
    isScanning = true;
    notifyListeners();

    FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      for (ScanResult r in results) {
        _checkDeviceForMatchingKeyword(r.device);
      }
      notifyListeners();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 10)).then((_) {
      print("Scan started");
      isScanning = false;
      notifyListeners();
    }).catchError((error) {
      print("Error starting scan: $error");
      isScanning = false;
      notifyListeners();
    });
  }

  void _checkDeviceForMatchingKeyword(BluetoothDevice device) {
    if (device.name.contains(targetDeviceKeyword)) {
      connectToDevice(device);
      FlutterBluePlus.stopScan();
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      isConnected = true;
      connectedDevice = device;
      notifyListeners();
      print("Connected to device: ${device.name}");

      List<BluetoothService> services = await device.discoverServices();
      _deviceServices[device] = services;

      // Only look for the specific service
      BluetoothService? targetService = services.firstWhere(
            (service) => service.uuid == serviceUUID,
        //orElse: () => null,
      );

      if (targetService != null) {
        for (BluetoothCharacteristic characteristic in targetService.characteristics) {
          if (characteristic.uuid == characteristicUUID && characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            if (_characteristicSubscriptions.containsKey(characteristic.uuid)) {
              _characteristicSubscriptions[characteristic.uuid]!.cancel();
            }
            _characteristicSubscriptions[characteristic.uuid] = characteristic.value.listen((value) async {
              print("Received data from characteristic: ${value}");
              String scannedData = String.fromCharCodes(value);
              print("Scanned data: $scannedData");

              await _handleScannedData(scannedData);
              notifyListeners();
            });
          }
        }
      } else {
        print("Target service not found");
      }
    } catch (error) {
      print("Error connecting to device: $error");
    }
  }

  void disconnect() {
    if (connectedDevice != null) {
      for (var subscription in _characteristicSubscriptions.values) {
        subscription.cancel();
      }
      _characteristicSubscriptions.clear();
      connectedDevice!.disconnect();
      isConnected = false;
      connectedDevice = null;
      _scanResults.clear();
      _deviceServices.clear();
      notifyListeners();
    }
  }

  Future<void> _handleScannedData(String data) async {
    if (_serverAddress == null) {
      _showProductNotFound();
      return;
    }
    final apiService = ApiService(baseUrl: _serverAddress!);
    try {
      final inventoryProvider = Provider.of<InventoryProvider>(_context!, listen: false);
      final itemNumber = int.tryParse(data);
      print("Here is the parsed data $itemNumber");
      if (itemNumber != null && inventoryProvider.containsItemNumber(itemNumber)) {
        final product = await apiService.getProductByNumber(itemNumber);
        if (product != null) {
          if (_context != null) {
            Navigator.push(
              _context!,
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(itemNumber: itemNumber),
              ),
            );
          }
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
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(content: Text('Product not found',textAlign: TextAlign.center,),backgroundColor: Colors.redAccent,),
      );
    }
  }
}
