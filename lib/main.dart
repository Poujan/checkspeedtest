import 'package:checkspeedtest/download.dart';
import 'package:checkspeedtest/upload.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';

void main() {
  // Register dart_ping_ios with dart_ping
  DartPingIOS.register();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'DartPing Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create instance of DartPing
  Ping ping = Ping('google.com', count: 5);
  PingData? _lastPing;

  List<String> pingData = [];

  void _startPing() {
    ping.stream.listen((event) {
      setState(() {
        // pingData.add(event.response?.time?.inMilliseconds);
        if (event.response?.time?.inMilliseconds != null) {
          _lastPing = event;
        }
      });
    });
  }

  bool _isPressed = false;

  void _myCallback() {
    setState(() {
      _isPressed = true;
    });
    _startPing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DartPing Flutter Demo'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _isPressed == false ? _myCallback : null,
            child: const Icon(Icons.radar_sharp),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  (_lastPing?.response?.time?.inMilliseconds.toString()) ??
                      'Push the button to begin ping',
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DownloadSpeed()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.download),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
