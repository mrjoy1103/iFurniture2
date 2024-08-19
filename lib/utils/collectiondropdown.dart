import 'package:flutter/material.dart';

class CollectionDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;

  const CollectionDropdown({
    Key? key,
    required this.selectedItems,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _CollectionDropdownState createState() => _CollectionDropdownState();
}

class _CollectionDropdownState extends State<CollectionDropdown> {
  late Future<List<String>> _collectionsFuture;
  late List<String> _allCollections;
  late List<String> _filteredCollections;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _loadCollections();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<String>> _loadCollections() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    // Replace with actual data fetching logic
    final collections = await fetchCollections(); // Your API call or data provider method
    setState(() {
      _allCollections = collections;
      _filteredCollections = collections;
    });
    return collections;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCollections = _allCollections
          .where((collection) => collection.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _collectionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No collections available');
        }

        return Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Collections',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCollections.length,
                itemBuilder: (context, index) {
                  final collection = _filteredCollections[index];
                  final isSelected = widget.selectedItems.contains(collection);
                  return ListTile(
                    title: Text(collection),
                    trailing: isSelected ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          widget.selectedItems.remove(collection);
                        } else {
                          widget.selectedItems.add(collection);
                        }
                        widget.onSelectionChanged(widget.selectedItems);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<List<String>> fetchCollections() async {
  // Your data fetching logic here
  // For demonstration, returning a static list
  return ['Collection 1', 'Collection 2', 'Collection 3', 'Collection 4'];
}

// Usage within your filter dialog
Widget _buildMultiSelectDropdown(BuildContext context,
    {required String title,
      required List<String> selectedItems,
      required ValueChanged<List<String>> onSelectionChanged}) {
  return ListTile(
    title: Text(title),
    trailing: Icon(Icons.arrow_drop_down),
    onTap: () async {
      final List<String>? selected = await showDialog<List<String>>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: CollectionDropdown(
              selectedItems: selectedItems,
              onSelectionChanged: onSelectionChanged,
            ),
          );
        },
      );

      if (selected != null) {
        onSelectionChanged(selected);
      }
    },
  );
}
