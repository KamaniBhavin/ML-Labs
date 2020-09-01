import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:handwriting_detection/model/draw_model.dart';
import 'package:rxdart/rxdart.dart';

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  List<DrawModel> pointsList = List();

  final pointsStream = BehaviorSubject<List<DrawModel>>();
  GlobalKey key = GlobalKey();
  GlobalKey repaintKey = GlobalKey();

  @override
  void dispose() {
    pointsStream.close();
    super.dispose();
  }

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          repaintKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      String bs64 = base64Encode(pngBytes);
      final decodedBytes = base64Decode(bs64);
      Image imagePNG = new Image.memory(pngBytes);
      print(bs64);
      print('png done');
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: GestureDetector(
        onPanStart: (details) {
          RenderBox renderBox = key.currentContext.findRenderObject();

          Paint paint = Paint();

          paint.color = Theme.of(context).accentColor;
          paint.strokeWidth = 3.0;
          paint.strokeCap = StrokeCap.round;

          pointsList.add(DrawModel(
              offset: renderBox.globalToLocal(details.globalPosition),
              paint: paint));
          pointsStream.add(pointsList);
        },
        onPanUpdate: (details) {
          RenderBox renderBox = key.currentContext.findRenderObject();

          Paint paint = Paint();

          paint.color = Theme.of(context).accentColor;
          paint.strokeWidth = 3.0;
          paint.strokeCap = StrokeCap.round;

          pointsList.add(DrawModel(
              offset: renderBox.globalToLocal(details.globalPosition),
              paint: paint));
          pointsStream.add(pointsList);
        },
        onPanEnd: (details) {
          pointsList.add(null);
          pointsStream.add(pointsList);
          Future<Uint8List> image = _capturePng();
        },
        child: Container(
          child: StreamBuilder<List<DrawModel>>(
              stream: pointsStream.stream,
              builder: (context, snapshot) {
                return RepaintBoundary(
                  key: repaintKey,
                  child: CustomPaint(
                    painter: DrawingPainter((snapshot.data ?? List())),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  List<DrawModel> pointList;

  DrawingPainter(this.pointList);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < (pointList.length - 1); i++) {
      if (pointList[i] != null && pointList[i + 1] != null) {
        canvas.drawLine(
            pointList[i].offset, pointList[i + 1].offset, pointList[i].paint);
      } else if (pointList[i] != null && pointList[i + 1] == null) {
        List<Offset> offsetLists = List();
        offsetLists.add(pointList[i].offset);
        canvas.drawPoints(ui.PointMode.points, offsetLists, pointList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
