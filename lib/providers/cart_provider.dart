import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../firebase_urls.dart';

// Class to model a cart item entity, different from a product item, as cart item also has a quantity.
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.name,
    @required this.price,
    @required this.quantity,
  });
}

// Class representing the collection of cart items, with the mixin ChangeNotifier, giving it the capability of broadcasting or
// notifying the registered listeners in the widget tree for data changes from this Cart class turned data provider.
class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  Future<void> refreshShoppingCart() async {
    // method with asynchronous code to handle the http get request

    var getResponse;

    try {
      getResponse = await http.get(
        FIREBASE_URL_C + '.json',
      ); // Get the cart items stored in Firebase backend
    } catch (error) {
      print(error);
      throw error; // Forward the exception/error to the caller/client to have an appropriate action in place, like
      // notifying user of the error.
    }

    // Control reaches here if no error occured with the GET request

    _cartItems.clear(); // Clear old data from the local copy

    // Extract Firebase data from response body and repopulate _cartItems with that data
    final cartData = json.decode(getResponse.body) as Map<String, dynamic>;

    cartData.forEach((cartItemId, cartItemMapValue) {
      Map<String, dynamic> cartItemProdIdDataMap = cartItemMapValue
          as Map<String, dynamic>; // casting "dynamic" type value to
      // Map<prodId, Map<dataAttr, dataValue>>

      String cartProductId = cartItemProdIdDataMap.keys
          .toList()[0]; // Extracting the productId linked to cart item
      Map<String, dynamic> cartItemData = cartItemProdIdDataMap.values
          .toList()[0]; // converting "dynamic" value to list of
      // single entry and extracting it as a map.

      print('refreshShoppingCart - Cart item data: $cartItemData');

      // Add new cart item as local copy to _cartItems
      _cartItems.putIfAbsent(
        cartProductId,
        () => CartItem(
          id: cartItemId,
          name: cartItemData['name'],
          price: cartItemData['price'],
          quantity: cartItemData['quantity'],
        ),
      );
    });

    notifyListeners(); // Notify registered listeners

  }

  Map<String, CartItem> get cartItems {
    return {
      ..._cartItems
    }; // Returning a new data copy as by default it is passed by reference and state can get inconsistent
    // if modified by the listeners as well. Since this is the data provider, need to ensure it to be
    // the data hub and single place for data changes. That is the design aspect.
    // From developer point if view, it also helps with debugging.
    // The "..." is the spread operator to breakdown constituents of a collective iterable, to its
    // respective elements.
  }

  // Get method for listeners to access cart item count
  int get cartItemCount {
    return (_cartItems.isEmpty)
        ? 0
        : _cartItems
            .length; // Check if map is empty and accordingly return the item count
  }

  // Get method for listeners to access the total price of all cart items with their respective quantities
  double get totalItemPrice {
    double totalPrice = 0.0;

    if (_cartItems.isNotEmpty) {
      // keep updating totalPrice if there are cart items
      _cartItems.forEach((productId, cartItemEntry) {
        totalPrice += (cartItemEntry.price *
            cartItemEntry
                .quantity); // Adding on total price for the chosen quantity of cart entry.
      });
    }

    return totalPrice;
  }

  // Method for listeners to pass on data to the provider and add/update existing cart entry.
  Future<void> addItem(
      String productId, String productName, double productPrice) async {
    // Client connection to span multiple http requests. Should be closed explicitly when
    // all requests are done, unlike the requests made with "http" directly (like, http.get),
    // which opens and closes client connection for each request made.
    var client = http.Client();

    try {
      final getResponse = await client.get(FIREBASE_URL_C + '.json');

      print('Cart get response status code: ${getResponse.statusCode}');
      print('Cart get response body: ${json.decode(getResponse.body)}');

      if (json.decode(getResponse.body) == null) {
        // No cart collection has been created yet, requiring the first post request
        // to create the collection and the first cart item entry.
        final postResponse = await client.post(
          FIREBASE_URL_C + '.json',
          body: json.encode(
            {
              // Map with productId as key and value as anotehr Map with cart item data (in sync with CartItem).
              '$productId': {
                'name': productName,
                'price': productPrice,
                'quantity':
                    1, // Being the first cart item, quantity should be 1 to start with.
              },
            },
          ),
        );

        print('Cart post response status code: ${postResponse.statusCode}');
        print('Cart post response body: ${json.decode(postResponse.body)}');

        final cartItemFirebaseId = json.decode(postResponse.body)[
            'name']; // id of cart item entry created in Firebase
        print('Extracted cart item id in Firebase: $cartItemFirebaseId');

        // Non-existent in the cart, so, create a new entry and add it to the cart map
        _cartItems.putIfAbsent(
          productId,
          () => CartItem(
            id: cartItemFirebaseId,
            name: productName,
            price: productPrice,
            quantity: 1, // Only one item added to cart for each user-click.
          ),
        );
      } else {
        // "cart" collection has cart items
        Map<String, dynamic> cartDataMap = json.decode(getResponse.body);

        String existingCartItemId = "";
        Map<String, dynamic> existingCartEntryData;
        bool productExists = false;

        // Capture the cart item entry and data if it already exists
        cartDataMap.forEach((cartEntryId /*key*/, cartEntryData /*value*/) {
          // Single cart entry in db
          print('Cart item id: $cartEntryId');
          print('Cart item data: $cartEntryData');

          if (productExists == false) {
            final productCartData = cartEntryData
                as Map<String, dynamic>; //Map Entry: productId => cartData

            if (productCartData.containsKey(productId)) {
              existingCartItemId = cartEntryId;
              productExists = true;
              existingCartEntryData = productCartData.values
                  .toList()[0]; // Single cart item data converted to list from
              // the "values" iterable.
            }
          }
        });

        //final cartDataValues = cartDataMap.values as Map<String, dynamic>;

        // Update cart item quantity of it exists or add a new one if it doesn't already exist in the cart.
        if (productExists) {
          // product entry exists in the cart

          print('Existing cart item id: $existingCartItemId');
          print('Existing cart item data: $existingCartEntryData');
          print('Existing cart item name: ${existingCartEntryData['name']}');
          // so, update the existing product entry by incrementing its quantity by 1.
          await client.patch(
            FIREBASE_URL_C + '/$existingCartItemId.json',
            body: json.encode(
              {
                '$productId': {
                  'name': existingCartEntryData['name'],
                  'price': existingCartEntryData['price'],
                  'quantity': existingCartEntryData['quantity'] + 1,
                },
              },
            ),
          );

          // Update the local copy
          print('Local cart items: $_cartItems');
          _cartItems.update(
            productId,
            (matchedItem) {
              CartItem(
                id: matchedItem.id,
                name: matchedItem.name,
                price: matchedItem.price,
                quantity: matchedItem.quantity + 1,
              );
            },
          );
        } else {
          // product entry doesn't exist in teh cart, so, create one
          final postResponse = await client.post(
            FIREBASE_URL_C + '.json',
            body: json.encode(
              {
                // Map with productId as key and value as anotehr Map with cart item data (in sync with CartItem).
                '$productId': {
                  'name': productName,
                  'price': productPrice,
                  'quantity':
                      1, // Being the first cart item, quantity should be 1 to start with.
                },
              },
            ),
          );

          print('Cart post response status code: ${postResponse.statusCode}');
          print('Cart post response body: ${json.decode(postResponse.body)}');

          final cartItemFirebaseId = json.decode(postResponse.body)[
              'name']; // id of cart item entry created in Firebase
          print('Extracted cart item id in Firebase: $cartItemFirebaseId');

          // Non-existent in the cart, so, create a new entry and add it to the cart map
          _cartItems.putIfAbsent(
            productId,
            () => CartItem(
              id: cartItemFirebaseId,
              name: productName,
              price: productPrice,
              quantity: 1, // Only one item added to cart for each user-click.
            ),
          );
        }
      }
    } catch (error) {
      print(error);

      client
          .close(); // close the connection to Firebase backend before existing with the exception throw.
      // block above.

      throw (error); // Forward the error/exception to the client/caller to take appropriate action, like notifying user of the
      // error through the UI.
    } finally {
      client
          .close(); // close the connection to Firebase backend, as all requests should have been completed in the try/catch
      // block above.
    }

    notifyListeners(); // Really important to have this line of code in methods that change provider data, in order to notify
    // all listeners that have registered for data changes, and thereby accordingly perform required action
    // on their end.
  }

  // Method for listeners to perform the delete action on an existing item in the cart.
  void deleteItem(String itemKey) {
    final CartItem deletedItem = _cartItems.remove(itemKey);

    if (deletedItem == null) {
      print(
          "Error deleting item !\n itemKey: " + itemKey + "\nDetails below:\n");

      _cartItems.removeWhere((currentItemKey, currentItemValue) {
        print("currentItemKey: " +
            currentItemKey +
            ", itemName: " +
            currentItemValue.name +
            ", passed in item key: " +
            itemKey);
        return currentItemKey == itemKey;
      });
    } else {
      // returned is not null, meaning a match was found and deletion was successful
      print("Item Successfully deleted !\n itemKey: " +
          itemKey +
          ", CartItem name: " +
          deletedItem.name);
      notifyListeners(); // Never forget this line of code to notify listeners on data changes in a provider.
    }
  }

  // Method to reduce the quantity of a product in cart by 1, and to delete the entire product from the cart in case
  // its quantity would get to 0 after the reduction of its quantity.
  CartItem reduceProductQuantityByOne(String productId) {
    // Need to check the product's mapped cart item quantity for appropriate action. That is to just update or delete the whole entry.

    CartItem itemAfterStateChange;

    if (_cartItems['$productId'].quantity > 1) {
      itemAfterStateChange = _cartItems.update(
        productId,
        (matchedCartItem) {
          // Input argument is the CartItem instance that is the mapped value for the matching key (productId) in the map
          return CartItem(
            id: matchedCartItem.id,
            name: matchedCartItem.name,
            price: matchedCartItem.price,
            quantity: matchedCartItem.quantity - 1,
          );
        },
      );
    } else {
      // Current product quantity is 1, so, reducing it to 0 essentially implies a non-existant cart item and hence the need for its deletion.
      itemAfterStateChange = _cartItems.remove(productId);
    }

    notifyListeners(); // Notifies all listeners about the change in data state.
    return itemAfterStateChange;
  }

  // Method for listeners to clear all cart items
  void clear() {
    _cartItems.clear(); // empties the map.

    notifyListeners();
  }
}
