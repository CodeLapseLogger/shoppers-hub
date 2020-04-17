import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_listing_screen.dart';
import './screens/product_detail_screen.dart';

import './providers/products_provider.dart';
import './providers/cart_provider.dart';

void main() => runApp(ShoppingApp());

// Main material app widget to launch the shopping app.
class ShoppingApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          // ChangeNotifierProvider is to setup the provider: ProductsProvider in the
          // app widget tree, above the parent of the widgets listening for data or changes in data.
          // When there is a change in the data managed by the "provider", only the listening widgets
          // are rebuilt and not the entire app widget tree. Entire widget tree re-build would be the
          // case if data was passed around through Stateful widget constructors, even in cases where
          // data being passed is only needed by widgets down the tree and not the one holding it, as
          // data is part of the widget's state. This central data management by the provider is a
          // cleaner approach to data management in the app widget tree.

          value:
              ProductsProvider(), // This is an instance of the provider and not a widget.
        ),
        ChangeNotifierProvider.value(
          value: CartProvider(), // Provider of cart items to listeners down the widget tree from this widget node.
        ),
      ],
      child: MaterialApp(
        title: 'Shoppers Hub',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        home: ProductsListingScreen(), // App root route,
        routes: {
          //ProductsListingScreen.routeName : (context) => ProductsListingScreen(), // redundant home route declaration
          ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
        },
      ),
    );
  }
}
