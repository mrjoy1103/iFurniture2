import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:fw_demo/models/listedItem.dart';
import 'package:fw_demo/pages/productdetails.dart';
import 'package:fw_demo/utils/sharedprefutils.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../providers/inventory_provider.dart';

class BluetoothManager extends ChangeNotifier {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager(GlobalKey<NavigatorState> navigatorKey) {
    _instance._navigatorKey = navigatorKey;
    return _instance;
  }
  BluetoothManager._internal();

  static BluetoothManager get instance => _instance;

  GlobalKey<NavigatorState>? _navigatorKey;
  bool isConnected = false;
  bool isScanning = false;
  BluetoothDevice? connectedDevice;
  String? _serverAddress;
  final String targetDeviceKeyword = "OPN2006";
  final Guid serviceUUID = Guid("46409BE5-6967-4557-8E70-784E1E55263B");
  final Guid characteristicUUID = Guid("720330f4-1db7-4fd7-ae5a-87e5bd942880");

  List<ScanResult> _scanResults = [];
  Map<BluetoothDevice, List<BluetoothService>> _deviceServices = {};
  Map<Guid, StreamSubscription<List<int>>> _characteristicSubscriptions = {};

  String currentPage = "otherThanLists";
  int _currentListid = -1;

  List<ScanResult> get scanResults => _scanResults;
  Map<BluetoothDevice, List<BluetoothService>> get deviceServices => _deviceServices;

  void Function()? onItemAddedCallback; // Callback function

  void setServerAddress(String serverAddress) {
    _serverAddress = serverAddress;
  }

  void setCurrentPage(String page, int listid) {
    Future.microtask(() {
      currentPage = page;
      _currentListid = listid;
      print("Set currentPage to: $currentPage with listId: $_currentListid");
      notifyListeners();
    });
  }

  void resetCurrentPage() {
    print("Resetting current page to otherThanLists");
    currentPage = "otherThanLists";
    _currentListid = -1;
    //notifyListeners();
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

      // Initiate service discovery after successful connection
      await discoverServices(device);
    } catch (error) {
      print("Error connecting to device: $error");
      isConnected = false;
      connectedDevice = null;
      notifyListeners();
    }
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      _deviceServices[device] = services;

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
              await _handleData(value);
            });
          }
        }
      } else {
        print("Target service not found");
      }
    } catch (error) {
      print("Error discovering services: $error");
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

  Future<void> _handleData(List<int> value) async {
    String scannedData = String.fromCharCodes(value);
    print("Received data from characteristic: ${value}");
    print("Scanned data: $scannedData");

    await _handleScannedData(scannedData);
    print("After Scanning data");
    notifyListeners();
  }

  Future<void> _handleScannedData(String data) async {
    if (_serverAddress == null) {
      _serverAddress = await SharedPreferencesUtil.getServerAddress();
      print("Server error");
      return;
    }
    print("You are in the function with currentPage: $currentPage");
    final apiService = ApiService(baseUrl: _serverAddress!);
    try {
      final inventoryProvider = Provider.of<InventoryProvider>(_navigatorKey!.currentContext!, listen: false);
      final itemNumber = int.tryParse(data);
      print("Here is the parsed data $itemNumber");

      if (itemNumber != null && inventoryProvider.containsItemNumber(itemNumber)) {
        final product = await apiService.getProductByNumber(itemNumber);
        if (product != null) {
          if (currentPage == "ListsPage") {
            print("Handling ListsPage functionality");
            // Fetch the current list items
            List<ListedItem> currentListItems = await apiService.getAllListedItemsByID(_currentListid);

            ListedItem? existingItem;
            // Check if the item already exists in the list
            try {
              existingItem = currentListItems.firstWhere(
                      (item) => item.itemNumber == itemNumber
              );}
            catch (e){
              existingItem = null;
            }

            if (existingItem != null) {
              // If the item exists, increase the quantity by 1
              existingItem.quantity = (existingItem.quantity ?? 1) + 1;
              await apiService.updateListedItem(existingItem);
              ScaffoldMessenger.of(_navigatorKey!.currentContext!).showSnackBar(
                SnackBar(content: Text('Quantity updated for existing product', textAlign: TextAlign.center), backgroundColor: Colors.green, duration: Duration(milliseconds: 150)),
              );
            } else {
              // If the item doesn't exist, add it to the list
              ListedItem listedItem = ListedItem(listId: _currentListid, itemNumber: itemNumber, price: product.retail!);
              await apiService.addItemToList(listedItem);
              ScaffoldMessenger.of(_navigatorKey!.currentContext!).showSnackBar(
                SnackBar(content: Text('Item added to the list', textAlign: TextAlign.center), backgroundColor: Colors.green, duration: Duration(milliseconds: 150)),
              );
            }

            // Notify callback
            if (onItemAddedCallback != null) {
              onItemAddedCallback!();
            }
          } else {
            print("Handling non-ListsPage functionality");
            // Navigate to ProductDetailsPage if not on ListsPage
            _navigatorKey!.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(itemNumber: itemNumber),
              ),
            );
          }
        } else {
          _showProductNotFound();
        }
      } else {
        print("you are in second if else");
        _showProductNotFound();
      }
    } catch (e) {
      print("Error handling scanned data: $e");
      _showProductNotFound();
    }
  }

  void _showProductNotFound() {
    final context = _navigatorKey?.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product not found', textAlign: TextAlign.center,), backgroundColor: Colors.redAccent, duration: Duration(milliseconds: 150)),
      );
    }
  }

  void setOnItemAddedCallback(void Function() callback) {
    onItemAddedCallback = callback;
  }
}