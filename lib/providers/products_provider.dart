import 'package:flutter/material.dart';

import './product_provider.dart';

// Provider class with added capability of notifying changes to listeners in the widget tree, through the mixin ChangeNotifier.
// It is the central data storage holding all the product data. The behind the scenes data channels are established through
// the mixin that handles the data communication. Also, a copy of the data is sent to avoid data changes in multiple places,
// since data by default is passed by reference in Dart. The copy is to avoid changes in multiple places and inconsistent
// data being served by this provider to the listener requests.

class ProductsProvider with ChangeNotifier {
  List<ProductProvider> _dummyProducts = [
    // The '_' is to signify that the list is to be private and not accesible outside this class.
    ProductProvider(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    ProductProvider(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    ProductProvider(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    ProductProvider(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

// START - Code to work with products_listing_screen where the selected option there is maintained here (data source) to ensure
// appropriate app rendering. This is one approach where teh filters specific to that screen are directly tied to the
// provider. A better approach would be to have that filter state local to the screen widget making it stateful and scoping
// provider code to cater more generic data needs and reusable in more than one place in the app.

  bool filterFavorites = false; // By default render all product data

// Method to set the favorites filter to true and enable rendering the marked favorite products.
  void setFavoritesFilter() {
    filterFavorites = true;
    notifyListeners();
  }

// Method to set the favorites filter to false and enable the default rendering of all products.
  void setAllProductsFilter() {
    filterFavorites = false;
    notifyListeners();
  }

// END - Code to work with products_listing_screen where the selected option there is maintained here (data source) to ensure
// appropriate app rendering. This is one approach where teh filters specific to that screen are directly tied to the
// provider. A better approach would be to have that filter state local to the screen widget making it stateful and scoping
// provider code to cater more generic data needs and reusable in more than one place in the app.

  void add() {
    notifyListeners();
  }

  // Method to render a copy of the products to the client caller outside this class.
  List<ProductProvider> get products {

    if(filterFavorites){ // if selected option is to filter favorites, accordingly filter products set as favorites and return
                         // the corresponding list of products.
      return _dummyProducts.where((product){
          return product.isFavorite;
      }).toList();
    }

    // if control reaches here, then the set filter is to render all products, hence the default list is returned.
    return [
      ..._dummyProducts
    ]; // Returning a copy of the _dummyProducts, by creating a new list and adding its elements
    // with a spread operator.
  }

  // Method to render a copy of a product with matching input product id
  ProductProvider getProductById(String id) {
    return [..._dummyProducts].firstWhere((product) {
      return product.id ==
          id; // test to match input id with the current product id
    });
  }
}
