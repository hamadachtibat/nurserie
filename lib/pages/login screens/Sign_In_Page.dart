import 'package:flutter/material.dart';
import 'package:Hathante/pages/login%20screens/wellcome.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("قم بتسجيل الدخول من أجل ميزات أكبر".tr()),
          SizedBox(height: 30,),
          InkWell( onTap: (){nextScreenCloseOthers(context, WellComePage());}, child: Container(color: Colors.blue, width: MediaQuery.of(context).size.width * 0.3, height: 30, child: Center(child :Text( "Sign In".tr() , style: TextStyle(color: Colors.white),)),))
        ],
      ),),),
    );
  }
}