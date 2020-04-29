import 'package:flutter/material.dart';
import 'package:flutter_camera_app/custom_camera_view.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Custom Camera'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> imageList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestPermission();
  }

  void _requestPermission() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  void _incrementCounter() async {
    setState(() {
      imageList = null;
    });
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CameraTest(),
      ),
    );
    setState(() {
      imageList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              'Click on camera to open custom camera',
            ),
            imageList != null
                ? new Column(
                    children: imageList
                        .map((dynamic val) => new Text('\n${val.toString()}'))
                        .toList(),
                  )
                : new Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
