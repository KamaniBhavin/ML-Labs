import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavigationModel {
  String title;
  IconData icon;

  NavigationModel({this.title, this.icon});
}

List<NavigationModel> navigationItems = [
  NavigationModel(title: "MNIST", icon: FontAwesomeIcons.penFancy),
  NavigationModel(title: "CIFAR", icon: FontAwesomeIcons.fileImage),
  NavigationModel(title: "About", icon: Icons.info),
];
