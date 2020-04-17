import 'package:flutter/material.dart';

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
class Cart with ChangeNotifier {
  Map<String, CartItem> _cartItems;

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

  void addItem(String productId, String productName, double productPrice) {
    // Need to check if the product being added to cart already exists or not, to take appropriate action.
    // Checks if the productId, which is also the key already exists
    if (_cartItems.containsKey(productId)) {
      _cartItems.update(
        productId,
        (matchedItem) => CartItem(
          id: matchedItem.id,
          name: matchedItem.name,
          price: matchedItem.price,
          quantity: matchedItem.quantity + 1,
        ),
      );
    } else {
      // Non-existent in the cart, so, create a new entry and add it to the cart map
      _cartItems.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          name: productName,
          price: productPrice,
          quantity: 1, // Only one item added to cart for each user-click.
        ),
      );
    } // end of else-part
  }
}
