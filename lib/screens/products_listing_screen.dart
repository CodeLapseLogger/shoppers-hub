import 'package:flutter/material.dart';
//import '../dummy_product_data.txt'; // File with an array of dummy product data, each encapsulated in a Product class instance.
import 'package:provider/provider.dart';

// Renders the product grid
import '../widgets/product_grid_widget.dart';
import '../providers/products_provider.dart';

// Enum representation of the screen display options, to either display only products marked as favorites or all products
enum displayOptions{
   Favorites,
   All,
}

class ProductsListingScreen extends StatelessWidget {
  // Route name has been made part of this screen itself to allow ease of use when mounting it as top/focus of he viewport
  // through Navigator and to avoid any typos. Setting done here would be the single source of an issue and thereby also easy
  // to debug.
  static const routeName = "/";

  @override
  Widget build(BuildContext context) {

    // Since the data on the screen is to be changed, need to associate this widgets filter option selection to the 
  // "provider": ProductsProvider, which is the data source, in order to apply the appropriate filter to the data and thereby
  // the UI display in the viewport.
  final productsProvider = Provider.of<ProductsProvider>(context, listen: false); // Only interested in the provider instance 
                                                                                  // methods to set/pass on the filter selection
                                                                                  // to the provider enabling filtered data, and
                                                                                  // not the actual data. So, listener is set to
                                                                                  // false to ignore notifications of data changes
                                                                                  // from the provider.


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shoppers Hub',
        ),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (selectedFilter){ // Value of enum type displayOptions passed in automatically upon selection
              if(selectedFilter == displayOptions.Favorites){
                  productsProvider.setFavoritesFilter();
              }
              else{ // selectedFilter == displayOptions.All
                  productsProvider.setAllProductsFilter();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(
                  "Only Favorites",
                ),
                value: displayOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text(
                  "Show All",
                ),
                value: displayOptions.All,
              ),
            ],
          ),
        ],
      ),
      body:
          ProductGridWidget(), // The widget that was originally here has now been made in to a separate Stateless widget,
      // as the listener set-up to listen to any data changes in the provider: ProductsProvider, will
      // rebuild this whole widget including the AppBar widget, which has static content. So, for
      // run-time efficiency the widget with the listener has been refactored in to an isolated widget
      // outside this screen widget.
    );
  }
}
