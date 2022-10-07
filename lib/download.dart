import 'package:checkspeedtest/upload.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:internet_speed/callbacks_enum.dart';
import 'package:internet_speed/internet_speed.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DownloadSpeed extends StatefulWidget {
  const DownloadSpeed({Key? key}) : super(key: key);

  @override
  State<DownloadSpeed> createState() => _DownloadSpeedState();
}

class _DownloadSpeedState extends State<DownloadSpeed> {
  InternetSpeed internetSpeed = InternetSpeed();

  double downloadRate = 0;
  double uploadRate = 0;
  double downloadProgress = 0;
  double uploadProgress = 0;
  String unitText = 'Mb/s';

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Widget _getRadialGauge({texts, number, values}) {
    return SfRadialGauge(
        title: GaugeTitle(
            text: texts,
            textStyle:
                const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 100, ranges: <GaugeRange>[
            GaugeRange(
                startValue: 0,
                endValue: 30,
                color: Colors.red,
                startWidth: 10,
                endWidth: 10),
            GaugeRange(
                startValue: 30,
                endValue: 60,
                color: Colors.orange,
                startWidth: 10,
                endWidth: 10),
            GaugeRange(
                startValue: 60,
                endValue: 100,
                color: Colors.green,
                startWidth: 10,
                endWidth: 10)
          ], pointers: <GaugePointer>[
            NeedlePointer(value: values)
          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Text(number.toString(),
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold)),
                angle: 90,
                positionFactor: 0.5)
          ])
        ]);
  }

  @override
  void initState() {
    super.initState();
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
      developer.log('Couldn\'t check connectivity status', error: e);
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
    // Ping ping = Ping('google.com', count: 5);
    // PingData? lastPing;

    // void _startPing() {
    //   ping.stream.listen((event) {
    //     setState(() {
    //       lastPing = event;
    //     });
    //   });
    //   print(lastPing);
    // }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Internet Speed'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                Text(
                    'Connection Status: ${_connectionStatus.name.toUpperCase()} Network'),
                _getRadialGauge(
                    texts: 'Download Speed Tests',
                    number: '$downloadRate $unitText',
                    values: downloadRate),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[],
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  child: const Text('Start Internet Test Speed'),
                  onPressed: () {
                    internetSpeed.startDownloadTesting(
                      onDone: (double transferRate, SpeedUnit unit) {
                        debugPrint(
                            'the transfer rate $transferRate, the percent 100');

                        setState(() {
                          downloadRate = transferRate;
                          unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                          downloadProgress = 100;
                        });
                      },
                      onProgress: (double percent, double transferRate,
                          SpeedUnit unit) {
                        debugPrint(
                            'the transfer rate $transferRate, the percent $percent');
                        setState(() {
                          downloadRate = transferRate;
                          unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                          downloadProgress = percent.truncateToDouble();
                        });
                      },
                      onError: (String errorMessage, String speedTestError) {
                        downloadProgress = 0;
                        debugPrint(
                            'the errorMessage $errorMessage, the speedTestError $speedTestError');
                      },
                      // testServer:
                      //     'https://speedtest.gsmnet.id.prod.hosts.ooklaserver.net:8080',
                      fileSize: 1000000,
                    );
                  },
                ),
                // ElevatedButton(
                //   onPressed: _startPing,
                //   child: const Text('Test ping'),
                // ),
                // Text(
                //   lastPing?.toString() ?? 'Push the button to begin ping',
                // ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadSpeed()),
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.speed),
        ),
      ),
    );
  }
}
