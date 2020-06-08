# Shoppers Hub

* Description

This is a sample android app to serve as an online shopping platform. It has been written using *Flutter/Dart* and is part of an online course taught by *Maximilian Schwarzmüller*. Most of the sample product data rendered in the app has been obtained from the online course project, along with the ideas for styling, screen layout, navigation and animations. However, there are differences in backend functionality and UI/UX design.

The app has different state management techniques, like, passing data around from screen to screen through constructors, as arguments to navigated named page routes and the more elegant data Provider/Listener mechanism. The data on products, favorites, cart items and orders are stored/managed in Firebase RealTime Database as backend, through REST api calls. The Firebase authentication has also beeen used with custom rules, based on which authorization of data is granted to the user.

The app allows users to signup/login through the authentication screen. Once authenticated, user will have access to all products created by different registered users. Appealing products can be marked as favorites, added to cart and when ready, checked out to place an order. There is a side drawer accessible by clicking the hamburger icon on the top-left, which allows users to navigate to different parts of the app through designated screens/pages, like, to look at placed orders, manage user-owned products, go to shop screen to view all products and also logout. Currently, a login session lasts an hour which is the default for Firebase backed user authentication. The session can certainly be extended for longer periods and will be explored and incorporated in the future.

Currently, there is no payment api linked to the app, like _Stripe_.

<img src="https://github.com/CodeLapseLogger/shoppers-hub/blob/master/Shopping_App_Final_Gif.gif" alt="Shopping-App-Gif" width=500px height=875px/>


***


* Installation

Apart from the normal process of installing an Android app on an emulator or actual device, two additional steps are needed
specific to this app.

1. If your android version < 5.0 (API level 21), _Multidex_ should be enabled in app-level _build.gradle_ file. Reason       being that the Dalvik executable (android's run-time until version 5.0) generated for this version of app has referenced methods in excess of 64K. That is the default limit set for Dalvik's executable (DEX file) in order to restrict the app (.apk file) to have a single DEX file.

_Multidex_ is a way to allow multiple DEX files in the app executable.

More information is available in below link, along with the required settings in app-level _build.gradle_ file:  
[Enable multidex for apps with over 64K methods](https://developer.android.com/studio/build/multidex)

*sample app-level gradle configuration file (within android/app folder) setting to enable multidex*:

    android {
        defaultConfig {
            ...
            minSdkVersion 15    // version number is < 21
            targetSdkVersion 28
            multiDexEnabled true // New line to be added to enable Multidex
        }
        ...
    }

    dependencies {
    // include below line only if your project had not been created with project type(-t option) set to AndroidX
    implementation 'com.android.support:multidex:1.0.3'

    // include below two lines only if your project had the project type(-t option) set to AndroidX at the creation time
    def multidex_version = "2.0.1"
    implementation 'androidx.multidex:multidex:$multidex_version'

    ...
    }


More details on migrating android projects to AndroidX can be found here: [AndroidX Migration](https://flutter.dev/docs/development/androidx-migration)




2. Register your app in Firebase and setup Realtime Databse as the backend. Necessary Cloud Firestore files and settings to be included in the project will be available as part of the Firebase account set-up and app registration process. 

During the app set-up process on Firebase, a _google-services.json_ file will be created with information like your api-key, which is to be downloaded and included in the android project's app folder path. That file would be used to enable app connection with Cloud Firestore and perform different data operations through its api. Additional settings would also be required in the *project-level* and *app-level* *build.gradle* files. All of that information will be given to you during the set-up process.

Here is the link to Google Firebase: [Firebase](https://firebase.google.com/)

Additionally, the actual user signup/login actions are carried out through Firebase Auth REST API, using respective urls, query parameters and necessary authentication data as payload. 

Here is the link to the documentation on urls and other data for different actions: [Firebase Auth REST API](https://firebase.google.com/docs/reference/rest/auth)

The signup/signin sections with username and password can be navigated to within the above linked webpage. Note that the Web API key for the registered app on Firebase will be required to make the POST requests. That Web API key will be available on the Firebase console in the Settings page.

Also, the Authentication and Database sections on the Firebase console should be configured to enable Email/Password as Sign-in method to add/manage user accounts, along with data access rules based on the user authentication.