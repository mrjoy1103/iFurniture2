import 'package:flutter/material.dart';

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialSelectedItems;

  MultiSelectDialog({
    required this.title,
    required this.items,
    required this.initialSelectedItems,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            final isSelected = _selectedItems.contains(item);
            return ListTile(
              title: Text(item),
              trailing: isSelected ? Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedItems.remove(item);
                  } else {
                    _selectedItems.add(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, widget.initialSelectedItems);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedItems);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
