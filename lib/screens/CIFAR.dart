import 'package:flutter/material.dart';
import 'package:handwriting_detection/commons/sidebar.dart';

class CIFAR extends StatefulWidget {
  @override
  _CIFARState createState() => _CIFARState();
}

class _CIFARState extends State<CIFAR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [Sidebar(selectedIndex: 2)],
      ),
    );
  }
}
