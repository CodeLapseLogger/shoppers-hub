import 'package:flutter/material.dart';
//import '../dummy_product_data.txt'; // File with an array of dummy product data, each encapsulated in a Product class instance.

// Renders the product grid
import '../widgets/product_grid_widget.dart';

class ProductsListingScreen extends StatelessWidget {

  // Route name has been made part of this screen itself to allow ease of use when mounting it as top/focus of he viewport
  // through Navigator and to avoid any typos. Setting done here would be the single source of an issue and thereby also easy 
  // to debug.
  static const routeName = "/";


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shoppers Hub',
        ),
      ),
      body: ProductGridWidget(), // The widget that was originally here has now been made in to a separate Stateless widget,
                                 // as the listener set-up to listen to any data changes in the provider: ProductsProvider, will
                                 // rebuild this whole widget including the AppBar widget, which has static content. So, for 
                                 // run-time efficiency the widget with the listener has been refactored in to an isolated widget
                                 // outside this screen widget.
    );
  }
}
