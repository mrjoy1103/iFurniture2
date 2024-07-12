import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:fw_demo/pages/menuPage.dart';

class LoadingPage extends StatefulWidget {
  final String serverAddress;

  LoadingPage({required this.serverAddress});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    InventoryProvider inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    if (inventoryProvider.inventory.isEmpty) {
      await inventoryProvider.fetchInventory(widget.serverAddress); // Ensure initial fetch
      await inventoryProvider.loadAllInventory();
      await inventoryProvider.fetchFilterData();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      /*appBar: AppBar(
        title: Text(''),
      ),*/
      body: Center(
        child: Consumer<InventoryProvider>(
          builder: (context, inventoryProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Loading data, please be patient...',
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: screenWidth * 0.8,
                  child: LinearProgressIndicator(
                    value: inventoryProvider.loadingProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  '${(inventoryProvider.loadingProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
