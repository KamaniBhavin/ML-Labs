import 'dart:convert';

import 'package:http/http.dart';

class NetworkController {
  String baseURL = 'http://35.232.215.158/api';

  Future getData(String bs64) async {
    String url = baseURL + '/MNIST/draw';

    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    String requestedBody = jsonEncode({'bs64': '$bs64'});

    Response response = await post(url, headers: headers, body: requestedBody);
    print(response.body);
    if (response.statusCode == 200) {
      String data = response.body;
      print(data);
      return data;
    } else {
      print('FAILED');
      var failed = 'failed';
      return failed;
    }
  }
}
