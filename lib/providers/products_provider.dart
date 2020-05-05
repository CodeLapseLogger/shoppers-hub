import 'dart:convert'; // Used for JSON object encoding and decoding needed for stringyfying JSON object format in the
// http RESTful web-api calls.

import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // For making RESTful Web API calls to Firebase Realtime Database
// Namely: GET, POST, PUT, PATCH, DELETE.

import './product_provider.dart';

import '../firebase_url.dart'; // File with the firebase database url for RESTful API calls

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
    ProductProvider(
      id: 'p5',
      title: 'Nike Shoes',
      description:
          'Breatheble uppers and cushioned inners - Get your pair today !',
      price: 79.99,
      imageUrl:
          'https://c.static-nike.com/a/images/t_PDP_1280_v1/f_auto/uwjw39b1xdsbtmfnxjqm/tanjun-shoe-MkTmejeq.jpg',
    ),
  ];

  Future<void> addProduct(ProductProvider newProduct){
    var url = FIREBASE_URL + '.json'; // Extension .json is specific to firebase real-time database.

    return http // As the http.post(), then(), catchError() all return a Future, the resultant Future at the end of chain
                // is returned here, since this method is supposed to return a Future<void>. So, no valid value is returned
                // but, introduces a way to program an action in the widget invoking this operation, after the add operation
                // completes .
        .post(
      url,
      body: json.encode(
        // converts the JSON object format to a string for transmission over the network
        {
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
          'isFavorite': newProduct.isFavorite,
        },
      ),
    )
        .then<void>((postResponse) { // Assign the id of database entry as the id of ProductProvider entry which is part of 
                                     // app state. Looks like the explicit mention of the void type for then() is necessary
                                     // to match the return type of this method: Future<void>, as then() is a generic. Otherwise,
                                     // the chained methods to the received Future at this method's call site in the 
                                     // _EditProductScreenState class seem to be unable to resolve the Future value and do their
                                     // part in the app. Explicit mention of "void" type in the showDialog, or chained then() of
                                     // _EditProductScreenState doesn't seem to be fixing the issue. Only the mention here
                                     // apparently is ensuring the propogation of right Future type to the caller and error handling,
                                     // even though the then() here is the part that is chained to run when the db add operation is
                                     // successful ! The chained catchError() seems to be returning Future<void> by default, but
                                     // possibly is being affected by the explicitness of the then() type, as it is generic.
                                     // Maybe, this is the case with developer written functions that return custom Future and
                                     // the need for type explicitness with code chain at the origin of error.
                                     
      print(json.decode(postResponse.body));
      newProduct = ProductProvider(
        id: json.decode(postResponse.body)['name'], // Need to decode the response body to extract the 'name' attribute value,
                                                    // which is the id of database entry.
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl,
        isFavorite: newProduct.isFavorite 
      );

      _dummyProducts.add(newProduct);
      notifyListeners();

    }).catchError((error){
       print(error);
       throw error; // error thrown here will be caught in the _EditProductScreenState class where there is another call to
                    // cathError(), chained to the addProduct() call site. That has been made possible as addProduct() also 
                    // returns as Future.
    });

  }

  // Method to render a copy of the products to the client caller outside this class.
  List<ProductProvider> get products {
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

  // Method to return a copy of favorite product list
  List<ProductProvider> get favoriteProducts {
    return _dummyProducts.where((product) {
      return product
          .isFavorite; // test to know if the current product is a marked favorite or not.
    }).toList();
  }

  // Update existing product
  void updateProduct(
      String existingProdId, ProductProvider updatedProductItem) {
    // Get the index of existing product with the given id.
    int existingItemIdx = _dummyProducts.indexWhere((product) {
      return product.id == existingProdId;
    });

    // Replace the existing product entry at the given index with the updated product entry.
    _dummyProducts.removeAt(existingItemIdx); // First remove
    _dummyProducts.insert(
        existingItemIdx, updatedProductItem); // Then insert at the same index
  }

  // Method to remove a product with given id
  void deleteProductById(String id) {
    _dummyProducts.removeWhere((product) {
      return product.id == id;
    });

    notifyListeners();
  }
}
