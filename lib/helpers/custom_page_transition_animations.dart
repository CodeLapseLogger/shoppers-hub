import "package:flutter/material.dart";

// Child class extending MaterialPageRoute to create a custom page route
// with a built in page transition animation.
class CustomPageRoute<T> extends MaterialPageRoute<T> {
  // Class constructor taking in the page/screen builder and route settings, just like
  // parent class and initializes the properties by calling the parent class constructor
  // with passed in arguments.
  CustomPageRoute({@required WidgetBuilder builder, RouteSettings settings})
      : super(
            builder: builder,
            settings: settings); // :super() is the notation to
  // call parent class constructor.

  @override
  Widget buildTransitions(
    // This is the method to implement our page transition animation as a FadeTransition.
    // Also, part of the parent class and is overridden in this child class.
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // All the input animations are implicitly created and handled by Flutter.
    // So, we don't have to create explicit controller, animation instances.
    // The FadeTransition below takes the "animation" argument to tween animate
    // the fade transition over opacity. And the "child" would be the passed in
    // "child" argument.

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// Child class implementing the abstract PageTransitionsBuilder to create a custom
// app-level page transition animation that can be applied for all
// page/screen transitions in the app.
class CustomPageTransitionsBuilder implements PageTransitionsBuilder {
  // Just the buildTransitions method is overwritten to have
  // a custom FadeTransition as the page transiton animation.
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {

    return FadeTransition(
      opacity: animation,
      child: child,
    );
    
  }
}
