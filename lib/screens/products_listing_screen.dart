import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './cart_detail_screen.dart';

import '../widgets/product_grid_widget.dart'; // Renders the product grid
import '../widgets/badge_widget.dart'; // Renders shopping cart icon with item count in a badge.
import '../widgets/side_drawer_widget.dart'; // Renders the Drawer widget from the side with screen widgets for app navigation.

import '../providers/cart_provider.dart'; // CartProvider class definition
import '../providers/products_provider.dart'; // ProductsProvider class definition

// Enum representation of the screen display options, to either display only products marked as favorites or all products
enum DisplayOptions {
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

  // Track the first time widget build
  bool isFirstBuild = true;

  // Track data loading state of the app screen
  bool isDataLoading = false;

  // Method with asynchronous code to refresh local data in product and cart providers
  Future<void> _refreshProductsAndCart() async {
    // Refresh product data
    await Provider.of<ProductsProvider>(context).refreshProducts();

    // Refresh cart data as well, as there is the cart item count in the appbar tracking user shopping.
    await Provider.of<CartProvider>(context).refreshShoppingCart();
  }

  @override
  void didChangeDependencies() {
    // Condition to only refresh data for the first widget build. Because the data would be refreshed  with the Provider
    // method call refreshProducts(), and this widget doesn listen to data changes from Provider, the widget will keep
    // building in an infinite loop. So, the data is refreshed only for the first widget build to break the loop and
    // allow the data display on this screen widget.
    if (isFirstBuild) {
      setState(() {
        isDataLoading =
            true; // The circular progress indicator will be accordingly made part of the widget tree in the UI.
      });

      Provider.of<ProductsProvider>(context)
          .refreshProducts()
          .catchError((error) {
        print(error);
      }).then((_) {
        // ignore the value from the Future

        // Refresh cart data as well, as there is the cart item count in the appbar tracking user shopping.
        Provider.of<CartProvider>(context).refreshShoppingCart().then((_) {
          setState(() {
            isDataLoading =
                false; // Circular progress indicator will be removed to allow the local data rendering in the widgets
          });
        });
      }); // Refresh/Re-render product data

      isFirstBuild =
          false; // Reset the flag to avoid refreshing data of products over subsequent widget builds
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Listener setup for provider: CartProvider, to fetch the provider instance once to access necessary data.
    // As the named attribute: listen is set to false, any future changes to data in CartProvider will not get
    // sent to this listener, and hence the widget re0build is avoided.
    // final CartProvider cart = Provider.of<CartProvider>(
    //   context, /*listen: false*/
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shoppers Hub',
        ),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (selectedFilter) {
              // Value of enum type displayOptions passed in automatically upon selection

              setState(() {
                if (selectedFilter == DisplayOptions.Favorites) {
                  filterFavorites = true;
                } else {
                  // selectedFilter == DisplayOptions.All
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
          Consumer<CartProvider>(
            // Consumer wrapped around Badge widget to localize the widget rebuild process to just that
            // sub-widget and not the whole widget tree that would have to be built by the build method,
            // if the listener was set up in the build method scope.
            builder: (_, cartProvider, staticChildWidget) {
              // Context is ignored with "_"; The IconButton which doesn't change
              // and is a child in the parent Consumer<>, is passed along to builder as staticChildWidget.
              // That is to avoid rebuilding the IconButton widget each time the Badge widget is rebuilt with
              // the data change trigger from the CartProvider. Hence, more efficient.
              return Badge(
                child: staticChildWidget,
                value: cartProvider.cartItemCount.toString(),
              );
            },
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  CartDetailScreen.routeName,
                ); // The action of icon click triggers the push event
                // of CartDetailScreen to the top of Navigator stack.
                // No arguments are being passed to the screen instance.
              },
            ),
          ),
        ],
      ),
      drawer: SideDrawerWidget(),
      body: isDataLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              // Can be used to refresh data in the screen by the pull down action, in cases where data is lost
              // during the load process, be it connection speed or broken connection. An option to refresh data
              // from within the app.
              onRefresh: () async {
                try {
                  await _refreshProductsAndCart(); // Method with asynchronous code to refresh data
                } catch (error) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Data rendering failed !',
                        textAlign: TextAlign.center,
                      ),
                      duration: Duration(
                        seconds: 2,
                      ),
                    ),
                  );
                }
              },
              child: ProductGridWidget(filterFavorites: filterFavorites),
            ), // The widget that was originally here has now been made in to a separate Stateless widget,
      // as the listener set-up to listen to any data changes in the provider: ProductsProvider, will
      // rebuild this whole widget including the AppBar widget, which has static content. So, for
      // run-time efficiency the widget with the listener has been refactored in to an isolated widget
      // outside this screen widget.
    );
  }
}
