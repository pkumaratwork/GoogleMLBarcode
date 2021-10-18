import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

import 'package:flutter_beep/flutter_beep.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String qr;
  bool camState = false;
  QrCamera camera;
  double _currentZoomLevel=0;
  //double _currentSliderValue=0;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    camera=
        QrCamera(
      onError: (context, error) => Text(
        error.toString(),
        style: TextStyle(color: Colors.red),
      ),
      qrCodeCallback: (code) async{
        //var cz=await camera.getCurZoom();
        setState(() {
          FlutterBeep.beep();
          qr = code;
          _currentZoomLevel= camera.getCurrentZoomLevel();
          camState=false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
              color: Colors.orange,
              width: 10.0,
              style: BorderStyle.solid),
        ),
      ),
    );

  camera.setPreferedZoomLevel(_currentZoomLevel);

    return Scaffold(
      appBar: AppBar(
        title: Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: camState
                    ? Center(

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300.0,
                              height: 500.0,
                              child: camera,
                            ),
                            // RaisedButton
                            //   (
                            //   child: Text("Get Max Zoom"),
                            // onPressed: () async{
                            // double zoom= await camera.getMaxZoom();
                            // print("Max zoom: $zoom");
                            //
                            // })
                            // ,
                            // RaisedButton
                            //   (
                            //     child: Text("Get min Zoom"),
                            //     onPressed: () async{
                            //       double zoom= await camera.getMinZoom();
                            //       print("Min zoom: $zoom");
                            //
                            //     })
                            //
                            // ,
                            // RaisedButton
                            //   (
                            //     child: Text("Get Cur Zoom"),
                            //     onPressed: () async{
                            //       double zoom= await camera.getCurZoom();
                            //       print("Cur zoom: $zoom");
                            //
                            //     })
                            // ,
                            // RaisedButton
                            //   (
                            //     child: Text("Zoom"),
                            //     onPressed: () async{
                            //       await camera.setZoom(40);
                            //
                            //
                            //     })
                            // ,Container(
                            //  // width: frameWidth*.7,
                            //   child: SliderTheme(data: SliderTheme.of(context).copyWith(
                            //     valueIndicatorColor: Colors.blue, // This is what you are asking for
                            //     inactiveTrackColor: Color(0xFF8D8E98), // Custom Gray Color
                            //     activeTrackColor: Colors.white,
                            //     thumbColor: Colors.white,
                            //     overlayColor: Color(0x29EB1555),  // Custom Thumb overlay Color
                            //     thumbShape:
                            //     RoundSliderThumbShape(enabledThumbRadius: 20.0),
                            //     overlayShape:
                            //     RoundSliderOverlayShape(overlayRadius: 20.0),
                            //   ),
                            //
                            //     child: Slider(
                            //       value: _currentSliderValue,
                            //       min: 0,
                            //       max: 80,
                            //       divisions: 20,
                            //       label: _currentSliderValue.round().toString(),
                            //       onChanged: (double value) {
                            //
                            //         setState(() {
                            //           _currentSliderValue = value;
                            //         });
                            //       },
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      )
                    : Center(child: Text("Camera inactive"))),
            Text("QRCODE: $qr"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Text(
            "press me",
            textAlign: TextAlign.center,
          ),
          onPressed: () async{
            setState(() {
              qr="";
              camState = !camState;
            });
          }),
    );
  }
}
