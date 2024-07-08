import 'package:flutter/material.dart';
import '../models/inventory_images.dart';
import '../models/inventory.dart';
import '../services/api_services.dart';
import '../utils/sharedprefutils.dart';
import 'package:fw_demo/pages/productdetails.dart';
import 'dart:convert';

class CollectionItemsWidget extends StatefulWidget {
  final int collectionId;
  final List<Inventory> allItems;

  const CollectionItemsWidget({Key? key, required this.collectionId, required this.allItems}) : super(key: key);

  @override
  _CollectionItemsWidgetState createState() => _CollectionItemsWidgetState();
}

class _CollectionItemsWidgetState extends State<CollectionItemsWidget> {
  late ApiService _apiService;
  late Future<void> _apiServiceFuture;

  @override
  void initState() {
    super.initState();
    _apiServiceFuture = _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    String? serverAddress = await SharedPreferencesUtil.getServerAddress();
    if (serverAddress == null) {
      throw Exception('Server address not found in SharedPreferences');
    }
    _apiService = ApiService(baseUrl: serverAddress);
  }

  List<Inventory> _filterItemsByCollection(int collectionId) {
    return widget.allItems.where((item) => item.collection.collectionID == collectionId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _apiServiceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error initializing API service'));
        }

        List<Inventory> collectionItems = _filterItemsByCollection(widget.collectionId);

        if (collectionItems.isEmpty) {
          return Center(child: Text('No items found in this collection'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collection Items (${collectionItems.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: collectionItems.length,
                itemBuilder: (context, index) {
                  Inventory item = collectionItems[index];
                  return FutureBuilder<List<ItemImage>>(
                    future: _apiService.getImagesByItemNumber(item.itemNumber),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 100,
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          width: 100,
                          height: 100,
                          child: Center(child: Text('Error')),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          width: 100,
                          height: 100,
                          child: Center(child: Text('No Image')),
                        );
                      }

                      String imageBase64 = snapshot.data!.first.imageBase64;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(itemNumber: item.itemNumber),
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
                                  base64Decode(imageBase64),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(item.itemNumber.toString()),
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
      },
    );
  }
}
