import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';

class BluetoothManager extends ChangeNotifier {
  //FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool isConnected = false;
  bool isScanning = false;
  BluetoothDevice? connectedDevice;
  String? data;

  final String targetDeviceKeyword = "OPN2006";
  final Guid serviceUUID = Guid("46409BE5-6967-4557-8E70-784E1E55263B");
  final Guid characteristicUUID = Guid("720330f4-1db7-4fd7-ae5a-87e5bd942880");

  List<ScanResult> _scanResults = [];
  Map<BluetoothDevice, List<BluetoothService>> _deviceServices = {};

  List<ScanResult> get scanResults => _scanResults;
  Map<BluetoothDevice, List<BluetoothService>> get deviceServices => _deviceServices;

  void startScanning() {
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

  void connectToDevice(BluetoothDevice device) {
    device.connect().then((_) {
      isConnected = true;
      connectedDevice = device;
      notifyListeners();
      print("Connected to device: ${device.name}");
      device.discoverServices().then((services) {
        _deviceServices[device] = services;
        for (BluetoothService service in services) {
          for (BluetoothCharacteristic c in service.characteristics) {
            if (c.uuid == characteristicUUID && c.properties.notify) {
              c.setNotifyValue(true);
              c.value.listen((value) {
                print("Received data from characteristic: ${value}");
                data = String.fromCharCodes(value);
                notifyListeners();
              });
            }
          }
        }
      });
    }).catchError((error) {
      print("Error connecting to device: $error");
    });
  }

  void disconnect() {
    if (connectedDevice != null) {
      connectedDevice!.disconnect();
      isConnected = false;
      connectedDevice = null;
      data = null;
      _scanResults.clear();
      _deviceServices.clear();
      notifyListeners();
    }
  }
}
