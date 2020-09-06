import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer';
import 'dart:async';

import 'common/button.dart';

void main() {
  runApp(MyApp());
}

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
          // primarySwatch: Colors.deepPurple,
          primaryColor: Color(0xff6200EE)),
      home: MyHomePage(title: 'Overdose Incident Form'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime selectedDate = DateTime.now();
  String selectedLocation = "";
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

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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
      body: Column(children: [
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
        Padding(
          padding: const EdgeInsets.all(0),
          child: Button(
            callback: () => log('Scan button pressed'),
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
        Text("Date of overdose", style: TextStyle(fontSize: 15.0)),
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
        Text("Location of overdose", style: TextStyle(fontSize: 15.0)),
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
                    selectedLocation,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ))),
        // Container(
        //   height: 150,
        //   child: GoogleMap(
        //     mapType: MapType.hybrid,
        //     initialCameraPosition: _kGooglePlex,
        //     onMapCreated: (GoogleMapController controller) {
        //       _controller.complete(controller);
        //     },
        //   ),
        // ),

        Container(
          margin: const EdgeInsets.only(top: 0),
          child: Text("Was Naloxone administered?",
              style: TextStyle(fontSize: 15.0)),
        ),
        ListTile(
          // contentPadding: const EdgeInsets.only(top: 0, bottom: 0),
          title: const Text('Yes'),
          leading: Radio(
            value: true,
            groupValue: naloxoneAdmin,
            onChanged: (bool value) {
              setState(() {
                naloxoneAdmin = value;
              });
            },
          ),
        ),
        ListTile(
          // contentPadding: const EdgeInsets.all(0),
          title: const Text('No'),
          leading: Radio(
            value: false,
            groupValue: naloxoneAdmin,
            onChanged: (bool value) {
              setState(() {
                naloxoneAdmin = value;
              });
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          child: Button(
            callback: () => log('Submit Form Pressed'),
            title: "Submit Form",
          ),
        ),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
