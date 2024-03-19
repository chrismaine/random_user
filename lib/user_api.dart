import 'dart:convert';
import 'package:http/http.dart' as http;

class UserApi {
  static Future<Map<String, dynamic>?> fetchUser() async {
    try {
      const url = 'https://randomuser.me/api/';
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      final body = response.body;
      final json = jsonDecode(body);
      return json['results'][0];
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
}
