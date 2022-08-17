import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';




class SignInBloc extends ChangeNotifier{


 /* SignInBloc (){
    checkSignIn();
  }*/


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  final GoogleSignIn _googlSignIn = new GoogleSignIn();
  var scaffoldKey = new GlobalKey<ScaffoldState>();
 // final FacebookLogin fbLogin = new FacebookLogin();

  



  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  set isSignedIn (newVal) => _isSignedIn = newVal;

  bool _guestUser = false ;
  bool get guestUser => _guestUser;
  set setguestUser (newVal) => _guestUser = newVal;


  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError (newError) => _hasError = newError;

  String _errorCode;
  String get errorCode => _errorCode;
  set errorCode(newCode) => _errorCode = newCode;

  bool _userExists = false;
  bool get userExists => _userExists;
  set setUserExist(bool value) => _userExists = value;


  String _name;
  String get name => _name;
  set setName(newName) => _name = newName;

  String _uid;
  String get uid =>_uid;
  set setUid(newUid) => _uid = newUid;

  bool _isAdmin;
  bool get isAdmin =>_isAdmin;

  String _email;
  String get email => _email;
  set setEmail(newEmail) => _email = newEmail;

  String _imageUrl;
  String get imageUrl => _imageUrl;
  set setImageUrl(newImageUrl) => _imageUrl = newImageUrl;

  String _imagePath;
  String get imagePath => _imagePath;
  set setImagePath(newImageUrl) => _imagePath = newImageUrl;



  String _joiningDate;
  String get joiningDate => _joiningDate;
  set setJoiningDate(newDate) => _joiningDate = newDate;

  String _nurseryAdmin = "" ;

  Future signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googlSignIn.signIn().catchError((error) => print('error : $error'));
    if(googleUser != null){
      try{
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

      User userDetails = (await _firebaseAuth.signInWithCredential(credential)).user;
      
      this._name = userDetails.displayName;
      this._email = userDetails.email;
      this._imageUrl = userDetails.photoURL;
      this._uid = userDetails.uid;
      this._imagePath = "google";
      
      hasError = false;
       notifyListeners();
    }
    
    catch(e){
      print("E");
      print(e);
      _hasError = true;
      _errorCode = e.code;
       notifyListeners();
    }
    } else{
      _hasError = true;
       notifyListeners();
    }
    
  }

  Future setGuestUserF() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest_user', true);
    await _firebaseAuth.signInWithEmailAndPassword(email: "travelappadmin@gmail.com" ,password: "abcdefg123@#");

    _guestUser = true;
    _isSignedIn =false ;
    notifyListeners();
  }

        

  Future checkUserExists () async {
    await FirebaseFirestore.instance.collection('users').get().then((QuerySnapshot snap) async{
      List values = snap.docs;
      List uids =[];
      values.forEach((element) {
        uids.add(element['uid']);
      });
      if(uids.contains(_uid)) {
       //  _isSubscribed = values.firstWhere((element) => element['uid'] == _uid)['nursries'].isNotEmpty;
        _userExists = true;
        
      } else{
        _userExists = false;
      }
     //  notifyListeners();

      
    });
  }



  Future saveToFirebase() async {
    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(uid);
    await ref.set({
      'name': _name,
      'email': _email,
      'uid': _uid,
      'image url': _imageUrl,
      'imagePath' : _imagePath,
      'joining date': _joiningDate,
      'loved blogs' : [],
      'loved places' : [],
      'bookmarked blogs' : [],
      'bookmarked places' : [],
      'nursries' : [],
      'isAdmin' : false ,
      'isTeacher' : false ,
    });
    
  }

    void setCredintialhMail(String name , String email , String imageurl ,String imagePath, String uid){
      _name =  name ;
      _email =  email;
      _imageUrl =  imageUrl;
      _uid =  uid;
      _imagePath = imagePath;

    }

  Future getJoiningDate ()async {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd-MM-yyyy').format(now);
    _joiningDate = _date;
   //  notifyListeners();
  }




  Future saveDataToSP() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    
    await sharedPreferences.setString('name', _name);
    await sharedPreferences.setString('email', _email);
    await sharedPreferences.setString('image url', _imageUrl);
    await sharedPreferences.setString('image path', _imagePath );

    await sharedPreferences.setString('uid', _uid);
    await sharedPreferences.setString('uid', _uid);
    await sharedPreferences.setString('nursery admin', _nurseryAdmin);
    await sharedPreferences.setBool('is admin', _isAdmin );


  }




  Future getUserData (uid) async{
    await FirebaseFirestore.instance.collection('users').doc(uid).get().then((DocumentSnapshot snap) {
      this._uid = (snap.data() as Map)['uid'];
      this._name = (snap.data() as Map)['name'];
      this._email = (snap.data() as Map)['email'];
      this._imageUrl = (snap.data() as Map)['image url'];
      this._joiningDate = (snap.data() as Map)['joining date'];
      _nurseryAdmin = (snap.data() as Map)['joining date'];
      _isAdmin = (snap.data() as Map)['isAdmin'] ;
      this._imagePath = (snap.data() as Map)['imagePath'] ??"";
    //  _isSubscribed = (snap.data() as Map)['nursries'].isNotEmpty;

    });
     notifyListeners();
    
  }





  Future setSignIn ()async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('sign in', true);
    sp.setBool("guest_user", false);
    _guestUser = false ;
   //  notifyListeners();
  }

  Future signOut() async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('sign in', false);
    sp.setBool("guest_user", false);
    sp.setBool('subscribed' , false);
    sp.setBool("is admin", false);

    _guestUser = false ;
    _isSignedIn = false ;

   _uid = null;
   _email = null;
   _imageUrl = null;
   _joiningDate = null;
     notifyListeners();
}

  Future<void> checkSignIn () async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('sign in')?? false;
    _guestUser =  sp.getBool('guest_user')?? false;
     notifyListeners();
  }

}