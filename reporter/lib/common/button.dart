import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final VoidCallback callback;
  final String title;

  Button({Key key, @required this.callback, @required this.title})
      : super(key: key);

  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Color(0xff6200EE),
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20, right: 20),
      splashColor: Colors.deepPurpleAccent,
      onPressed: () {
        widget.callback();
      },
      child: Text(
        widget.title,
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}
