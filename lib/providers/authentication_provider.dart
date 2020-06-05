// Provider for authentication details and also a manager for authentication actions
// Since the user authentication state (logged in or not) is an important information
// for other screens in rendering user-specific data, this Provider has been implemented
// to pass on data to registered listeners in the widget tree.

import 'dart:convert'; // For JSON data encoding/decoding in the API request/response objects.
import 'dart:async'; // For asynchronous programming

import 'package:flutter/widgets.dart'; // For ChangeNotifier mixin
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For storing user credentials on the device

import '../models/rest_api_exception.dart';

import '../firebase_urls.dart';

class AuthenticationProvider with ChangeNotifier {
  String _authToken;
  DateTime _tokenExpiryTime;
  String _userId;

  // Method to determine if user is authenticated on not.
  // Accordingly, can have the user login to gain access to parts of app.
  bool isAuthenticated() {
    return (token != null);
  }

  // Getter method to access the token given by Firebase as a response to user authentication action.
  // Depending on whether the token is valid or not appropriate string value is returned, which also acts
  // as a basis to determine the validity of user authentication in the method isAuthenticated()
  String get token {
    if (_tokenExpiryTime != null &&
        _tokenExpiryTime.isAfter(DateTime.now()) &&
        _authToken != null) {
      return _authToken;
    } else {
      return null;
    }
  }

  // Getter for user-id
  String get userIdentifier {
    return _userId;
  }

  // Method to perform user signup with given email/password
  Future<void> signup(String email, String password) async {
    try {
      final response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$FIREBASE_API_KEY',
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      print(response);

      final responseData = json.decode(response.body);
      print("SIGNUP - responseData: $responseData");

      // Because Firebase can only pass on any error as data in REST API response, need to
      // look into the response body for the 'error' key when decoded as json object.
      // Wouldn't be able to get that as an exception to be caught in the catch-block.
      if (responseData['error'] == null) {
        _authToken = responseData['idToken'];
        _tokenExpiryTime = DateTime.now().add(
          Duration(
            seconds: int.parse(
              responseData['expiresIn'],
            ), // Need to parse the string to extract the seconds as an integer.
          ),
        );
        _userId = responseData['localId'];

        print(
            "SIGNUP - token: $_authToken\nexpiryTime: $_tokenExpiryTime\nuserId: $_userId");

        notifyListeners(); // Notify registered listeners of the changes to auth data

        _autoLogout(); // Sets timer to automatically logout after token expires

      } else {
        throw RESTAPIException(errorMessage: responseData['error']['message']);
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Method to perform user login with given email/password
  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$FIREBASE_API_KEY',
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);
      print("LOGIN - responseData: $responseData");

      // Because Firebase can only pass on any error as data in REST API response, need to
      // look into the response body for the 'error' key when decoded as json object.
      // Wouldn't be able to get that as an exception to be caught in the catch-block.
      if (responseData['error'] == null) {
        // No error
        _authToken = responseData['idToken'];
        _tokenExpiryTime = DateTime.now().add(
          Duration(
            seconds: int.parse(
              responseData['expiresIn'],
            ),
          ),
        );
        _userId = responseData['localId'];

        print(
            "LOGIN - token: $_authToken\nexpiryTime: $_tokenExpiryTime\nuserId: $_userId");

        notifyListeners(); // Notify registered listeners of the changes to auth data

        _autoLogout(); // Set timer for token expiry and automatically logout when token times out.

        // Store user authentication credentials on the device
        final _onDeviceAuthDataHandler = await SharedPreferences.getInstance();

        final authData = json.encode({
          'token': _authToken,
          'userId': _userId,
          'expiryTime': _tokenExpiryTime.toIso8601String()
        });

        final data = {
          'token': _authToken,
          'userId': _userId,
          'expiryTime': _tokenExpiryTime.toIso8601String()
        };

        print("login - auth data written to device: $data");

        _onDeviceAuthDataHandler.setString('authData',
            authData); // Stores data as a key-valus pair on the device
      } else {
        throw RESTAPIException(errorMessage: responseData['error']['message']);
      }
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  // Method to automatically login user if the previous login token hasn't expired yet
  Future<bool> autoLogin() async {
    final _onDeviceAuthDataHandler = await SharedPreferences.getInstance();

    final _authData = json.decode(_onDeviceAuthDataHandler.getString('authData')) as Map<String, dynamic>;
 
    print("autoLogin - _authData extracted from device: $_authData\n");
    if ( _authData == null) {
      // If true, key-value pair doesn't exists, meaning first login
      return false; // Since return-type is Future<bool>, "false" automatically gets wrapped in a Future.
    } else {
      // Auth data from previous login exists, so, extract the data from device and store in app local Provider data
      
      _authToken = _authData['token'];
      _userId = _authData['userId'];
      _tokenExpiryTime = DateTime.parse(_authData['expiryTime']);

      print("autoLogin - token: $_authToken");
      print("autoLogin - userId: $_userId");
      print("autoLogin - expiryTime: $_tokenExpiryTime");

      notifyListeners();
      _autoLogout();

      return true;
    }
  }

  // Method to reset authentication details and notify registered listeners to check on authentication
  // again and accordingly load the login screen (as authentication check fails with the reset), giving
  // the effect of logout.
  void _resetAuthData() {
    _authToken = null;
    _tokenExpiryTime = null;
    _userId = null;

    // To remove the authentication data mapped to the key 'authData' in SharedPreferences, and thereby avoiding auto-login after
    // each explicit logout as the authentication details would still be accessible from the device, if not removed/cleared as
    // part of logout/auto-logout process.
    SharedPreferences.getInstance()
        .then((_onDeviceAuthDataHandler) => _onDeviceAuthDataHandler.clear()); /*Can also user remove() if there is more than one
                                                                                 key-value pait store in SharedPreferences*/

    notifyListeners();
  }

  // Method to simulate the expiration of user login by resetting token and other auth details.
  void logout() {
    _resetAuthData();
  }

  // Method to automatically logout after the token expires, by setting a timer and associating a callback
  // to carry out the auth details reset, giving the effect of user logout.
  void _autoLogout() {
    Timer(
        Duration(
            seconds: _tokenExpiryTime.difference(DateTime.now()).inSeconds),
        _resetAuthData);
  }
}
