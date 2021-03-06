import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for formatting DateTime objects

import '../providers/orders_provider.dart'
    show OrderItem; // Only importing the model: OrderItem and not the provider

class OrderItemWidget extends StatefulWidget {
  final OrderItem orderData;
  final int orderNum;

  OrderItemWidget({@required this.orderData, @required this.orderNum});

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool isExpanded =
      false; // Flag to track if the user has clicked on the expand-{more,less} icon button for order details.
  // Accordingly, the icon and details are displayed for that order.
  // By default, the details are not expanded. So, value is set to false.

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: 300,
      ),
      height: (isExpanded)
          ? min(widget.orderData.orderedItems.length * 30.0 + 120.0,
              240.0) // 25.0 is the estimated pixels for each item
          // + 110.0 for additional spacing with rest of
          // order data and spacing. So, having an
          // estimate of things does help in formulating
          // the UI layout and feel.
          : 100, // 100px when not expanded
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        elevation: 8,
        child: Column(
          // Wrapped in a column to allow conditional inclusion of widget with order details toward the end.
          children: <Widget>[
            ListTile(
              leading: Text(
                '\$${widget.orderData.orderTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              title: Text('Order # ${widget.orderNum}'),
              subtitle: Text(
                  '${DateFormat.yMMMd().format(widget.orderData.orderTimeStamp)}'),
              trailing: IconButton(
                icon: (isExpanded)
                    ? Icon(Icons.expand_more)
                    : Icon(Icons.expand_less),
                onPressed: () {
                  setState(() {
                    isExpanded =
                        !isExpanded; // toggle/negate the existing flag value.
                  });
                },
              ),
            ),
            AnimatedContainer(
              // Turned normal container to AnimatedContainer, removing the if-condition
              // and putting it in the height which can be the input data to AnimatedContainer
              // to carry out the animation. Seems default is a Tween<double> animation with
              // curve: linear.
              duration: Duration(
                milliseconds: 300,
              ),
              height: isExpanded
                  ? min(widget.orderData.orderedItems.length * 30.0 + 20.0,
                      200.0) // 25.0 is the estimated pixels for each item
                  // + 10.0 for additional spacing. So, having an
                  // estimate of things does help in formulating
                  // the UI layout and feel.
                  : 0, // 0px when not expanded
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                // Wrapped in a container with a set height does help with having an estimate of the widget layout
                // with this inner-most ListView widget wrapped in column and an outer ListView.
                itemBuilder: (orderItem, itemIdx) {
                  return Row(
                    // Not wrapped in a ListTile, as this is a sub-widget of a outer ListTile, and content should blend in.
                    children: <Widget>[
                      Text(
                        '${widget.orderData.orderedItems[itemIdx].name}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.orderData.orderedItems[itemIdx].quantity} x ${widget.orderData.orderedItems[itemIdx].price}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  );
                },
                itemCount: widget.orderData.orderedItems.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
