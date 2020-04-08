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

  @override
  Widget build(BuildContext context) {
    // Commented out Provider.of<> approach to try out an alternate way of setting-up listener in a widget for the
    // provider: ProductsProvider. The below line of code is perfectly fine to set-up a listener and works.

    // final List<ProductProvider> productList = Provider.of<ProductsProvider>(
    //         context)
    //     .products; // Fetching product list from the data provider: ProductsProvider

    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, _) {
        // The Conusmer provides access to an instance of provider, through which further
        // calls or references to methods, attributes of the Provider class can be done
        // to retrieve data, like the list of products below using the "products" get method.
        // Also, the named attribute "child" has been ignored (with an "_") in the builder method, as the
        // GridView.builder constructor itself doesn't contrsuct a widget to display static
        // content like a label, using a Text widget.

        List<ProductProvider> productList;
        
        // Additional check for data from parent widget ProductListingScreen, to know if user has chosen the favorites filter
        // or not. Accordingly, the appropriate list of products are being rendered from the provider: ProductsProvider, to be
        // displayed in a grid.
        
        if(filterFavorites){
          productList = productsProvider.favoriteProducts;
        }
        else{
          productList = productsProvider.products;
        }
        

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2, // height should be greater than width
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: productList.length,
          itemBuilder: (builderContext, productIdx) {
            //final ProductProvider product = productList[productIdx];

            return ChangeNotifierProvider.value(
              // Setting-up the provider above the ProductItemWidget, which listens for the ProductProvider
              // data. If context is needed then the normal constructor can be used instead of the value
              // contrsuctor.
              value: productList[productIdx],
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
          padding: EdgeInsets.all(10),
        );
      },
    );
  }
}
