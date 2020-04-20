import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

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
                      onPressed: () {},
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
            ),
            ListView.builder(
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
                initialScrollOffset: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
