import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

import '../screens/edit_product_screen.dart';

class ManagedProductItemWidget extends StatelessWidget {
  final String productId;
  final String productName;
  final String productImageUrl;

  // Constructor initialized with data only needed by this widget. So, makes sense to pass on data through the constructor
  // as it is local state, rather than the provider/listener method which is better suited for global state.
  ManagedProductItemWidget({
    @required this.productId,
    @required this.productName,
    @required this.productImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              productImageUrl,
            ),
          ),
          title: Text(
            productName,
          ),
          trailing: Container(
            // Wrapped the Row as it looks for max width possible, but, we only need it to take a fraction
            // of the width. The fixed width of 100 helps with the widget layout by constraining the Row to
            // that size.
            width: 100,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    // Navigate to the EditProductScreen by pushing it on to Navigator's screen stack
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: {
                      'productId': productId, // Passing in the product name for screen appBar display.
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                  onPressed: () {
                    Provider.of<ProductsProvider>(context, listen: false).deleteProductById(productId); // Call the ProductsProvider delete method
                                                                                         // to remove the product with given id.
                                                                                         // Not listening to product data changes as
                                                                                         // it is being deleted here.
                  },
                ),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
