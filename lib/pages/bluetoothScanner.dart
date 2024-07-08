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
    if (await Permission.location.request().isGranted) {
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
                    return deviceFound(device[0], device[1]);
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

  Widget deviceFound(String address, String name) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            isConnected
                ? const Icon(Icons.bluetooth_connected_rounded, color: Colors.green)
                : const Icon(Icons.bluetooth_rounded, color: Colors.grey),
            const SizedBox(width: 10),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(address, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                ]),
            const Spacer(),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      isConnected ? Colors.green : Colors.lightBlue),
                ),
                onPressed: () {
                  _bluetoothAdvanced.connectDevice().listen((event) {
                    switch (event.toString()) {
                      case STATE_RECOGNIZING:
                        break;
                      case STATE_CONNECTING:
                        break;
                      case STATE_CONNECTED:
                        setState(() {
                          isConnected = true;
                        });
                        break;
                      case STATE_DISCONNECTED:
                        setState(() {
                          isConnected = false;
                        });
                        break;
                      case STATE_CONNECTING_FAILED:
                        break;
                      default:
                    }
                  });
                },
                child: Text(
                  isConnected ? 'Connected' : 'Connect',
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                )),
          ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline_rounded, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              'Remember to turn on Bluetooth\nand GPS first',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(vertical: 20)),
              backgroundColor: MaterialStateProperty.all<Color>(
                  isConnected && isData ? Colors.cyan.shade900 : Colors.grey),
            ),
            onPressed: () async {
              await _bluetoothAdvanced.dispose();
            },
            child: const Icon(Icons.stop_circle)),
      ],
    );
  }
}
