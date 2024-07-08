class Device {
  String deviceName;
  String deviceIP;

  Device({
    required this.deviceName,
    required this.deviceIP,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceName: json['deviceName'],
      deviceIP: json['deviceIP'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'deviceIP': deviceIP,
    };
  }
}
