import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';

class SpeedTestList extends StatefulWidget {
  const SpeedTestList({super.key});

  @override
  State<SpeedTestList> createState() => _SpeedTestListState();
}


class _SpeedTestListState extends State<SpeedTestList> {
  final Map<String, List> _elements = {
  'Speed Test': [],
};

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
    return MaterialApp(
      title: 'Group List View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Check You Internet Speed'),
        ),
        body: GroupListView(
          sectionsCount: _elements.keys.toList().length,
          countOfItemInSection: (int section) {
            return _elements.values.toList()[section].length;
          },
          itemBuilder: _itemBuilder,
          groupHeaderBuilder: (BuildContext context, int section) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Text(
                _elements.keys.toList()[section],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 10),
          sectionSeparatorBuilder: (context, section) => SizedBox(height: 10),
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, IndexPath index) {
    String user = _elements.values.toList()[index.section][index.index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 8,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10.0),
          leading: CircleAvatar(
            child: Text(
              _getInitials(user),
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          title: Text(
            _elements.values.toList()[index.section][index.index],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  String _getInitials(String user) {
    var buffer = StringBuffer();
    var split = user.split(" ");
    for (var s in split) buffer.write(s[0]);

    return buffer.toString().substring(0, split.length);
  }
}
