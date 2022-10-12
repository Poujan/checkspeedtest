import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:checkspeedtest/SpeedTest.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_speed/callbacks_enum.dart';
import 'package:internet_speed/internet_speed.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// Sets a platform override for desktop to avoid exceptions. See
// https://flutter.dev/desktop#target-platform-override for more info.
void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  _enablePlatformOverrideForDesktop();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InternetSpeed internetSpeed = InternetSpeed();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String _connectionStatus2 = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();

  // @override
  // void initState() {
  //   super.initState();
  //   _initNetworkInfo();
  // }
  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Test'),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Container(
          margin: const EdgeInsets.symmetric(vertical: 250.0),
          child: Column(
            children: [
              const Text(
                'CLICK HERE TO BEGIN',
                style: TextStyle(fontSize: 18, color: Colors.black38),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SpeedTest()));
                },
                child: const Text('Start Test'),
              ),
              const SizedBox(
                height: 150,
              ),
              const Divider(
                color: Colors.black,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: const Text(
                  'Network info',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  Text(
                    _connectionStatus2,
                    style: const TextStyle(fontSize: 16, color: Colors.black38),
                  ),
                  Text(
                    'Connect To: ${_connectionStatus.name.toUpperCase()} Network',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }

  Future<void> _initNetworkInfo() async {
    String? IPv4;

    try {
      IPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      IPv4 = 'Failed to get IPv4';
    }

    setState(() {
      _connectionStatus2 = 'IPv4: $IPv4\n';
    });
  }
}
