import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:handwriting_detection/controllers/route_controller/fade.dart';
import 'package:handwriting_detection/main.dart';
import 'package:handwriting_detection/screens/CATvsDog.dart';
import 'package:handwriting_detection/screens/CIFAR.dart';
import 'package:handwriting_detection/screens/MNIST.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;

  const Sidebar({Key key, @required this.selectedIndex}) : super(key: key);
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with TickerProviderStateMixin {
  List<String> _list = [
    "Home",
    "MNIST",
    "CIFAR10",
    "CAT&DOG",
    "FOUR",
    "FIVE",
    "SIX",
    "SEVEN",
    "EIGHT",
    "NINE",
    "TEN",
    "ABOUT"
  ];

  int checkIndex = 0;

  @override
  void initState() {
    super.initState();
    checkIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: _buildList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildList() {
    List<Widget> _widget_list = [];

    for (int i = 0; i < _list.length; i++) {
      _widget_list.add(GestureDetector(
          onTap: () {
            setState(() {});
            indexChecked(i);
            //Add screen here
            switch (i) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  FadeRoute(page: HomePage()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  FadeRoute(page: MNIST()),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  FadeRoute(page: CIFAR()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  FadeRoute(page: CATvsDOG()),
                );
                break;
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 7,
            child: VerticalText(_list[i], checkIndex == i),
          )));
    }
    return _widget_list;
  }

  void indexChecked(int i) {
    if (checkIndex == i) return;

    setState(() {
      checkIndex = i;
    });
  }
}

class VerticalText extends StatelessWidget {
  String name;
  bool checked;

  VerticalText(this.name, this.checked);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Text(
        name,
        style: TextStyle(
          color: checked ? Colors.black : Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
