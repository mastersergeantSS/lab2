import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:isolate/isolate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {

  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen.navigate(
        name: 'assets/splash1.flr',
        next: (context) => MyHomePage(),
        backgroundColor: Colors.white70,
        until: () => Future.delayed(Duration(seconds: 2)),
        loopAnimation: 'splash',
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: FutureBuilder<List<Tech>>(
      future: isolateFunc(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
                ? BuildList(snapshot.data)
                : Center(child: CircularProgressIndicator());
      }
    )
    ); 
  }
}


class BuildList extends StatefulWidget {
  List<Tech> Techs;
  BuildList(this.Techs);
  @override
  _BuildListState createState() => _BuildListState(Techs);
}

class _BuildListState extends State<BuildList> {

  List<Tech> Techs;
  _BuildListState(this.Techs);

  @override 
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,
                                        DeviceOrientation.landscapeLeft,
                                        DeviceOrientation.landscapeRight]); 


   return 
    Scaffold(
        appBar: AppBar(
          title: Text('Techs list'),
          backgroundColor: Colors.yellow,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(6.0),
          itemCount: Techs.length,
          itemBuilder: (context, i) {
              var url = Techs[i].getUrl();
              return ListTile(
              
              title: Text(Techs[i].getName()), 
              trailing: CachedNetworkImage(
                imageUrl: url, 
                width: 50,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error,
                size: 50.0,
                ),
              ),
              onTap: () { Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuildPages(Techs, i),
              ),
            );
            },
          );
        } 
        )
      );
  }
}


class BuildPages extends StatefulWidget {
  int index;
  List<Tech> Techs;

  BuildPages(this.Techs, this.index);
  @override
  _BuildPagesState createState() => _BuildPagesState(Techs, index);
}

class _BuildPagesState extends State<BuildPages> {
  int index;
  List<Tech> Techs;

  _BuildPagesState(this.Techs, this.index);

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: PageController(initialPage: index),
        itemCount: Techs.length,
        itemBuilder: (context, index) {
          var url = Techs[index].getUrl();
          return  ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(100),
                child: CachedNetworkImage(
                
                imageUrl: url,
                placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 5.0,),
                errorWidget: (context, url, error) => Icon(Icons.error, size: 50.0),
                alignment: Alignment.center,
                
              ),
              ),
              Container(
                  child: 
                  Text(Techs[index].getText(), textScaleFactor: 2.0, textAlign: TextAlign.center),
              ),
            ],
            
          );
        } 
        )
    );
  }

}


class Tech {
  String picUrl = 'https://raw.githubusercontent.com/wesleywerner/ancient-tech/02decf875616dd9692b31658d92e64a20d99f816/src/images/tech/';
  String name;
  String helptext = 'Coming soon...';
  Image img;

  Tech(String endUrl, String name, String helptext) {
    picUrl += endUrl;
    this.name = name;
    if (helptext != null) 
    this.helptext = helptext;
  }

  factory Tech.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('description')) {
      return null;
    }
    return Tech(json['graphic'] as String, json['name'] as String, json['helptext']as String);
  }

  
  String getName() => this.name;
  String getUrl() => this.picUrl;
  String getText() => this.helptext;
}


Future<List<Tech>> parseTechs(http.Client client) async {
  final response = await client.get('https://raw.githubusercontent.com/wesleywerner/ancient-tech/02decf875616dd9692b31658d92e64a20d99f816/src/data/techs.ruleset.json');
  final parsed = jsonDecode(response.body).cast<Map<String,dynamic>>();
  parsed.removeAt(0);
  
  return parsed.map<Tech>((json) => Tech.fromJson(json)).toList();
}

Future<List<Tech>> isolateFunc(http.Client client) async {
  final runner = await IsolateRunner.spawn();
  return runner
  .run(parseTechs, client)
  .whenComplete(() => runner.close());
}













































