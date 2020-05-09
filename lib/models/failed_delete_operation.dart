import 'package:flutter/foundation.dart';

class FailedDeleteOperation implements Exception{

   final errorMessage;

   FailedDeleteOperation({@required this.errorMessage,});

   // This method is actually inherited from Object class, from which every object in Dart is created as a child class instance.
   @override
   String toString() {
    return errorMessage;
    //return super.toString(); // returns default string of the format: "Instance of <type-of-object>"
  }



}