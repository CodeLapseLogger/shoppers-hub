import 'package:flutter/material.dart';

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
  void addOrder(String orderId, List<CartItem> orderItemList, double payableAmt,
      DateTime orderedTime) {
    ordersPipeline.add(OrderItem(
      id: orderId,
      orderedItems: orderItemList,
      orderTotal: payableAmt,
      orderTimeStamp: orderedTime,
    ));

    notifyListeners(); // Very important to call this method inorder to have an automated notification setup for listeners
    // upon data changes.
  }
}
