import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../Models/Provider/Sending KOT.dart';
import '../Utils/GlobalFn.dart';
import 'Dashboard.dart';
import 'homepage.dart';

class Employeespage extends StatefulWidget {
  const Employeespage({Key? key}) : super(key: key);
  @override
  State<Employeespage> createState() => _EmployeespageState();
}

class _EmployeespageState extends State<Employeespage> {
  List<Map<String, dynamic>> employees = [];
  String? BaseUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    BaseUrl = await fnGetBaseUrl();
    final String apiUrl = '${BaseUrl}api/Employee/Employees';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the 'Data' and 'Employees' keys exist
        if (responseData.containsKey('Data') &&
            responseData['Data'].containsKey('Employees')) {
          final List<dynamic> employeesList = responseData['Data']['Employees'];

          setState(() {
            employees = List<Map<String, dynamic>>.from(employeesList);
          });
        } else {
          print('Invalid API response structure');
        }
      } else {
        print('Failed to load employees. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching employees: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Dashboardpage(),
                  ));
            },
            color: Colors.white),
        backgroundColor: Colors.blueGrey,
        title: const Text("Employees", style: TextStyle(color: Colors.white)),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => KotProvider(

                      employeeId: employee['EmpId'],
                      deviceId: '', // Pass employee ID here
                    ),
                    child: Homepage(
                      employeeName: employee['EmployeeName'],
                      employeeId: employee['EmpId'],
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 350,
                width: 100,
                child: Column(
                  children: [
                    // Image.network(
                    //   "https://img.freepik.com/premium-vector/man-profile-cartoon_18591-58482.jpg?w=740",
                    // height: 80,
                    //   width: 80,
                    // ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(employee['EmployeeName']),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
