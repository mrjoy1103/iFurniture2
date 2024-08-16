import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/filter_criteria.dart';
import '../providers/inventory_provider.dart';
import 'package:fw_demo/utils/multiselectdialog.dart';

class FilterWidget extends StatefulWidget {
  final FilterCriteria criteria;
  final ValueChanged<FilterCriteria> onCriteriaChanged;

  const FilterWidget({
    super.key,
    required this.criteria,
    required this.onCriteriaChanged,
  });

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late FilterCriteria _tempCriteria;
  late InventoryProvider _inventoryProvider;

  @override
  void initState() {
    super.initState();
    _tempCriteria = widget.criteria;
    _inventoryProvider = context.read<InventoryProvider>();
  }

  Widget _buildMultiSelectDropdown({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onSelectionChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () async {
        final List<String>? selected = await showDialog<List<String>>(
          context: context,
          builder: (BuildContext context) {
            return MultiSelectDialog(
              title: title,
              items: items,
              initialSelectedItems: selectedItems,
            );
          },
        );

        if (selected != null) {
          onSelectionChanged(selected);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<int>(
          value: _tempCriteria.availability,
          onChanged: (value) {
            setState(() {
              _tempCriteria = _tempCriteria.copyWith(availability: value);
            });
            widget.onCriteriaChanged(_tempCriteria);
          },
          items: const [
            DropdownMenuItem(value: 0, child: Text('All')),
            DropdownMenuItem(value: 1, child: Text('In Stock')),
            DropdownMenuItem(value: 2, child: Text('On Order')),
            DropdownMenuItem(value: 3, child: Text('Available')),
          ],
        ),
        DropdownButton<int>(
          value: _tempCriteria.sortby,
          onChanged: (value) {
            setState(() {
              _tempCriteria = _tempCriteria.copyWith(sortby: value);
            });
            widget.onCriteriaChanged(_tempCriteria);
          },
          items: const [
            DropdownMenuItem(value: 0, child: Text('A-Z')),
            DropdownMenuItem(value: 1, child: Text('Z-A')),
            DropdownMenuItem(value: 2, child: Text('Price Low to High')),
            DropdownMenuItem(value: 3, child: Text('Price High to Low')),
          ],
        ),
        _buildMultiSelectDropdown(
          title: 'Supplier',
          items: _inventoryProvider.suppliers,
          selectedItems: _tempCriteria.supplier,
          onSelectionChanged: (selectedItems) {
            setState(() {
              _tempCriteria = _tempCriteria.copyWith(supplier: selectedItems);
            });
            widget.onCriteriaChanged(_tempCriteria);
          },
        ),
        _buildMultiSelectDropdown(
          title: 'Category',
          items: _inventoryProvider.categoriesWithSubcategories.keys.toList(),
          selectedItems: _tempCriteria.category,
          onSelectionChanged: (selectedItems) {
            setState(() {
              _tempCriteria = _tempCriteria.copyWith(category: selectedItems, subCategory: []);
            });
            widget.onCriteriaChanged(_tempCriteria);
          },
        ),
        _buildMultiSelectDropdown(
          title: 'Subcategory',
          items: _tempCriteria.category.isEmpty
              ? []
              : _inventoryProvider.categoriesWithSubcategories[_tempCriteria.category.first] ?? [],
          selectedItems: _tempCriteria.subCategory,
          onSelectionChanged: (selectedItems) {
            setState(() {
              _tempCriteria = _tempCriteria.copyWith(subCategory: selectedItems);
            });
            widget.onCriteriaChanged(_tempCriteria);
          },
        ),
        _buildMultiSelectDropdown(
          title: 'Collection',
          items: _inventoryProvider.collections,
          selectedItems: _tempCriteria.collection,
          onSelectionChanged: (selectedItems) {
            setState(() {
              _tempCriteria = _tempCriteria.copyWith(collection: selectedItems);
            });
            widget.onCriteriaChanged(_tempCriteria);
          },
        ),
        _buildMultiSelectDropdown(
          title: 'Style',
          items: _inventoryProvider.styles,
          selectedItems: _tempCriteria.style,
          onSelectionChanged: (selectedItems) {
            setState(() {
              _tempCriteria = _tempCriteria.copyWith(style: selectedItems);
            });
            widget.onCriteriaChanged(_tempCriteria);
          },
        ),
      ],
    );
  }
}
