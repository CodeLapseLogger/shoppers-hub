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

  bool isScreenLoading =
      false; // Flag to track the intermediate state when switching screens post the completion of a
  // data operation like add/update.

  String productId =
      ""; // Stores the id of the product when this screen is built to update an existing product.

  ProductProvider productDetails = ProductProvider(
    id: "", // Would be overwritten with id from new db entry
    title: "",
    price: 0,
    description: "",
    imageUrl: "",
  ); // Product object with default values for add operation. Will be overwritten for update operation in
  // build method.

  Widget
      imgPreviewRenderingWidget; // Widget to render image preview based on the content of image url.

  final formStateRef = GlobalKey<
      FormState>(); // Global key that can reference a Form widget state. Will be the one to
  // track state of the Form widget on this screen.

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

  // Callback to listener set in the initState method to rebuild the impage preview box based on the content and focus of the
  // image url form field. Being setup explicitly through controller and listener.
  //
  // ALTERNATIVE APPROACH: Setup a focusNode for the image url field and also a listener in the initState() method, to listen
  // for it to go out of focus (when another field on the form is selected by user) and have a callback which just has an empty
  // setState() method to rebuild after the url has been entered in the field, which can then be previewed with the re-build.
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
            _imageurlController.text
                .trim(), // To avoid any trailing spaces being encoded in the url, which can lead to a
            // 404 (page not found) http response .
          ),
          fit: BoxFit.cover,
        );
      }
    });
  }

  // Callback for form submission action
  Future<void> saveFormState() async {
    // Access form state through the GlobalKey<FormState> instance and perform validations before saving it
    final formInputIsClean = formStateRef.currentState
        .validate(); // returns true if no issues with form input

    
    if (formInputIsClean) {
      // Save form input and pop this screen only if the input passes validation checks.
      // Required validation for each form field is embedded in the textFormField instances
      // of the Form widget, as part of the "validator" attribute.

      // Access form state through the GlobalKey that gives reference to the associated Form widget, and save it.
      formStateRef.currentState.save();

      // Data to be returned to prior screen on the Navigator stack, for displaying success message through SnackBar at the
      // bottom. Any error is being handled here with an AlertDialog. So, I believe conveying failure message on the prior
      // screen (when this screen is popped) would be redundant and act as a deterrent to user experience. Not redundant for
      // success though, as only a circular progress loader is diplayed before this screen pops.
      String successMessage = "";

      // Listener set to false as screen will be popped after the respective operation.
      if (productId.isEmpty) {
        // Re-build widget to reflect the UI transition during the data operation
        setState(() {
          // Set screen loading flag to true, as either the add/update operation would be performed next
          isScreenLoading = true;
        });

        // With async/await, error handling done with try/catch/finally block
        // The methods returning Future types, in other words, actions/operations that need the execution to be done synchronously
        // when qualified by "await" keyword, implicitly return the value of Future. Don't explicitly need the return statement
        // like in the case of then(), catchError() methods used to handle part of code that deal with Futures.
        try {
          await Provider.of<ProductsProvider>(context, listen: false)
              .addProduct(productDetails);

          successMessage = "Add was successful !";
        } catch (error) {
          await showDialog(
            context: context,
            builder: (buildContext) {
              return AlertDialog(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.error,
                      color: Theme.of(context).errorColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('ERROR',
                        style: TextStyle(
                          color: Theme.of(context).errorColor,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                content: Text(
                  'New product couldn\'t be added !',
                  // style: TextStyle(
                  //   fontWeight: FontWeight.bold,
                  // ),
                ),
                actions: <Widget>[
                  RaisedButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(buildContext)
                            .pop(); // pop the AlertDialog off the top of app Navigator stack. Notice that the
                        // context given to Navigator is buildContext, which is different than the
                        // Stateful widget's "context".
                      }),
                ],
              );
            },
          );
        } // end of catch-block
         finally {
          // Irrespective of whether there was an error or not during the add operation, this screen is popped, allowing the
          // app to recover from the failed operation. So, it has been put in the "finally" block which executes in either
          // case (successful/failed operation).

          // Re-build widget again to signify end of data operation, allowing the screen to be popped, taking it to prior
          // screen in the Navigator stack.
          setState(() {
            // Unset the screen loading flag as the operation is now complete
            isScreenLoading = false;
          });

          // Pop this screen
          Navigator.of(context).pop({
            'successMessage': successMessage,
          });
        }
      } else {
        // Update

        // Re-build widget to reflect the UI transition during the data operation
        setState(() {
          // Set screen loading flag to true, as either the add/update operation would be performed next
          isScreenLoading = true;
        });

        try {
          // productId.isNotEmpty, so, an edit/update operation
          await Provider.of<ProductsProvider>(context, listen: false)
              .updateProduct(productId,
                  productDetails); // Wait until the update operation is done

          successMessage = "Update was successful !";

        } catch (error) {
          await showDialog(
            context: context,
            builder: (buildContext) {
              return AlertDialog(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.error,
                      color: Theme.of(context).errorColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('ERROR',
                        style: TextStyle(
                          color: Theme.of(context).errorColor,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                content: Text(
                  'Chosen product couldn\'t be updated !',
                  // style: TextStyle(
                  //   fontWeight: FontWeight.bold,
                  // ),
                ),
                actions: <Widget>[
                  RaisedButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(buildContext)
                            .pop(); // pop the AlertDialog off the top of app Navigator stack. Notice that the
                        // context given to Navigator is buildContext, which is different than the
                        // Stateful widget's "context".
                      }),
                ],
              );
            },
          );
        } finally {
          // Re-build widget again to signify end of data operation, allowing the screen to be popped, taking it to prior
          // screen in the Navigator stack.
          setState(() {
            // Unset the screen loading flag as the operation is now complete
            isScreenLoading = false;
          });

          Navigator.of(context).pop({
            'successMessage': successMessage,
          }); // To remove this screen from the user's app view and get back to the previous
          // ProductManagerScreen.
        }
      }
    } // end of if(formInputIsClean)
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

          _imageurlController.text = productDetails
              .imageUrl; // Setting the mapped Image Url form field's initial value, as
          // form field can not have both initialValue and controller set at
          // the same time.
          // This is the ideal place as any changes to productDetails are done
          // at this point in code.
        }
      } // argument passed for edit operation

    }

    isFirstBuild = false; // set to false after the first build

    super.didChangeDependencies();
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
            onPressed: () async {
              await saveFormState();
            },
          ),
        ],
      ),
      body: isScreenLoading // To account for the intermediate state when carrying out the add/update operation and reflect
          // that in the UI with CircularProgressIndicator(), which can improve user experience as it conveys
          // the start, progress and end of the add/update operation triggered by the user.
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key:
                  formStateRef, // This connects the form to the GlobalKey that can reference the associated form state here.
              child: SingleChildScrollView(
                // Helps with the column layout by making it scrollable on the screen and accomodate
                // widgets being brought on to screen from the bottom when it's content is scrolled.
                child: Container(
                  padding: (MediaQuery.of(context).orientation ==
                          Orientation.landscape)
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
                  alignment: Alignment.center,
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
                        validator: (fieldValue) {
                          // Return value: null, means input passed the validation.
                          // Return value: String, means error message being returned upon failure of input
                          // validation.
                          if (fieldValue.isEmpty)
                            return 'Please enter a title'; // Error message to be displayed on screen prompting for user input.

                          return null; // reaches here if input is non-empty. In other words, passed validation
                        },
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
                          initialValue: (productId.isNotEmpty)
                              ? productDetails.price.toString()
                              : "", // need to convert double to string as form fields only deal
                          // with strings.
                          validator: (fieldValue) {
                            if (fieldValue.isEmpty)
                              return 'Please enter product price';
                            else if (double.tryParse(fieldValue) ==
                                null) // tryParse returns null if parse fails and doesn't throw
                              // an error. So, it can be worked with during validation
                              // to return an error message, enabling the app to resume
                              // with corrected user input.
                              return 'Please enter a number';
                            else if (double.parse(fieldValue) <=
                                0.0) // Input is number but still an invalid value <= 0
                              return 'Price should be > 0';
                            else // Past all validation checks, so, return null to signify error free user input
                              return null;
                          },
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
                        minLines:
                            3, // Set a minimum number of lines to start with
                        maxLines: 5, // Set a limit on the content.
                        focusNode: _descriptionFocusNode,
                        initialValue: productDetails.description,
                        validator: (fieldValue) {
                          if (fieldValue.isEmpty) // Validation check
                            return 'Please enter product description';

                          return null; // Good user input
                        },
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
                          // space in the layout than the default maximum possible space, the norm for Row
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
                                validator: (fieldValue) {
                                  if (fieldValue.isEmpty)
                                    return 'Please enter image url';
                                  else if (!fieldValue.startsWith('http') &&
                                      !fieldValue.startsWith('https'))
                                    return 'Please enter a valid image url';
                                  else // Past validation checks
                                    return null; // user input is good.
                                },
                                onSaved: (fieldValue) {
                                  productDetails = ProductProvider(
                                    // Except for the title extracted from this field, all other data is retained from the
                                    // existing product data.
                                    id: productDetails.id,
                                    title: productDetails.title,
                                    description: productDetails.description,
                                    price: productDetails.price,
                                    imageUrl: fieldValue
                                        .trim(), // To ensure a clean url string is saved avoiding any trouble
                                    // in rendering the image preview, in the box to the left of this
                                    // field. Any trailing spaces will be will be encoded in the url as
                                    // %20, leading to 404 (page not found) http response.
                                    isFavorite: productDetails.isFavorite,
                                  );
                                },
                                onFieldSubmitted: (_) async {
                                  await saveFormState();
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
