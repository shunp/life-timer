import 'package:flutter/material.dart';
import './pages/lifespan.dart';

void main() => runApp(MaterialApp(
  title: 'Lifespan Calcurator',
  // theme: ThemeData(
  //   primaryColor: Color(0xffb74093),
  //   backgroundColor: Colors.black54
  // ),
  theme: ThemeData.dark(),
  home: LifespanPage(),
));
