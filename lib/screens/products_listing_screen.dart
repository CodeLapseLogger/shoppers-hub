import 'package:flutter/material.dart';

// Renders the product grid
import '../widgets/product_grid_widget.dart';


// Enum representation of the screen display options, to either display only products marked as favorites or all products
enum DisplayOptions{
   Favorites,
   All,
}

// This widget has been turned in to a StatefulWidget to handle the state of user chosen filter for product items display.
// It is an alternative approach to using provider/listener technique for app's state management, as this state is specific 
// to just this widget and not needed at any other place in the app at this point in app design/development state.
class ProductsListingScreen extends StatefulWidget {
  // Route name has been made part of this screen itself to allow ease of use when mounting it as top/focus of he viewport
  // through Navigator and to avoid any typos. Setting done here would be the single source of an issue and thereby also easy
  // to debug.
  static const routeName = "/";

  @override
  _ProductsListingScreenState createState() => _ProductsListingScreenState();
}

class _ProductsListingScreenState extends State<ProductsListingScreen> {

  // Tracks the user chose to filter favorites or not
  bool filterFavorites = false; // Default setting to display all product items

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shoppers Hub',
        ),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (selectedFilter){ // Value of enum type displayOptions passed in automatically upon selection

            setState((){
              if(selectedFilter == DisplayOptions.Favorites){
                filterFavorites = true;
              }
              else{ // selectedFilter == DisplayOptions.All
                filterFavorites = false;
              }
            });
              
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(
                  "Only Favorites",
                ),
                value: DisplayOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text(
                  "Show All",
                ),
                value: DisplayOptions.All,
                
              ),
            ],
          ),
        ],
      ),
      body:
          ProductGridWidget(filterFavorites: filterFavorites), // The widget that was originally here has now been made in to a separate Stateless widget,
      // as the listener set-up to listen to any data changes in the provider: ProductsProvider, will
      // rebuild this whole widget including the AppBar widget, which has static content. So, for
      // run-time efficiency the widget with the listener has been refactored in to an isolated widget
      // outside this screen widget.
    );
  }
}
