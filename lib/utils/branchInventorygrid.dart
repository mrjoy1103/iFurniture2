import 'package:flutter/material.dart';
import '../models/branch_inventory.dart';

class BranchInventoryGrid extends StatelessWidget {
  final List<BranchInventory> branchInventory;
  final int itemNumber; // Change to itemNumber

  const BranchInventoryGrid({
    Key? key,
    required this.branchInventory,
    required this.itemNumber, // Change to itemNumber
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BranchInventory> regularBranchInventory = branchInventory
        .where((branch) => branch.branchID == 10 || branch.branchID == 20)
        .toList();
    List<BranchInventory> supplierInventory = branchInventory
        .where((branch) => branch.branchID != 10 && branch.branchID != 20)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Branch Inventory Details'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Branch Inventory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('In Stock')), // Remove modelNumber
                    DataColumn(label: Text('Available')),
                    DataColumn(label: Text('On Order')),
                  ],
                  rows: regularBranchInventory.map((branch) {
                    return DataRow(cells: [
                      DataCell(Text(branch.branchName)),
                      DataCell(Text(branch.inStock.toInt().toString())),
                      DataCell(Text(branch.available.toInt().toString())),
                      DataCell(Text(branch.onOrder.toInt().toString())),
                    ]);
                  }).toList(),
                ),
                if (supplierInventory.isNotEmpty  ) ...[
                  SizedBox(height: 20),
                  Text(
                    'Ashley Inventory',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DataTable(
                    columns: [
                      DataColumn(label: Text('Model')),
                      DataColumn(label: Text('$itemNumber')), // Use itemNumber
                    ],
                    rows: supplierInventory.map((branch) {
                      return DataRow(cells: [
                        DataCell(Text(branch.branchName)),
                        DataCell(Text(branch.inStock.toInt().toString())),
                      ]);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
