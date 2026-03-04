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
      barrierDismissible: true,
      builder: (BuildContext context) {

        final isTablet = MediaQuery.of(context).size.width > 600;

        return Center(
          child: SingleChildScrollView(
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: isTablet ? 400 : double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// Title
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// URL Field
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'Enter URL',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// Device ID Field
                    TextField(
                      controller: IdController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Device ID',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          _saveUrlAndIdToLocal(
                            urlController.text,
                            IdController.text,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
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
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {

            final isTablet = constraints.maxWidth > 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Container(
                    width: isTablet ? 400 : double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// ===== Email =====
                        TextField(
                          controller: emailController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ===== Password =====
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// ===== Login + Settings Same Line =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            /// Login Button
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey,
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 15),

                            /// Settings Icon
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  _showSettingsMenu(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
