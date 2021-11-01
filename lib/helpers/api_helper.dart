import 'dart:convert';

import 'package:madeupu_app/models/document_type.dart';
import 'package:madeupu_app/models/participation_type.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';

class ApiHelper {
  static Future<Response> getDocumentTypes(Token token) async {
    if (!_validToken(token)) {
      return Response(
          isSuccess: false,
          message:
              'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }

    var url = Uri.parse('${Constants.apiUrl}/api/DocumentTypes');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }

    List<DocumentType> list = [];
    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(DocumentType.fromJson(item));
      }
    }

    return Response(isSuccess: true, result: list);
  }

  static Future<Response> put(String controller, String id,
      Map<String, dynamic> request, String token) async {
    var url = Uri.parse('${Constants.apiUrl}$controller$id');
    var response = await http.put(url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
          'authorization': 'bearer $token'
        },
        body: jsonEncode(request));
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }
    return Response(isSuccess: true);
  }

  static Future<Response> post(
      String controller, Map<String, dynamic> request, String token) async {
    var url = Uri.parse('${Constants.apiUrl}$controller');

    var response = await http.post(url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
          'authorization': 'bearer $token'
        },
        body: jsonEncode(request));

    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

  static Future<Response> delete(
      String controller, String id, String token) async {
    var url = Uri.parse('${Constants.apiUrl}$controller$id');

    var response = await http.delete(url, headers: {
      'content-type': 'application/json',
      'accept': 'application/json',
      'authorization': 'bearer $token'
    });

    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

  static bool _validToken(Token token) {
    if (DateTime.parse(token.expiration).isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }

  static Future<Response> getParticipationTypes(Token token) async {
    if (!_validToken(token)) {
      return Response(
          isSuccess: false,
          message:
              'Your credentials have expired, please log out and log back into the system.');
    }

    var url = Uri.parse('${Constants.apiUrl}/api/ParticipationTypes');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }

    List<ParticipationType> list = [];
    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(ParticipationType.fromJson(item));
      }
    }

    return Response(isSuccess: true, result: list);
  }
}
