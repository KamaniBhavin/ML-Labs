import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'draw_model.dart';

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
