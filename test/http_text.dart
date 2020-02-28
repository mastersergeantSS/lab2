import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:isolate/isolate.dart';

// Future<List<Tech>> parseTechs(http.Client client) async {
//   final response = await client.get('https://raw.githubusercontent.com/wesleywerner/ancient-tech/02decf875616dd9692b31658d92e64a20d99f816/src/data/techs.ruleset.json');
//   final parsed = jsonDecode(response.body).cast<Map<String,dynamic>>();
//   return parsed.map<Tech>((json) => Tech.fromJson(json)).toList();
// }


class Tech {
  String picUrl = 'https://raw.githubusercontent.com/wesleywerner/ancient-tech/02decf875616dd9692b31658d92e64a20d99f816/src/images/tech/';
  String name;
  String helptext;
  Image img;

  Tech(String endUrl, String name, String helptext) {
    picUrl += endUrl;
    this.name = name;
    this.helptext = helptext;
  }

  factory Tech.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('description')) {
      return null;
    }
    return Tech(json['graphic'] as String, json['name'] as String, json['helptext']as String);
  }
}



  void main(List<String> args) {
    final parsed = jsonDecode('assets/data/techs.ruleset.json').cast<Map<String, dynamic>>();
    return parsed.map<Tech>((json) => Tech.fromJson(json)).toList();
  }