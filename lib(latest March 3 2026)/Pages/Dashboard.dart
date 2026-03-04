import 'package:flutter/material.dart';

import '../TakeAway/pagesTA/HomepageTA.dart';
import 'Employees.dart';
import 'LogSettings.dart';
import 'Login.dart';

class Dashboardpage extends StatefulWidget {
  const Dashboardpage({Key? key}) : super(key: key);

  @override
  State<Dashboardpage> createState() => _DashboardpageState();
}

class _DashboardpageState extends State<Dashboardpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ));
            },
            color: Colors.white),
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
      int crossAxisCount = 2;

      if (constraints.maxWidth > 900) {
        crossAxisCount = 4; // Large tablets
      } else if (constraints.maxWidth > 600) {
        crossAxisCount = 3; // Medium tablets
      } else {
        crossAxisCount = 2; // Mobile
      }

      return GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 40,
        mainAxisSpacing: 50,
        childAspectRatio: 1.6,
        children: [
          _dashboardCard(
            context,
            title: "Employees",
            image:
            "https://icon-library.com/images/staff-icon/staff-icon-4.jpg",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Employeespage()),
              );
            },
          ),
          _dashboardCard(
            context,
            title: "KOT",
            image:
            "https://cdni.iconscout.com/illustration/premium/thumb/chef-3462294-2895976.png",
            onTap: () {},
          ),
          _dashboardCard(
            context,
            title: "POS",
            image:
            "https://cdni.iconscout.com/illustration/premium/thumb/business-manager-planning-workflow-4633347-3838849.png",
            onTap: () {},
          ),
          _dashboardCard(
            context,
            title: "Take Away",
            image:
            "https://cdn3d.iconscout.com/3d/premium/thumb/delivery-person-riding-scooter-5349142-4466370.png",
            onTap: () {},
          ),
          _dashboardCard(
            context,
            title: "Message",
            image:
            "https://cdn3d.iconscout.com/3d/premium/thumb/man-and-woman-communicating-with-each-other-4620319-3917176.png",
            onTap: () {},
          ),
          _dashboardIcon(
            context,
            icon: Icons.settings,
            title: "Settings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const logsettings()),
              );
            },
          ),
        ],
      );
    },
    ),
    );



  }
}

Widget _dashboardIcon(
    BuildContext context, {
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.blueGrey),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _dashboardCard(
    BuildContext context, {
      required String title,
      required String image,
      required VoidCallback onTap,
    }) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(image, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
