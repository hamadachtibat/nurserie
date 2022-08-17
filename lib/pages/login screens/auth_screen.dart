import 'dart:io';
import 'package:Hathante/widgets/search%20widgets/auth_form_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/sign_in_bloc.dart';
import 'package:Hathante/pages/login%20screens/splash.dart';
import 'package:Hathante/pages/login%20screens/success.dart';
import 'package:Hathante/utils/next_screen.dart';
import '../../utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthScreen extends StatefulWidget {
  final int state;
  AuthScreen(this.state);
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;
  final auth = FirebaseAuth.instance;

  void _submitAuthForm(
      String userName,
      String userPassword,
      String mail,
      bool isLogin,
      BuildContext context,
      File image,
      String phoneNumber) async {
    UserCredential authRes;
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    try {
      setState(() {
        isLoading = true;
      });
      if (isLogin) {
        authRes = await auth.signInWithEmailAndPassword(
            email: mail, password: userPassword);
        if (authRes.user.emailVerified) {
          sb.getUserData(authRes.user.uid).then((value) => sb
              .saveDataToSP()
              .then((value) => sb
                  .setSignIn()
                  .then((value) => nextScreenReplace(context, SuccessPage()))));
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SplashPage()));
        } else {
          //not vertify email
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Verify your email".tr())));
        }
      } else {
        //create user with emailvertifaction
        try {
          authRes = await auth.createUserWithEmailAndPassword(
              email: mail, password: userPassword);
          await authRes.user.sendEmailVerification();
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(authRes.user.uid + '.jpg');
          await ref.putFile(image);
          final url = await ref.getDownloadURL();
          final String imagePath =  ref.fullPath ;
          sb.getJoiningDate();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(authRes.user.uid)
              .set({
            "name": userName,
            "uid": authRes.user.uid,
            "email": mail,
            "image url": url,
            "imagePath" : imagePath,
            "phoneNumber": phoneNumber,
            "joining date": sb.joiningDate,
            "loved blogs": [],
            "loved places": [],
            "olduid": "",
            "enable": true,
          });
          sb.checkUserExists().then((value) {
            if (sb.userExists == true) {
              sb.getUserData(sb.uid).then((value) => sb.saveDataToSP().then(
                  (value) => sb.setSignIn().then(
                      (value) => nextScreenReplace(context, SuccessPage()))));
            } else {
              if (authRes.user.emailVerified) {
                sb.setCredintialhMail(userName, mail, url,imagePath, authRes.user.uid);
                sb.getJoiningDate().then((value) => sb.saveDataToSP().then(
                    (value) => sb.setSignIn().then(
                        (value) => nextScreenReplace(context, SuccessPage()))));
              } else {
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                        SnackBar(content: Text("Verify your email".tr())))
                    .close();
              }
            } //sign up
          });
          //   sb.setSignIn();
          //   Navigator.of(context).push( MaterialPageRoute(builder: (context) => SplashPage()));

        } catch (e) {
          openToast(context,
              "An error occured while trying to send email verification".tr());
          print(e.message);
          var message = 'An error occured please check your data';
          if (e.message != null) {
            message = e.message;
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message.tr())));
          setState(() {
            isLoading = false;
          });
        } //end of mail try
      } //end of signup try

    } on PlatformException catch (error) {
      var message = 'An error occured please check your data';
      if (error.message != null) {
        message = error.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.tr())));
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print("the error is : " + error.toString());
      setState(() {
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: AuthForm(_submitAuthForm, isLoading),
            ),
          ),
        ),
      ),
    );
  }
}
