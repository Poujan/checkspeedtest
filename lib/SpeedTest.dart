import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';

class SpeedTest extends StatefulWidget {
  const SpeedTest({super.key});

  @override
  State<SpeedTest> createState() => _SpeedTestState();
}

class _SpeedTestState extends State<SpeedTest> {
  // ignore: non_constant_identifier_names
  StartTimer() {
    Timer(const Duration(seconds: 6), () async {
      _starttesting();
    });
  }

  final internetSpeedTest =
      FlutterInternetSpeedTest(); //FlutterInternetSpeedTest()..enableLog();

  bool _testInProgress = false;
  double _downloadRate = 0;
  double _uploadRate = 0;

  String _unitText = 'Mb/s';

  @override
  void initState() {
    super.initState();

    _startPing();
    StartTimer();
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  // Create instance of DartPing
  Ping ping = Ping('google.com', count: 6);
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

  _starttesting() async {
    _testInProgress = true;
    if (_testInProgress) {
      final started = await internetSpeedTest.startTesting(
        onDone: (TestResult download, TestResult upload) {
          if (internetSpeedTest.isLogEnabled) {
            print(
                'the transfer rate ${download.transferRate}, ${upload.transferRate}');
          }
          setState(() {
            _downloadRate = download.transferRate;
            _unitText = download.unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          });
          setState(() {
            _uploadRate = upload.transferRate;
            _unitText = upload.unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
            _testInProgress = false;
          });
        },
        onProgress: (double percent, TestResult data) {
          if (internetSpeedTest.isLogEnabled) {
            print('the transfer rate $data.transferRate, the percent $percent');
          }
          setState(() {
            _unitText = data.unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
            if (data.type == TestType.DOWNLOAD) {
              _downloadRate = data.transferRate;
            } else {
              _uploadRate = data.transferRate;
            }
          });
        },
        onError: (String errorMessage, String speedTestError) {
          if (internetSpeedTest.isLogEnabled) {
            print(
                'the errorMessage $errorMessage, the speedTestError $speedTestError');
          }
        },
      );
      setState(() => _testInProgress = started);
    }
  }

  // void _startdownload() {
  //   internetSpeed.startDownloadTesting(
  //     onDone: (double transferRate, SpeedUnit unit) {
  //       debugPrint('the transfer rate $transferRate, the percent 100');

  //       setState(() {
  //         downloadRate = transferRate;
  //         unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
  //         downloadProgress = 100;
  //       });
  //     },
  //     onProgress: (double percent, double transferRate, SpeedUnit unit) {
  //       debugPrint('the transfer rate $transferRate, the percent $percent');
  //       setState(() {
  //         downloadRate = transferRate;
  //         unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
  //         downloadProgress = percent.truncateToDouble();
  //       });
  //     },
  //     onError: (String errorMessage, String speedTestError) {
  //       downloadProgress = 0;
  //       debugPrint(
  //           'the errorMessage $errorMessage, the speedTestError $speedTestError');
  //     },
  //     fileSize: 1000000,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Center(
        child: Card(
          child: Column(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.arrow_back),
                  title: Text('Latency'),
                  subtitle: Text(
                      (_lastPing?.response?.time?.inMilliseconds.toString()) ??
                          'Start ping')),

              ListTile(
                leading: Icon(Icons.arrow_drop_down_circle),
                title: Text('Download Speed'),
                subtitle: Text('$_downloadRate $_unitText'),
              ),

              ListTile(
                leading: Icon(Icons.arrow_upward),
                title: Text('Upload Speed'),
                subtitle: Text('$_uploadRate $_unitText'),
              ),

              // Row(
              //   children: [
              //     Text('Download Speed: '),
              //     Text('$_downloadRate $_unitText'),
              //   ],
              // ),
              // Row(
              //   children: [
              //     Text('Upload Speed: '),
              //     Text('$_uploadRate $_unitText'),
              //   ],
              // )
            ],
          ),
        ),
      ),

      // ElevatedButton(
      //   child: const Text('Start Internet Test Speed'),
      //   onPressed: () {
      //     _startdownload();
      //   },
      // ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const DownloadSpeed()),
      //     );
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.download),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
