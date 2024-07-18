import 'dart:async';
import 'dart:convert';
import 'package:fw_demo/utils/sharedprefutils.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/branch_inventory.dart';
import '../models/cipherInventory.dart';
import '../models/device.dart';
import '../models/inventory_images.dart';
import '../models/list.dart';
import '../models/listedItem.dart';
import '../models/selectedItemlist.dart';
import '../models/user.dart';
import '../models/inventory.dart';
import '../models/filter_criteria.dart';

class ApiService {
    final String baseUrl;
    late String deviceName;

    ApiService({required this.baseUrl}) {
        _loadDeviceName();
    }

    Future<void> _loadDeviceName() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        deviceName = prefs.getString('device_name') ?? 'Unknown Device';
        print(deviceName);
    }

    Future<bool> checkServerConnection() async {
        try {
            await _loadDeviceName();
            final response = await http.get(
                Uri.parse('$baseUrl/Inventory/ErrorResponse'),
            ).timeout(Duration(seconds: 20));

            if (response.statusCode >= 200 && response.statusCode < 300) {
                print("Response Data: ${response.body}");
                return true;
            } else {
                print("Failed to connect to server. Status code: ${response.statusCode}");
            }
        } on http.ClientException catch (e) {
            print('ClientException: $e');
        } on TimeoutException catch (e) {
            print('TimeoutException: $e');
        } catch (e) {
            print('Error connecting to server: $e');
        }
        return false;
    }

    Future<User?> login(String username, String password) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Users/Login');
        print("Logging in to: $url with username: $username");
        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode({'userName': username, 'pass': password}),
            );

            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    return User.fromJson(responseBody['Data']);
                } else {
                    print('Login failed: ${responseBody['Message']}');
                }
            } else {
                print('Failed to login. Status code: ${response.statusCode}');
            }
        } catch (e) {
            print('Error logging in: $e');
        }
        return null;
    }

    Future<bool> addDevice(Device device) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Devices/AddDevice');
        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode(device.toJson()),
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                print("Response body: ${response.body}");
                return responseBody['Result'] == 0;
            } else {
                print('Failed to add device. Status code: ${response.statusCode}');
                return false;
            }
        } catch (e) {
            print('Error adding device: $e');
            return false;
        }
    }

    Future<List<Inventory>> getFilteredInventory(FilterCriteria criteria) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/FilteredInventory');
        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName, // Ensure this value is not null
                },
                body: jsonEncode(criteria.toJson()),
            );
            print(criteria.toJson());
            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                print(responseBody);
                if (responseBody['Data'] == null) {
                    return [];
                }
                List<dynamic> body = responseBody['Data'];
                List<Inventory> inventory = body.map((dynamic item) => Inventory.fromJson(item)).toList();
                return inventory;
            } else {
                throw Exception('Failed to load inventory');
            }
        } catch (e) {
            print('Error fetching filtered inventory: $e');
            throw e;
        }
    }

    Future<List<dynamic>> getAllCollections() async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/GetAllCollections');

        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName, // Ensure this value is not null
                },
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    print(responseBody['Data']);
                    return responseBody['Data'];
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to retrieve collections');
            }
        } catch (e) {
            print('Error fetching collections: $e');
            throw e;
        }
    }

    Future<List<dynamic>> getAllsuppliers() async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/GetAllSuppliers');

        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    print(responseBody['Data']);
                    return responseBody['Data'];
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to retrieve Suppliers');
            }
        } catch (e) {
            print('error fetching suppliers : $e');
            throw e;
        }
    }

    Future<List<dynamic>> getAllStyles() async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/GetAllStyles');

        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    print(responseBody['Data']);
                    return responseBody['Data'];
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to retrieve the styles');
            }
        } catch (e) {
            print('error fetching the styles , exception is thrown ');
            throw e;
        }
    }

    Future<List<dynamic>> getAllCategories() async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/GetAllCategories');

        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    print(responseBody['Data']);
                    return responseBody['Data'];
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to retrieve the categories');
            }
        } catch (e) {
            print('error fetching the categories, exception is thrown ');
            throw e;
        }
    }

    Future<Inventory> getProductByNumber(int itemNumber) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/GetItemById?id=$itemNumber');
        print('Fetching product details from: $url');
        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            print('Response status: ${response.statusCode}');
            print('Response body (truncated): ${response.body.substring(0, 100)}');

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                print('Response body (full): ${responseBody}');
                if (responseBody['Result'] == 0) {
                    return Inventory.fromJson(responseBody['Data']);
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to load product');
            }
        } catch (e) {
            print('Error fetching product details: $e');
            throw e;
        }
    }

    Future<List<ItemImage>> getImagesByItemNumber(int itemNumber) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/GetImageById?id=$itemNumber');
        print('Fetching images from: $url');
        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                print('Response body parsed: $responseBody');

                if (responseBody['Result'] == 0) {
                    InventoryImages images = InventoryImages.fromJson(responseBody['Data']);
                    return images.itemImage;
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to load images');
            }
        } catch (e) {
            print('Error fetching images: $e');
            throw e;
        }
    }

    Future<void> addItemImage(ItemImage itemImage, int itemNumber) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/AddImageToItem');
        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode({
                    'itemNumber': itemNumber,
                    'fileName': itemImage.fileName,
                    'base64Image': itemImage.imageBase64,
                }),
            );

            if (response.statusCode == 200) {
                print("Image added Successfully");

            } else {
                throw Exception('Failed to add image to item. Status code: ${response.statusCode}');
            }
        } catch (e) {
            print('Error adding image to item: $e');
            throw e;
        }
    }


    Future<List<BranchInventory>> getBranchInventory(int itemNumber) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/GetItemBranchDetails?id=$itemNumber');
        print('Fetching branch inventory from: $url');
        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                print('Response body parsed: $responseBody');

                if (responseBody['Result'] == 0 ) {
                    List<dynamic> data = responseBody['Data'];
                    return data.map((item) => BranchInventory.fromJson(item)).toList();
                } else if(responseBody['Result']==2 && responseBody['Data']!=null)
                    {
                        List<dynamic> data = responseBody['Data'];
                        return data.map((item) => BranchInventory.fromJson(item)).toList();
                    }
                else  {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to load branch inventory');
            }
        } catch (e) {
            print('Error fetching branch inventory: $e');
            throw e;
        }
    }

    Future<List<ItemList>> getAllLists() async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/GetAllLists');

        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    List<dynamic> body = responseBody['Data'];
                    List<ItemList> lists = body.map((dynamic item) => ItemList.fromJson(item)).toList();
                    return lists;
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to load lists');
            }
        } catch (e) {
            print('Error fetching lists: $e');
            throw e;
        }
    }

    Future<ItemList> createList(ItemList itemList) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/CreateList');

        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode(itemList.toJson()),
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    return ItemList.fromJson(responseBody['Data']);
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to create list');
            }
        } catch (e) {
            print('Error creating list: $e');
            throw e;
        }
    }

    Future<void> addItemToList(ListedItem item) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/AddItemToList');

        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode(item.toJson()),
            );

            if (response.statusCode != 200) {
                throw Exception('Failed to add item to list');
            }
        } catch (e) {
            print('Error adding item to list: $e');
            throw e;
        }
    }

    

    Future<void> clearList(int id) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/ClearList?id=$id');

        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            if (response.statusCode != 200) {
                print(id);
                print(url);
                print(response.body);
                throw Exception('Failed to clear list');
            } else {
                // Optionally handle successful response
                print('List cleared successfully');
            }
        } catch (e) {
            print('Error clearing list: $e');
            throw e;
        }
    }

    Future<void> clearListedItems(int id) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/ClearListedItems');

        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode({'id': id}),
            );

            if (response.statusCode != 200) {
                throw Exception('Failed to clear listed items');
            }
        } catch (e) {
            print('Error clearing listed items: $e');
            throw e;
        }
    }

    Future<void> clearListedItem(ListedItem item) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/ClearListedItem');

        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode(item.toJson()),
            );

            if (response.statusCode != 200) {
                throw Exception('Failed to clear listed item');
            }
        } catch (e) {
            print('Error clearing listed item: $e');
            throw e;
        }
    }

    Future<void> clearSelectedItems(SelectedItemList items) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/ClearSelectedItems');

        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode(items.toJson()),
            );

            if (response.statusCode != 200) {
                throw Exception('Failed to clear selected items');
            }
        } catch (e) {
            print('Error clearing selected items: $e');
            throw e;
        }
    }

    Future<void> updateListedItem(ListedItem listedItem) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/UpdateListedItem');

        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode(listedItem.toJson()),
            );

            if (response.statusCode != 200) {
                throw Exception('Failed to update listed item');
            }
        } catch (e) {
            print('Error updating listed item: $e');
            throw e;
        }
    }

    Future<void> addCipher(List<CipherInventory> items) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/Inventory/AddCipher');

        try {

            String token = await SharedPreferencesUtil.getTokenAddress() ?? 'Unknown Device';
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                    'token' : token,
                },
                body: jsonEncode(items.map((item) => item.toJson()).toList()),

            );
                print(jsonEncode(items.map((item) => item.toJson()).toList()));
            if (response.statusCode == 200)
                {
                    print(response.body);
                }
            if (response.statusCode != 200) {
                print(response.body);
                throw Exception('Failed to add cipher items');
            }
        } catch (e) {
            print('Error adding cipher items: $e');
            throw e;
        }
    }

    Future<List<ListedItem>> getAllListedItems() async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/GetAllListedItems');

        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    List<dynamic> body = responseBody['Data'];
                    List<ListedItem> listedItems = body.map((dynamic item) => ListedItem.fromJson(item)).toList();
                    return listedItems;
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to load listed items');
            }
        } catch (e) {
            print('Error fetching listed items: $e');
            throw e;
        }
    }

    Future<List<ListedItem>> getAllListedItemsByID(int id) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/GetAllListedItemsByID?id=$id');

        try {
            final response = await http.get(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    List<dynamic> body = responseBody['Data'];
                    List<ListedItem> listedItems = body.map((dynamic item) => ListedItem.fromJson(item)).toList();
                    return listedItems;
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to load listed items by ID');
            }
        } catch (e) {
            print('Error fetching listed items by ID: $e');
            throw e;
        }
    }

    Future<ListedItem> getListedItem(ListedItem item) async {
        await _loadDeviceName();
        final url = Uri.parse('$baseUrl/ItemList/GetListedItem');

        try {
            final response = await http.post(
                url,
                headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'deviceName': deviceName,
                },
                body: jsonEncode(item.toJson()),
            );

            if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                if (responseBody['Result'] == 0) {
                    return ListedItem.fromJson(responseBody['Data']);
                } else {
                    throw Exception(responseBody['Message']);
                }
            } else {
                throw Exception('Failed to get listed item');
            }
        } catch (e) {
            print('Error fetching listed item: $e');
            throw e;
        }
    }
}
