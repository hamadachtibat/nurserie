import 'dart:io';
import 'dart:math' as mth;
import 'package:Hathante/blocs/bookmark_bloc.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/widgets/search%20widgets/user_input_image_picker.dart';
import 'package:easy_localization/easy_localization.dart' ;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/sign_in_bloc.dart';
import 'package:Hathante/pages/login%20screens/success.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:Hathante/utils/snacbar.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool isLoginMode = true ;
  bool isLoading = false ;
  String userEmail = '';
  String userName = '';
  String userPassword = '';
  String confPass = '' ;
  File _userImageFile ;
  bool forgetPass = false ;
  final auth = FirebaseAuth.instance;

  TextEditingController mailCont ;
  TextEditingController usernameCont ;
  TextEditingController passCont = new TextEditingController() ;
  TextEditingController confPassCont ;
  TextEditingController phoneNumbCont ;
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  void getImage(File image){
_userImageFile = image ;
  }

 void _submitAuthForm(String _userName , String _userPassword , String _mail , bool _isLogin , File _image ,  )async{
    UserCredential authRes ;
    FocusScope.of(context).unfocus();

     final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
     try{
     setState(() {
   isLoading = true ;
  });
       if(isLoginMode){
       authRes =await auth.signInWithEmailAndPassword(email: _mail, password: _userPassword);
        if (authRes.user.emailVerified) {
         
        await sb.getUserData(authRes.user.uid);
        await sb.saveDataToSP();
        await sb.setSignIn(); 
        await fetchAndSetData();
        await nextScreenReplace(context, SuccessPage());
        Navigator.of(context).push( MaterialPageRoute(
                    builder: (context) => SuccessPage()));
      }else{ //not vertify email
            setState(() {
                    isLoading = false ;
                  });
      openSnacbar(_scaffoldKey , "Verify your email".tr());
      }
      }else{
        
      //create user with email vertifaction
      try {
        int random = mth.Random().nextInt(5000);
        authRes =await auth.createUserWithEmailAndPassword(email: _mail, password: userPassword);
        await authRes.user.sendEmailVerification();
        String path = authRes.user.uid+random.toString();
        Reference   ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child(path + '.jpg');
        TaskSnapshot taskSnapshot = await ref.putFile(_userImageFile) ;
        final url = await taskSnapshot.ref.getDownloadURL();
        sb.getJoiningDate();
        final String imagePath = path;
        await FirebaseFirestore.instance.collection('users').doc(authRes.user.uid).set({
        "name" : _userName ,
        "uid":authRes.user.uid ,
        "email" : _mail ,
        "image url"  : url ,
        "imagePath" : imagePath,
        "joining date" : sb.joiningDate,
        "loved blogs" : [] , 
        "loved places" : [] ,
        'bookmarked blogs' : [],
        'bookmarked places' : [],
        'nursries' : [],
        'isAdmin' : false ,
        'isTeacher' : false ,
         "olduid" : "" ,
         "enable" : true ,
         });
         sb.checkUserExists().then((value){
          if(sb.userExists == true){
            sb.getUserData(sb.uid).then((value) => sb.saveDataToSP().then((value) => sb.setSignIn().then((value) => nextScreenReplace(context, SuccessPage()))));
          } else{
             if (authRes.user.emailVerified) {
            sb.setCredintialhMail(_userName , _mail , url, imagePath , authRes.user.uid) ;
            sb.getJoiningDate().then((value) => sb.saveDataToSP().then((value) => sb.setSignIn().then((value) => nextScreenReplace(context, SuccessPage()))));
             }else{
              setState(() {
       isLoading = false ;                      
                  });
                   openSnacbar(_scaffoldKey , "Verify your email".tr());
             }
              }//sign up
            }); 
     } catch (e) {
        print("An error occured while trying to send email verification".tr());
        print(e.message);
         var message = 'An error occured please check your data';
       if(e.message != null){
         message = e.message ;
       }
            openSnacbar(_scaffoldKey , message.tr());

           setState(() {
       isLoading = false ;
       });
     }  //end of mail try
     }//end of signup try

     }on PlatformException catch(error){
       var message = 'An error occured please check your data';
       if(error.message != null){
         message = error.message.tr() ;
       }
             openSnacbar(_scaffoldKey , message);

           setState(() {
   isLoading = false ;
  });
     }catch (error){
      openSnacbar(_scaffoldKey , error.toString());

       print("the error is : " + error.toString());
          setState(() {
   isLoading = false ;
  });
     }

    setState(() {
   isLoading = false ;
  });
  }

   void resetPassword() async{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail ).then((value) {
              setState(() {
                openSnacbar(_scaffoldKey ,"done".tr());
                forgetPass = false;
              });
              } );  
  }


//widgets
  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email'.tr(),
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: mailCont,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            onChanged: (text){
              setState(() {
                userEmail = text ;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email'.tr(),
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password'.tr() ,
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            obscureText: true,
            controller: passCont,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
             onChanged: (text){
                userPassword = text ;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password'.tr(),
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildConfirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
       SizedBox(height: 10.0),
        Text(
          "Confirm Your Password".tr(),
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: confPassCont,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            onChanged: (text){
                confPass = text ;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Confirm Your Password'.tr(),
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildUserNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      SizedBox(height: 10.0),
        Text(
          'Your Name'.tr(),
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: usernameCont,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            onChanged: (text){
                userName = text ;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.perm_identity,
                color: Colors.white,
              ),
              hintText: 'Enter your Name'.tr(),
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

 /* Widget _buildPhoneTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          'Phone Number',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.phone,
            controller: phoneNumbCont ,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            onChanged: (text){
                phoneNumber = text ;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              hintText: 'Enter your phone Number',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }*/

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () {
          setState(() {
           forgetPass = !forgetPass ;
          });
        },
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
         forgetPass ?'Go back'.tr() :'Forgot Password?'.tr(),
          style: kLabelStyle,
        ),
      ),
    );
  }
  

//main
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 80.0, //120
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(onPressed: (){
                            Navigator.pop(context);
                          }, icon: Icon(Icons.arrow_back_ios, color: Colors.white,)),
                          Spacer(),
                          Text(
                          isLoginMode ?'Sign In'.tr() : "Sign Up".tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'OpenSans',
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Container(),
                        ],
                      ),
                      SizedBox(height: 30.0),
                    isLoginMode?Container():UserImagePicker(getImage),
                      _buildEmailTF(),
                      SizedBox(
                        height: 10.0,
                      ),
                  isLoginMode ? (forgetPass ? Container() : _buildPasswordTF()) :_buildPasswordTF(),
                  isLoginMode ?Container(): _buildConfirmPasswordTF(),
                  isLoginMode ?Container(): _buildUserNameTF(),
                 // isLoginMode ?Container(): _buildPhoneTF(), 
                  isLoginMode ?_buildForgotPasswordBtn() :Container(),
                     isLoading ?CircularProgressIndicator(color: Colors.white,) :_buildLoginBtn(),
                      _buildSignupBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
           if (validate() ){
            if (userPassword.length < 6 && isLoginMode == false && !forgetPass ){
              openSnacbar(_scaffoldKey, "Passwords Should be at least 6 characters".tr());
            }
            if (userPassword != confPass && isLoginMode == false && !forgetPass ){
             openSnacbar(_scaffoldKey, "Passwords aren't match".tr());
            }
            if (forgetPass){
              resetPassword();
            }else{
           _submitAuthForm(userName , userPassword, userEmail , isLoginMode ,_userImageFile );
            }
          
          }else{
            if (_userImageFile == null && !isLoginMode){
          openSnacbar(_scaffoldKey, "You Should add an image".tr());
            }
          openSnacbar(_scaffoldKey, "You Should fill all fields".tr());

        }
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
         forgetPass ? "SEND EMAIL".tr() : isLoginMode ?"LOGIN".tr() : "SIGNUP".tr(),
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }
  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLoginMode = !isLoginMode ;
          if (!isLoginMode){
            forgetPass = false ;
          }
        });
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: isLoginMode ? "Don't have an Account? ".tr() :'Have an Account? '.tr() ,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: isLoginMode ? 'Sign Up'.tr() : 'Login'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  bool validate(){

    if (isLoginMode && !forgetPass){
      return (userEmail != "" && userPassword != "");
    }else if(forgetPass){
        return userEmail != "" && (userEmail.contains('@')) ;
    }
    else{
       return (userEmail != "" && (userEmail.contains('@')) && userPassword != "" && confPass != ""
        && userName != "" && _userImageFile != null);
    }
  }
  Future<void> fetchAndSetData() async{

     final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
      PlaceBloc pb = Provider.of<PlaceBloc>(context, listen: false);
      final BookmarkBloc bb = Provider.of<BookmarkBloc>(context, listen: false);
      final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);

      if (!sb.guestUser) {
        try {
           await ub.getUserData();
        } catch (e) {
          print(e);
        }
      }

      try {
       pb.lovedPlaces == null ?await pb.getLovedList(): null;
      } catch (e) {
        print(e);
      }
      try {
        if(pb.myNursries == null || pb.data == null || pb.dataByPlace == null){
            await pb.getData();
        }
      
      } catch (e) {
        print(e);
      }

      if (!sb.guestUser) {
        try {
          bb.bookmarkedPlaces== null?  await bb.getBookmarkedList():null;
        } catch (e) {
          print(e);
        }
      }

      if (!sb.guestUser) {
        try {
          bb.placeData == null ?  await bb.getPlaceData() : null;
        } catch (e) {
          print(e);
        }
      }

 
  }
}