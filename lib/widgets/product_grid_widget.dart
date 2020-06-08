import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_item_widget.dart';

import '../providers/products_provider.dart';
import '../providers/product_provider.dart';

class ProductGridWidget extends StatelessWidget {
  final bool filterFavorites;

  ProductGridWidget({
    @required this.filterFavorites,
  });

  Widget renderErrorWidget() {
    return Center(
      child: RichText(
        text: TextSpan(
            text: 'ERROR: Failed rendering favorites',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            )),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget renderGridViewBuilder(List<ProductProvider> products) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2, // height should be greater than width
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (builderContext, productIdx) {
        //final ProductProvider product = productList[productIdx];

        return ChangeNotifierProvider.value(
          // The earlier ChangeNotifierProxyProvider<AuthenticationProvider, ProductProvider>
          // instance has been replaced as it disposes off the passed in ProductProvider instance
          // from the local data array resulting in an app crash. So, the required auth details
          // needed for user authorization with REST api call, to update product favorite status,
          // is being accessed through a registered listener for AuthenticationProvider data inside
          // ProductItemWidget. Accordingly, auth details are being set in the ProductProvider instance
          // which is being sourced from this ChangeNotifierProvider instance and listened to in 
          // ProductItemWidget.
          value: products[productIdx],
          child: ProductItemWidget(
              // Commented out the code to pass-on data through the constructor, as data is now being passed
              // by a provider: ProductProvider, and the widget gets a hold of it through a listener set-up in
              // its build method.
              // productId: product.id,
              // productTitle: product.title,
              // productImageUrl: product.imageUrl,
              ),
        );
      },
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Commented out Provider.of<> approach to try out an alternate way of setting-up listener in a widget for the
    // provider: ProductsProvider. The below line of code is perfectly fine to set-up a listener and works.

    // final List<ProductProvider> productList = Provider.of<ProductsProvider>(
    //         context)
    //     .products; // Fetching product list from the data provider: ProductsProvider

    // Additional check for data from parent widget ProductListingScreen, to know if user has chosen the favorites filter
    // or not. Accordingly, the appropriate list of products are being rendered from the provider: ProductsProvider, to be
    // displayed in a grid.

    // This also separates out the asynchronous and synchronous code flow between the display of only favorites and all
    // products.
    if (filterFavorites) {
      return FutureBuilder(
        future: Provider.of<ProductsProvider>(context).favoriteProducts,
        builder: (builderContext, favoritesSnapshot) {
          // ConnectionState.waiting means that the request is still being processed
          if (favoritesSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (favoritesSnapshot.hasError) {
            return renderErrorWidget();
          } else {
            // Request has completed with a value
            final productList = favoritesSnapshot.data as List<ProductProvider>;
            return renderGridViewBuilder(productList);
          }
        },
      );
    } else {
      return Consumer<ProductsProvider>(
        builder: (consumerContext, productsProvider, _) {
          // The Conusmer provides access to an instance of provider, through which further
          // calls or references to methods, attributes of the Provider class can be done
          // to retrieve data, like the list of products below using the "products" get method.
          // Also, the named attribute "child" has been ignored (with an "_") in the builder method, as the
          // GridView.builder constructor itself doesn't contrsuct a widget to display static
          // content like a label, using a Text widget.

          List<ProductProvider> productList = productsProvider.products;

          return renderGridViewBuilder(
              productList); // grid with all products without the favorites filter
        },
      );
    }
  }
}
