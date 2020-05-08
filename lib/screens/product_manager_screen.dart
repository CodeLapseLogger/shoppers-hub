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
  Future<void> refreshProductData(BuildContext context) async{
    await Provider.of<ProductsProvider>(context).refreshProducts();
  }


  @override
  Widget build(BuildContext context) {
    ProductsProvider productCollection = Provider.of<ProductsProvider>(
        context); // Listener registered for data changes from ProductsProvider.

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
      body: RefreshIndicator(
        onRefresh: () async{ // As the method to refresh data needs the context, it has been inside a wrapper method that is 
                             // also asynchronous to handle the Future returned by the method and also satisfy the requirement
                             // of the onRefresh attribute.
          await refreshProductData(context);
        },
              child: ListView.builder(
          itemBuilder: (buildContext, productIdx) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ManagedProductItemWidget(
                productId: productCollection.products[productIdx].id,
                productName: productCollection.products[productIdx].title,
                productImageUrl: productCollection.products[productIdx].imageUrl,
              ),
            );
          },
          itemCount: productCollection.products.length,
        ),
      ),
    );
  }
}
