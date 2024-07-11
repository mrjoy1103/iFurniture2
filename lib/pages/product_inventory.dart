import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory.dart';
import '../providers/inventory_provider.dart';
import '../models/filter_criteria.dart';
import '../utils/filterdialog.dart';
import 'productdetails.dart';

class ProductInventoryPage extends StatefulWidget {
  final String serverAddress;

  const ProductInventoryPage({super.key, required this.serverAddress});

  @override
  _ProductInventoryPageState createState() => _ProductInventoryPageState();
}

class _ProductInventoryPageState extends State<ProductInventoryPage> {
  late InventoryProvider _inventoryProvider;
  final TextEditingController _searchController = TextEditingController();
  FilterCriteria _currentCriteria = FilterCriteria(
    pageSize: 5000,
    pageNum: 1,
    style: [],
    availability: 0,
    sortby: 0,
    collection: [],
    set: 0,
    category: [],
    supplier: [],
    textFilter: '',
    subCategory: [],
  );

  @override
  void initState() {
    super.initState();
    _inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    if (_inventoryProvider.inventory.isEmpty) {
      _inventoryProvider = InventoryProvider(_currentCriteria);
      _inventoryProvider.fetchInventory(widget.serverAddress);
      _inventoryProvider.loadAllInventory();
    }

    _searchController.addListener(() {
      _inventoryProvider.searchInventory(_searchController.text);
    });
  }

  void _clearFilters() {
    setState(() {
      _currentCriteria = FilterCriteria(
        pageSize: 5000,
        pageNum: 1,
        style: [],
        availability: 0,
        sortby: 0,
        collection: [],
        set: 0,
        category: [],
        supplier: [],
        textFilter: '',
        subCategory: [],
      );
    });
    _inventoryProvider.updateFilterCriteria(_currentCriteria);
  }

  Future<void> _openFilterDialog() async {
    bool isLoading = false;

    final FilterCriteria? newCriteria = await showDialog<FilterCriteria>(
      context: context,
      builder: (context) {
        FilterCriteria tempCriteria = _currentCriteria;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Inventory'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (isLoading) Center(child: CircularProgressIndicator()),
                    FilterWidget(
                      criteria: tempCriteria,
                      onCriteriaChanged: (newCriteria) {
                        setState(() {
                          tempCriteria = newCriteria;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await _showLoadingDialog(context, () async {
                      await _inventoryProvider.updateFilterCriteria(tempCriteria);
                    });
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context, tempCriteria);
                  },
                  child: const Text('Apply'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempCriteria = FilterCriteria(
                        pageSize: 20000,
                        pageNum: 1,
                        style: [],
                        availability: 0,
                        sortby: 0,
                        collection: [],
                        set: 0,
                        category: [],
                        supplier: [],
                        subCategory: [], // Clear subcategories
                        textFilter: '',
                      );
                    });
                    Navigator.pop(context, tempCriteria);
                  },
                  child: const Text('Clear Filters'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newCriteria != null) {
      setState(() {
        _currentCriteria = newCriteria;
      });
    }
  }

  Future<void> _showLoadingDialog(BuildContext context, Future<void> Function() asyncOperation) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading... Please wait'),
              ],
            ),
          ),
        );
      },
    );

    await asyncOperation();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return ChangeNotifierProvider<InventoryProvider>.value(
      value: _inventoryProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Inventory'),
          backgroundColor: Colors.white70,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilterDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _inventoryProvider.searchInventory('');
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                onChanged: (query) {
                  _inventoryProvider.searchInventory(query);
                },
              ),
            ),
            Expanded(
              child: Consumer<InventoryProvider>(
                builder: (context, inventoryProvider, child) {
                  if (inventoryProvider.isLoading && inventoryProvider.inventory.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: inventoryProvider.inventory.length + (inventoryProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == inventoryProvider.inventory.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final item = inventoryProvider.inventory[index];
                      bool inStock = item.branchInventory.any((branch) => branch.inStock > 0);
                      bool available = item.branchInventory.any((branch) => branch.available > 0);
                      bool onOrder = item.branchInventory.any((branch) => branch.onOrder > 0);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                itemNumber: item.itemNumber,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(flex: 1, child: Text(item.itemNumber.toString())),
                                Flexible(flex: 2, child: Text(item.description)),
                                Flexible(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Icon(Icons.circle, color: inStock ? Colors.blue : Colors.grey),
                                      Icon(Icons.circle, color: available ? Colors.green : Colors.grey),
                                      Icon(Icons.circle, color: onOrder ? Colors.red : Colors.grey),
                                    ],
                                  ),
                                ),
                                Flexible(flex: 1, child: Text('\$${item.retail?.toStringAsFixed(2) ?? 'N/A'}')),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
