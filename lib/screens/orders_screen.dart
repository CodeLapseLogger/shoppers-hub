import "dart:async";

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expired_authorization_exception.dart';

import '../providers/orders_provider.dart';

import '../widgets/order_item_widget.dart';
import '../widgets/side_drawer_widget.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = "/orders";

  // Method with asynchronous code to refresh data in the OrdersProvider.
  Future<void> _refreshOrders(BuildContext context) async {
    await Provider.of<OrdersProvider>(context, listen: false)
        .refreshOrderData(); // Need to have listen: false, as the
    // notifyListeners will trigger a infinite
    // loop build.
  }

  bool _isLoggingOut =
      true; // Set to true to start with the handling of expired auth token

  // Callback method for the timer set in logoutTransition()
  void _logoutTimerCallback(BuildContext ctx) {
    _isLoggingOut =
        false; // This stops the CircularProgressIndicator from loading and marks the completion of logout

    // Complete the logout transition by loading the login screen and removing all other screens from
    // the navigator stack.
    Navigator.of(ctx).pushNamedAndRemoveUntil(
      '/', // Home route: AuthenticationScreen(), as it is not part of the "routes" table
      ModalRoute.withName(
          '/'), // Remove all screens from the Navigator stack except for the loaded login screen.
    );
  }

  // Method to initiate and carryout the logout transition
  void _logoutTransition(BuildContext ordersContext) {
    Timer(
      Duration(seconds: 3),
      () => _logoutTimerCallback(ordersContext),
    );
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
          future: Provider.of<OrdersProvider>(context, listen: false)
              .refreshOrderData(),
          builder: (buildContext, returnedFutureSnapshot) {
            if (returnedFutureSnapshot.connectionState ==
                ConnectionState.waiting) {
              // Means the data is still loading and Future not yet done/ready to return
              // the value of the Future
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (returnedFutureSnapshot.hasError) {
              var exception;
              var errMsg;

              if (returnedFutureSnapshot.error
                  is ExpiredAuthorizationException) {
                exception = returnedFutureSnapshot.error
                    is ExpiredAuthorizationException;
                errMsg = exception.toString();
              } else {
                // Unknown error
                errMsg = "ERROR: Orders rendering failed !";
              }

              if (errMsg == "Authorization Expired") {
                _logoutTransition(
                    context); // Kick-off the timed logout transition to the login screen

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      RichText(
                        // To have parts of text with custom styling
                        text: TextSpan(
                          // Error message in red
                          text: errMsg,
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: "\nLogging out . . .",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        //style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, )
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (_isLoggingOut) CircularProgressIndicator(),
                    ],
                  ),
                );
              } else {
                // Unknown error
                return Center(
                  child: Text(
                    errMsg,
                    style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
            } else {
              // Everything went fine. Having Consumer provide data from OrdersProvider
              // as only the ListView is to be updated and not the whole widget on any data changes in
              // provider. Also, to avoid an infinite loop of build() method run if Provider data fetching
              // done at the build() method scope.
              return Consumer<OrdersProvider>(builder:
                  (consumerBuildContext, ordersCollection, staticChildWidget) {
                final ordersCnt = ordersCollection.orders.length;

                if (ordersCnt == 0) {
                  // No orders have been placed yet by the logged=in user
                  return Center(
                    child: Text(
                      'You haven\'t placed any orders yet !',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  );
                } else {
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
                    itemCount: ordersCnt,
                  );
                }
              });
            }
          },
        ),
      ),
    );
  }
}
