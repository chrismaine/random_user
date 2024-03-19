import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Garamond',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? user = {
    'name': {'first': null, 'last': null},
    'email': null,
    'location': {'city': null, 'country': null},
    'dob': {'age': null},
    'phone': null,
    'gender': null,
    'picture': {'large': null}
  };

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Random User API",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: user != null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: user!['picture']['large'] != null
                        ? NetworkImage(user!['picture']['large'])
                        : AssetImage('assets/placeholder_image.png')
                            as ImageProvider,
                  ),
                  SizedBox(height: 15),
                  Text(
                    '${user!['name']['first'] ?? 'Unknown'} ${user!['name']['last'] ?? 'User'}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  _buildUserDetail(
                    icon: Icons.mail,
                    label: 'Email',
                    value: user!['email'] ?? 'Unknown',
                  ),
                  _buildUserDetail(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: '${user!['location']['city'] ?? 'Unknown'}, ${user!['location']['country'] ?? 'Unknown'}',
                  ),
                  _buildUserDetail(
                    icon: Icons.cake,
                    label: 'Age',
                    value: user!['dob']['age'] != null ? user!['dob']['age'].toString() : 'Unknown',
                  ),
                  _buildUserDetail(
                    icon: Icons.phone,
                    label: 'Contact',
                    value: user!['phone'] ?? 'Unknown',
                  ),
                  _buildUserDetail(
                    icon: user!['gender'] == 'male' ? Icons.male : Icons.female,
                    label: 'Gender',
                    value: user!['gender'] ?? 'Unknown',
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildUserDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    Color iconColor = user!['gender'] == 'male' ? Colors.blue : Colors.pink;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  void fetchUser() async {
    print("fetchUser called");
    const url = 'https://randomuser.me/api/';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    setState(() {
      user = json['results'][0];
    });

    print('fetchUser completed');
  }
}
