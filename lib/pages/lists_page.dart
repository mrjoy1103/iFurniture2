import 'package:flutter/material.dart';
import 'package:fw_demo/models/cipherInventory.dart';
import 'package:fw_demo/models/selectedItemlist.dart';
import '../models/listedItem.dart';
import '../services/api_services.dart';
import '../models/list.dart';
import '../utils/reconcilation_util.dart';
import '../utils/sharedprefutils.dart';
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
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items in ${widget.list.listName}'),
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
