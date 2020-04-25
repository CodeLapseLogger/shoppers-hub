import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/widgets/side_drawer_widget.dart';

import '../providers/products_provider.dart';

import './edit_product_screen.dart';

import '../widgets/managed_product_item_widget.dart';
import '../widgets/side_drawer_widget.dart';

class ProductManagerScreen extends StatelessWidget {

  static const routeName = '/product-manager';

  @override
  Widget build(BuildContext context) {
    ProductsProvider productCollection = Provider.of<ProductsProvider>(
        context); // Listener registered for data from ProductsProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products Manager',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add,),
            onPressed:(){
              Navigator.of(context).pushNamed(EditProductScreen.routeName); // No arguments passed with the routing call, unlike
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
      body: ListView.builder(
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
    );
  }
}
