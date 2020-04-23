import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';

import '../widgets/cart_item_widget.dart';

class CartDetailScreen extends StatelessWidget {
  static const routeName =
      "/cart-detail"; // defined in a static const variable to give it the scope of this class and also to
  // allow its use in the client(another class that interfaces through this class api),
  // thereby avoiding typos.

  @override
  Widget build(BuildContext context) {
    CartProvider cartDetails = Provider.of<CartProvider>(
        context); // Registered listener for the data provider CartProvider.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart Items',
        ),
      ),
      body: SingleChildScrollView(
        //primary: true,
        controller: ScrollController(),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 6,
              margin: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Spacer(), // Take up available space, creating appropriate space between the encapsulating widgets.
                    Chip(
                      label: Text(
                        '\$${cartDetails.totalItemPrice.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).primaryTextTheme.title.copyWith(
                                  fontSize: 15,
                                ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    FlatButton(
                      onPressed: () {
                        // Add cart item collection as an order to the OrdersProvider.
                        Provider.of<OrdersProvider>(context).addOrder(
                          DateTime.now().toString(),
                          cartDetails.cartItems.values.toList(),
                          cartDetails.totalItemPrice,
                          DateTime.now(),
                        );

                        // Clear cart items
                        cartDetails.clear();
                      },
                      child: Text(
                        'Place Order',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey[400],
              //height: MediaQuery.of(context).size.height * 0.05,
            ),
            Container(
              height:
                  (MediaQuery.of(context).orientation == Orientation.landscape)
                      ? 200
                      : (MediaQuery.of(context).size.height -
                          MediaQuery.of(context)
                              .viewInsets
                              .top) /* For Portrait Orientation: Total Height - Height of insets at the top (appBar) */,
              child: ListView.builder(
                // Can't really use Expanded with lists/grids as all available space will be taken up by them
                // affecting the layout of other elements in terms of available space distribution on thw whole screen.
                // Ok, to use with fixed number of elements, rather than dynamic item counts, like in the ListView.builder.
                itemCount: cartDetails.cartItemCount,
                itemBuilder: (builderContext, itemIdx) {
                  return CartItemWidget(
                    cartItem: cartDetails.cartItems.values.toList()[itemIdx],
                    cartItemProductId:
                        cartDetails.cartItems.keys.toList()[itemIdx],
                  ); // All data needed for display
                  // will be taken out from the
                  // cartItem by CartItemWidget
                  // while building.
                },
                shrinkWrap: true,
                controller: ScrollController(
                  initialScrollOffset: 1,
                  keepScrollOffset: true,
                ),
                //itemExtent: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
