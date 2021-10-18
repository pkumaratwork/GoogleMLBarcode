import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:qr_mobile_vision/qr_mobile_vision.dart';

final WidgetBuilder _defaultNotStartedBuilder = (context) => Text("Camera Loading ...");
final WidgetBuilder _defaultOffscreenBuilder = (context) => Text("Camera Paused.");
final ErrorCallback _defaultOnError = (BuildContext context, Object? error) {
  print("Error reading from camera: $error");
  return Text("Error reading from camera...");
};

typedef Widget ErrorCallback(BuildContext context, Object? error);

class QrCamera extends StatefulWidget {
  QrCamera({
    Key? key,
    required this.qrCodeCallback,
    this.child,
    this.fit = BoxFit.cover,
    WidgetBuilder? notStartedBuilder,
    WidgetBuilder? offscreenBuilder,
    ErrorCallback? onError,
    this.formats,
  })  : notStartedBuilder = notStartedBuilder ?? _defaultNotStartedBuilder,
        offscreenBuilder = offscreenBuilder ?? notStartedBuilder ?? _defaultOffscreenBuilder,
        onError = onError ?? _defaultOnError,
        super(key: key);

  final BoxFit fit;
  final ValueChanged<String?> qrCodeCallback;
  final Widget? child;
  final WidgetBuilder notStartedBuilder;
  final WidgetBuilder offscreenBuilder;
  final ErrorCallback onError;
  final List<BarcodeFormats>? formats;

  @override
  QrCameraState createState() => QrCameraState();

   Future<double> _getMaxZoom() async{
    return await QrMobileVision.getMaxZoom();
  }


  double getCurrentZoomLevel(){
    return _currentSliderValue;
  }

  void setPreferedZoomLevel(double zoomlevel){
    _currentSliderValue=zoomlevel;
  }

   Future<double> _getMinZoom() async{
    return await QrMobileVision.getMinZoom();
  }


  Future<double> _getCurZoom() async{
    return await QrMobileVision.getCurZoom();
  }


   Future _setZoom(double zoomlevel) async{
     return await QrMobileVision.setZoom(zoomlevel);
   }

  double _currentSliderValue=0;
}

class QrCameraState extends State<QrCamera> with WidgetsBindingObserver {

  //double _currentSliderValue=0;
 // double _scaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    //_currentSliderValue= widget._currentSliderValue;
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => onScreen = true);
    } else {
      if (_asyncInitOnce != null && onScreen) {
        QrMobileVision.stop();
      }
      setState(() {
        onScreen = false;
        _asyncInitOnce = null;
      });
    }
  }

  bool onScreen = true;
  Future<PreviewDetails>? _asyncInitOnce;

  Future<PreviewDetails> _asyncInit(num width, num height) async {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return await QrMobileVision.start(
      width: (devicePixelRatio * width.toInt()).ceil(),
      height: (devicePixelRatio * height.toInt()).ceil(),
      qrCodeHandler: widget.qrCodeCallback,
      formats: widget.formats,
    );
  }



  /// This method can be used to restart scanning
  ///  the event that it was paused.
  void restart() {
    (() async {
      await QrMobileVision.stop();
      setState(() {
        _asyncInitOnce = null;
      });
    })();
  }

  /// This method can be used to manually stop the
  /// camera.
  void stop() {
    (() async {
      await QrMobileVision.stop();
    })();
  }

  @override
  deactivate() {
    super.deactivate();
    QrMobileVision.stop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      if (_asyncInitOnce == null && onScreen) {
        _asyncInitOnce = _asyncInit(constraints.maxWidth, constraints.maxHeight);
      } else if (!onScreen) {
        return widget.offscreenBuilder(context);
      }

      return FutureBuilder(
        future: _asyncInitOnce,
        builder: (BuildContext context, AsyncSnapshot<PreviewDetails> details) {


          switch (details.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return widget.notStartedBuilder(context);
            case ConnectionState.done:

              if (details.hasError) {
                debugPrint(details.error.toString());
                return widget.onError(context, details.error);
              }
              if(details!.data!.minZoom!.toDouble() <widget._currentSliderValue && widget._currentSliderValue < details!.data!.maxZoom!.toDouble()) {
                QrMobileVision.setZoom(widget._currentSliderValue);
              }else{
                widget._currentSliderValue=0;
              }
              Widget preview = SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Preview(
                  previewDetails: details.data!,
                  targetWidth: constraints.maxWidth,
                  targetHeight: constraints.maxHeight,
                  fit: widget.fit,
                ),
              );

              if (widget.child != null) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  // onTap: (){
                  //
                  //
                  // },
                  //   onScaleStart: (details) {
                  //    //_baseScaleFactor = _currentSliderValue;
                  //   },
                  //   onScaleUpdate: (scd) {
                  //     setState(() {
                  //       var zoom=_currentSliderValue + (20*scd.scale);
                  //       if(zoom<details.data!.maxZoom!.toDouble()){
                  //        // _currentSliderValue=zoom;
                  //        // QrMobileVision.setZoom(_currentSliderValue);
                  //         print("zoom:$zoom");
                  //       }
                  //     });
                  //     },
                  onDoubleTap: (){

                    setState(() {
                      var zoom=widget._currentSliderValue + (details.data!.maxZoom!.toDouble()*.2);
                      if(zoom<details.data!.maxZoom!.toDouble()){
                        widget._currentSliderValue=zoom;
                        QrMobileVision.setZoom(widget._currentSliderValue);
                      }else{
                        widget._currentSliderValue=0;
                      }
                    });

                  },

                  child: Stack(
                    //alignment: Alignment.bottomCenter,
                      children: [
                  preview,
                    // widget.child!,
                        Positioned(
                          bottom: 50,
                          left: MediaQuery.of(context).size.width*.02,
                          width: MediaQuery.of(context).size.width*.7,
                          child: Container(
                           // width: details.data!.width!.toDouble()*.7,
                            child: SliderTheme(data: SliderTheme.of(context).copyWith(
                              // valueIndicatorColor: Colors.blue, // This is what you are asking for
                              // inactiveTrackColor: Color(0xFF8D8E98), // Custom Gray Color
                              // activeTrackColor: Colors.white,
                              // thumbColor: Colors.white,
                              // overlayColor: Color(0x29EB1555),  // Custom Thumb overlay Color
                              // thumbShape:
                              // RoundSliderThumbShape(enabledThumbRadius: 12.0),
                              // overlayShape:
                              // RoundSliderOverlayShape(overlayRadius: 20.0),
                            ),

                              child: Slider(
                                value: widget._currentSliderValue,
                                min: details.data!.minZoom!.toDouble(),
                                max: details.data!.maxZoom!.toDouble(),
                                divisions: 20,
                                label: widget._currentSliderValue.round().toString(),
                                onChanged: (double value) {

                                  setState(() {
                                    widget._currentSliderValue = value;
                                    QrMobileVision.setZoom(value);
                                  });
                                },
                              ),
                            ),
                          ),
                        )


                      ],
                    ),
                );
              }
              return preview;

            default:
              throw AssertionError("${details.connectionState} not supported.");
          }
        },
      );
    });
  }
}

class Preview extends StatefulWidget {
  final double width, height;
  final double targetWidth, targetHeight;
  final int? textureId;
  final int? sensorOrientation;
  final BoxFit fit;
  final double minZoom, maxZoom;

  Preview({
    required PreviewDetails previewDetails,
    required this.targetWidth,
    required this.targetHeight,
    required this.fit,
  })  : textureId = previewDetails.textureId,
        width = previewDetails.width!.toDouble(),
        height = previewDetails.height!.toDouble(),
        minZoom= previewDetails.minZoom!.toDouble(),
        maxZoom= previewDetails.maxZoom!.toDouble(),
        sensorOrientation = previewDetails.sensorOrientation as int?;

  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  double _currentSliderValue=0;

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      builder: (context) {
        var nativeOrientation = NativeDeviceOrientationReader.orientation(context);

        int nativeRotation = 0;
        switch (nativeOrientation) {
          case NativeDeviceOrientation.portraitUp:
            nativeRotation = 0;
            break;
          case NativeDeviceOrientation.landscapeRight:
            nativeRotation = 90;
            break;
          case NativeDeviceOrientation.portraitDown:
            nativeRotation = 180;
            break;
          case NativeDeviceOrientation.landscapeLeft:
            nativeRotation = 270;
            break;
          case NativeDeviceOrientation.unknown:
          default:
            break;
        }

        int rotationCompensation = ((nativeRotation - widget.sensorOrientation! + 450) % 360) ~/ 90;

        double frameHeight = widget.width;
        double frameWidth = widget.height;

        return ClipRect(
          child: FittedBox(
            fit: widget.fit,
            child: RotatedBox(
              quarterTurns: rotationCompensation,
              child:
            //  Stack(
              //  alignment: Alignment.center ,


                //children:[
              SizedBox(
              width: frameWidth,
              height: frameHeight,
              child: Texture(textureId: widget.textureId!),
                ),
              // Container(
              //   width: frameWidth*.7,
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
              //       min: widget.minZoom,
              //       max: widget.maxZoom,
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
              //  ],
          //    ),
            ),
          ),
        );
      },
    );
  }
}
