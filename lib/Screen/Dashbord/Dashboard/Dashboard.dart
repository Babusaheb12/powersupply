import 'package:flutter/material.dart';

import '../../../Api/shared_preference.dart';
import '../../../utils/Size_config.dart';
import '../../../utils/flutter_font_style.dart';
import '../../StoreReading/storereadingshow/readingshow/readingshow.dart';
import '../AddProject/AddProject.dart';
import '../AddProject/AddstoreProject.dart';
import '../viewReports/ShowInReading.dart';


class DashboardPage extends StatelessWidget {   /// viewFactoryReading
  final Function(int)? onNavigateToProfile;

   DashboardPage({super.key, this.onNavigateToProfile});

  @override
  Widget build(BuildContext context) {
    return _DashboardPageView(onNavigateToProfile: onNavigateToProfile);
  }
}

class _DashboardPageView extends StatelessWidget {
  final Function(int)? onNavigateToProfile;

   _DashboardPageView({this.onNavigateToProfile});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    /// Get user data from SharedPreferences
    final userData = Prefs.userData;
    String userName = userData?['name'] ?? 'User';
    String userId = userData?['id'] ?? 'N/A';
    String department = userData?['role'] ?? 'N/A';
    String email = userData?['email'] ?? 'N/A';

    return Scaffold(
      backgroundColor:  Color(0xFFF8F9FA),

      appBar: AppBar(
        title: Text('Dashboard', style: FTextStyle.dashboard(context)),
        backgroundColor:  Color(0xFF007BFF),
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>  MyNotificationScreen(),
              //   ),
              // );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Welcome Card
            Card(
              color: Colors.transparent, // background remove
              elevation: 0, // shadow remove
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome,", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),

                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "ID: $userId • $department",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding:  EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Quick Actions", style: FTextStyle.header(context)),
                   SizedBox(height: 10),

                  /// Create Site
                  _actionCard(
                    icon: Icons.add,
                    color:  Color(0xFF007BFF),
                    title: "Add Meter Reading",
                    subtitle: "capture new kwh & Kvah reading",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  CreateNewProject(),   ///ShowInReadingScreen
                        ),
                      );
                    },
                  ),

                  /// Draw Layout
                  _actionCard(
                    icon: Icons.electric_meter,
                    color: Color(0xFF28A745),
                    title: "Add Store Meter Reading",
                    subtitle: "Add and manage meter readings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateStoreProject(),
                        ),
                      );
                    },
                  ),

                  /// Reports
                  _actionCard(
                    icon: Icons.description,
                    color:  Color(0xFF28A745),
                    title: "View Reports",
                    subtitle: "Check previous meter reading",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  ShowInReadingScreen(),
                        ),
                      );
                    },
                  ),

                  _actionCard(
                    icon: Icons.receipt_long, // better icon for reports 📊
                    color: Color(0xFF28A745),
                    title: "View Store Reading",
                    subtitle: "Check previous store meter readings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreReadingScreen(),
                        ),
                      );
                    },
                  ),
                   SizedBox(height: 20),

                  Text("Employee Information",
                      style: FTextStyle.header(context)),

                   SizedBox(height: 10),

                  Card(
                    child: Column(
                      children: [
                        _profileRow("Employee ID", userId),
                         Divider(),
                        _profileRow("Email", email),
                         Divider(),
                        _profileRow("Department", department),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Action Card Widget
  Widget _actionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white, // card background white
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  /// Profile Row
  Widget _profileRow(String title, String value) {
    return Padding(
      padding:  EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(child: Text(title, style:  TextStyle(color: Colors.grey))),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style:  TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}


