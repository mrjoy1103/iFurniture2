import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bluetooth_advanced/bluetooth_advanced.dart';

class BluetoothScannerPage extends StatefulWidget {
  @override
  _BluetoothScannerPageState createState() => _BluetoothScannerPageState();
}

class _BluetoothScannerPageState extends State<BluetoothScannerPage> {
  final _bluetoothAdvanced = BluetoothAdvanced();
  bool isConnected = false;
  String? data;
  bool isData = false;
  List<String> deviceList = [];

  static const String SCANNING_FINISHED_WITH_NO_DEVICE = 'SCANNING_FINISHED_WITH_NO_DEVICE';
  static const String DEVICE_GATT_AVAILABLE = 'DEVICE_GATT_AVAILABLE';
  static const String DEVICE_GATT_INITIATED = 'DEVICE_GATT_INITIATED';
  static const String DEVICE_GATT_CONNECTING = 'DEVICE_GATT_CONNECTING';
  static const String DEVICE_GATT_CONNECTED = 'DEVICE_GATT_CONNECTED';
  static const String DEVICE_GATT_DISCONNECTED = 'DEVICE_GATT_DISCONNECTED';
  static const String STATE_RECOGNIZING = 'STATE_RECOGNIZING';
  static const String STATE_CONNECTING = 'STATE_CONNECTING';
  static const String STATE_CONNECTED = 'STATE_CONNECTED';
  static const String STATE_DISCONNECTED = 'STATE_DISCONNECTED';
  static const String STATE_CONNECTING_FAILED = 'STATE_CONNECTING_FAILED';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.location.request().isGranted &&
        await Permission.bluetooth.request().isGranted &&
    await Permission.bluetoothConnect.request().isGranted
    ) {
      initBluetoothConfig();
      listentoDeviceData();
    } else {
      // Handle permission denial
      print("Location permission is required for Bluetooth scanning");
    }
  }

  Future<void> initBluetoothConfig() async {
    try {
      await _bluetoothAdvanced.setServiceCharactersticUUID("46409BE5-6967-4557-8E70-784E1E55263B");
      await _bluetoothAdvanced.setDataCharactersticUUID("720330F4-1DB7-4FD7-AE5A-87E5BD942880");
      await _bluetoothAdvanced.setScanPeriod(10000);
      await _bluetoothAdvanced.setNotificationText("new text");
      await _bluetoothAdvanced.setNotificationTitle("new title");
    } catch (e) {
      print(e.toString());
    }
  }

  void listentoDeviceData() {
    _bluetoothAdvanced.listenData().listen((event) {
      if (event.startsWith(DEVICE_GATT_AVAILABLE)) {
        setState(() {
          isData = true;
          data = event.toString();
        });
      }
      switch (event) {
        case DEVICE_GATT_INITIATED:
        case DEVICE_GATT_CONNECTING:
        case DEVICE_GATT_CONNECTED:
        case DEVICE_GATT_DISCONNECTED:
          setState(() {
            isData = false;
            isConnected = false;
          });
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Object>(
              stream: _bluetoothAdvanced.scanDevices(),
              builder: (BuildContext context, AsyncSnapshot<Object> snapshot) {
                if (snapshot.hasError) {
                  return showError(snapshot.error);
                } else if (snapshot.hasData) {
                  if (snapshot.data.toString() == SCANNING_FINISHED_WITH_NO_DEVICE) {
                    return deviceNotFound();
                  } else {
                    List<String> device = snapshot.data.toString().split(",");
                    if (!deviceList.contains(device[0])) {
                      deviceList.add(device[0]);
                    }
                    return deviceListFound();
                  }
                } else {
                  return deviceScanning();
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _bluetoothAdvanced.dispose();
            },
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Widget showError(Object? error) {
    String errorMessage = 'Some Error Encountered';
    if (error is PlatformException) {
      errorMessage = error.code;
    } else {
      errorMessage = error.toString();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Error:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(errorMessage, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget deviceScanning() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Row(
          children: const [
            Text("scanning devices", style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            SizedBox(width: 12),
            SizedBox(height: 22, width: 22, child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }

  Widget deviceNotFound() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("No Device found, Retry",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                "Troubleshoot: \n ► Try increasing the scan period.\n ► Check if the device is paired in bluetooth settings.\n ► Check if paired device has correct configurations like UUIDs",
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget deviceListFound() {
    return ListView.builder(
      itemCount: deviceList.length,
      itemBuilder: (context, index) {
        String device = deviceList[index];
        return ListTile(
          title: Text(device),
          onTap: () {
            _bluetoothAdvanced.connectDevice().listen((event) {
              switch (event.toString()) {
                case STATE_CONNECTING:
                  print('Connecting to $device');
                  break;
                case STATE_CONNECTED:
                  setState(() {
                    isConnected = true;
                  });
                  print('Connected to $device');
                  break;
                case STATE_DISCONNECTED:
                  setState(() {
                    isConnected = false;
                  });
                  print('Disconnected from $device');
                  break;
                default:
              }
            });
          },
        );
      },
    );
  }
}
