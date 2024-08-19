import 'package:flutter/material.dart';
import 'package:fw_demo/pages/menuPage.dart';
import 'package:fw_demo/utils/bluetooth_manager.dart';
import 'package:provider/provider.dart';
import 'package:fw_demo/providers/inventory_provider.dart';
import 'package:fw_demo/utils/routes.dart';
import 'package:fw_demo/pages/serverConnect.dart';
import 'package:fw_demo/pages/login.dart';
import 'package:fw_demo/pages/loginSucces.dart';
import 'package:fw_demo/pages/product_inventory.dart';
import 'models/filter_criteria.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FilterCriteria initialCriteria = FilterCriteria(
      pageSize: 5000,
      pageNum: 1,
      style: [],
      availability: 0,
      sortby: 0,
      collection: [],
      set: 0,
      category: [],
      subCategory: [],
      supplier: [],
      textFilter: '',
     // deviceName: 'Temp Device'
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider(initialCriteria)),
        ChangeNotifierProvider(create: (_) => BluetoothManager(navigatorKey)),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Product Inventory',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: MyRoutes.ipRoute,
        routes: {
          MyRoutes.ipRoute: (context) => ServerAddressPage(),
          MyRoutes.loginRoute: (context) => LoginPage(),
          MyRoutes.menupageRoute: (context) => MenuPage()
        },
        onGenerateRoute: (settings) {
          if (settings.name == MyRoutes.loginRoute) {
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (context) {
                return LoginPage();
              },
            );
          }
          if (settings.name == MyRoutes.productInventoryRoute) {
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (context) {
                return ProductInventoryPage(serverAddress: args['serverAddress']!);
              },
            );
          }
          return null; // Let `onUnknownRoute` handle the rest
        },
      ),
    );
  }
}
