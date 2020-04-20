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
class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

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
}
