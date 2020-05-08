import 'dart:convert'; // for encoding and decoding json data in the http request body.

import 'package:flutter/material.dart'; // Also includes ChangeNotifier definition.
import 'package:http/http.dart'
    as http; // For making the RESTful HTTP PATCH api call

import '../models/failed_marking_as_favorite_exception.dart'; // Custom exception class modeled to tag the event of
// failure in marking a chosen product as favorite.

import '../firebase_urls.dart'; // file with url to connect to firebase

// Class to model the product entity. It would essentially be the digital representation of physical products,
// that would be shopped online through the app.

// Later this class has been turned in to

class ProductProvider with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite =
      false; // default value set to false, so, not a favorite unless the user marks it.

  ProductProvider(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  Future<void> switchProductFavoriteState() async {
    isFavorite =
        !isFavorite; // Set the negation of the current state as the new state, to mark or unmark a Product class
    // instance as a favorite on the ProductsListingScreen. Each of this provider instance is
    // essentially tied to each ProductItemWidget's listener, providing the product data and
    // enabling rendering of each product as a UI component.
    notifyListeners();

    final String url = FIREBASE_URL_P +
        '/$id.json'; // url tied to specific product entry through its id.

    try {
      // Update just the isFavorite field of the specified product entry in the db, through the url.
      // Other field data in the db entry will be retained with PATCH call and not overwritten, unlike PUT.
      final patchResponse = await http.patch(
        url,
        body: json.encode(
          {
            'isFavorite': isFavorite,
          },
        ),
      );

      print('PATCH request status code: ${patchResponse.statusCode}');

      // ***** IMPORTANT OBSERVATION:
      // There seems to be a race condition with the asynchronous code here !

      // **** HOW TO REPRODUCE THE RACE CONDITION ?
      // Uncomment the below print statement, so as to hold this method long enough on the call stack and capture the error
      // thrown by the Firebase backend about the badly formatted url (missing .json in the end).
      // When it is commented out, method seems to be finishing its execution before the error from backend could be
      // captured by the catch-block. So, handling is to be done in the try-block itself based on the status code in the
      // PATCH response, effectively needing handling in both try and catch blocks. That defeats the purpose of error handling
      // through try/catch block.

      //print('PATCH request body: ${json.decode(patchResponse.body)}');

      // Error handling done in try=block as well, in case the error from Firebase backend fails to reach the catch-block.
      if (patchResponse.statusCode >= 400) {
        if (isFavorite) {
          throw FailedMarkingAsFavoriteException(
            errorMessage: '\'$title\' could not be unmarked as favorite !',
          ); // forward the error to the caller, a widget, which can perform a UI notification action to inform user of
          // the data update/patch failure. Client receiving the exception would have to call the toString() method to extract
          // the error message.
        } else {
          throw FailedMarkingAsFavoriteException(
            errorMessage: '\'$title\' could not be marked as favorite !',
          ); // forward the error to the caller, a widget, which can perform a UI notification action to inform user of
          // the data update/patch failure. Client receiving the exception would have to call the toString() method to extract
          // the error message.
        }
      }

      // However, additonal code above is actually giving time to this method to stay on the stack and enable catch-block to
      // capture the thrown error.

    } catch (error) {
      // Undo the isFavorite state change in the local data to keep it consistent with the data entry in the db.
      // Also, notify the data change to registered listeners.
      isFavorite = !isFavorite;
      notifyListeners();

      print('PATCH request failed !');
      if (isFavorite) {
        throw FailedMarkingAsFavoriteException(
          errorMessage: '\'$title\' could not be unmarked as favorite !',
        ); // forward the error to the caller, a widget, which can perform a UI notification action to inform user of
        // the data update/patch failure. Client receiving the exception would have to call the toString() method to extract
        // the error message.
      } else {
        throw FailedMarkingAsFavoriteException(
          errorMessage: '\'$title\' could not be marked as favorite !',
        ); // forward the error to the caller, a widget, which can perform a UI notification action to inform user of
        // the data update/patch failure. Client receiving the exception would have to call the toString() method to extract
        // the error message.
      }
    }
  }
}
