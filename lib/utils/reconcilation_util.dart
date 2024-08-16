
import 'package:fw_demo/models/cipherInventory.dart';
import 'package:fw_demo/models/listedItem.dart';
import 'package:fw_demo/services/api_services.dart';
import 'package:fw_demo/utils/sharedprefutils.dart';
import '../models/inventory.dart';


Future<List<CipherInventory>> createCipherInventoryList(List<ListedItem> listItems, ApiService apiService) async {
  List<CipherInventory> cipherItems = [];
  String userName = await SharedPreferencesUtil.getDeviceName() ?? 'Unknown Device';

  for (var item in listItems) {
    Inventory inventoryDetails = await fetchInventoryDetails(item.itemNumber, apiService);

    CipherInventory cipherItem = CipherInventory(
      id: 0,
      itemNumber: item.itemNumber.toInt(),
      cipherDate: '',
      qty: item.quantity ?? 1,
      dateTime: DateTime.now(),
      ipAddress: '0.0.0.0', // Update with actual IP address
      application: -1,
      upc: '', // Assuming UPC is not available, adjust as needed
      supplier: truncate(inventoryDetails.supplier.supplierName, 50),
      description: truncate(inventoryDetails.description, 255),
      price: item.price,
      poNumber: '',
      lineNumber: null,
      userName: truncate(userName, 50),
      serialNumber: '',
    );

    cipherItems.add(cipherItem);
  }

  return cipherItems;
}

Future<Inventory> fetchInventoryDetails(int itemNumber, ApiService apiService) async {
  String? serverAddress = await SharedPreferencesUtil.getServerAddress();
  if (serverAddress == null) {
    throw Exception('Server address not found in SharedPreferences');
  }
  return await apiService.getProductByNumber(itemNumber);
}

String truncate(String text, int length) {
  return text.length > length ? text.substring(0, length) : text;
}
