/*import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fw_demo/models/cipherInventory.dart';
import 'package:fw_demo/models/inventory.dart';
import 'package:fw_demo/models/selectedItemlist.dart';
import 'package:fw_demo/utils/bluetooth_manager.dart';
import 'package:provider/provider.dart';
import '../models/Inventory.dart';
import '../models/listedItem.dart';
import '../providers/inventory_provider.dart';
import '../services/api_services.dart';
import '../models/list.dart';
import '../utils/cam_scan_utility.dart';
import '../utils/reconcilation_util.dart';
import '../utils/sharedprefutils.dart';
import '../utils/slidingbar.dart';
import 'productdetails.dart';

class ListsPage extends StatefulWidget {
  final String serverAddress;

  const ListsPage({Key? key, required this.serverAddress}) : super(key: key);

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  late ApiService _apiService;
  List<ItemList> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: widget.serverAddress);
    _fetchLists();
  }

  Future<void> _fetchLists() async {
    try {
      List<ItemList> lists = await _apiService.getAllLists();
      setState(() {
        _lists = lists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching lists: $e');
    }
  }

  Future<void> _createList(String listName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String deviceName = await SharedPreferencesUtil.getDeviceName() ?? 'Unknown Device';

      ItemList newList = ItemList(
        listId: 0, // This will be set by the server
        userName: deviceName, // Replace with actual user name
        customerId: null,
        dateCreated: DateTime.now(),
        listName: listName,
      );
      await _apiService.createList(newList);
      await _fetchLists();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error creating list: $e');
    }
  }

  Future<void> _clearList(int listId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _apiService.clearList(listId);
      await _fetchLists();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error clearing list: $e');
    }
  }

  void _showCreateListDialog() {
    final TextEditingController _listNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New List'),
          content: TextField(
            controller: _listNameController,
            decoration: InputDecoration(hintText: 'List Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _createList(_listNameController.text);
                Navigator.pop(context);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showListItems(ItemList list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListItemsPage(
          serverAddress: widget.serverAddress,
          list: list,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _lists.length,
        itemBuilder: (context, index) {
          final list = _lists[index];
          return ListTile(
            title: Text(list.listName),
            subtitle: Text('Created by ${list.userName} on ${list.dateCreated}'),
            onTap: () => _showListItems(list),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _clearList(list.listId);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fw_demo/models/cipherInventory.dart';
import 'package:fw_demo/models/inventory.dart';
import 'package:fw_demo/models/selectedItemlist.dart';
import 'package:fw_demo/utils/bluetooth_manager.dart';
import 'package:provider/provider.dart';
import '../models/Inventory.dart';
import '../models/listedItem.dart';
import '../providers/inventory_provider.dart';
import '../services/api_services.dart';
import '../models/list.dart';
import '../utils/cam_scan_utility.dart';
import '../utils/reconcilation_util.dart';
import '../utils/sharedprefutils.dart';
import '../utils/slidingbar.dart';
import 'productdetails.dart';

class ListsPage extends StatefulWidget {
  final String serverAddress;

  const ListsPage({Key? key, required this.serverAddress}) : super(key: key);

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  late ApiService _apiService;
  List<ItemList> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: widget.serverAddress);
    _fetchLists();
  }

  Future<void> _fetchLists() async {
    try {
      List<ItemList> lists = await _apiService.getAllLists();
      setState(() {
        _lists = lists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching lists: $e');
    }
  }

  Future<void> _createList(String listName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String deviceName = await SharedPreferencesUtil.getDeviceName() ?? 'Unknown Device';

      ItemList newList = ItemList(
        listId: 0, // This will be set by the server
        userName: deviceName, // Replace with actual user name
        customerId: null,
        dateCreated: DateTime.now(),
        listName: listName,
      );
      await _apiService.createList(newList);
      await _fetchLists();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error creating list: $e');
    }
  }

  Future<void> _clearList(int listId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _apiService.clearList(listId);
      await _fetchLists();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error clearing list: $e');
    }
  }

  void _showCreateListDialog() {
    final TextEditingController _listNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Create New List', style: TextStyle(color: Colors.blueAccent)),
          content: TextField(
            controller: _listNameController,
            decoration: InputDecoration(
              hintText: 'List Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                _createList(_listNameController.text);
                Navigator.pop(context);
              },
              child: Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showListItems(ItemList list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListItemsPage(
          serverAddress: widget.serverAddress,
          list: list,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Lists', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _lists.length,
          itemBuilder: (context, index) {
            final list = _lists[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text(list.listName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Created by ${list.userName} on ${list.dateCreated}'),
                onTap: () => _showListItems(list),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _clearList(list.listId);
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
/*
class ListItemsPage extends StatefulWidget {
  final String serverAddress;
  final ItemList list;

  const ListItemsPage({Key? key, required this.serverAddress, required this.list}) : super(key: key);

  @override
  _ListItemsPageState createState() => _ListItemsPageState();
}

class _ListItemsPageState extends State<ListItemsPage> {
  late ApiService _apiService;
  bool _isLoading = true;
  List<ListedItem> _listItems = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: widget.serverAddress);
    _fetchListItems();
  }

  Future<void> _fetchListItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<ListedItem> items = await _apiService.getAllListedItemsByID(widget.list.listId);
      setState(() {
        _listItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching list items: $e');
    }
  }

  Future<void> _updateItemQuantity(ListedItem item, int quantity) async {
    try {
      item.quantity = quantity;
      await _apiService.updateListedItem(item);
      setState(() {});
    } catch (e) {
      print('Error updating item quantity: $e');
    }
  }

  Future<void> _deleteItem(ListedItem item) async {
    try {
      SelectedItemList selectedItemList = SelectedItemList(
        listID: item.listId,
        itemNumber: [item.itemNumber],
      );
      await _apiService.clearSelectedItems(selectedItemList);
      setState(() {
        _listItems.remove(item);
      });
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  String truncate(String text, int length) {
    return text.length > length ? text.substring(0, length) : text;
  }


  Future<void> _reconcileItems(int listid) async {
    try {
      List<CipherInventory> cipherItems = await createCipherInventoryList(_listItems, _apiService);

      await _apiService.addCipher(cipherItems);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Items reconciled successfully')),
      );

      await _apiService.clearList(listid);

      Navigator.pop(context);

    } catch (e) {
      print('Error reconciling items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reconciling items')),
      );
    }

  }

  void _showEditQuantityDialog(ListedItem item) {
    final TextEditingController _quantityController = TextEditingController(text: item.quantity?.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Quantity'),
          content: TextField(
            controller: _quantityController,
            decoration: InputDecoration(hintText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int? newQuantity = int.tryParse(_quantityController.text);
                if (newQuantity != null) {
                  _updateItemQuantity(item, newQuantity);
                }
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _handleScannedBarcode(String barcode) async {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final itemNumber = int.tryParse(barcode);
    //Inventory? item = inventoryProvider.getInventoryItemByNumber(itemNumber!) ;
    double? priceite = inventoryProvider.getInventoryItemByNumber(itemNumber!);
    if (itemNumber != null && inventoryProvider.containsItemNumber(itemNumber)) {
      ListedItem listedItem = ListedItem(listId: widget.list.listId, itemNumber: itemNumber, price: priceite!);
      await _apiService.addItemToList(listedItem);
      _fetchListItems();
      print("You are here");
      showSlidingBar(context, "Product added to list", isError: false);
    } else {
      showSlidingBar(context, 'Product not found', isError: true);
    }
  }

  void showSlidingBar(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SlidingBar(
          message: message,
          isError: isError,
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(Duration(milliseconds: 50), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      bluetoothManager.setCurrentPage("ListsPage", widget.list.listId);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Items in ${widget.list.listName}'),
        actions: [
          IconButton(onPressed: () async {
            String? barcode = await BarcodeScannerUtil.scanBarcode();
            if (barcode != null && barcode.isNotEmpty) {
              _handleScannedBarcode(barcode);
            }
          },icon: Icon(Icons.camera_alt_outlined))
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listItems.length,
              itemBuilder: (context, index) {
                final item = _listItems[index];
                return ListTile(
                  title: Text('Item ${item.itemNumber}'),
                  subtitle: Row(
                    children: [
                      Text('Quantity: ${item.quantity ?? 1}'),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditQuantityDialog(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(item),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(itemNumber: item.itemNumber),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {_reconcileItems(widget.list.listId);},
            child: Text('Reconcile'),
          ),
        ],
      ),
    );
  }
}
*/
class ListItemsPage extends StatefulWidget {
  final String serverAddress;
  final ItemList list;

  const ListItemsPage({Key? key, required this.serverAddress, required this.list}) : super(key: key);

  @override
  _ListItemsPageState createState() => _ListItemsPageState();
}

class _ListItemsPageState extends State<ListItemsPage> {
  late ApiService _apiService;
  bool _isLoading = true;
  List<ListedItem> _listItems = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: widget.serverAddress);
    _fetchListItems();

    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    bluetoothManager.setOnItemAddedCallback(_fetchListItems);
  }

  Future<void> _fetchListItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<ListedItem> items = await _apiService.getAllListedItemsByID(widget.list.listId);
      setState(() {
        _listItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching list items: $e');
    }
  }

  Future<void> _updateItemQuantity(ListedItem item, int quantity) async {
    try {
      item.quantity = quantity;
      await _apiService.updateListedItem(item);
      setState(() {});
    } catch (e) {
      print('Error updating item quantity: $e');
    }
  }

  Future<void> _deleteItem(ListedItem item) async {
    try {
      SelectedItemList selectedItemList = SelectedItemList(
        listID: item.listId,
        itemNumber: [item.itemNumber],
      );
      await _apiService.clearSelectedItems(selectedItemList);
      setState(() {
        _listItems.remove(item);
      });
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  String truncate(String text, int length) {
    return text.length > length ? '${text.substring(0, length)}...' : text;
  }

  Future<void> _reconcileItems(int listId) async {
    try {
      List<CipherInventory> cipherItems = await createCipherInventoryList(_listItems, _apiService);

      await _apiService.addCipher(cipherItems);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Items reconciled successfully')),
      );

      await _apiService.clearList(listId);

      Navigator.pop(context);
    } catch (e) {
      print('Error reconciling items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reconciling items')),
      );
    }
  }

  void _showEditQuantityDialog(ListedItem item) {
    final TextEditingController _quantityController = TextEditingController(text: item.quantity?.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Edit Quantity', style: TextStyle(color: Colors.blueAccent)),
          content: TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              hintText: 'Quantity',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                int? newQuantity = int.tryParse(_quantityController.text);
                if (newQuantity != null) {
                  _updateItemQuantity(item, newQuantity);
                }
                Navigator.pop(context);
              },
              child: Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleScannedBarcode(String barcode) async {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final itemNumber = int.tryParse(barcode);
    double? priceitem = inventoryProvider.getInventoryItemByNumber(itemNumber!);
    if (itemNumber != null ) {
      ListedItem listedItem = ListedItem(listId: widget.list.listId, itemNumber: itemNumber, price: priceitem!);
      await _apiService.addItemToList(listedItem);
      _fetchListItems();
      showSlidingBar(context, "Product added to list", isError: false);
    } else {
      showSlidingBar(context, 'Product not found', isError: true);
    }
  }

  void showSlidingBar(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SlidingBar(
          message: message,
          isError: isError,
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      bluetoothManager.setCurrentPage("ListsPage", widget.list.listId);
    });


    return Scaffold(
      appBar: AppBar(
        title: Text('Items in ${widget.list.listName}', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () async {
              String? barcode = await BarcodeScannerUtil.scanBarcode();
              if (barcode != null && barcode.isNotEmpty) {
                _handleScannedBarcode(barcode);
              }
            },
            icon: Icon(Icons.camera_alt_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _listItems.length,
                itemBuilder: (context, index) {
                  final item = _listItems[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text('Item ${item.itemNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Quantity: ${item.quantity ?? 1}'),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () => _showEditQuantityDialog(item),
                          ),

                        Text('Price: \$ ${item.price}',textAlign: TextAlign.left,),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteItem(item),
                          ),
                        ],
                        
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(itemNumber: item.itemNumber),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _reconcileItems(widget.list.listId),
              child: Text('Reconcile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

