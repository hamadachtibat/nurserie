import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hathante/models/icon_data.dart';
import 'package:Hathante/utils/toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';


class PlaceBloc extends ChangeNotifier{
  
  List _data  ;
  List _myNursries  ;
  List _dataId = [];
  List _placesByLocation ;
  List _mySubscribedNuersries = [] ;
  List _myChildren = [] ;

  String _errorMsg = "" ;

  double _lat ;
  double _lng ;
  String _location ;

  bool _hasData = false;
  int _loves = 0;
  int _commentCount = 0;
  Icon _loveIcon = LoveIcon().normal;

  List _filteredData = [];
  List _lovedPlaces ;
  String _explore ;
  String _country =  "no location ! touch to update" ;
  var _currentPlace ;

  List _mySubscribedNurseriesId = [] ;
  List _currentChild ;

  bool _isAdmin ;
  bool get isAdmin => _isAdmin ;

  List get currentChild => _currentChild;

  set setCurrentChild(value){
      _currentChild = value ;
  }


  set data (newValue){
    _data = newValue;
  }
   set listID (newValue){
    _dataId = newValue;
  }

    set listByPlace (newValue){
    _placesByLocation = newValue;
  }

  set setCurrentPlace (newValue){
   // log()
   try{
      _currentPlace = newValue.data();
   }catch(e){
    try{
      _currentPlace = newValue;
    }catch(e){

    }
   }
  }
    set setCountry (newValue){
    _country = newValue;
  }


  set hasData(data){
    _hasData = data;
  }

  set loves(newLoves){
    _loves = newLoves;
  }

  set loveIcon(newLoveIcon){
    _loveIcon = newLoveIcon;
  }


  set filteredData(newData) {
    _filteredData = newData;
  }

  set commentsCount (newComment){
    _commentCount = newComment;
  }
  set setExploreCountry (country){
    _explore  = country;
   //  notifyListeners();
  }
  set lovedPlaces(newItem) =>_lovedPlaces = newItem;
  
  
  List get data => _data;
  List get dataId => _dataId;
  List get dataByPlace => _placesByLocation;

  bool get hasData => _hasData;
  int get loves => _loves;
  Icon get loveIcon => _loveIcon;
  List get filteredData => _filteredData;
  int get commentsCount => _commentCount;
  List get lovedPlaces => _lovedPlaces;
  List get myNursries => _myNursries;
  String get exploredCountry => _explore ;
  String get country => _country ;

  List get mySubscribedNuersries => _mySubscribedNuersries ;
  List get myChildren => _myChildren ;
  get currentPlace => _currentPlace ;
  String get errorMsg => _errorMsg ;

  List get mySubscribedNurseriesId => _mySubscribedNurseriesId ; 


  DocumentSnapshot _mealsAr ;
  DocumentSnapshot get mealsAr => _mealsAr ;

  DocumentSnapshot _mealsEn ;
  DocumentSnapshot get mealsEn => _mealsEn ;

  double get lat => _lat ;
  double get lng => _lng ;
  String get location => _location ;

  Future getData() async {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String _uid = sp.getString('uid');
      _isAdmin = sp.getBool('is admin') ??false;
    print("sds");
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('places').get();
    List<QueryDocumentSnapshot<Object>> x = snap.docs;
    _data = [];
    _placesByLocation = [];
    _myNursries = [];
    x.forEach((QueryDocumentSnapshot<Object> f) {
      if (f['isEnabled'] ?? true){
            _data.add(f );
            _placesByLocation.add( (f.data() as Map));

      }
      if(f['uid'] != null){
      if (f['uid'] == _uid){
        _myNursries.add(f.data());
      }}
    });
    data.shuffle();
    
    notifyListeners();
  }


   void requestEdit(timestamp){
  FirebaseFirestore.instance.collection('places').doc(timestamp).update({
     "requestToEdit" : true ,
   });

  }

  void requestDelte(id){
    FirebaseFirestore.instance.collection('places').doc(id).update({
     "requestToDelete" : true ,
   });

  }

  Future getLovedList() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');

    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = (snap.data() as Map)['loved places'];
    _lovedPlaces = d;
    
   ////  notifyListeners();

  }





  Future getLovesAmount(timestamp) async {
    final DocumentReference ref =FirebaseFirestore.instance.collection('places').doc(timestamp);
    DocumentSnapshot snap = await ref.get();
    int loves = snap['loves'];
    _loves = loves;
   ////  notifyListeners();
    
  }

  Future getCommentsAmount(timestamp) async {
    final DocumentReference ref =FirebaseFirestore.instance.collection('places').doc(timestamp);
    DocumentSnapshot snap = await ref.get();
    int comments = int.parse(snap['comments count'].toString());
    _commentCount = comments;
   ////  notifyListeners();
    
  }

  Future commentsIncrement (timestamp) async{
   FirebaseFirestore.instance.collection('places').doc(timestamp).update({
      'comments count' : _commentCount+1
    });
  }


  Future commentsDecrement (timestamp) async{
   FirebaseFirestore.instance.collection('places').doc(timestamp).update({
      'comments count' : _commentCount-1
    });
  }



  void loveIconCheck(timestamp) async {
  if (lovedPlaces == null){
    _loveIcon = LoveIcon().normal;
  }
  if(_lovedPlaces.contains(timestamp)){
      _loveIcon = LoveIcon().bold;
    }else{
      _loveIcon = LoveIcon().normal;
    }
    //notifyListeners();
    
  }


Future<void> getMyNurseriesActivitesNew() async{
   SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    await FirebaseFirestore.instance.collection('users').doc(_uid). get().then((value) async{
      (value['nursries' ] as List).forEach((element) async{
        _mealsEn = (await FirebaseFirestore.instance.collection('places').doc(element.toString()).collection("general").doc("food table en").get());
        _mealsAr = (await FirebaseFirestore.instance.collection('places').doc(element.toString()).collection("general").doc("food table ar").get());

       _mySubscribedNuersries = [] ; 
      _mySubscribedNurseriesId = [] ;
      _myChildren = [] ;
      try{
        DocumentSnapshot x= (await FirebaseFirestore.instance.collection('places').doc(element.toString()).get());
        DocumentSnapshot y= (await FirebaseFirestore.instance.collection('places').doc(element.toString()).collection('appointment').doc(_uid).get()) ;
        QuerySnapshot z= (await FirebaseFirestore.instance.collection('places').doc(element.toString()).collection('general').get() );
     
        _mySubscribedNurseriesId.add( (x.data() as Map)['timestamp']);
     /* var y =  (x['subscribers']  as List).firstWhere((element) =>
           element['parent uid'] == _uid); */
     if (y != null){
       if (y['approved']){
           _mySubscribedNuersries.add([ x ,y, z.docs ]);
       y['children'].forEach((element) { 
          _myChildren.add([element ,x, z.docs]);
      });
       }
     }
          }catch(e){
            print("Error");
            print(e);
        _errorMsg = "لم تسجل في نظام الحضانة, تواصل معاهم" ;
      }
           notifyListeners();
     });   
      });
  
}

Future<void> getMyNurseriesActivitess() async{
   SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    await FirebaseFirestore.instance.collection('users').doc(_uid).get().then((value) async{
      (value['nursries' ] as List).forEach((element) async{

       _mySubscribedNuersries = [] ; 
      _mySubscribedNurseriesId = [] ;
      _myChildren = [] ;
      try{
        DocumentSnapshot x = (await FirebaseFirestore.instance.collection('places').doc(element.toString()).get()) ;
        DocumentSnapshot y = (await FirebaseFirestore.instance.collection('places').doc(element.toString()).collection('appointment').doc(_uid).get()) ;

      _mySubscribedNurseriesId.add(x['timestamp']);
     /* var y =  (x['subscribers']  as List).firstWhere((element) =>
           element['parent uid'] == _uid);*/ 
      _mySubscribedNuersries.add([ x ,y ]);
       y['children'].forEach((element) { 
        _myChildren.add([element ,x ]);
      });
   
          }catch(e){
            print(e);
            print(_uid);
        _errorMsg = "لم تسجل في نظام الحضانة, تواصل معاهم" ;
      }
           notifyListeners();
     });   
      });
  
}

  Future findNyId(uid) async{
    //this will populate the widget into array
  QuerySnapshot snap = await FirebaseFirestore.instance.collection('places').doc(uid).collection('nearby').get();
   var x = snap.docs;
    _dataId = [];
    
    x.forEach((f) {
      _dataId.add(f);
    });
    
  }



 bool orderByLatLng(double lat1,double lng1 ,double lat2 ,double lng2, int scale){
    final Distance distance = new Distance();
    final double km = distance.as(LengthUnit.Kilometer,
     new LatLng(lat1,lng1),new LatLng(lat2,lng2));
   
    if (scale >= km){
      return true ;
    }
  return false ;
  }

//filter by place
 void filterByPlace(double lat, double lng , String country) {
  print("ssdsd");
   dynamic temp ;
  if ((lat != null && lng != null && country != null)){
   for (int i = 0 ; i < _placesByLocation.length ; i++){
    double placeLat = double.parse(  ( _placesByLocation[i]['latitude'] ).toString());
    double placeLong = double.parse( ( _placesByLocation[i]['longitude'] ).toString()) ;
    
      if (orderByLatLng(placeLat,placeLong , lat , lng , 50 ) ){     
        _placesByLocation[i]['order'] = 0 ;
        
     
      }else if ( orderByLatLng(placeLat,placeLong , lat , lng , 100 )){
        _placesByLocation[i]['order'] = 1 ;
          
      }else if ( orderByLatLng(placeLat,placeLong , lat , lng , 250 )){
        _placesByLocation[i]['order'] = 2 ;
       
      }else if (orderByLatLng(placeLat,placeLong , lat , lng , 500 )){
        _placesByLocation[i]['order'] = 3 ;
        
      }else if ( orderByLatLng(placeLat,placeLong , lat , lng , 1000 )){
        _placesByLocation[i]['order'] = 4 ;
        
      }else{
          _placesByLocation[i]['order'] = 5 ;
         
      }
  
  }
   _placesByLocation.sort((first , second){
     if (first['order'] > second['order'] ){//first is near than second
        temp = first ;
        first = second ;
        second = temp ;
     }
     return 0 ;
   });
 }else{
  
   _placesByLocation = _data ;
 }

 notifyListeners();
 }


  loveIconClicked(timestamp) async {
    final DocumentReference ref =FirebaseFirestore.instance.collection('places').doc(timestamp);
  
    if(_lovedPlaces.contains(timestamp)){
      _removeFromLove(timestamp);
      
      await getLovedList();
      loveIconCheck(timestamp);
      ref.update({ 'loves': _loves-1});
      getLovesAmount(timestamp);
    } else{
      _addtoLove(timestamp);
      
      await getLovedList();
      loveIconCheck(timestamp);
      ref.update({ 'loves': _loves+1});
      getLovesAmount(timestamp);
    }
    
    //notifyListeners();
  }


  void _addtoLove (timestamp) async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(_uid);
    
    List firstItem = [timestamp];
    
    if(_lovedPlaces == null){
      ref.update({'loved places': FieldValue.arrayUnion(firstItem)});
    } else{
      _lovedPlaces.add(timestamp);
      ref.update({'loved places' : FieldValue.arrayUnion(_lovedPlaces)});
    }

   //  notifyListeners();
  }

  void _removeFromLove (timestamp) async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(_uid);
    List d = [timestamp];
    ref.update({'loved places' : FieldValue.arrayRemove(d)});
  }


  afterSearch(value) {
    _filteredData = _data
        .where((u) => (u['place name'].toLowerCase().contains(value.toLowerCase()) ||
            u['location'].toLowerCase().contains(value.toLowerCase()) ||
            u['description'].toLowerCase().contains(value.toLowerCase())))
        .toList();

   //  notifyListeners();
  }

  Future<void> reserveAppotiment(uid,userID, data,) async{
   FirebaseFirestore.instance.collection('places').doc(uid).collection("appointment").doc(userID).set(data).whenComplete(() => print("completed"));

  }

  Future<void> getCountry() async{
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Position _currentPosition ;
  try{
      
  geolocator.getCurrentPosition (desiredAccuracy: LocationAccuracy.best).then((Position position)async {
  _currentPosition = position;
  List<Placemark> p = await geolocator.placemarkFromCoordinates( _currentPosition.latitude, _currentPosition.longitude);
  await prefs.setString("location", p[0].name);
  _country = p[0].administrativeArea ;
  await prefs.setDouble("lat", _currentPosition.latitude);
  await prefs.setDouble("lng",_currentPosition.longitude);

  _lat = _currentPosition.latitude ;
  _lng = _currentPosition.longitude ;
  _location =  p[0].name ;
  filterByPlace(lat, lng, country);
  });

  }catch(error){
    print("the error is " + error.toString());
        prefs.setString("location","Failed to get location");

}
notifyListeners();
}

}