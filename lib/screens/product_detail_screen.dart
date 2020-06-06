import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // Route name has been made part of this screen itself to allow ease of use when mounting it as top/focus of he viewport
  // through Navigator and to avoid any typos. Setting done here would be the single source of an issue and thereby also easy
  // to debug.
  static const routeName = "/product-detail";

  // Variable declaration and initialization through data passed in to the constructor.
  // The constructor would be a way to pass data when pushing this screen on to the Navigator as an anonymous route, or,
  // in other words not a named route set in the main MaterialApp widget.
  // final title;

  // ProductDetailScreen({
  //   @required this.title,
  // });

  @override
  Widget build(BuildContext context) {
    // Access route parameters passed as arguments when onboarding this screen onto the navigator as a named route,
    // set in the main MaterialApp widget. Apparently, the type-cast to Map<String, String> doesn't work as the arguments
    // passed in with Navigator.of(context).pushNamed() are of type object. However, it is possible after extracting the
    // arguments.

    // Even if the type is not explicity mentioned in our code, when the data is populated in the widgets, like the Text widget
    // below, which have explicit types, if we indeed pass on a string between screens and widgets, implicit type-casting is
    // happening during the widget creation/building process. Probably an error/exception would be thrown when casting is not
    // possible.

    // However, for code readability/maintainability, it is probably best to have explicit types during variable declaration
    // in classes that model data and widgets. It would certainly be helpful for others to quickly follow code, and also the
    // author when referencing code after a while.

    final routeArguments =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final String prodId =
        routeArguments['id']; // product id fetched as a route argument.
    // This is better approach compared to getting
    // each individual data value as a route argument,
    // as the central data management done in ProductsProvider
    // can give the product item with id that matches prodId.

    // Render the matching product using the prodId through the provider, by setting up a listener.
    // Here, the listen attribute in the listener set-up is set to false as we are only interested in
    // getting product info that matches prodId and not listen for any further data changes from the
    // provider. Since data changes with any new items will not affect existing items,
    // it is not important for this screen to listen for those changes, as this only renders detail of
    // product with id matching prodId. However, assumption in that case would be that once a product item
    // is created, it is never edited again.

    ProductProvider prodItem =
        Provider.of<ProductsProvider>(context, listen: false)
            .getProductById(prodId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          prodItem.title,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Hero(
              // This Hero widget enables smooth transition from ProdItemWidget
              // in ProductsListingScreen to this screen through the image set as
              // "child" in Image.network. To establush this mapping, same Hero
              // widget with same "tag" attribute value has been setup in
              // ProdItemWidget as well for the same image widget.
              tag: prodItem.id,
              child: Image.network(
                prodItem.imageUrl,
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.72,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Container(
              // height: (MediaQuery.of(context).size.height -
              //         MediaQuery.of(context).viewInsets.top) *
              //     0.05,
              child: Text(
                '\$${prodItem.price}',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              padding: const EdgeInsets.only(
                top: 2.0,
                left: 5.0,
                right: 5.0,
              ),
              child: Text(
                prodItem.description,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
