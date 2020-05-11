import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';

import '../widgets/order_item_widget.dart';
import '../widgets/side_drawer_widget.dart';

class OrdersScreen extends StatefulWidget {
  static const String routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isDataLoading = true;
  bool isFirstBuild = true;

  @override
  void initState() {
    // To delay the execution and return of the Future from the OrdersProvider method: refreshOrderData.
    // Notice that the duration is Duration.zero and the method is not called here, but rather its reference is passed on
    // to be triggered after the intended delay and fetch the desired Future<void>.
    //
    // With Duration.zero, one might think that the method returning Future would execute immediately, but, there is an
    // event loop involved with Futures and with the delayed() method call, the execution of refreshOrderData is queued
    // to be triggered by the event loop when preceding entries in the queue are pushed on to the call stack and executed.
    // So, here, eventhough the build() method should technically run after the initState(), due to the Future.delayed, it
    // would be pushed to the call stack only after the build() finishes, which is the natural app execution flow. Once the
    // stack is empty, event loop then gets the opportuniry to pick entries from the start of its queue and push them on to
    // the call stack for execution.
    //
    // The dalayed Future is to ensure the refreshOrderData is executed only after the context has been created, as with the
    // natural execution flow of initState wouldn't have the required context. However, with the listen:false setting in
    // Provider, seems the entire context is not needed and can have below line in initState without delaying the Future.

    //if (isFirstBuild) {
      isDataLoading =
          true; // For displaying the CircularProgressIndicator during the network RESTFUL api call done in
      // refreshOrderData. Don't need setState here as this line of code in initState executes before
      // the build() method.

      //Future.delayed(Duration.zero).then((_){
      Provider.of<OrdersProvider>(context, listen: false)
          .refreshOrderData()
          .then((_) {
        setState(() {
      //    isFirstBuild = false;
          isDataLoading =
              false; // set to false after the data refresh. Note that setState() is being used in initState, as the
          // execution would be asynchronous and the build method have been executed and loaded the
          // CircularProgressLoader. The then() method which is executed after the refresh is then
          // pushed by event loop on to the call stack to execute and reset the flag to trigger the
          // build() method with the setState().
        });
      });
      //});

    //}

    // if (isFirstBuild) {
    //   Provider.of<OrdersProvider>(context).refreshOrderData().then((_) {
    //     isFirstBuild = false;
    //   }); // refresh orders data prior to build()
    // }

    // super.didChangeDependencies();
    super.initState();
  }

  // Method with asynchronous code to refresh data in the OrdersProvider.
  Future<void> _refreshOrders() async {
    await Provider.of<OrdersProvider>(context).refreshOrderData();
  }

  @override
  Widget build(BuildContext context) {
    OrdersProvider ordersData =
        Provider.of<OrdersProvider>(context /*,
        listen: false*/
            ); // listener set to false and data only
    // fetched once, as no data changes are
    // possible to cart items when cleared and
    // order items also can not be modified at
    // this time.
    List<OrderItem> ordersCollection = ordersData.orders;

    print('Orders screen - ordersCollection: $ordersCollection');

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Placed Orders',
          ),
        ),
        drawer: SideDrawerWidget(),
        body: isDataLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  // Asynchronous code to handle the future returned by _refreshOrders
                  await _refreshOrders(); // implicitly returns Future<void>
                },
                child: ListView.builder(
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
                ),
              ));
  }
}
