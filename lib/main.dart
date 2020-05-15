import 'package:flutter/material.dart';
import 'package:pesquisagifs/ui/HomePage.dart';
void main () {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      hintColor: Colors.white
    ),
  ));
}