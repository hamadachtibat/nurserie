import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart' ;
import './user_input_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
final void Function(String userName , String userPassword , String mail, bool isLogin , BuildContext context , File image , String phoneNumber) submitFN ; 
final bool isLoading  ;

AuthForm(this.submitFN ,this.isLoading);
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool isLoginMode = true ;
  String userEmail = '';
  String userName = '';
  String userPassword = '';
  File _userImageFile ;
  String phoneNumber = "";
  bool forgetPass = false ;
  
  void getImage(File image){
_userImageFile = image ;
  }

  final _formKey = GlobalKey<FormState>();

  void resetPassword() async{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail ).then((value) {
              setState(() {
                forgetPass = false;
              });
              } );  
  }
  void _trySubmit(){
  final isValid =  _formKey.currentState.validate();
  FocusScope.of(context).unfocus();

  if (_userImageFile == null && !isLoginMode){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No image is selected".tr() , style: TextStyle(color : Theme.of(context).errorColor))));
    return ;
  }
  if (isValid){
    _formKey.currentState.save(); //run onSave on each text field
    widget.submitFN(userName ,userPassword  ,userEmail.trim()  , isLoginMode , context , _userImageFile , phoneNumber.trim());
  }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child:  Form(
      key: _formKey,  
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min, //take the size as yhe col need only
        children: <Widget>[
         if (!isLoginMode)
          UserImagePicker(getImage),
          TextFormField(
            key: ValueKey("Email"), //id
          validator: (value){
            if (value.length == null){
              return "email is requaired".tr();
            }else if (!value.contains('@')){
              return "Enter a valid email address".tr();
            }
            return null;
          },
          onSaved: (value){
            userEmail = value ;
          },
          keyboardType: TextInputType.emailAddress , decoration: InputDecoration(labelText: "email address" , ),),
         
          if (!isLoginMode)
          TextFormField(
              validator: (value){
            if (value.length == null){
              return "user name is requaired".tr();
            }
            return null;
          },
          onSaved: (value){
            userName = value ;
          },
         key: ValueKey("user name"), //id
          decoration: InputDecoration(labelText: "user name".tr() , ),),
         
        forgetPass ?Container() : TextFormField(
             validator: (value){
            if (value.length <6){
              return "password should be more than 7 letters".tr();
            }
            return null;
          }, 
            key: ValueKey("password"), //id
          onSaved: (value){
          userPassword = value ;
          }
            ,keyboardType: TextInputType.visiblePassword , decoration: InputDecoration(labelText: "pasword" , ), obscureText: true,),
         
          //ins
          if (!isLoginMode)
          TextFormField(
            keyboardType: TextInputType.number,
              validator: (value){
            if (value.length == null){
              return "Phone Number is requaired".tr();
            }
            return null;
          },
          onSaved: (value){
            phoneNumber = value ;
          },
         key: ValueKey("phone Number"), //id
        decoration: InputDecoration(labelText: "Phone Number".tr() , ),),
          
        SizedBox(height: 12,),
        widget.isLoading? CircularProgressIndicator() :RaisedButton(
            child: Text(forgetPass ?"Send!".tr() :(isLoginMode ?"Sign in".tr() :"Signup".tr())),
            onPressed:() async{
              forgetPass ?resetPassword() :_trySubmit();
            }
             ) ,
         
            FlatButton(onPressed: () async{
         
               setState(() {
                isLoginMode  =! isLoginMode ;
              });
              
            }, 
          child: Text( isLoginMode ?"Create new account".tr() :"I have an account".tr()) , textColor: Theme.of(context).primaryColor,)  ,
        
         isLoginMode ? FlatButton(onPressed: () {
           setState(() {
             forgetPass = !forgetPass ;
            });
         
            }, 
          child: Text(forgetPass ?"Done !".tr() : "Forget Your Password ?".tr() ) , textColor: Theme.of(context).primaryColor,) :Container(),
         
        ],),
      ) ),
    );
  }
}