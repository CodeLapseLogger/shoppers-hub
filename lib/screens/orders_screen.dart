import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';

import '../widgets/order_item_widget.dart';
import '../widgets/side_drawer_widget.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = "/orders";

  // Method with asynchronous code to refresh data in the OrdersProvider.
  Future<void> _refreshOrders(BuildContext context) async {
    await Provider.of<OrdersProvider>(context, listen: false).refreshOrderData(); // Need to have listen: false, as the
                                                                                  // notifyListeners will trigger a infinite
                                                                                  // loop build.
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Placed Orders',
        ),
      ),
      drawer: SideDrawerWidget(),
      body: RefreshIndicator(
              onRefresh: () async {
                // Asynchronous code to handle the future returned by _refreshOrders
                await _refreshOrders(context); // implicitly returns Future<void>
              },
              child: FutureBuilder(
                future: Provider.of<OrdersProvider>(context, listen: false).refreshOrderData(),
                builder: (buildContext, returnedFutureSnapshot) {
                  if (returnedFutureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    // Means the data is still loading and Future not yet done/ready to return
                    // the value of the Future
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (returnedFutureSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'ERROR: Orders rendering failed !',
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    // Everything went fine. Having Consumer provide data from OrdersProvider
                    // as only the ListView is to be updated and not the whole widget on any data changes in
                    // provider. Also, to avoid an infinite loop of build() method run if Provider data fetching
                    // done at the build() method scope.
                    return Consumer<OrdersProvider>(builder:
                        (consumerBuildContext, ordersCollection, staticChildWidget) {
                      return ListView.builder(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                        ),
                        itemBuilder: (listBuildContext, itemIdx) {
                          return OrderItemWidget(
                            orderData: ordersCollection.orders[itemIdx],
                            orderNum: itemIdx + 1,
                          );
                        },
                        itemCount: ordersCollection.orders.length,
                      );
                    });
                  }
                },
              ),
            ),
    );
  }
}
