import 'package:flutter/material.dart';
import './pages/lifespan.dart';

void main() => runApp(MaterialApp(
  title: 'Lifespan Calcurator',
  theme: ThemeData(
    primaryColor: Colors.orange,
  ),
  home: LifespanPage(),
));
