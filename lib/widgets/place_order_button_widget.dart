import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import '../providers/cart_provider.dart'; // Don't need explicit import as "final" qualifier handles inbound CartProvider
                                            // instance with "dynamic" type. All method calls done on that "dynamic" instance
                                            // (which is actually of type CartProvider) will resolve at run-time. The ones
                                            // that don't resolve will lead to a run-time error.
import '../providers/orders_provider.dart';

class PlaceOrderButtonWidget extends StatefulWidget {

  final cartDetails;

  PlaceOrderButtonWidget({@required this.cartDetails,});

  @override
  _PlaceOrderButtonWidgetState createState() => _PlaceOrderButtonWidgetState();
}

class _PlaceOrderButtonWidgetState extends State<PlaceOrderButtonWidget> {

  bool isOrderBeingPlaced =
      false; // Track the order processing state of the screen

  @override
  Widget build(BuildContext context) {
    return isOrderBeingPlaced // To have the circular loader in just the button, as an indication of 
                                                 // order being processed with the button press. This loader state is
                                                 // actually set in the code set to execute on button press.
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : FlatButton(
                                      // Toggle color between disabled and active button states
                                      //color: cartDetails.cartItemCount == 0 ? Colors.grey : Theme.of(context).primaryColor,
                                      disabledColor: Colors.grey[200],
                                      onPressed:
                                          // To have a disabled button when there
                                          // are no items in the cart, onPressed is
                                          // being set to null.
                                          widget.cartDetails.cartItemCount == 0
                                              ? null
                                              : () async {
                                                  // Method with asynchronous code to handle the Future returned by
                                                  // addOrder() method.

                                                  setState(() {
                                                    isOrderBeingPlaced =
                                                        true; // Mark the start of order processing stage and,
                                                    // rebuild this screen to reflect the state on the UI.
                                                  });

                                                  try {
                                                    // Add cart item collection as an order to the OrdersProvider and Firebase backend.
                                                    await Provider.of<
                                                                OrdersProvider>(
                                                            context)
                                                        .addOrder(
                                                      DateTime.now().toString(),
                                                      widget.cartDetails
                                                          .cartItems.values
                                                          .toList(),
                                                      widget.cartDetails
                                                          .totalItemPrice,
                                                      DateTime.now(),
                                                    );

                                                    // Clear cart items from Firebase backend and also the local copy
                                                    await widget.cartDetails.clear();

                                                   Scaffold.of(context).hideCurrentSnackBar(); // Hide existing SnackBar before
                                                    // creating a new one.

                                                    // Display the success message in a SnackBar at the screen bottom
                                                    Scaffold.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Text(
                                                              'Order placed successfully !',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 15,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            Icon(
                                                              Icons.done,
                                                              color:
                                                                  Colors.green,
                                                              size: 25,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  } catch (error) {
                                                    print(error);
                                                    Scaffold.of(context)
                                                        .hideCurrentSnackBar(); // Hide existing SnackBar before
                                                    // creating a new one.

                                                    // Display the failure message in a SnackBar at the screen bottom
                                                    Scaffold.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Text(
                                                              'Order could not be processed !',
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .errorColor,
                                                                fontSize: 15,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            Icon(
                                                              Icons.error,
                                                              color: Theme.of(
                                                                      context)
                                                                  .errorColor,
                                                              size: 25,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  setState(() {
                                                    isOrderBeingPlaced =
                                                        false; // Mark the end of order processing stage and,
                                                    // rebuild this screen to reflect the state on the UI. Done irrespective of
                                                    // the order processing outcome.
                                                  });
                                                },
                                      child: Text(
                                        'Place Order',
                                        style: TextStyle(
                                          // Toggle color between disabled and active button states.
                                          color: widget.cartDetails.cartItemCount == 0
                                              ? Colors.grey
                                              : Theme.of(context).primaryColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
  }
}