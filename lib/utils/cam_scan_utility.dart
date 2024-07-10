import 'package:barcode_scan2/barcode_scan2.dart';

class BarcodeScannerUtil {
  static Future<String?> scanBarcode() async {
    var result = await BarcodeScanner.scan();
    return result.rawContent;
  }
}
