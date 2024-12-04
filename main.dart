import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOT Drop-Off System',
      theme: ThemeData(
        primaryColor: Colors.blueGrey[800],
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.tealAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DoorControlPage(),
    );
  }
}

class DoorControlPage extends StatefulWidget {
  const DoorControlPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DoorControlPageState createState() => _DoorControlPageState();
}

class _DoorControlPageState extends State<DoorControlPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Firebase Realtime Database reference
  String doorStatus = "Unknown";
  String connectionStatus = "Not Connected";
  String notification = "No Data";

  @override
  void initState() {
    super.initState();

    // Listening to changes in the Firebase database
    _database.child("ultrasonic/notification").onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        notification = data.toString();
      });
    });
  }

  void lockDoor() {
    setState(() {
      doorStatus = "Locked";
    });
    _database.child("doorStatus").set("Locked"); // Send status to Firebase
  }

  void unlockDoor() {
    setState(() {
      doorStatus = "Unlocked";
    });
    _database.child("doorStatus").set("Unlocked"); // Send status to Firebase
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text("IOT Drop-Off System"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenPadding, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusCard("Connection Status", connectionStatus, Icons.wifi, Colors.blueGrey),
            const SizedBox(height: 20),
            _buildStatusCard("Door Status", doorStatus, Icons.lock, Colors.orangeAccent),
            const SizedBox(height: 20),
            _buildStatusCard("Notification", notification, Icons.notification_important, Colors.greenAccent),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildControlButton("Lock Door", Icons.lock_outline, Colors.redAccent, lockDoor),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildControlButton("Unlock Door", Icons.lock_open, Colors.greenAccent, unlockDoor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, IconData icon, Color color) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          status,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildControlButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
