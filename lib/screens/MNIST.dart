import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:custom_switch/custom_switch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:handwriting_detection/commons/sidebar.dart';
import 'package:handwriting_detection/controllers/draw_controller.dart';
import 'package:handwriting_detection/controllers/network_controller.dart';
import 'package:handwriting_detection/model/draw_model.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';

class MNIST extends StatefulWidget {
  @override
  _MNISTState createState() => _MNISTState();
}

class _MNISTState extends State<MNIST> {
  List<DrawModel> pointsList = List();
  bool selectedCNN = false, painted = false;
  var maxClass;

  final pointsStream = BehaviorSubject<List<DrawModel>>();
  GlobalKey key = GlobalKey();
  GlobalKey repaintKey = GlobalKey();

  @override
  void dispose() {
    pointsStream.close();
    super.dispose();
  }

  Future<String> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          repaintKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      String bs64 = base64Encode(pngBytes);
      setState(() {});
      return bs64;
    } catch (e) {
      print(e);
    }
  }

  File _imagePicker;

  Future getImage(ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
    );
    setState(() {
      _imagePicker = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Sidebar(
          selectedIndex: 1,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 32.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                height: MediaQuery.of(context).size.height / 10,
                width: MediaQuery.of(context).size.width * 0.7,
                child: Center(
                    child: Text(
                  'MNIST',
                  style: TextStyle(fontSize: 24),
                )),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orangeAccent),
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CNN'),
                      CustomSwitch(
                        activeColor: Colors.orangeAccent,
                        value: selectedCNN,
                        onChanged: (value) {
                          print("VALUE : $value");
                          setState(() {
                            selectedCNN = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              (_imagePicker == null)
                  ? Container(
                      child: Container(
                        key: key,
                        child: GestureDetector(
                          onPanStart: (details) {
                            RenderBox renderBox =
                                key.currentContext.findRenderObject();

                            Paint paint = Paint();

                            paint.color = Theme.of(context).accentColor;
                            paint.strokeWidth = 3.0;
                            paint.strokeCap = StrokeCap.round;

                            pointsList.add(DrawModel(
                                offset: renderBox
                                    .globalToLocal(details.globalPosition),
                                paint: paint));
                            pointsStream.add(pointsList);
                          },
                          onPanUpdate: (details) {
                            RenderBox renderBox =
                                key.currentContext.findRenderObject();

                            Paint paint = Paint();

                            paint.color = Theme.of(context).accentColor;
                            paint.strokeWidth = 3.0;
                            paint.strokeCap = StrokeCap.round;

                            pointsList.add(DrawModel(
                                offset: renderBox
                                    .globalToLocal(details.globalPosition),
                                paint: paint));
                            pointsStream.add(pointsList);
                          },
                          onPanEnd: (details) {
                            pointsList.add(null);
                            pointsStream.add(pointsList);
                          },
                          child: Container(
                            child: StreamBuilder<List<DrawModel>>(
                                stream: pointsStream.stream,
                                builder: (context, snapshot) {
                                  return RepaintBoundary(
                                    key: repaintKey,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: CustomPaint(
                                        painter: DrawingPainter(
                                            (snapshot.data ?? List())),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Image.file(
                        _imagePicker,
                        fit: BoxFit.cover,
                      ),
                    ),
              (painted)
                  ? Container(
                      height: 90,
                      width: 70,
                      child: Ink(
                        decoration: const ShapeDecoration(
                          color: Colors.orangeAccent,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close),
                          color: Colors.white,
                          onPressed: () async {
                            setState(() {});
                            painted = false;
                            pointsList = [];
                            pointsStream.add(null);
                            _imagePicker = null;
                          },
                        ),
                      ),
                    )
                  : Container(
                      height: 90,
                      width: 70,
                      child: Ink(
                        decoration: const ShapeDecoration(
                          color: Colors.orangeAccent,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_downward),
                          color: Colors.white,
                          onPressed: () async {
                            painted = true;
                            if (_imagePicker == null) {
                              String bs64 = await _capturePng();
                              var res = await NetworkController()
                                  .getPredictionOnMNISTFFNNDraw(bs64);
                              maxClass = jsonDecode(res);
                            } else {
                              Dio dio = Dio();
                              String fileName =
                                  _imagePicker.path.split('/').last;
                              FormData formData = FormData.fromMap({
                                'file': MultipartFile.fromFileSync(
                                    _imagePicker.path)
                              });
                              var res = await dio.post(
                                  'http://35.232.215.158/api/MNIST/FFNN',
                                  data: formData);
                              print(res.data);
                              maxClass = res.data;
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ),
              Container(
                height: 120,
                child: CircularPercentIndicator(
                  radius: 90.0,
                  lineWidth: 7.0,
                  percent: maxClass != null
                      ? double.parse(maxClass['probability'])
                      : 0,
                  center: new Text(
                      maxClass != null ? '${maxClass['class_id']}' : 'NAN'),
                  progressColor: Colors.orange,
                ),
              )
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage(ImgSource.Camera);
        },
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }
}
