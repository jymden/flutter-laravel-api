import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Network {
  // final String _baseUrl = 'http://localhost:8000/api/v1'; // Use on device
  final String _baseUrl = '10.0.2.2:8000'; // Use in emulator
  final String _basePrefix = '/api/v1';
  var token;

  /// Get token from local storage
  _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = jsonDecode(prefs.getString('token'));
  }

  authData(data, apiUrl) async {
    var uri = Uri.http(_baseUrl, _basePrefix + apiUrl);
    return await http.post(
      uri,
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  getData(apiUrl) async {
    var uri = Uri.http(_baseUrl, _basePrefix + apiUrl);
    await _getToken();
    return await http.get(
      uri,
      headers: _setHeaders(),
    );
  }

  login(String email, String password) async {
    var data = {'email': email, 'password': password};
    var res = await Network().authData(data, '/login');

    var body = json.decode(res.body);

    if (body['success']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', json.encode(body['data']['token']));
      prefs.setString('user', json.encode(body['data']['user']));
      return {'success': body['success'], 'message': body['message']};
    }

    return {'success': body['success'], 'message': body['message']};
  }

  logout() async {
    var res = await Network().getData('/logout');
    var body = json.decode(res.body);
    print(body);
    if (body['success']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('user');
      prefs.remove('token');
      return {'success': body['success'], 'message': body['message']};
    }
    return {'success': body['success'], 'message': body['message']};
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<bool> isLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return token != null;
  }

}
