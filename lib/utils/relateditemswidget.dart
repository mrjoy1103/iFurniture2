import 'package:flutter/material.dart';
import '../models/inventory_images.dart';
import '../models/inventory_related_items.dart';
import '../services/api_services.dart';
import '../utils/sharedprefutils.dart';
import 'dart:convert';
import '../pages/productdetails.dart';  // Ensure the correct import path for ProductDetailsPage

class RelatedItemsWidget extends StatefulWidget {
  final List<InventoryRelatedItems> relatedItems;

  const RelatedItemsWidget({super.key, required this.relatedItems});

  @override
  _RelatedItemsWidgetState createState() => _RelatedItemsWidgetState();
}

class _RelatedItemsWidgetState extends State<RelatedItemsWidget> {
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    String? serverAddress = await SharedPreferencesUtil.getServerAddress();
    if (serverAddress == null) {
      throw Exception('Server address not found in SharedPreferences');
    }
    _apiService = ApiService(baseUrl: serverAddress);
  }

  Future<List<ItemImage>> _fetchImages(int itemNumber) async {
    String? serverAddress = await SharedPreferencesUtil.getServerAddress();
    if (serverAddress == null) {
      throw Exception('Server address not found in SharedPreferences');
    }
    ApiService apiService = ApiService(baseUrl: serverAddress);
    return await apiService.getImagesByItemNumber(itemNumber);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.relatedItems.isEmpty) {
      return const Center(
        child: Text(
          'Related Items (0)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.relatedItems.length,
            itemBuilder: (context, index) {
              InventoryRelatedItems item = widget.relatedItems[index];
              return FutureBuilder<List<ItemImage>>(
                future: _fetchImages(item.relatedItem.toInt()), // Fetch the images based on related item number
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return const SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(child: Text('Error')),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(child: Text('No Image')),
                    );
                  }

                  String imageBase64 = snapshot.data!.first.imageBase64;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(itemNumber: item.relatedItem.toInt()),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.memory(
                              base64Decode(imageBase64), // Decode the base64 image
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(item.itemNumber.toString()), // Ensure item number is shown correctly
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
