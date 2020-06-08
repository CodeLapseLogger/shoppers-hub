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

  String
      authToken; // Stores the authentication token returned by Firebase during user authentication.
  // Will be used in all Firebase REST API calls to authenticate and grant appropriate
  // access to data and actions.

  String userId; // Stores the authenticated user's id

  // Setter method for the authentication/authorization token. Will be used with instantiation of this Provider instance
  // through ChangeNotifierProxyProvider instance in main.dart
  set authorizationToken(String userToken) {
    authToken = userToken;
  }

  // Setter method for the authenticated/authorized user-id. Will be used with instantiation of this Provider instance
  // through ChangeNotifierProxyProvider instance in main.dart
  set authorizedUserId(String uId) {
    userId = uId;
  }

  ProductsProvider() {
    authToken = "";
  }

  // Constructor to fetch a positional and a named attribute and accordingly set the class
  // member variables.
  ProductsProvider.withAuthRelatedData(
      List<ProductProvider> previousProductList,
      {@required this.authToken,
      @required this.userId}) {
    _products = previousProductList;
  }

  // Method to fetch products from the Firebase database through a RESTful HTTP GET request. Since the product data is being
  // maintained in a Provider class, local data copy is being maintained in sycn with that of database data. If the data was
  // being directly rendered in the widget (StreamBuilder), it would be automatically rebuilt with each data change streamed
  // from the database. So, resorting to the http package to manually make data changes through RESTful API calls.
  Future<void> refreshProducts([bool isReqUserSpecific = false]) async {
    // The [] syntax is to make the positional argument
    // isReqUserSpecific optional, by giving a default
    // value of "false". Also that flag is to have a
    // custom url for rendering all or user-specific
    // products.

    String remainingQueryString =
        ''; // query string for data filtration on server side

    if (isReqUserSpecific) {
      // Request is to get user-specific products
      remainingQueryString = 'orderBy="ownerId"&equalTo="$userId"';
    }

    var url = FIREBASE_URL_P +
        '.json?auth=$authToken&$remainingQueryString'; // Extension .json is specific to firebase real-time database.
    // Query string "?auth=[AUTH_TOKEN]" is to authenticate user requesting access to
    // data resource, in line with the rules set for FIREBASE DB access.

    final getResponse = await http.get(
        url); // RESTful HTTP GET request, to fetch all the product data from Firebase
    Map<String, dynamic> productsData = json.decode(getResponse.body) as Map<
        String,
        dynamic>; // Map<String, dynamic> is returned as Future, matching
    // the return type, since, async/await deal with Futures.
    // If the type of void, no return statement would have
    // been needed before the "await" keyword.

    url = FIREBASE_URL_UF +
        '/$userId.json?auth=$authToken'; // Url to user-specific favorite products
    final getFavoritesResponse = await http.get(url);
    final favoritesData = json.decode(getFavoritesResponse
        .body); // Extract favorite products data from the response body.

    print("favorite products data: $favoritesData");

    _products.clear(); // Clear the list before re-populating all product data

    // Convert each product item info into local app data model instance: ProductProvider, to be
    // rendered in a widget.
    productsData.forEach((productId, productInfo) {
      print(productInfo['title']);

      _products.add(
        ProductProvider(
            id: productId,
            title: productInfo['title'],
            description: productInfo['description'],
            price: productInfo['price'],
            imageUrl: productInfo['imageUrl'],
            isFavorite: (favoritesData == null)
                ? false
                : (favoritesData['$productId']) ??
                    false), // "??" operator checks if preceding expression value is a null or not.
        //  If null, takes the value given after the operator, else, takes the
        // non-null value given by the expression.
      );
    });

    _products.forEach((element) {
      print(
          "id: ${element.id}, title: ${element.title}, description: ${element.description}, price: ${element.price}, imageUrl: ${element.imageUrl}, isFavorite: ${element.isFavorite}");
    });

    notifyListeners();

    //return;
  }

  /* ************************************************************************************************************* *
   * Since, add/update/delete can only be for user-specific products would it be better to have a different list   *
   * for data manipulation rather than _products itself ?                                                          *
   *                                                                                                               *
   * Certainly possible, given that this app would be rendering 2 sets of products from the Firebase backend,      *
   * depending on the products screen currently in the view port. For ProductsListingScreen() it would be the      *
   * whole product collection created by different registered/signed-up users. But, for ProductManagerScreen()     *
   * only the products created by the logged in user will be rendered (through server-side data filtration with    *
   * corresponding url query parameters). So, same application will be rendering a super-set or a sub-set of       *
   * products depending on the current screen.                                                                     *
   *                                                                                                               *
   * So, makes sense to have two different lists with one constrained to data manipulation operations in           *
   * ProductManagerScreen() will be constrained to the specific products mapped to logged-in user. But, the        *
   * getProductById() is being used in another screen as well: ProductListingScreen(), needing logic to            *
   * accordingly fetch the product data from appropriate list.                                                     *
   *                                                                                                               *
   * That can affect the readability of the code and a more cleaner approach is to have _products loaded with  the *
   * set of products needed by one of those two screen currently in the view port in the refreshProducts() method. *
   * That way, the code in all methods in this Provider can have a simpler code to just access _products, with     *
   * custom data load happening in one place refreshProducts(), giving code better readability.                    *
   * Hence, that is the final data management approach implemented in this Provider class.                         *
   * ************************************************************************************************************* */

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
        '.json?auth=$authToken'; // Extension .json is specific to firebase real-time database.

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
            'ownerId':
                userId, // id of user creating the product entry store only on the server. This allows data filtration
            // through appropriate query parameters in the Firebase API call.
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
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

  // Method to render a copy of a product with matching input product id. Used only in
  ProductProvider getProductById(String id) {
    return [..._products].firstWhere((product) {
      return product.id ==
          id; // test to match input id with the current product id
    });
  }

  // Method to return a copy of favorite product list. Important to
  // mark this method with return type of Future and appropriate handling at
  // caller site to avoid access to null values and app crash.
  Future<List<ProductProvider>> get favoriteProducts async {
    final userFavoritesUrl = FIREBASE_URL_UF + '/$userId.json?auth=$authToken';

    // As then() is being used here, need to set the response upon competion of the future within then().
    // Setting getResponse to return value of the http.get() will retain the Future<Response> and not the
    // completed value.

    List<ProductProvider> favoriteProducts;
    Map<String, dynamic> favoritesData;

    try {
      final getResponse = await http.get(userFavoritesUrl);

      // Extract the favorites data(Map: productId->isFavorite) from the response body
      favoritesData = json.decode(getResponse.body);

      favoriteProducts = _products.where((product) {
        return favoritesData.containsKey(product.id) &&
            favoritesData[product.id]
                as bool; // test to know if the current product exists in the favoritesData and is marked as favorite.
        // Since, the bool is rendered as "dynamic", type-casting it to bool with "as" keyword.
      }).toList();
    } catch (error) {
      print(error);
      throw error;
    }

    // Cleanup marked favorite products that are owned and now deleted by other users
    final deletedProductsUrl = FIREBASE_URL_DP + '.json?auth=$authToken';

    // Get deleted product data and cleanup corresponding favorites data specific to
    // this user.
    try {
      final deletedProductsGetResponse = await http.get(deletedProductsUrl);

      // Decode the product data as a map of <productId, isDeleted> key-value pairs.
      final Map<String, dynamic> deletedProductsData =
          json.decode(deletedProductsGetResponse.body);

      // Check if each of the deleted product has an entry in the favorites data and 
      // accordingly, delete it from the user-specific favorites data in the backend.
      deletedProductsData.forEach((deletedProductId,deletedProductData) {
        if (favoritesData.containsKey(deletedProductId)) {
          final deleteFavoriteUrl = FIREBASE_URL_UF +
              '/$userId/$deletedProductId.json?auth=$authToken';
          http.delete(deleteFavoriteUrl).then((deleteFavoriteResponse) => print(
              'Deleted favorite entry for product with id: $deletedProductId'));
        }
      });
    } catch (error) {
      print(error);
      throw error;
    }

    return favoriteProducts;
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
    notifyListeners();

    String url = FIREBASE_URL_P +
        '/$existingProdId.json?auth=$authToken'; // url to access corresponding db entry through the
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
            'ownerId': userId,
            'description': updatedProductItem.description,
            'price': updatedProductItem.price,
            'imageUrl': updatedProductItem.imageUrl,
          }));
    } catch (error) {
      // As there is an error, undo the update by reverting to the data prior to the operation
      print(error);
      _products[existingItemIdx] = existingItem;
      notifyListeners();
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
    var url = FIREBASE_URL_P +
        '/$id.json?auth=$authToken'; // url to the product entry in the database to be deleted. Identified by the id in
    // the url.
    try {
      final deleteResponse = await http
          .delete(url); // make the http delete request to delete the db entry.
      print(json.decode(deleteResponse.body));
    } catch (error) {
      // There was some trouble with the backend deletion. Undo the local delete (by inserting back) and proprogate
      // the error back to the caller widget to perform a UI action that can inform the user of the failed deletion.
      await addProduct(
          removedProduct); // Addback the removed product, both in the database and the local data array.
      notifyListeners(); // Can have multiple calls to notifyListeners() in the same method, for each of the data manipulation
      // operations.

      throw error;
    }

    // Cleanup the removed product entry if marked as favorite by this user (also the product owner).
    // Won't be able to cleanup this deleted product entry in favoites of other users as it is user-specific
    // and authentication would fail with the current auth token. So, need to track the deleted product-ids as
    // well in the Firestore backend, which can be referenced when loading favorites and accordingly looked-up
    // to delete any matching product entries.

    final userProdFavoriteUrl =
        FIREBASE_URL_UF + '/$userId/$id.json?auth=$authToken';

    try {
      // Delete all of this product data instances from user-favorites collection as well

      final deleteUserFavoritesResponse =
          await http.delete(userProdFavoriteUrl);
      print(
          'User favorite deletion response: ${json.decode(deleteUserFavoritesResponse.body)}');
    } catch (error) {
      print(error);
      throw error;
    }

    // Log the deleted product-id to lookup and cleanup its favorite entry in other users data, when they
    // login and try to access their favorites.
    url = FIREBASE_URL_DP + '/$id.json?auth=$authToken';

    try {
      final postResponse = await http.put( // To be RESTFUL, the update through PUT request has to be specific
                                           // to the document (with "id") and not the collection, like GET, POST.
        url,
        body: json.encode(
          true, // All product-ids as keys will have "true"
          // as the value signifying that it it has been
          // deleted. The '[]' operator will be used to
          // lookup the product-id which will return true or
          // null depending on the existence of the product-id
          // in the map. Accordingly, the favorite entry in the
          // user-data will be deleted through a REST api call.
        ),
      );

      print(json.decode(
        postResponse.body,
      ));
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
