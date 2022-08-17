import 'dart:async';

import 'package:Hathante/widgets/search%20widgets/navbar.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:Hathante/utils/next_screen.dart';

class SuccessPage extends StatefulWidget {


  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {

@override
  void didChangeDependencies() {
  // navigate();
        Future.delayed(Duration(milliseconds: 3000)).then((_) => nextScreenReplace(context, NavBar())); 
    super.didChangeDependencies();
  }
  @override
  void initState() {
    super.initState();
   
  }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 150,
          width: 150,
          child: FlareActor(
              'assets/flr/success.flr',
              animation : 'success',
              
              alignment: Alignment.center,
              fit: BoxFit.contain,  
            ),
        ),     
    ),
    );
  }
}