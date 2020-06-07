import 'dart:ui';
import 'dart:math';

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import '../providers/authentication_provider.dart';

import '../models/rest_api_exception.dart';

enum AuthAction { LOGIN, SIGNUP }

class AuthenticationScreen extends StatefulWidget {
  static const routeName = '/auth-screen';

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  AuthAction _userChosenAuthAction =
      AuthAction.LOGIN; // Default action for screen load
  FocusNode _passwordFocus =
      new FocusNode(); // Reference of focus on the screen to be associated with the Password field.
  FocusNode _confirmPasswordFocus =
      new FocusNode(); // Reference of focus on the screen to be associated with the redundant
  // password field to confirm the original password.
  FocusNode _actionButtonFocusNode =
      new FocusNode(); // Reference of focus on the screen to be associated with the action
  // button in the form (login/signup).

  // Global key to be associated with the auth form in order to process its state (details entered in the form fields)
  GlobalKey<FormState> _formState = new GlobalKey<FormState>();

  // TextEditingController for the password field
  TextEditingController _pwdFieldController = new TextEditingController();

  // Store user credentials to be used with the Firebase REST API
  Map<String, String> _userCredentials = {
    'email': "",
    'password': "",
  };

  bool isLoading =
      false; // To track is a network API call is being processed or not

  AnimationController
      _authFormAnimeController; // Animation controller for the field switch between login/signup
  Animation<Size>
      _authFieldAnimation; // Animation for the change in form height with add/remove of field with login/signup.

  Animation<double>
      _authFieldFadeAnimation; // Animation for the confirm password field for sign-up action

  Animation<Offset>
      _authFieldSlideAnimation; // Animation for the confirm password field for sign-up action

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /* ************************************************************************************* *
     * OBSERVATION:                                                                          *
     * ------------                                                                          *
     * With animations, need to find a balance between the duration and the set animation    *
     * transition between the two values (with Tween<Size> animation). So, if duration in    *
     * controller is set to a low value, depending on the chosen animation, detail of the    *
     * designed animation might be skewed leading to a stunted visual. The end result would  *
     * be a compressed visual within the given smaller timeframe.                            *
     *                                                                                       *
     * An opposite effect would be seen with a longer duration, set in the animation         *
     * controller, which can lead to an elongated animation effect depending on the chosen   *
     * animation's design and its optimal duration to witness a smooth animation.            *
     *                                                                                       *
     * Therefore, need to exercise trial and error to understand how the chosen animation    *
     * performs at different durations, and the set size constraints on which it is rendered *
     * on the screen, to get a feel for its visual aesthetics and find the right combination *
     * of duration, constraints and animation.                                               *
     *                                                                                       *
     * Also, seems the adaptive height with MediaQuery.of(context) doesn't seem to render    *
     * distinguished animations. Could see the animations with fixed being and end values    *
     * the Container height. Will have to explore it further.                                *
     *                                                                                       *
     * ************************************************************************************* */

    // Initialize/Configure the form animation related state variables
    _authFormAnimeController = AnimationController(
      vsync:
          this, // The vsync named attribute tells controller to animate the desired object
      // only when it is in the viewport. The "this" associates controller to the
      // state object and thereby to the widget mapped to the state.
      duration: Duration(
        milliseconds: 400,
      ),
    );

    _authFieldAnimation = Tween<Size>(
      begin: Size(
          double.infinity, 280 /*MediaQuery.of(context).size.height * 0.55*/),
      end: Size(double.infinity, 360
          /*MediaQuery.of(context).size.height *
              0.75*/
          ), // Giving the animated form field a height
      // of 20% or 0.2
    ).animate(CurvedAnimation(
      parent: _authFormAnimeController,
      curve: Curves.easeInOutBack,
    ));

    // Configure fade animation for the confirm password field with signup action.
    // Since the fade is controlled by opacity, the being and end attributes range
    // from 0 (invisible) to 1 (completely visible).
    _authFieldFadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _authFormAnimeController,
      curve: Curves.easeInBack,
      reverseCurve: Curves.easeOutBack,
    ));

    // Configure slide animation for the confirm password field with signup action.
    // Since the slide should appear as if it has been drawn from the left, outside
    // the view port to its proper position, the Offset along x-axis would be
    // from -1.0 (notice the -ve value for start outside its default start position)
    // to 0 (its default start position). However, the offset along y-axis will be unaltered.
    _authFieldSlideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
        parent: _authFormAnimeController,
        curve: Curves.easeInBack,
        reverseCurve: Curves.easeOutBack));
  }

  Future<void> showDialogWrapper(String errMsg, String dialogButtonText) async {
    await showDialog(
      context: context,
      builder: (buildContext) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.error,
              color: Theme.of(context).errorColor,
            ),
            SizedBox(width: 5),
            Text(
              'ERROR',
              style: TextStyle(
                color: Theme.of(context).errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          errMsg,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        contentPadding: EdgeInsets.all(10),
        actions: <Widget>[
          RaisedButton(
            color: Theme.of(context).cursorColor,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              dialogButtonText,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Important to dispose off all the heap instances created with "new" keyword
    _pwdFieldController.dispose();

    _authFormAnimeController.dispose(); // Dispose off the animation controller

    if (_formState.currentState != null)
      _formState.currentState
          .dispose(); // FormState is a StatefulWidget disposed through its state.
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  // Method to toggle between login/signup. OnPressed action for the secondary form button.
  void _toggleAuthAction() {
    setState(() {
      if (_userChosenAuthAction == AuthAction.LOGIN) {
        _userChosenAuthAction = AuthAction.SIGNUP;
      } else {
        // _userChosenAuthAction == AuthAction.SIGNUP
        _userChosenAuthAction = AuthAction.LOGIN;
      }
    });

    if (_userChosenAuthAction == AuthAction.SIGNUP) {
      _authFormAnimeController
          .forward(); // Run the animation forward for signup action,
      // animating height when new form field is added.
    } else {
      _authFormAnimeController
          .reverse(); // Run the animation backward for login action,
      // animating height when existing form field is removed.
    }
  }

  // Method to validate form and perform the save to allow login/signup
  Future<void> _validateFormAndAuthenticate() async {
    final isFormDataValid = _formState.currentState.validate();

    if (!isFormDataValid) {
      // Form data is invalid
      return;
    }

    _formState.currentState
        .save(); // Only if the form data is valid, go ahead and save the form data.

    setState(() {
      isLoading = true; // As a network API call is about to be made
    });

    String errorMsg = "Authentication Failed !\nPlease try again.";

    try {
      if (_userChosenAuthAction == AuthAction.SIGNUP) {
        print("Form action: Signup");
        // Perform user signup through Firebase REST API
        //var response;
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .signup(_userCredentials['email'], _userCredentials['password']);
      } else {
        print("Form action: Login");
        // Perform user signup through Firebase REST API

        await Provider.of<AuthenticationProvider>(context, listen: false)
            .login(_userCredentials['email'], _userCredentials['password']);
      }
    } on RESTAPIException catch (restApiExcp) {
      print(restApiExcp);

      if (restApiExcp.toString().contains('EMAIL_EXISTS')) {
        errorMsg =
            "${_userCredentials['email']} is in use !\nPlease try a different email address";
      } else if (restApiExcp.toString().contains('EMAIL_NOT_FOUND')) {
        errorMsg =
            "${_userCredentials['email']} not found !\nPlease check your email address";
      } else if (restApiExcp.toString().contains('INVALID_PASSWORD')) {
        errorMsg = "Incorrect password !\nPlease try again";
      }

      await showDialogWrapper(errorMsg, "OK");
    } catch (runtimeExcp) {
      print(runtimeExcp.toString());
      await showDialogWrapper(errorMsg, "OK");
    }

    setState(() {
      isLoading = false; // As required network API call is done at this point
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[300],
                  Colors.purple[900],
                ],
              ),
            ),
          ),
          Container(
            //height: MediaQuery.of(context).size.height * 0.4,
            alignment: Alignment.topCenter,
            child: Image.network(
              'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse3.mm.bing.net%2Fth%3Fid%3DOIP.eea9GWyoH31zEBu5khsKUwHaE8%26pid%3DApi&f=1',
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.8,
            alignment: Alignment.center,
            padding: EdgeInsets.all(12),
            transform: Matrix4.rotationZ(-8*pi/180)..translate(65.0, -490.0,),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20,),color: Color(0xff515177)/*Colors.amber.withOpacity(0.9)*/,),
            child: Text(
              'Shoppers Hub',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // AnimatedContainer has built-in logic to perform animation by itself without the controller or animation instances.
          // However, need to provide the duration of animation (given to controller when using AnimatedBuilder) and the
          // animation curve (given to the animation instance when using AnimatedBuilder) to render the animation in the UI.
          // So, AnimatedContainer is a better built-in widget than AnimatedBuilder with tween animation when attributes like
          // height, width, padding,... of a Container widget need to be animated as part of their change.
          // As an animation instance is not being used here, the normal auth action flag is being used below for setting a
          // different height depending on the action, which will be factored in by the in-built animator to render the
          // desired animation.
          AnimatedContainer(
            duration: Duration(
              milliseconds: 400,
            ),
            curve: Curves.easeInOutBack,
            //height: MediaQuery.of(context).size.height * 0.55,
            height: (_userChosenAuthAction == AuthAction.SIGNUP) ? 360 : 280,
            // height: _authFieldAnimation.value
            //     .height, // Set the current height value from the animation instance
            // as the height of this container.
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.all(14),
            child: SingleChildScrollView(
              child: Form(
                key: _formState, // Gives access to this Form's state
                child: Card(
                  color: Colors.white38,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      3,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.email,
                            ),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            border: const OutlineInputBorder(),
                            errorStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.white38,
                            ),

                            //focusColor: Colors.amberAccent,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(
                                  _passwordFocus), // Takes cursor to the next
                          // password field
                          validator: (userEmail) {
                            if (userEmail.isEmpty) {
                              return "Please enter your email address";
                            } else if (!userEmail.contains("@")) {
                              return "Please enter a valid email address"; // return of a String means an error message for failed
                              // user input validation
                            } else {
                              return null; // null means the validation passed
                            }
                          },
                          cursorColor: Colors.black38,
                          onSaved: (userEmail) =>
                              _userCredentials['email'] = userEmail,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.lock_outline,
                              ),
                              border: const OutlineInputBorder(),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              errorStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.white38,
                              ),
                            ),
                            cursorColor: Colors.black38,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            focusNode: _passwordFocus,
                            controller: _pwdFieldController,
                            onFieldSubmitted: (_) {
                              if (_userChosenAuthAction == AuthAction.SIGNUP) {
                                // Only then there would be the additional field to confirm password
                                FocusScope.of(context)
                                    .requestFocus(_confirmPasswordFocus);
                              } else {
                                // To the form action button (login/signup)
                                FocusScope.of(context)
                                    .requestFocus(_actionButtonFocusNode);
                              }
                            },
                            onSaved: (userPassword) =>
                                _userCredentials['password'] = userPassword,
                            validator: (userPassword) {
                              if (userPassword.length < 8) {
                                return "Please enter password with atleast 8 characters";
                              } else if (userPassword.isEmpty) {
                                return "Please enter your password";
                              } else if (!userPassword.contains(
                                new RegExp(
                                  r"[A-Z]",
                                  caseSensitive: true,
                                ),
                              )) {
                                return "Please ensure your password has an upper-case alphabet";
                              } else if (!userPassword.contains(
                                new RegExp(
                                  r"[a-z]",
                                  caseSensitive: true,
                                ),
                              )) {
                                return "Please ensure your password has a lower-case alphabet";
                              } else if (!userPassword.contains(
                                new RegExp(
                                  r"[0-9]",
                                  caseSensitive: false,
                                ),
                              )) {
                                return "Please ensure your password has a number";
                              } else if (!userPassword.contains(
                                new RegExp(
                                  r"",
                                  caseSensitive: false,
                                ),
                              )) {
                                return "Please ensure your password has a special character";
                              } else {
                                return null;
                              }
                            }),
                        if (_userChosenAuthAction == AuthAction.SIGNUP)
                          SizedBox(
                            height: 15,
                          ),
                        if (_userChosenAuthAction == AuthAction.SIGNUP)
                          FadeTransition(
                            // FadeTransition renders configured animation in
                            // _authFieldFadeAnimation by controlling its
                            // appearance in the view port by transitioning the
                            // opacity with the range, also set in the Tween animation.
                            // It automatically rebuilds the nested TextFormField widget
                            // with change in animation, like AnimatedBuilder, without the
                            // need for setting up an explicit listener. However, will still
                            // need the controller and animation instances.
                            // Also, single controller can be mapped to multiple animations
                            // configured for a single widget, with a single trigger event or
                            // widget state change.
                            opacity: _authFieldFadeAnimation,
                            child: SlideTransition(
                              position: _authFieldSlideAnimation,
                              child: TextFormField(
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.lock_outline,
                                    ),
                                    border: OutlineInputBorder(),
                                    labelText: 'Confirm Password',
                                    labelStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    errorStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      backgroundColor: Colors.white38,
                                    ),
                                  ),
                                  cursorColor: Colors.black38,
                                  focusNode: _confirmPasswordFocus,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context)
                                          .requestFocus(_actionButtonFocusNode),
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  validator: (userReEnteredPassword) {
                                    if (!(userReEnteredPassword ==
                                        _pwdFieldController.text)) {
                                      return "Password Mismatch";
                                    } else {
                                      return null;
                                    }
                                  }),
                            ),
                          ),
                        SizedBox(
                          height: 15,
                        ),
                        RaisedButton(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 8,
                          ),
                          child: (isLoading)
                              ? CircularProgressIndicator()
                              : Text(
                                  (_userChosenAuthAction == AuthAction.SIGNUP)
                                      ? 'Signup'
                                      : 'Login',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          focusNode: _actionButtonFocusNode,
                          color: Colors.amber,
                          splashColor: Colors.amber.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () {
                            _validateFormAndAuthenticate().then((_) {});
                          },
                        ),
                        Divider(
                          color: Colors.black26,
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                        ),
                        FlatButton(
                          child: Text(
                            (_userChosenAuthAction == AuthAction.SIGNUP)
                                ? 'Login Instead ?'
                                : 'Signup Instead ?',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                          splashColor:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onPressed: _toggleAuthAction,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}
