import 'dart:io';

import 'package:custom_switch/custom_switch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:handwriting_detection/commons/sidebar.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';

class CATvsDOG extends StatefulWidget {
  @override
  _CATvsDOGState createState() => _CATvsDOGState();
}

class _CATvsDOGState extends State<CATvsDOG> {
  File _imagePicker;
  bool inserted = false, loading = false, dropout = false;
  var maxClass;
  int _prediction;
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
      body: Row(
        children: [
          Sidebar(
            selectedIndex: 3,
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
                      'Cat vs Dog',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
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
                        Text('Dropout'),
                        CustomSwitch(
                          activeColor: Colors.orangeAccent,
                          value: dropout,
                          onChanged: (value) {
                            print("VALUE : $value");
                            setState(() {
                              dropout = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                (inserted == true || _imagePicker != null)
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: (_prediction == 0)
                            ? Image.asset('assets/Cat.jpg')
                            : (_prediction == 1)
                                ? Image.asset('assets/Dog.jpg')
                                : Image.file(_imagePicker),
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
                        child: Center(
                          child: Text('Add your friends pic'),
                        ),
                      ),
                (inserted)
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
                              inserted = false;
                              _imagePicker = null;
                              _prediction = 999;
                              loading = false;
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
                              setState(() {});
                              inserted = true;
                              loading = true;
                              Dio dio = Dio();
                              String fileName =
                                  _imagePicker.path.split('/').last;
                              FormData formData = FormData.fromMap({
                                'file': MultipartFile.fromFileSync(
                                    _imagePicker.path)
                              });
                              var res;
                              if (dropout) {
                                res = await dio.post(
                                    'http://35.232.215.158/api/CVD/with/dropout',
                                    data: formData);
                              } else {
                                res = await dio.post(
                                    'http://35.232.215.158/api/CVD/without/dropout',
                                    data: formData);
                              }
                              print(res.data);
                              maxClass = res.data;

                              setState(() {
                                loading = false;
                                if (maxClass['class_id'] == 'Cat') {
                                  _prediction = 0;
                                } else {
                                  _prediction = 1;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                Center(
                  child: Text((loading) ? 'Keep calm Processing...' : ''),
                )
              ],
            ),
          ),
        ],
      ),
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
