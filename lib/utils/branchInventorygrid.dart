import 'package:flutter/material.dart';
import '../models/branch_inventory.dart';

class BranchInventoryGrid extends StatelessWidget {
  final List<BranchInventory> branchInventory;
  final int itemNumber; // Change to itemNumber

  const BranchInventoryGrid({
    super.key,
    required this.branchInventory,
    required this.itemNumber, // Change to itemNumber
  });

  @override
  Widget build(BuildContext context) {
    int supplierStartIndex = branchInventory.indexWhere((branch) => branch.branchName.startsWith('Today'));

    // If there is no such branch, set supplierStartIndex to the length of the list (i.e., no supplier inventory)
    if (supplierStartIndex == -1) {
      supplierStartIndex = branchInventory.length;
    }

    // Split the list into regular and supplier inventory based on the found index
    List<BranchInventory> regularBranchInventory = branchInventory.sublist(0, supplierStartIndex);
    List<BranchInventory> supplierInventory = branchInventory.sublist(supplierStartIndex);


    List<String> supplierBranchNames = supplierInventory.map((branch) => branch.branchName).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Inventory Details'),
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
                const Text(
                  'Branch Inventory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('In Stock')),
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
                if (supplierInventory.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Ashley Inventory',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        const DataColumn(label: Text('Model')),
                        //DataColumn(label: Text('$itemNumber')),
                        ...supplierBranchNames.map((branchName) => DataColumn(label: Text(branchName))),
                      ],
                      rows: [
                        DataRow(cells: [
                          //DataCell(Text('Model')),
                          DataCell(Text('$itemNumber')),
                          ...supplierBranchNames.map((branchName) {
                            BranchInventory? branch = supplierInventory.firstWhere((b) => b.branchName == branchName);
                            return DataCell(Text(branch.inStock.toInt().toString()));
                          }),
                        ]),
                      ],
                    ),
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
