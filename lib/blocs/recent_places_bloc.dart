import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RecentPlacesBloc extends ChangeNotifier{
  
  List _data = [];
  List get data => _data;
  set data(newData) => _data = newData;

  

  RecentPlacesBloc(){
    getData();
  }


  

  

  Future getData() async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('places').get();
    var x = snap.docs;
    _data = [];
    x.forEach((f) {
       if (f['isEnabled']??true){
      _data.add(f);
       }
    });
    _data.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

   //  notifyListeners();
    
    
  }


  





}