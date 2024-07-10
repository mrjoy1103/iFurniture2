import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/inventory.dart';
import '../models/filter_criteria.dart';
import '../services/api_services.dart';

class InventoryProvider with ChangeNotifier {
  List<Inventory> _originalInventory = [];
  List<Inventory> _inventory = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _page = 1;
  final int _pageSize = 20000;
  FilterCriteria _currentCriteria;
  String _baseUrl = '';
  double _loadingProgress = 0.0;

  List<String> _suppliers = [];
  List<String> _styles = [];
  List<String> _collections = [];
  Map<String, List<String>> _categoriesWithSubcategories = {};

  InventoryProvider(this._currentCriteria);

  List<Inventory> get inventory => _inventory;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  double get loadingProgress => _loadingProgress;
  List<String> get suppliers => _suppliers;
  List<String> get styles => _styles;
  List<String> get collections => _collections;
  Map<String, List<String>> get categoriesWithSubcategories => _categoriesWithSubcategories;



  Future<void> fetchInventory(String baseUrl, {bool isLoadingMore = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _baseUrl = baseUrl;
    if (!isLoadingMore) {
      _page = 1;
      _inventory = [];
      _originalInventory = [];
      _hasMoreData = true;
    }

    try {
      ApiService apiService = ApiService(baseUrl: baseUrl);
      FilterCriteria criteria = _currentCriteria.copyWith(pageNum: _page, pageSize: _pageSize);
      List<Inventory> newInventory = await apiService.getFilteredInventory(criteria);

      if (newInventory.isEmpty || newInventory.length < _pageSize) {
        _hasMoreData = false;
      }

      _inventory.addAll(newInventory);
      _originalInventory.addAll(newInventory);

      // Sort the original inventory list
      _originalInventory.sort((a, b) {
        int result = a.itemNumber.compareTo(b.itemNumber);
        if (result != 0) return result;
        return a.description.compareTo(b.description);
      });

      // Ensure the current inventory is also sorted
      _inventory = List.from(_originalInventory);

      _loadingProgress = _inventory.length / (_page * _pageSize);
      _page++;
    } catch (e) {
      print('Failed to load inventory: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> loadAllInventory() async {
    while (_hasMoreData) {
      await fetchInventory(_baseUrl, isLoadingMore: true);
      await Future.delayed(const Duration(milliseconds: 100)); // Non-blocking delay between page loads
    }
  }

  Future<void> fetchFilterData() async {
    try {
      ApiService apiService = ApiService(baseUrl: _baseUrl);
      _collections = await apiService.getAllCollections().then((data) => data.map((item) => item['collection'].toString()).toList());
      _suppliers = await apiService.getAllsuppliers().then((data) => data.map((item) => item['SupplierName'].toString()).toList());
      _styles = await apiService.getAllStyles().then((data) => data.map((item) => item['style'].toString()).toList());
      _categoriesWithSubcategories = await apiService.getAllCategories().then((data) {
        Map<String, List<String>> categories = {};
        for (var category in data) {
          String categoryName = category['category'];
          List<String> subCategories = (category['subCategory'] as List).map((sub) => sub['Size'].toString()).toList();
          categories[categoryName] = subCategories;
        }
        return categories;
      });
    } catch (e) {
      print('Failed to fetch filter data: $e');
    }
    _safeNotifyListeners();
  }

  void searchInventory(String query) {
    if (query.isEmpty) {
      _inventory = List.from(_originalInventory);
    } else {
      List<Inventory> searchResults = [];
      searchResults.addAll(_originalInventory.where((item) => item.itemNumber.toString().contains(query)));
      searchResults.addAll(_originalInventory.where((item) =>
      !searchResults.contains(item) &&
          item.description.toLowerCase().contains(query.toLowerCase())));

      _inventory = searchResults;
    }
    // Debug print after search
    print('Search results count: ${_inventory.length}');
    _safeNotifyListeners();
  }

  Future<void> updateFilterCriteria(FilterCriteria criteria) async{
    _currentCriteria = criteria;
    await _applyFilters();
    _isLoading = false;
  }

  Future<void> _applyFilters() async {
    _inventory = _originalInventory.where((item) {
      // Filter by availability (existing logic)
      if (_currentCriteria.availability == 1 && !item.branchInventory.any((branch) => branch.inStock > 0)) {
        print('Excluding item due to availability (In Stock): ${item.itemNumber}');
        return false;
      }
      if (_currentCriteria.availability == 2 && !item.branchInventory.any((branch) => branch.onOrder > 0)) {
        print('Excluding item due to availability (On Order): ${item.itemNumber}');
        return false;
      }
      if (_currentCriteria.availability == 3 && !item.branchInventory.any((branch) => branch.available > 0)) {
        print('Excluding item due to availability (Available): ${item.itemNumber}');
        return false;
      }

      // Filter by supplier
      if (_currentCriteria.supplier.isNotEmpty && !_currentCriteria.supplier.contains(item.supplier.supplierName)) {
        print('Excluding item due to supplier: ${item.itemNumber}');
        return false;
      }

      // Filter by style
      if (_currentCriteria.style.isNotEmpty && !_currentCriteria.style.contains(item.style)) {
        print('Excluding item due to style: ${item.itemNumber}');
        return false;
      }

      // Filter by collection
      if (_currentCriteria.collection.isNotEmpty && !_currentCriteria.collection.contains(item.collection.collection)) {
        print('Excluding item due to collection: ${item.itemNumber}');
        return false;
      }

      // Filter by category
      if (_currentCriteria.category.isNotEmpty && !_currentCriteria.category.contains(item.category)) {
        print('Excluding item due to category: ${item.itemNumber}');
        return false;
      }
      if (_currentCriteria.subCategory.isNotEmpty && !_currentCriteria.subCategory.contains(item.subCategory)) {
        print('Excluding item due to subCategory: ${item.itemNumber}');
        return false;
      }

      // Filter by text
      if (_currentCriteria.textFilter.isNotEmpty && !item.description.toLowerCase().contains(_currentCriteria.textFilter.toLowerCase())) {
        print('Excluding item due to textFilter: ${item.itemNumber}');
        return false;
      }

      // Filter by packages only
      // if (_currentCriteria.packagesOnly && !item.isPackage) {
      //   print('Excluding item due to packagesOnly: ${item.itemNumber}');
      //   return false;
      // }

      return true;
    }).toList();

    // Debug print after filtering
    print('Filtered inventory count: ${_inventory.length}');

    // Sorting logic (existing)
    _inventory.sort((a, b) {
      switch (_currentCriteria.sortby) {
        case 0: // A-Z
          return a.description.compareTo(b.description);
        case 1: // Z-A
          return b.description.compareTo(a.description);
        case 2: // Price Low to High
          return a.retail!.compareTo(b.retail as num);
        case 3: // Price High to Low
          return b.retail!.compareTo(a.retail as num);
        default:
          return 0;
      }
    });
    _isLoading = false;
    _safeNotifyListeners();
  }

  bool containsItemNumber(int itemNumber) {
    return _inventory.any((item) => item.itemNumber == itemNumber);
  }

  void _safeNotifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }
}
