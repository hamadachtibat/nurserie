import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:touch_indicator/touch_indicator.dart';
import 'package:easy_localization/easy_localization.dart' ;

class FindOnMap extends StatefulWidget {
final Function(String url , int state) submitFn ;

FindOnMap(this.submitFn);
static const routeName = '/findonmap';  

  @override
  _FindOnMapState createState() => _FindOnMapState();
}

class _FindOnMapState extends State<FindOnMap> {
 Completer<WebViewController> _controller = Completer<WebViewController>();
  int state ;

  @override
  void initState() {
     if (Platform.isAndroid) WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(  
          title: Text("أضغط مرة واحدة على الموقع".tr(), style: TextStyle(color: Colors.black),),
        ),
          body:  TouchIndicator(
            enabled: true,
            forceInReleaseMode: true,
            indicatorColor: Colors.red,
            child: WebView(

            javascriptMode: JavascriptMode.unrestricted ,
            initialUrl: 'https://www.google.com/maps/@23.5811575,58.3938513,15.25z',
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },   
            ),
          ),
          floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done),
          onPressed: () async{
          WebViewController result = await _controller.future ;
          final url = await result.currentUrl() ;
          state = 2 ;
          widget.submitFn(url , state); 
          Navigator.of(context).pop();
          }),
    );
  }
}