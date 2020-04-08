import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';

import '../providers/product_provider.dart';

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
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
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
            leading: Consumer<ProductProvider>( // Listener to constantly look out for changes to the "favorite" state from
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
                  onPressed: () => product.switchProductFavoriteState(),
                );
              },
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }
}
