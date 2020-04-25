import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<StatefulWidget> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // FocusNode instance should be in the global scope outside the build method, as the form rebuilds with each user tap on
  // different form fields and creating new instances showing weird behavior with multiple fields in focus on the form.

  final _priceFocusNode = FocusNode(); // Reference to Price field focus
  final _descriptionFocusNode =
      FocusNode(); // Reference to Description field focus
  // final _imageurlFocusNode =
  //     FocusNode(); // Reference to Image URL field focus. This will be used to check if the field is
  // out of focus and accordingly, render its image preview in the box. That enables
  // preview without submitting the form and by just going to other fields, which is
  // probably the user's desired app behavior.

  bool isFirstBuild =
      true; // Flag to track if the screen is being built for the first time.
  String productId =
      ""; // Stores the id of the product when this screen is built to update an existing product.

  Widget
      imgPreviewRenderingWidget; // Widget to render image preview based on the content of image url.

  final formStateRef = GlobalKey<
      FormState>(); // Global key that can reference a Form widget state. Will be the one to
  // track state of the Form widget on this screen.

  ProductProvider productDetails = ProductProvider(
    id: DateTime.now().toString(),
    title: "",
    price: 0,
    description: "",
    imageUrl: "",
  ); // Product object with default values for add operation. Will be overwritten for update operation in
  // build method.

  final _imageurlController =
      TextEditingController(); // Used to access content entered in the image url field, which will be
  // passed on to the container widget (box to the left) for image preview.

  @override
  void initState() {
    _imageurlController.addListener(
        _renderImagePreview); // Listener to track changes to content in Image Url form field.
    // Upon change, listener triggers the callback _renderImagePreview.
    // Being set when the widget state is being initialized to track all
    // changes thereafter.
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Extract the product title passed as an argument
    // by the action pushing this screen on to the
    // Navigator stack of screens. Done in this method before
    // the build to extract arguments only during the first build
    // and not subsequent re-builds.
    //
    // This is cleaner than passing in the argument
    // via the class constructor.

    if (isFirstBuild) {
      Map<String, String> routeData = ModalRoute.of(context).settings.arguments
          as Map<String,
              String>; // Need to cast to Map<String, String> as it is being passed as a generic object type over the
      // routing system.

      if (routeData != null) {
        productId = routeData['productId'];

        if (productId.isNotEmpty) {
          // Means this screen has been built to perform the edit operation on an existing product
          productDetails =
              Provider.of<ProductsProvider>(context).getProductById(productId);
        }

        _imageurlController.text = productDetails.imageUrl; // Setting the mapped Image Url form field's initial value, as 
                                                            // form field can not have both initialValue and controller set at
                                                            // the same time.
                                                            // This is the ideal place as any changes to productDetails are done
                                                            // at this point in code.
      } // argument passed for edit operation

    }

    isFirstBuild = false; // set to false after the first build

    super.didChangeDependencies();
  }

  // Callback to listener set in the initState method to rebuild the impage preview box based on the content and focus of the
  // image url form field. Being setup explicitly through controller and listener.
  //
  // ALTERNATIVE APPROACH: Setup a focusNode for the image url field and also a listener in the initState() method, to listen
  // for it to go out of focus (when another field on the form is selected by user) and have a callback which just has an empty
  // setState() method to rebuild after the url has been entered in the field, which can the be previewed with the re-build.
  void _renderImagePreview() {
    setState(() {
      if (_imageurlController.text.isEmpty) {
        imgPreviewRenderingWidget = Text(
          'Enter image url',
        );
      } else {
        //if (!_imageurlFocusNode.hasFocus) // out of focus
        imgPreviewRenderingWidget = FittedBox(
          child: Image.network(
            _imageurlController.text,
          ),
          fit: BoxFit.cover,
        );
      }
    });
  }

  @override
  void dispose() {
    // Cleanup state of focusNode, controller objects when this screen is popped off the Navigator stack
    _imageurlController.removeListener(_renderImagePreview);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    //_imageurlFocusNode.dispose();
    _imageurlController.dispose();
    super.dispose();
  }

  // Callback for form submission action
  void saveFormState() {
    // Access form state through the GlobalKey that gives reference to the associated Form widget, and save it.
    formStateRef.currentState.save();

    // Listener set to false as screen will be popped after the respective operation.
    if (productId.isEmpty) {
      Provider.of<ProductsProvider>(context, listen: false).addProduct(
          productDetails); // After state is saved to productDetails, add it to
    } // providers product data.
    else {
      // productId.isNotEmpty, so, an edit/update operation
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(productId, productDetails);
    }

    // Once the change is done, just pop this screen to get back to previous product listing screen in the Navigator
    // stack and see the changes.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    print("Price focus node ref: $_priceFocusNode");
    print("Description focus node ref: $_descriptionFocusNode");

    return Scaffold(
      appBar: AppBar(
        title: (productId
                .isNotEmpty) // Render custom title depending on whether there is a route argument passed along with
            // the screen routing call.
            ? Text(
                'Edit Product - ${productDetails.title}',
              )
            : Text(
                'Add Product',
              ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
            ),
            onPressed: saveFormState,
          ),
        ],
      ),
      body: Form(
        key:
            formStateRef, // This connects the form to the GlobalKey that can reference the associated form state here.
        child: SingleChildScrollView(
          // Helps with the column layout by making it scrollable on the screen and accomodate
          // widgets being brought on to screen from the bottom when it's content is scrolled.
          child: Container(
            padding:
                (MediaQuery.of(context).orientation == Orientation.landscape)
                    ? EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                        bottom: MediaQuery.of(context).viewInsets.bottom +
                            15, // For pushing the form fields up by 15px, when
                        // the keyboard kicks in from the bottom of the
                        // device screen.
                      )
                    : EdgeInsets.all(10), // Orientation == landscape
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  keyboardType: TextInputType.text,
                  //autofocus: true,
                  textInputAction: TextInputAction.next,
                  initialValue: productDetails
                      .title, // Empty if it is an add operation and existing value for update operation,
                  // as values in productDetails object are set based on action prior to code
                  // reached in build method.
                  onSaved: (fieldValue) {
                    productDetails = ProductProvider(
                      // Except for the title extracted from this field, all other data is retained from the
                      // existing product data.
                      id: productDetails.id,
                      title: fieldValue,
                      description: productDetails.description,
                      price: productDetails.price,
                      imageUrl: productDetails.imageUrl,
                      isFavorite: productDetails.isFavorite,
                    );
                  },
                  onFieldSubmitted: (_) {
                    // Field content returned as value is not required here and hence ignored with "_".
                    FocusScope.of(context).requestFocus(
                        _priceFocusNode); // Swicth focus to the immediate Price field on field
                    // submission.
                  },
                ),
                TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Price',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ), // As price is typically a decimal value
                    focusNode:
                        _priceFocusNode, // Means to switch focus to this field from other fields in the form
                    textInputAction: TextInputAction.next,
                    initialValue: (productId.isNotEmpty) ? productDetails.price
                        .toString() : "", // need to convert double to string as form fields only deal
                    // with strings.
                    onSaved: (fieldValue) {
                      productDetails = ProductProvider(
                        // Except for the title extracted from this field, all other data is retained from the
                        // existing product data.
                        id: productDetails.id,
                        title: productDetails.title,
                        description: productDetails.description,
                        price: double.parse(
                            fieldValue), // fieldValue retrieved as string by default is converted to double (type for price).
                        imageUrl: productDetails.imageUrl,
                        isFavorite: productDetails.isFavorite,
                      );
                    },
                    onFieldSubmitted: (_) {
                      // Ignore the field content returned as value
                      //FocusScope.of(context).unfocus();
                      FocusScope.of(context).requestFocus(
                          _descriptionFocusNode); // Swicth focus to the immediate Description field
                    }),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  keyboardType: TextInputType
                      .multiline, // As description can span more than one line.
                  minLines: 3, // Set a minimum number of lines to start with
                  maxLines: 5, // Set a limit on the content.
                  focusNode: _descriptionFocusNode,
                  initialValue: productDetails.description,
                  onSaved: (fieldValue) {
                    productDetails = ProductProvider(
                      // Except for the title extracted from this field, all other data is retained from the
                      // existing product data.
                      id: productDetails.id,
                      title: productDetails.title,
                      description: fieldValue,
                      price: productDetails.price,
                      imageUrl: productDetails.imageUrl,
                      isFavorite: productDetails.isFavorite,
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment
                      .end, // To have child widgets positioned vertically at the bottom,
                  // giving it a uniform form layout.
                  children: <Widget>[
                    // Child widgets have been wrapped in Expanded widget to ensure they take minimum possible
                    // space in the layout than the default maximum possible space, the norm for Row widget.
                    // Or else, flutter will not be able to figure out the layout of widgets on the screen.
                    Container(
                      // To render image preview of the imageUrl given as input in the sibling TextFormField in the row
                      height: 100,
                      width: 100,
                      margin: EdgeInsets.only(
                        top: 10,
                        right: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: imgPreviewRenderingWidget,
                    ),
                    Expanded(
                      flex:
                          2, // This attribute gives more of the available space to the child widget, compared to the other
                      // child with flex set to default value: 1.

                      child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Image Url',
                          ),
                          keyboardType: TextInputType
                              .url, // As the input would be an image url
                          textInputAction: TextInputAction
                              .done, // Set to done being the last field in the form and submit
                          // when content is filled and submitted.
                          controller: _imageurlController,
                          //initialValue: productDetails.imageUrl, // Can not have both controller and initialValue set at the
                          // same time. So, initial value for update operation has been
                          // set in the controller mapped to Image Url form field.
                          onSaved: (fieldValue) {
                            productDetails = ProductProvider(
                              // Except for the title extracted from this field, all other data is retained from the
                              // existing product data.
                              id: productDetails.id,
                              title: productDetails.title,
                              description: productDetails.description,
                              price: productDetails.price,
                              imageUrl: fieldValue,
                              isFavorite: productDetails.isFavorite,
                            );
                          },
                          onFieldSubmitted: (_) {
                            saveFormState();
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
