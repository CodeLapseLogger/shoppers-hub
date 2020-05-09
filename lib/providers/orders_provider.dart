import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart_provider.dart';

import '../firebase_urls.dart';

// Class to model an order item (collection of items in the cart)
class OrderItem {
  final String id;
  final List<CartItem> orderedItems;
  final double orderTotal;
  final DateTime orderTimeStamp;

  OrderItem({
    @required this.id,
    @required this.orderedItems,
    @required this.orderTotal,
    @required this.orderTimeStamp,
  });
}

// Provider class to create/manage OrderItem instances and supply requested orders data to listeners setup at different widgets
// in the widget tree.

class OrdersProvider with ChangeNotifier {
  List<OrderItem> ordersPipeline =
      []; // Always initialize provider data to avoid access to null during run-time

  // Get method for listeners to access all the orders in the pipeline
  List<OrderItem> get orders {
    return [...ordersPipeline];
  }

  // Method for listeners to add as order to the pipeline
  Future<void> addOrder(String orderId, List<CartItem> orderItemList,
      double payableAmt, DateTime orderedTime) async {
    // Convert the cart item list in to a nested map to be json encodable data in the POST request body.
    // final cartItemDataIterable = orderItemList.map((cartItem) {
    //   return {
    //     'name': cartItem.name,
    //     'price': cartItem.price,
    //     'quantity': cartItem.quantity
    //   };
    // });

    // Add the new order entry to the Firebase backend
    try {
      final getResponse = await http.post(
        FIREBASE_URL_O + '.json',
        body: json.encode({
          'orderedCartItems':
              orderItemList,
          'totalOrderAmt': payableAmt,
          'orderPlacementTime': orderedTime.toString(),
        }, toEncodable: (cartItem) { // The toEncodable attribute is a way to provide an encoder function that can encode
                                     // user-defined/custom data types to JSON. Here the custom type is CartItem,
                                     // that types all entries in the list: orderItemList.
          CartItem castedCartItem = cartItem as CartItem;
          return {
            'name': castedCartItem.name,
            'price': castedCartItem.price,
            'quantity': castedCartItem.quantity,
          };
        }),
      );

      String firebaseOrderId = json.decode(getResponse.body)['name'];

      ordersPipeline.add(OrderItem(
        id: firebaseOrderId,
        orderedItems: orderItemList,
        orderTotal: payableAmt,
        orderTimeStamp: orderedTime,
      ));

      notifyListeners(); // Very important to call this method inorder to have an automated notification setup for listeners
      // upon data changes.

    } catch (error) {
      print(error);
      throw error; // For the widget world to have appropriate handling, like notifying user about the error, through a UI
      // component.
    }
  }
}
