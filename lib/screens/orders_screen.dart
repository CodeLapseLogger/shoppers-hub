import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';

import '../widgets/order_item_widget.dart';
import '../widgets/side_drawer_widget.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = "/orders";

  @override
  Widget build(BuildContext context) {
    OrdersProvider ordersData = Provider.of<OrdersProvider>(context,
        listen: false); // listener set to false and data only
    // fetched once, as no data changes are
    // possible to cart items when cleared and
    // order items also can not be modified at
    // this time.
    List<OrderItem> ordersCollection = ordersData.orders;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Placed Orders',
          ),
        ),
        drawer: SideDrawerWidget(),
        body: ListView.builder(
          padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          itemBuilder: (buildContext, itemIdx) {
            return OrderItemWidget(
              orderData: ordersCollection[itemIdx],
              orderNum: itemIdx + 1,
            );
          },
          itemCount: ordersCollection.length,
        ));
  }
}
