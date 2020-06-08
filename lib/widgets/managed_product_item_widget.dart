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

    final scaffoldRef = Scaffold.of(context);

    return Column(
      children: <Widget>[
        ListTile(
          //key: ValueKey(productId), // Key's uniqueness is derived from the uniqueness of productId value
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
                      'productId':
                          productId, // Passing in the product name for screen appBar display.
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                  onPressed: () async {
                    // Tagged as method with asynchronous code, since deleteProductById returns a Future
                    try {

                      

                      // Display success message upon completion in a snackbar at the bottom of the app screen (Scaffold widget).
                      // If the context doesn't resolve here, can also have it declared in a variable (Scaffold.of(context)), above
                      // where the context is well-defined and not in a intermediary state.
                      Scaffold.of(context).hideCurrentSnackBar(); // Hides any existing snakbar before showing a new one 
                                                                  // with below code.

                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Deletion Successful !',
                            textAlign: TextAlign.center,
                          ),
                          duration: Duration(
                            seconds: 2,
                          ),
                        ),
                      );


                      await Provider.of<ProductsProvider>(context,
                              listen: false)
                          .deleteProductById(
                              productId); // Call the ProductsProvider delete method
                      // to remove the product with given id.
                      // Not listening to product data changes as
                      // it is being deleted here.

                      
                      
                    } catch (error) {
                      // For better user experience (UX), the nearest encapsulating Scaffold widget (screen: ProductManagerScreen) up the widget tree
                      // will have a snackbar displayed at the bottom to notify user of the failed deletion.

                      scaffoldRef.hideCurrentSnackBar(); // Hides any existing snakbar before showing a new one 
                                                                  // with below code.

                      scaffoldRef.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Deletion Failed !',
                            textAlign: TextAlign.center,
                          ),
                          duration: Duration(
                            seconds: 2,
                          ),
                        ),
                      );
                    }
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
