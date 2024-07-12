import 'package:flutter/material.dart';
import 'package:fw_demo/pages/menuPage.dart';
import 'package:fw_demo/providers/inventory_provider.dart';
import 'package:fw_demo/utils/addToList.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/inventory.dart';
import '../models/inventory_images.dart';
import '../models/branch_inventory.dart';
import '../services/api_services.dart';
import '../utils/cam_scan_utility.dart';
import '../utils/sharedprefutils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fw_demo/utils/relateditemswidget.dart';
import 'package:fw_demo/utils/collectionitemswidget.dart';
import 'package:fw_demo/utils/branchInventorygrid.dart';
import '../utils/slidingbar.dart';
import 'barcodecamerascan.dart';

class ProductDetailsPage extends StatefulWidget {
  final int itemNumber;

  const ProductDetailsPage({Key? key, required this.itemNumber}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<Inventory> _futureProduct;
  late Future<List<ItemImage>> _futureImages;
  late Future<List<BranchInventory>> _futureBranchInventory;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeFutures();
  }

  void _initializeFutures() {
    _futureProduct = _fetchProductDetails(widget.itemNumber);
    _futureImages = _fetchProductImages(widget.itemNumber);
    _futureBranchInventory = _fetchBranchInventory(widget.itemNumber);
  }

  Future<Inventory> _fetchProductDetails(int itemNumber) async {
    try {
      String? serverAddress = await SharedPreferencesUtil.getServerAddress();
      if (serverAddress == null) {
        throw Exception('Server address not found in SharedPreferences');
      }
      print('Server Address: $serverAddress');
      ApiService apiService = ApiService(baseUrl: serverAddress);
      Inventory product = await apiService.getProductByNumber(itemNumber);
      print('Fetched product details: ${product.description}');
      return product;
    } catch (e) {
      print('Error fetching product details: $e');
      throw e;
    }
  }

  Future<List<ItemImage>> _fetchProductImages(int itemNumber) async {
    try {
      String? serverAddress = await SharedPreferencesUtil.getServerAddress();
      if (serverAddress == null) {
        throw Exception('Server address not found in SharedPreferences');
      }
      print('Server Address: $serverAddress');
      ApiService apiService = ApiService(baseUrl: serverAddress);
      List<ItemImage> images = await apiService.getImagesByItemNumber(itemNumber);
      print('Fetched product images: ${images.length}');
      return images;
    } catch (e) {
      print('Error fetching product images: $e');
      throw e;
    }
  }

  Future<List<BranchInventory>> _fetchBranchInventory(int itemNumber) async {
    try {
      String? serverAddress = await SharedPreferencesUtil.getServerAddress();
      if (serverAddress == null) {
        throw Exception('Server address not found in SharedPreferences');
      }
      print('Server Address: $serverAddress');
      ApiService apiService = ApiService(baseUrl: serverAddress);
      List<BranchInventory> branchInventory = await apiService.getBranchInventory(itemNumber);
      print('Fetched branch inventory: ${branchInventory.length}');
      return branchInventory;
    } catch (e) {
      print('Error fetching branch inventory: $e');
      throw e;
    }
  }

  void _onStatusCircleTap(String label, String modelNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<BranchInventory>>(
          future: _futureBranchInventory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No inventory data available'));
            }

            return BranchInventoryGrid(
              branchInventory: snapshot.data!,
              itemNumber: widget.itemNumber,  // Pass the model number here
            );
          },
        );
      },
    );
  }

  Widget _buildStatusCircle(String label, Color color, int count, String modelNumber) {
    return GestureDetector(
      onTap: () => _onStatusCircleTap(label, modelNumber),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,  // Increased size
            backgroundColor: color,
            child: Text(
              label,
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScannedBarcode(String barcode) async {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final itemNumber = int.tryParse(barcode);

    if (itemNumber != null && inventoryProvider.containsItemNumber(itemNumber)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(itemNumber: itemNumber),
        ),
      );
    } else {
      showSlidingBar(context, 'Product not found', isError: true);
    }
  }

  void showSlidingBar(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SlidingBar(
          message: message,
          isError: isError,
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MenuPage()),
              );
            },
            icon: Icon(Icons.menu),
          ),
          IconButton(onPressed: () async {
            String? barcode = await BarcodeScannerUtil.scanBarcode();
            if (barcode != null && barcode.isNotEmpty) {
              _handleScannedBarcode(barcode);
            }
          },icon: Icon(Icons.camera_alt_outlined))
        ],
      ),
      body: FutureBuilder<Inventory>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Snapshot error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Product not found'));
          }

          Inventory product = snapshot.data!;
          double inStockCount = product.branchInventory.fold(0, (sum, branch) => sum + branch.inStock);
          double availableCount = product.branchInventory.fold(0, (sum, branch) => sum + branch.available);
          double onOrderCount = product.branchInventory.fold(0, (sum, branch) => sum + branch.onOrder);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.retail?.toStringAsFixed(2) ?? 'N/A'}',
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<ItemImage>>(
                    future: _futureImages,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print('Snapshot error: ${snapshot.error}');
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No images available'));
                      }

                      List<ItemImage> images = snapshot.data!;
                      return Column(
                        children: [
                          Container(
                            height: 300,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child: Image.memory(
                                        base64Decode(images[index].imageBase64),
                                        fit: BoxFit.contain,
                                        height: 300,
                                        width: MediaQuery.of(context).size.width - 32, // Adjust for padding
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: images.length,
                            effect: WormEffect(
                              dotHeight: 8.0,
                              dotWidth: 8.0,
                              activeDotColor: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Item Number:', product.itemNumber.toString()),
                  _buildDetailRow('Supplier:', product.supplier.supplierName),
                  _buildDetailRow('Category:', product.category),
                  _buildDetailRow('Model:', product.model),
                  _buildDetailRow('Subcategory:', product.subCategory),
                  _buildDetailRow('Collection:', product.collection.collection),
                  _buildDetailRow('Dimensions:', product.dimensions),
                  _buildDetailRow('Style:', product.style),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusCircle('I', inStockCount > 0 ? Colors.blue : Colors.grey, inStockCount.toInt(), product.model),
                      _buildStatusCircle('A', availableCount > 0 ? Colors.green : Colors.grey, availableCount.toInt(), product.model),
                      _buildStatusCircle('O', onOrderCount > 0 ? Colors.red : Colors.grey, onOrderCount.toInt(), product.model),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Add to list logic
                        String? serverAddress = await SharedPreferencesUtil.getServerAddress();
                        if (serverAddress == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Server address not found')),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddToListDialog(
                              itemNumber: widget.itemNumber,
                              price: product.retail ?? 0.0,
                              serverAddress: serverAddress,
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: const Text('Add to List'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RelatedItemsWidget(relatedItems: product.relatedItems),
                  const SizedBox(height: 16),
                  CollectionItemsWidget(
                    collectionId: product.collection.collectionID,
                    allItems: context.read<InventoryProvider>().inventory, // Pass the filtered items from the provider
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
