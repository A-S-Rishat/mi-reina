import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vibration/vibration.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://mi-reina-b3230-default-rtdb.asia-southeast1.firebasedatabase.app",
  ).ref();

  String myUserId = "userA";
  String friendUserId = "userB";

  @override
  void initState() {
    super.initState();
    listenForPokes();
  }

  void sendPoke() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await database.child('pokes/$friendUserId').set({
      'from': myUserId,
      'timestamp': timestamp,
    });
    print("Poke sent to $friendUserId");
  }

  void listenForPokes() {
    database.child('pokes/$myUserId').onValue.listen((event) {
      print("Listener triggered: ${event.snapshot.exists}");
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map;
        final from = data['from'];
        final timestamp = data['timestamp'];

        print("Received poke from $from at $timestamp");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Poke received from $from')));
        Vibration.vibrate(duration: 500);
        database.child('pokes/$myUserId').remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: sendPoke,
          child: Text(
            "Poke",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
