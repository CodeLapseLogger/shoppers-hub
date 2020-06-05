// Class to model an exception thrown while performing an REST api call
class RESTAPIException implements Exception{
    final String errorMessage;

    RESTAPIException({this.errorMessage});

    @override
    String toString(){
      return errorMessage;
    }
}