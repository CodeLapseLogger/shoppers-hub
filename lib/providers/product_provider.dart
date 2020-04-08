import 'package:flutter/material.dart'; // Also includes ChangeNotifier definition.

// Class to model the product entity. It would essentially be the digital representation of physical products,
// that would be shopped online through the app.

// Later this class has been turned in to 

class ProductProvider with ChangeNotifier{
  
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite = false; // default value set to false, so, not a favorite unless the user marks it.

  ProductProvider({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false
  });

  void switchProductFavoriteState(){
    isFavorite = !isFavorite; // Set the negation of the current state as the new state, to mark or unmark a Product class
                              // instance as a favorite on the ProductsListingScreen. Each of this provider instance is 
                              // essentially tied to each ProductItemWidget's listener, providing the product data and
                              // enabling rendering of each product as a UI component.
    notifyListeners();
  }

}
