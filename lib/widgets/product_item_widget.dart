import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';

class ProductItemWidget extends StatelessWidget {
  // final String productId;
  // final String productTitle;
  // final String productImageUrl;

  ProductItemWidget(
      //{
      // @required this.productId,
      // @required this.productTitle,
      // @required this.productImageUrl,
      //}
      );

  @override
  Widget build(BuildContext context) {
    // Listener to listen for product data from ProductProvider instance, just once during creation and not subsequent changes.
    // The ProductProvider instances are created in ProductsProvider (difference is only an 's' in the name after 'Product'),
    // with data that won't be changing during the app lifecycle, including the method associated with switching the product
    // state of being a favorite or not. So, there isn't any need to listen for future data changes post creation. Hence, the
    // "listen" attribute has been set to false.
    final ProductProvider product = Provider.of<ProductProvider>(context,
        listen:
            false); // Unlike Consumer<ProductProvider> approach of setting up a
    // listener, which is hard-wired to listen to data changes signalled
    // by the associated provider ProductProvider,
    // ProviderProvider.of<ProductProvider> has the option to
    // turn-off the listening capability to any data change notifications
    // initiated by ProductProvider.
    //
    // However, with the Consumer approach there is also the benefit of minimizing
    // the widget area that needs to rebuild with each Provider notification, by only
    // wrapping the sub-widget with the Consumer<> widget and localizing the effect,
    // which also improves the user experience with reduced work with the widget/UI
    // rebuild.

    final CartProvider cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[
            16], // Box shadow for elevation 12. Helps with better visualization of the
        // product item in the viewport. There are also other possible elevations
        // with max of 24.
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            child: Hero(
              // Hero animation is to enable a smooth transition of bringing in an image over from previous
              // screen to the current screen.
              // Essentially used between two screens and same widget and tag named attribute, is to be setup
              // in both source and target screens to map and enable the image transition between the two.
              tag: product
                  .id, // Tag to probably uniquely identify the target of animated transition in the
              // previous screen when transitioning to the next screen.
              child: FadeInImage(
                // Animated image widget to display a placeholder image while
                // the actual image is loading and to fade it in once fully
                // loaded over the network.
                // placeholder and image are image providers and not Image widgets
                // like Image.network().
                placeholder: AssetImage(
                  "assets/images/product-placeholder.png",
                ),
                image: NetworkImage(
                  product.imageUrl,
                ),
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              // Code to push ProductDetailScreen on to Navigator as an anonymous/ or un-named route

              // Navigator.of(context).push(MaterialPageRoute(builder: (context){
              //    return ProductDetailScreen(title: productTitle);
              // }),);

              // Code to push ProductDetailScreen on to Navigator as a named route in the
              Navigator.of(context)
                  .pushNamed(ProductDetailScreen.routeName, arguments: {
                'id': product.id,
              });
            },
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            leading: Consumer<ProductProvider>(
              // Listener to constantly look out for changes to the "favorite" state from
              // the associated ProductProvider, up the widget tree, which when found is set
              // to the "product" argument in the builder method.
              // The "_"  argument is the named "child" argument which is being ignored here,
              // hence the "_". If there are parts of the widget that are to still remain
              // unchanged then the "child" argument of the Consumer<> widget can be set,
              // which is then assigned to "child" argument of the builder method in Consumer<>.
              // That wiring between the Consumer<> named "child" attribute and the builder
              // "child" attribute is taken care of by Flutter.
              builder: (context, product, _) {
                return IconButton(
                  icon: product.isFavorite
                      ? Icon(
                          Icons.favorite,
                          color: Theme.of(context).accentColor,
                        )
                      : Icon(
                          Icons.favorite_border,
                          color: Theme.of(context).accentColor,
                        ),
                  onPressed: () async {
                    // method with asynchronous code to handle the returned Future and possible failed state
                    // change.

                    try {
                      await product
                          .switchProductFavoriteState(); // wait until the state switch completes

                      Scaffold.of(context)
                          .hideCurrentSnackBar(); // Hide existing Snackbar before popping in the new one

                      // Display success message in a Snackbar at the bottom
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            product.isFavorite
                                ? '\'${product.title}\' marked as favorite !'
                                : '\'${product.title}\' unmarked as favorite !',
                            textAlign: TextAlign.center,
                          ),
                          duration: Duration(
                            seconds: 2,
                          ),
                        ),
                      );
                    } catch (error) {
                      Scaffold.of(context)
                          .hideCurrentSnackBar(); // Hide existing Snackbar before popping in the new one

                      // handle error by displaying the error message in a SnackBar at the bottom of he screen.
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                          ),
                          duration: Duration(
                            seconds: 2,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () async {
                // asynchronous method to handle the future returned by addItem
                await cart.addItem(
                    product.id,
                    product.title,
                    product
                        .price); // Adds/updates the product item/quantity in the cart.

                // To address possible race conditions with asynchronous code run a loop until data is refreshed
                var cartItemData = cart.cartItems.values;

                while (cartItemData == null) {
                  // Loop breaks only when cartItemData references valid data
                  cartItemData = cart.cartItems.values;
                }

                // Control reaches here only when the cart item data has been extracted from Cart Provider
                int currentItemQuantity = cartItemData
                    .where((cartItem) {
                      return cartItem.name == product.title;
                    })
                    .toList()[
                        0] // Converted to single item list with matching item
                    .quantity;

                Scaffold.of(context)
                    .hideCurrentSnackBar(); // This comes in handy for immediate successive clicks on the shopping cart icon,
                // By closing the snackbar for prior click first before triggering snackbar for
                // current click event.
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added "${product.title}" to cart (quantity: $currentItemQuantity)',
                    ),
                    action: SnackBarAction(
                        label: "UNDO",
                        onPressed: () {
                          CartItem revertedCartItem =
                              cart.reduceProductQuantityByOne(product.id);
                          print(
                              'Item name: ${revertedCartItem.name}, quantity before undo: $currentItemQuantity, quantity after undo: ${revertedCartItem.quantity}');
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: (currentItemQuantity ==
                                      revertedCartItem.quantity)
                                  ? Text(
                                      'Removed "${revertedCartItem.name}" from cart',
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      'Reduced "${revertedCartItem.name}" quantity to ${revertedCartItem.quantity}',
                                      textAlign: TextAlign.center,
                                    ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
