// Exception class to model the run-time error of expired authorization, which is 
// essentially the expiry of the token.
import 'package:flutter/foundation.dart';

class ExpiredAuthorizationException implements Exception {
  final String errorMessage;

  ExpiredAuthorizationException({@required this.errorMessage});

  @override
  String toString(){
    return errorMessage;
  }
}
