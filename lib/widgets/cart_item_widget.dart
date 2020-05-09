import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final String cartItemProductId;

  CartItemWidget(
      {this.cartItem, // Cart entry. Used to display the cart entry details.
      this.cartItemProductId // Product-id associated with the cart entry. Used for identifying cart data to be deleted in
      // the provider, on delete action.
      });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(
        context); // State of inherited widget (context) captured here as "context" would be in an
    // unstable state when referenced in the try-catch block encapsulating the
    // cart item deletion operation from the local copy in the CartProvider, returning a
    // Future. This is more of a hack with the Stateless widget. A better management
    // possible with Stateful widget with the use of didChangeDependencies(). Need to
    // dig deeper.
    final CartProvider cartDetails =
        Provider.of<CartProvider>(context); // Registered listener for cart data

    return Dismissible(
      key: Key(
          cartItemProductId), // To uniquely identify this widget's corresponding entry in the element tree and avoid transference
      // of this widget's state to its replacement, as we delete this item from the cart with the screen swipe .
      direction: DismissDirection.endToStart, // in other words, right to left
      background: Container(
        // Container widget with delete icon and red color, to appear in the background when tile is swiped
        // from end -> start (or right -> left), creating a nice animation during the delete process.
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).primaryIconTheme.color,
          size: 30,
        ),
        color: Theme.of(context).errorColor,
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        padding: EdgeInsets.only(
          right: 12,
        ),
      ),
      confirmDismiss: (_) {
        return showDialog(
            // showDialog is a way to place a dialog widget on the app screen from a function that
            // doesn't return a widget. It is not tied to any widget on the app screen ( like Scaffold), so, it
            // is called directly.

            // Don't forget to return the Future<bool> given by showDialog method call, or else the desired effect
            // of dialog pop and chosen action can not be seen in the app.
            context: context,
            builder: (buildContext) {
              return AlertDialog(
                title: Text(
                  'Are you sure ?',
                ),
                content: Text(
                  'Do you really want to remove "${cartItem.name}" from your cart ?',
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Yes',
                    ),
                    onPressed: () {
                      // Possible place to call the delete method of the CartProvider************

                      Navigator.of(context).pop(
                          true); // upon button press, user intention is known, so, close the alert dialog
                      // and return the decision value reflecting the button text.
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'No',
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // upon button press, user intention is known, so, close the alert dialog
                      // and return the decision value reflecting the button text.
                    },
                  ),
                ],
              );
            });
      },
      onDismissed: (_) async {
        // Since we are only allowing one dismissible swipe direction, ignoring the direction input and no
        // other custom action would be necessary.

        try {
          await cartDetails.deleteItem(
              cartItemProductId); // Using the passed in cart item's product-id as key, corresponding entry will be removed from the cart.

          scaffold
              .hideCurrentSnackBar(); // Hide the exsiting SnackBar before creating a new one with below code.

          // Notify user of the successful operation through a message in a SnackBar tied to the closest Scaffold(or screen) widget
          // up the widget tree.
          scaffold.showSnackBar(
            SnackBar(
              duration: Duration(
                seconds: 2,
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '\'${cartItem.name}\' removed from cart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.done,
                    color: Colors.green,
                    size: 25,
                  ),
                ],
              ),
            ),
          );
        } catch (error) {
          scaffold
              .hideCurrentSnackBar(); // Hide the exsiting SnackBar before creating a new one with below code.

          // Notify user of the successful operation through a message in a SnackBar tied to the closest Scaffold(or screen) widget
          // up the widget tree.
          scaffold.showSnackBar(
            SnackBar(
              duration: Duration(
                seconds: 2,
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '\'${cartItem.name}\' could not be removed from cart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.error,
                    color: Theme.of(context).errorColor,
                    size: 25,
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Card(
        elevation: 6,
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Text(
                    '\$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                  ),
                ),
              ),
            ),
            title: Text(
              cartItem.name,
            ),
            subtitle: Text(
              '\$${cartItem.price}',
            ),
            trailing: Text(
              'X ${cartItem.quantity}',
            ),
          ),
        ),
      ),
    );
  }
}
