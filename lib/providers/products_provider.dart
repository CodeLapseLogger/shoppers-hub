import 'dart:convert'; // Used for JSON object encoding and decoding needed for stringyfying JSON object format in the
// http RESTful web-api calls.

import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // For making RESTful Web API calls to Firebase Realtime Database
// Namely: GET, POST, PUT, PATCH, DELETE.

import './product_provider.dart';

import '../firebase_urls.dart'; // File with the firebase database url for RESTful API calls

// Provider class with added capability of notifying changes to listeners in the widget tree, through the mixin ChangeNotifier.
// It is the central data storage holding all the product data. The behind the scenes data channels are established through
// the mixin that handles the data communication. Also, a copy of the data is sent to avoid data changes in multiple places,
// since data by default is passed by reference in Dart. The copy is to avoid changes in multiple places and inconsistent
// data being served by this provider to the listener requests.

class ProductsProvider with ChangeNotifier {
  List<ProductProvider> _products =
      []; // The '_' is to signify that the list is to be private and not accesible outside
  // this class.

  // Method to fetch products from the Firebase database through a RESTful HTTP GET request. Since the product data is being
  // maintained in a Provider class, local data copy is being maintained in sycn with that of database data. If the data was
  // being directly rendered in the widget (StreamBuilder), it would be automatically rebuilt with each data change streamed
  // from the database. So, resorting to the http package to manually make data changes through RESTful API calls.
  Future<void> refreshProducts() async {
    var url = FIREBASE_URL_P +
        '.json'; // Extension .json is specific to firebase real-time database.

    final getResponse = await http.get(
        url); // RESTful HTTP GET request, to fetch all the product data from Firebase
    Map<String, dynamic> productsData = json.decode(getResponse.body) as Map<
        String,
        dynamic>; // Map<String, dynamic> is returned as Future, matching
    // the return type, since, async/await deal with Futures.
    // If the type of void, no return statement would have
    // been needed before the "await" keyword.

    _products
        .clear(); // Clear the list before re-populating all product data

    productsData.forEach((productId, productInfo) {
      print(productInfo['title']);

      _products.add(ProductProvider(
          id: productId,
          title: productInfo['title'],
          description: productInfo['description'],
          price: productInfo['price'],
          imageUrl: productInfo['imageUrl'],
          isFavorite: productInfo['isFavorite']));
    });

    notifyListeners();

    //return;
  }

  Future<void> addProduct(ProductProvider newProduct) async {
    // async/await to give the asynchronous code more readability
    // by fitting well with the synchronous code flow. With this
    // approach, the method return type has to be a Future, unlike
    // the then(), catchError() methods, which can be applied to parts
    // of code within any function. So, async/await is tied as an
    // attribute to the method with the requirement to have a return
    // type of Future<>. If the method return type can be a Future<>
    // aysnc/await is probably a cleaner way to incorporate asycnchronous
    // code with smooth integration with synchronous code flow.
    var url = FIREBASE_URL_P +
        '.json'; // Extension .json is specific to firebase real-time database.

    try {
      final postResponse =
          await http // Async/Await being explicitly tied to the method making it an asynchronous method, the Future returned by
              // http.post(), is implicitly returned as the method's value to caller removing the need for a return
              // statement. However, in the case of then() method which is only tied to part of a method code requires the
              // explicit return statement. With the asycn/await mechanism, caller can still perform an action in the
              // widget based on the result of the Future, returned after the "post" RESTful api call completes.
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
      );

      print(json.decode(postResponse.body));
      newProduct = ProductProvider(
          id: json.decode(postResponse.body)[
              'name'], // Need to decode the response body to extract the 'name' attribute value,
          // which is the id of database entry.
          title: newProduct.title,
          description: newProduct.description,
          price: newProduct.price,
          imageUrl: newProduct.imageUrl,
          isFavorite: newProduct.isFavorite);

      _products.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error; // error thrown here will be caught in the _EditProductScreenState class where there is another call to
      // cathError(), chained to the addProduct() call site. That has been made possible as addProduct() also
      // returns as Future.
    }
  }

  // Method to render a copy of the products to the client caller outside this class.
  List<ProductProvider> get products {
    return [
      ..._products
    ]; // Returning a copy of the _products, by creating a new list and adding its elements
    // with a spread operator.
  }

  // Method to render a copy of a product with matching input product id
  ProductProvider getProductById(String id) {
    return [..._products].firstWhere((product) {
      return product.id ==
          id; // test to match input id with the current product id
    });
  }

  // Method to return a copy of favorite product list
  List<ProductProvider> get favoriteProducts {
    return _products.where((product) {
      return product
          .isFavorite; // test to know if the current product is a marked favorite or not.
    }).toList();
  }

  // Update existing product
  Future<void> updateProduct(
      String existingProdId, ProductProvider updatedProductItem) async {
    // Asynchronous method to work with network RESTful
    // PUT api call.
    // Get the index of existing product with the given id.
    int existingItemIdx = _products.indexWhere((product) {
      return product.id == existingProdId;
    });

    // Get the product to be updated with given id
    ProductProvider existingItem = _products[existingItemIdx];

    // Replace the existing product entry at the given index with the updated product entry.
    _products[existingItemIdx] = updatedProductItem;

    String url = FIREBASE_URL_P +
        '/$existingProdId.json'; // url to access corresponding db entry through the
    // matching product-id.
    try {
      await http.put(url,
          body: json.encode({
            // RESTful HTTP PUT api call to update db entry. Alternatively, a PATCH api call can be made without the isFavorite
            // attibute in teh encoded json data, as data that is not part of update will not be be lost but retained with the
            // PATCH call. However, with PUT api call, missing data fields will be removed from the entry and overritten with
            // passed in fields and data. Therefore, leading to a data loss. So, would have to send the whole set of fields and
            // data with PUT for the call to be a lossless operation.
            'title': updatedProductItem.title,
            'description': updatedProductItem.description,
            'price': updatedProductItem.price,
            'imageUrl': updatedProductItem.imageUrl,
            'isFavorite': updatedProductItem.isFavorite
          }));
    } catch (error) {
      // As there is an error, undo the update by reverting to the data prior to the operation
      _products[existingItemIdx] = existingItem;
      throw error;
    }
  }

  // Method to remove a product with given id
  Future<void> deleteProductById(String id) async {
    final removedProductPos = _products.indexWhere((product) =>
        product.id ==
        id); // Get the index of the product in the list where id  matches
    // the id of the product to be deleted.

    final removedProduct = _products[removedProductPos];

    _products.remove(removedProduct);
    notifyListeners(); // Notify the delete to listeners allowing the widget tree to be accordingly refreshed

    // Perform the actual delete in the backend database.
    final url = FIREBASE_URL_P +
        '/$id.json'; // url to the product entry in the database to be deleted. Identified by the id in
    // the url.
    try {
      final deleteResponse = await http
          .delete(url); // make the http delete request to delete the db entry.
      print(json.decode(deleteResponse.body));
    } catch (error) {
      // There was some trouble with the backend deletion. Undo the local delete (by inserting back) and proprogate
      // the error back to the caller widget to perform a UI action that can inform the user of the failed deletion.

      _products.insert(removedProductPos, removedProduct);
      notifyListeners(); // Can have multiple calls to notifyListeners() in the same method, for each of the data manipulation
      // operations.
      throw error;
    }
  }
}
