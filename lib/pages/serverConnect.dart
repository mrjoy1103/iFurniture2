import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fw_demo/services/api_services.dart';
import 'package:fw_demo/models/device.dart';
import 'package:fw_demo/utils/routes.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/filter_criteria.dart';

class ServerAddressPage extends StatefulWidget {
  @override
  _ServerAddressPageState createState() => _ServerAddressPageState();
}

class _ServerAddressPageState extends State<ServerAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverAddressController = TextEditingController();
  final _deviceNameController = TextEditingController();
  String? _savedAddress;
  String? _savedDeviceName;
  bool _isLoading = false;
  String? _errorMessage;
  String? _deviceIP;
  int? _deviceID;
  String? _deviceName;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    //_getDeviceInfo();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getDeviceInfo();
  }
  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedAddress = prefs.getString('server_address');
      _savedDeviceName = prefs.getString('device_name');
      if (_savedAddress != null) {
        _serverAddressController.text = _savedAddress!.replaceAll('http://', '').replaceAll(':9000', '');
      }
      if (_savedDeviceName != null) {
        _deviceNameController.text = _savedDeviceName!;
      }
    });
  }

  Future<void> _saveData(String address, String deviceName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_address', address);
    await prefs.setString('device_name', deviceName);
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _deviceName = androidInfo.model ?? 'Unknown Android Device';
          _deviceID = androidInfo.id.hashCode;
          _deviceIP = '10.0.2.2'; // Use special IP for Android emulator
        });
        print('Android Device Info: name=$_deviceName, id=$_deviceID, ip=$_deviceIP');
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        setState(() {
          _deviceName = iosInfo.name ?? 'Unknown iOS Device';
          _deviceID = iosInfo.identifierForVendor?.hashCode ?? 0;
          _deviceIP = '127.0.0.1'; // Use localhost for iOS simulator
        });
        print('iOS Device Info: name=$_deviceName, id=$_deviceID, ip=$_deviceIP');
      } else {
        setState(() {
          _deviceIP = '127.0.0.1'; // Default to localhost
          _deviceName = 'Unknown Device';
          _deviceID = DateTime.now().millisecondsSinceEpoch; // Generate a unique ID based on current time
        });
        print('Other Device Info: name=$_deviceName, id=$_deviceID, ip=$_deviceIP');
      }
    } catch (e) {
      print('Error retrieving device info: $e');
      setState(() {
        _deviceName = 'Unknown Device';
        _deviceID = DateTime.now().millisecondsSinceEpoch;
        _deviceIP = '127.0.0.1'; // Default fallback IP
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final serverAddress = 'http://${_serverAddressController.text.trim()}:9000';
      final deviceName = _deviceNameController.text.trim();
      await _saveData(serverAddress, deviceName);

      ApiService apiService = ApiService(baseUrl: serverAddress);
      bool isConnected = await apiService.checkServerConnection();
      if (isConnected) {
        // Ensure device information is not null
        if (_deviceName != null && _deviceIP != null) {
          // Log device information
          print('Device Info in submit: name=$_deviceName, ip=$_deviceIP');

          Device device = Device(
            deviceName: _deviceName!,
            deviceIP: _deviceIP!,
          );

          bool deviceAdded = await apiService.addDevice(device);
          setState(() {
            _isLoading = false;
          });

          if (deviceAdded) {
            Navigator.pushNamed(
              context,
              MyRoutes.loginRoute,
              arguments: {'serverAddress': serverAddress},
            );
          } else {
            setState(() {
              _errorMessage = 'Failed to add device. Please check the details.';
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to retrieve device information.';
            print('Device Info is null: name=$_deviceName, ip=$_deviceIP');
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to connect to server. Please check the address.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Server Address'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/fw_logo.png', height: 150), // Ensure the image exists in assets
              const SizedBox(height: 20),
              const Text(
                'Welcome! Please enter your IP address and device name.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        //const Text('http://'),
                        Expanded(
                          child: TextFormField(
                            controller: _serverAddressController,
                            decoration: const InputDecoration(
                              hintText: 'Enter IP address',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the IP address';
                              }
                              // Additional validation for IP address can be added here
                              return null;
                            },
                          ),
                        ),
                        //const Text(':9000'),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _deviceNameController,
                      decoration: const InputDecoration(
                        labelText: 'Device Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the device name';
                        }
                        else
                          {
                            _deviceName = value;
                          }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
