import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/widgets/side_drawer_widget.dart';

import '../providers/products_provider.dart';

import './edit_product_screen.dart';

import '../widgets/managed_product_item_widget.dart';
import '../widgets/side_drawer_widget.dart';

class ProductManagerScreen extends StatelessWidget {
  static const routeName = '/product-manager';

  bool isDataLoading =
      false; // To track the data loading/rendering state of the screen

  final scaffoldStateRef = GlobalKey<ScaffoldState>();

  // Method to refresh the product data in the provider and notify its listeners (ProductManagerScreen is one of them),
  // and get access to latest data to be displayed in the UI.
  Future<void> refreshUsersProductData(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .refreshProducts(true); // just to refresh data but not a listener
    // as the build method also has a registered
    // listener. Also, the input argument is to set the flag to fetch 
    // user-specific product data.
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldStateRef,
      appBar: AppBar(
        title: const Text(
          'Products Manager',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName)
                  .then((returnMessage) {
                Map<String, String> msgData =
                    returnMessage as Map<String, String>;
                if (msgData['successMessage'].isNotEmpty) {
                  scaffoldStateRef.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                        msgData['successMessage'],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              }); // No arguments passed with the routing call, unlike
              // the action for edit, where existing product id is
              // passed as an argument for rendering form filled in
              // with details of existing product.
              // The EditProductScreen is essentially being reused
              // with both add/update operations.
            },
          ),
        ],
      ),
      drawer: SideDrawerWidget(),
      body: FutureBuilder(
        future:
            Provider.of<ProductsProvider>(context, listen: false).refreshProducts(true), // Rendered data is void, so can not use
                                                                               // "data" attribute in userOwnedProdSnapshot
                                                                               // for the list of products to be displayed
                                                                               // in ListView.builder below. For that
                                                                               // reason, Consumer<ProductsProvider> has been
                                                                               // used to render the required data from provider
                                                                               // Since , it is wired to always listen to changes
                                                                               // in provider data, will be reactive and consistent
                                                                               // with all data changes in the local product 
                                                                               // collection. So, run all aysnchronous code first
                                                                               // with FutureBuilder, followed by synchronous data
                                                                               // access through Consumer<ProductProvider> within
                                                                               // the FutureBuilder. The reversed widget hierarchy,
                                                                               // with asynchronous code nested in synchronous code
                                                                               // will not lead to desired effect of pause in the
                                                                               // synchronous code, so as to wait for completion of
                                                                               // asynchronous action with value. It will only have 
                                                                               // Future<value> that can not be used for rendering
                                                                               // data in widgets.
        builder: (builderContext, userOwnedProdSnapshot) {
          if (userOwnedProdSnapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (userOwnedProdSnapshot.hasError) {
            return Center(
              child: Text(
                'ERROR: Products rendering failed',
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            );
          } else {
            // Future successfully rendered a value
            return RefreshIndicator(
              onRefresh: () async {
                // As the method to refresh data needs the context, it has been inside a wrapper method that is
                // also asynchronous to handle the Future returned by the method and also satisfy the requirement
                // of the onRefresh attribute.
                await refreshUsersProductData(context);
              },
              child: Consumer<ProductsProvider>(
                builder: (consumerContext, productProviderInstance, _ /* ignoring static child widget, as there isn't
                                                                                one in ListView.builder*/) =>
                              ListView.builder(
                  itemBuilder: (buildContext, productIdx) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ManagedProductItemWidget(
                        productId: productProviderInstance.products[productIdx].id,
                        productName: productProviderInstance.products[productIdx].title,
                        productImageUrl:
                            productProviderInstance.products[productIdx].imageUrl,
                      ),
                    );
                  },
                  itemCount: productProviderInstance.products.length,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
