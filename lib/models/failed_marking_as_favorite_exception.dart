import 'package:flutter/foundation.dart';

// Implementation of a custom exception implementing the interface Exception.
// An interface is an abstract class which has no implementation and hence, can not be instantiated.
// The inheriting custom exception class bears the responsibility to implement/override the inherited class methods.
// The toString() method, in this case.

// Also, every dart object inherits from the Object class, which has the toString method.
class FailedMarkingAsFavoriteException implements Exception{

   final String errorMessage;

   FailedMarkingAsFavoriteException({
      @required this.errorMessage,
   });

   @override
   String toString() {
    return errorMessage; // return the input error message instead of the default string.
    //return super.toString(); // returns the default string of the format: "Instance of <type-of-object>"
  }
 

}