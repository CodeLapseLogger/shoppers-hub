import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/screens/authentication_screen.dart';

import './screens/products_listing_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_manager_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/splash_screen.dart';

import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import './providers/orders_provider.dart';
import './providers/authentication_provider.dart';

void main() => runApp(ShoppingApp());

// Main material app widget to launch the shopping app.
class ShoppingApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Provider that registers multiple data sources as providers at a given node, allowing data channels
      // to listeners at different widget nodes down the app widget tree, through the "providers" attribute.
      providers: [
        // ChangeNotifierProvider is to setup the provider: ProductsProvider in the
        // app widget tree, above the parent of the widgets listening for data or changes in data.
        // When there is a change in the data managed by the "provider", only the listening widgets
        // are rebuilt and not the entire app widget tree. Entire widget tree re-build would be the
        // case if data was passed around through Stateful widget constructors, even in cases where
        // data being passed is only needed by widgets down the tree and not the one holding it, as
        // data is part of the widget's state. This central data management by the provider is a
        // cleaner approach to data management in the app widget tree.
        ChangeNotifierProvider.value(
          // This provider should be the first instance in the list of providers for other providers
          // to be able to get authentication related data with the *ProxyProvider* class instance.
          value: AuthenticationProvider(),
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, ProductsProvider>(
          // *ProxyProvider* is to allow data propogation between two providers.
          // Here, the ProductsProvider() needs authentication token information
          // from AuthenticationProvider().
          // Two constructors created in the ProductsProvider() class. One is the default
          // with no data and picked as the initial instance here for "create" attribute.
          // Another is a named constructor with authentication related data, like token
          // and also data from previous instance.
          // If the default constructor instance is not set with the "create", will have to
          // include a check for previous instance being "null" in the "update" instance and
          // provide corresponding data for default instance. The check can be avoided with the
          // "create" attribute setting, as that is implicitly being picked as the initial value,
          // or the previous instance value with the "update" during creation. Removing "create" works
          // but would need the check for null in the "update" with respect to previous data or the
          // instance itself. It is not explicit and people may not pick that up on first glance at code.
          // So, with respect to code readability, it is debatable to have that explicit check on "null"
          // or not.
          create: (context) => ProductsProvider(),
          update: (context, authProviderInstance,
                  previousProdsProviderInstance) =>
              ProductsProvider.withAuthRelatedData(
                  previousProdsProviderInstance.products,
                  authToken: authProviderInstance.token,
                  userId: authProviderInstance
                      .userIdentifier), // This is an instance of the provider and not a widget.
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, CartProvider>(
          // Using the older CartProvider instance itself and updating through a setter, rather than creating a new one, which
          // deletes the old object first, which can be an overhead. Setter is relatively more efficient and also the suggested
          // approach in the documentation for ChangeNotifierProxyProvider.
          create: (context) => CartProvider(),
          update: (context, authProviderInstance,
                  previousCartProviderInstance) =>
              previousCartProviderInstance
                ..authorizationToken = authProviderInstance.token
                ..userIdentification = authProviderInstance
                    .userIdentifier, // Update previous instance to have the token value.
          // With this, we also don't have to worry about
          // checking for data that might be lost and required
          // to be passed in when creating a new instance of the
          // CartProvider.
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, OrdersProvider>(
          create: (providerContext) => OrdersProvider(),
          update: (providerContext, authProviderInstance,
                  previousOrdersProviderInstance) =>
              previousOrdersProviderInstance
                ..authorizationToken = authProviderInstance.token
                ..userIdentification = authProviderInstance.userIdentifier,
        ),
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (builderContext, authProvider,
            _ /*ignoring child widget here as MaterialApp has no static widget */) {
          return MaterialApp(
            title: 'Shoppers Hub',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: (authProvider.isAuthenticated())
                ? ProductsListingScreen()
                : FutureBuilder( // Since "home" expects a widget, FutureBuilder has been used here to potentially extract the
                                 // data from the Future.
                    future: authProvider.autoLogin(),
                    builder: (builderContext, autoLoginSnapshot) =>
                        (autoLoginSnapshot.connectionState ==
                                ConnectionState.waiting)
                            ? SplashScreen()
                            : AuthenticationScreen()), // Here another tertiary operator can be used to check on the boolean 
                                                       // value in the future to accordingly render ProductsListingScreen() 
                                                       // or AuthenticationScreen(). However, because autoLogin notifies listeners
                                                       // with change in auth data and the parent widget is an 
                                                       // AuthenticationProvider listener registered with Consumer<AuthenticationProvider>
                                                       // that would be a redundant check as the widget would re-build with notification of
                                                       // change and get to the ProductsListingScreen(). And if the autoLogin fails, meaning
                                                       // no auth data stored on the device and no notifyListeners() call, then 
                                                       // AuthenticationScreen() will be loaded when Future completes after the connection 
                                                       // wait state is done.
            routes: {
              //ProductsListingScreen.routeName : (context) => ProductsListingScreen(), // redundant home route declaration
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartDetailScreen.routeName: (context) => CartDetailScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              ProductManagerScreen.routeName: (context) =>
                  ProductManagerScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          );
        },
      ),
    );
  }
}
