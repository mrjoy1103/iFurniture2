import 'package:flutter/material.dart';
import '../models/listedItem.dart';
import '../models/list.dart';
import '../services/api_services.dart';
import 'package:fw_demo/utils/sharedprefutils.dart';

class AddToListDialog extends StatefulWidget {
  final int itemNumber;
  final double price;
  final String serverAddress;

  const AddToListDialog({
    super.key,
    required this.itemNumber,
    required this.price,
    required this.serverAddress,
  });

  @override
  _AddToListDialogState createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<AddToListDialog> {
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _newListNameController = TextEditingController();
  late ApiService _apiService;
  bool _isLoading = true;
  List<ItemList> _lists = [];
  String? _selectedListId;
  bool _isCreatingNewList = false;

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

  Future<void> _addItemToList() async {
    setState(() {
      _isLoading = true;
    });














    try {
      String deviceName = await SharedPreferencesUtil.getDeviceName() ?? 'Unknown Device';
      int quantity = int.parse(_quantityController.text.trim());

      if (_isCreatingNewList) {
        String listName = _newListNameController.text.trim();

        // Create a new list
        ItemList newList = ItemList(
          listId: 0,
          userName: deviceName,
          customerId: null,
          dateCreated: DateTime.now(),
          listName: listName,
        );

        ItemList createdList = await _apiService.createList(newList);

        // Add item to the newly created list
        ListedItem newItem = ListedItem(
          listId: createdList.listId,
          itemNumber: widget.itemNumber,
          quantity: quantity,
          price: widget.price,
        );

        await _apiService.addItemToList(newItem);
      } else {
        // Add item to the selected list
        ListedItem newItem = ListedItem(
          listId: int.parse(_selectedListId!),
          itemNumber: widget.itemNumber,
          quantity: quantity,
          price: widget.price,
        );

        await _apiService.addItemToList(newItem);
      }

      Navigator.pop(context);
    } catch (e) {
      print('Error adding item to list: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to List'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isCreatingNewList)
              DropdownButton<String>(
                value: _selectedListId,
                hint: const Text('Select List'),
                onChanged: (value) {
                  setState(() {
                    _selectedListId = value;
                  });
                },
                items: _lists.map((list) {
                  return DropdownMenuItem(
                    value: list.listId.toString(),
                    child: Text(list.listName),
                  );
                }).toList(),
              ),
            if (_isCreatingNewList)
              TextField(
                controller: _newListNameController,
                decoration: const InputDecoration(hintText: 'New List Name'),
              ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(hintText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text('Create New List'),
              value: _isCreatingNewList,
              onChanged: (value) {
                setState(() {
                  _isCreatingNewList = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _addItemToList,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
