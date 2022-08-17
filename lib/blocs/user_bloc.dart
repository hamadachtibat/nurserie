import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserBloc extends ChangeNotifier {
  List _classWithSubjectsAr = [];
  void setClassWithSubjectsAr(newVal) {
    _classWithSubjectsAr = newVal;
  }

  List get classWithSubjectsAr => _classWithSubjectsAr;

  List _classWithSubjectsEn = [];
  void setClassWithSubjectsEn(newVal) {
    _classWithSubjectsEn = newVal;
  }

  List get classWithSubjectsEn => _classWithSubjectsEn;

  String _name;
  String get name => _name;
  set setName(String name) => _name = name;

  String _email;
  String get email => _email;
  set setEmail(String email) => _email = email;

  bool _isAdmin;
  bool get isAdmin => _isAdmin;

  String _imageUrl;
  String get imageUrl => _imageUrl;
  set setImageUrl(String imageUrl) => _imageUrl = imageUrl;

  String _imagePath;
  String get imagePath => _imagePath;
  set setImagePath(String imageUrl) => _imagePath = imageUrl;

  String _uid;
  String get getUid => _uid;
  set setUid(String uid) => _uid = uid;

  String _joiningDate;
  String get joiningDate => _joiningDate;
  set setJoiningDate(String value) => _joiningDate = value;

  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  Future<void> getUserData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String _userUid = sp.getString('uid');
    String _userEmail = sp.getString('email');
    String _userName = sp.getString('name');
    String _userImageUrl = sp.getString('image url');
    String _imagePathSP = sp.getString('image path');

    _isSubscribed = sp.getBool('subscribed') ?? false;
    _isAdmin = sp.getBool('is admin');

    _uid = _userUid;
    _email = _userEmail;
    _name = _userName;
    _imageUrl = _userImageUrl;
    _imagePath = _imagePathSP;

    notifyListeners();
  }

  bool isUserDataEmpty() {
    return _uid == null && _email == null && _name == null && _imageUrl == null;
  }

  Future signOut() async {
    _uid = null;
    _email = null;
    _imageUrl = null;
    _joiningDate = null;
    _isAdmin = null;
    notifyListeners();
  }

  Future updateNewData(
      String newName, String newImageUrl, String newImagePath) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    
    newImagePath== null ?null : FirebaseFirestore.instance.collection('users').doc(_uid).update(
       {'imagePath': newImagePath});

    FirebaseFirestore.instance.collection('users').doc(_uid).update(
        {'image url': newImageUrl, 'name': newName,});
    await sp.setString('name', newName);
    await sp.setString('image url', newImageUrl);
    newImagePath== null ?null :await sp.setString('image path', newImagePath);

    _name = newName;
    _imageUrl = newImageUrl;
    _imagePath = newImagePath;
    notifyListeners();
  }
}
