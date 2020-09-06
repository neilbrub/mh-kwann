import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:async';

import 'common/button.dart';

import 'package:camera/camera.dart';
import 'package:reporter/scan.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OD Report',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          // primarySwatch: Colors.grey,
          primaryColor: Color(0xff878787)),
      home: MyHomePage(title: 'Overdose Incident Form'),
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
  DateTime selectedDate = DateTime.now();
  String selectedLocationString = "";
  LatLng selectedLocation = new LatLng(43.4643, -80.5204);
  String comment = "";
  bool naloxoneAdmin;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> setLocation(LatLng loc) async {
    final http.Response res = await http.get(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${loc.latitude},${loc.longitude}&key=AIzaSyAt0uDly9OqciR3hgpDsSzpAX4KCeXkljo');
    setState(() {
      selectedLocationString =
          json.decode(res.body)['results'][0]['formatted_address'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView(children: [
        Container(
          padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
          child: Text(
            'Fill out the form manually or scan the ambulance call report (ACR) if you have it on hand.',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.only(top: 14, right: 16, left: 16, bottom: 14),
          child: Text(
            'Scanning an ACR will allow the app to extract data from the report to automatically fill out the form. ',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          child: Button(
            callback: () => Navigator.push(context,
                new MaterialPageRoute(builder: (ctxt) => new ACRScreen())),
            title: "Scan ACR Report",
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 30,
          thickness: 0.3,
          indent: 10,
          endIndent: 10,
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          child: Text("Date of overdose", style: TextStyle(fontSize: 15.0)),
        ),
        GestureDetector(
            onTap: () {
              _selectDate(context);
            },
            child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: new Center(
                  child: new Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ))),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          child: Text("Location of overdose", style: TextStyle(fontSize: 15.0)),
        ),
        GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (ctxt) => new MapsScreen(
                          loc: selectedLocation, setLocation: setLocation)));
            },
            child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: new Center(
                  child: new Text(
                    selectedLocationString,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ))),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          child: Text("Was Naloxone administered?",
              style: TextStyle(fontSize: 15.0)),
        ),
        Container(
            padding: const EdgeInsets.all(0),
            child: Row(children: [
              Radio(
                value: true,
                activeColor: Color(0xff6200EE),
                groupValue: naloxoneAdmin,
                onChanged: (bool value) {
                  setState(() {
                    naloxoneAdmin = value;
                  });
                },
              ),
              Text("Yes", style: TextStyle(fontSize: 16.0))
            ])),
        Container(
            padding: const EdgeInsets.all(0),
            child: Row(children: [
              Radio(
                value: false,
                activeColor: Color(0xff6200EE),
                groupValue: naloxoneAdmin,
                onChanged: (bool value) {
                  setState(() {
                    naloxoneAdmin = value;
                  });
                },
              ),
              Text("No", style: TextStyle(fontSize: 16.0))
            ])),
        Container(
          margin: const EdgeInsets.only(top: 5, left: 16, right: 16),
          child: Text("Comments", style: TextStyle(fontSize: 15.0)),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: TextField(
            decoration: new InputDecoration.collapsed(hintText: ''),
            cursorColor: Color(0xff6200EE),
            onSubmitted: (String value) {
              comment = value;
              log(comment);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          child: Button(
            callback: () => Navigator.push(context,
                new MaterialPageRoute(builder: (ctxt) => new SubmitScreen())),
            title: "Submit Form",
          ),
        ),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ACRScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Scan ACR Report"),
      ),
      body: new Text("Scan"),
    );
  }
}

class MapsScreen extends StatelessWidget {
  final LatLng loc;
  final void Function(LatLng) setLocation;

  final Completer<GoogleMapController> _controller = Completer();

  MapsScreen({Key key, @required this.loc, @required this.setLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Select Overdose Location"),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: new CameraPosition(target: loc, zoom: 15),
        onTap: (LatLng loc) {
          setLocation(loc);
          Navigator.pop(context);
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}

class SubmitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(""),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 50, right: 16, left: 16),
            child: Text(
              'Your form has been submitted.',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 200),
            child: Button(
              callback: () => Navigator.pop(context),
              title: "Submit new report",
            ),
          ),
        ]));
  }
}
