import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart_provider.dart';

import '../models/expired_authorization_exception.dart';

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

  // Property to hold the authentication token and userId to be used with REST API calls.
  String authToken="";
  String userId="";

  // Setter to set the authToken
  set authorizationToken(String userToken){
    authToken = userToken;
  }

  // Setter to set the userId
  set userIdentification(String uId){
    userId = uId;
  }



  // Refresh local orders data copy with new data from remote Firebase db
  Future<void> refreshOrderData() async {

    var getResponse;

    try {


      // Clear existing order data before repopulating the order list.
      // Note: It is important to clear the orders list before this method returns
      // because of no orders data sent by the GET response.
      // Within the emulator, it might be fine as data get purged with each refresh (without autologin yet).
      // But, when installed on a device, there wont be an app restart (unless user kills and restarts the device).
      // So, when one user logs out and another user logs in to the app on the same device, orders data from previous
      // login will still be available if not cleared here, leading to data privacy violation.
      ordersPipeline.clear();
      notifyListeners();

      getResponse = await http.get(FIREBASE_URL_O + '/$userId.json?auth=$authToken'); // URL for user-specific orders

      print('Orders get response body: ${json.decode(getResponse.body)}');

      final Map<String, dynamic> orderData = json.decode(getResponse.body);

      if(orderData == null){ // Means no orders have been placed by the logged-in user yet
        return;
      }

      // Check if there was an error with authenticating the get api call
      if(orderData['error'] != null){
          final errMsg = orderData['error'] as String;
          if(errMsg.contains("auth token")){
            throw ExpiredAuthorizationException(errorMessage: "Authorization Expired");
          }
      }

      
      // Extract order data from the GET response, convert it to instances of OrderItem and add to the local order data copy
      // in ordersPipeline.
      orderData.forEach((orderId, orderDetails) {
        final List<dynamic> mappedCartItemList =
            orderDetails['orderedCartItems'];

        var itemIdx = 0; // Id of the cart item
        
        // Extract the cart item data from the dynamic data in the GET response
        final List<CartItem> cartItemList =
            mappedCartItemList.map((dynamicCartItemData) {

          // Decode and create new CartItem instance    
          CartItem decodedCartItem =  CartItem(
            id: itemIdx.toString(), // 
            name: dynamicCartItemData['name'],
            price: dynamicCartItemData['price'],
            quantity: dynamicCartItemData['quantity'],
          );

          itemIdx++; // Incremented to set as id for next decoded CartItem

          return decodedCartItem;

        }).toList(); // Convert the iterable to a list

        // Create and add order items as OrderItem instances to the ordersPipeline list
        ordersPipeline.add(
          OrderItem(
            id: orderId,
            orderedItems: cartItemList,
            orderTotal: orderDetails['totalOrderAmt'],
            orderTimeStamp: DateTime.parse(orderDetails['orderPlacementTime']), // Parse the string representing
                                                                                // the date/time of placed order to
                                                                                // convert to DateTime.
          ),
        );

        print('Intermediate ordersPipeline state: $ordersPipeline');

      });
    } catch (error) {
      print(error);
      print(getResponse.statusCode);
      print(json.decode(getResponse.body));
      throw error;
    } finally {
      notifyListeners();
    }

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
      final postResponse = await http.post(
        FIREBASE_URL_O + '/$userId.json?auth=$authToken',
        body: json.encode({
          'orderedCartItems': orderItemList,
          'totalOrderAmt': payableAmt,
          'orderPlacementTime': orderedTime.toString(),
        }, toEncodable: (cartItem) {
          // The toEncodable attribute is a way to provide an encoder function that can encode
          // user-defined/custom data types to JSON. Here the custom type is CartItem,
          // that types all entries in the list: orderItemList.
          // Alternative is to directly convert the list entries to map objects (JSON format),
          // using the .map() method.
          CartItem castedCartItem = cartItem as CartItem;
          return {
            'name': castedCartItem.name,
            'price': castedCartItem.price,
            'quantity': castedCartItem.quantity,
          };
        }),
      );

      String firebaseOrderId = json.decode(postResponse.body)['name'];

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
