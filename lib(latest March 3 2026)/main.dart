import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Models/Provider/ReorderUsingProvider.dart';
import 'Models/Provider/Sending KOT.dart';
import 'Pages/Dashboard.dart';
import 'Pages/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedItemsProvider()),
        ChangeNotifierProvider(
            create: (_) => KotProvider(employeeId: 0, deviceId: '')),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Restaurant App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const Dashboardpage(),
      ),
    );
  }
}
