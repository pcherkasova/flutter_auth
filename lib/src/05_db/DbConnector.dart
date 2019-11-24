import 'dart:convert';
import 'dart:core';

import 'package:meta/meta.dart';
import 'package:faui/FauiDb.dart';
import 'package:faui/src/06_auth/FbException.dart';
import 'package:http/http.dart';

// https://firebase.google.com/docs/firestore/use-rest-api
class DbConnector {
  static Future<void> upsert({
    @required FauiDb db,
    @required String idToken,
    @required String collection,
    @required String docId,
  }) async {
    await _sendFbApiRequest(
        collection: collection, docId: docId, idToken: idToken, db: db);
  }

  static Future<Map<String, dynamic>> _sendFbApiRequest({
    @required FauiDb db,
    @required String idToken,
    @required String collection,
    @required String docId,
  }) async {
    // FauiUtil.throwIfNullOrEmpty(value: projectId, name: "projectId");
    // FauiUtil.throwIfNullOrEmpty(value: collection, name: "collection");

    // const String baseUrl = "https://firestore.googleapis.com/v1/projects";

    // String url = "$baseUrl/$projectId/databases/$db/documents/$collection/$key";

    String url =
        "https://firestore.googleapis.com/v1beta1/projects/${db.projectId}/databases/${db.db}/documents/$collection/$docId/?key=${db.apiKey}";

    Response response = await patch(
      url,
      body: jsonEncode({
        "fields": {
          "Field1": {"stringValue": '1'},
          "Field2": {"stringValue": '2'},
          "Field3": {"stringValue": "var3"}
        }
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      return map;
    }
    String action = "insert";

    reportFailedRequest(action, response);
    return null;
  }

  static void reportFailedRequest(String action, dynamic response) {
    String message = "Error requesting firebase api $action.";
    print(message);
    printResponse(response);
    throw FbException(message + response.body);
  }

  static void printResponse(dynamic response) {
    if (response is Response) {
      print("code: " + response.statusCode.toString());
      print("response body: " + response.body);
      print("reason: " + response.reasonPhrase);
      return;
    }
    print(
        "Could not print response of type ${response.runtimeType.toString()}");
  }
}

//https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:delete?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=[API_KEY]
class FirebaseActions {
  static const SendResetLink = "sendOobCode";
  static const DeleteAccount = "delete";
  static const RegisterUser = "signUp";
  static const SignIn = "signInWithPassword";
  static const Verify = "lookup";
}
