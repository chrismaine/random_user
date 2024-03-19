import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'connectivity.dart';

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

  bool _isConnected = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _subscribeToConnectivityChanges();
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isConnected
              ? user != null
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
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
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
                            value:
                                '${user!['location']['city'] ?? 'Unknown'}, ${user!['location']['country'] ?? 'Unknown'}',
                          ),
                          _buildUserDetail(
                            icon: Icons.cake,
                            label: 'Age',
                            value: user!['dob']['age'] != null
                                ? user!['dob']['age'].toString()
                                : 'Unknown',
                          ),
                          _buildUserDetail(
                            icon: Icons.phone,
                            label: 'Contact',
                            value: user!['phone'] ?? 'Unknown',
                          ),
                          _buildUserDetail(
                            icon: user!['gender'] == 'male'
                                ? Icons.male
                                : Icons.female,
                            label: 'Gender',
                            value: user!['gender'] ?? 'Unknown',
                          ),
                        ],
                      ),
                    )
                  : Center(child: Text("No user data available"))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No internet connection",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchUser,
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isConnected ? fetchUser : null,
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildUserDetail(
      {required IconData icon,
      required String label,
      required String value}) {
    Color iconColor =
        user!['gender'] == 'male' ? Colors.blue : Colors.pink;
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
    setState(() {
      _isLoading = true;
    });

    try {
      const url = 'https://randomuser.me/api/';
      final uri = Uri.parse(url);
      
      // Check connectivity before making the API call
      var isConnected = await ConnectivityService.isConnected();
      if (!isConnected) {
        throw Exception('No internet connection');
      }

      final response = await http.get(uri);
      final body = response.body;
      final json = jsonDecode(body);

      setState(() {
        user = json['results'][0];
      });

      print('fetchUser completed');
    } catch (e) {
      print('Error fetching user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  void _subscribeToConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }
}
