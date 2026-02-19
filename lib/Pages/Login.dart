import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Import dart:io for SocketException
import 'package:shared_preferences/shared_preferences.dart'; // Import the shared_preferences package
import '../Utils/GlobalFn.dart';
import 'Dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController IdController = TextEditingController();

  String? advertisingId = '';

  @override
  initState() {
    super.initState();
    loadSettings();
  }

  loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('BaseUrl');
    String? savedId = prefs.getString('DeviceId');
    setState(() {
      urlController.text = savedUrl ?? '';
      IdController.text = savedId ?? '';
    });
  }

  Future<void> _login() async {
    try {
      final String? baseUrl = await fnGetBaseUrl();
      if (baseUrl == null || baseUrl.isEmpty) {
        _showErrorDialog('Error', 'Base URL is not set.');
        return;
      }
      final String apiUrl = '${baseUrl}api/User/DoLogin';

      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "Username": emailController.text,
          "Password": passwordController.text,
          "DeviceId": IdController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['Status'] == '200' &&
            jsonResponse['ResponseMessage'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Dashboardpage()),
          );
        } else {
          _showErrorDialog('Login failed',
              'Status: ${jsonResponse['Status']}, Message: ${jsonResponse['ResponseMessage']}');
        }
      } else {
        _showErrorDialog('Login failed', 'Status code: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      _showErrorDialog('Connection Error',
          'Could not connect to the server. Please check the URL and your internet connection.');
    } catch (e) {
      _showErrorDialog('An error occurred during login', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Enter URL',
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: IdController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Device id',
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _saveUrlAndIdToLocal(urlController.text,
                        IdController.text); // Save the URL to local storage
                    Navigator.pop(context); // Close the settings menu
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveUrlAndIdToLocal(String url, String Id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('BaseUrl', url);
    prefs.setString('DeviceId', Id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors
                            .blueGrey), // Change color to your preferred color
                      ),
                      child: const Text('Login',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Center(
                  child: InkWell(
                    onTap: () {
                      _showSettingsMenu(context);
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 30,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
