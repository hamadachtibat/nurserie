import 'package:Hathante/models/icon_data.dart';
import 'package:Hathante/utils/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkBloc extends ChangeNotifier {

  
  List _blogData = [];
  List get blogData => _blogData;
  set blogData(newData) => _blogData = newData;
  

  List _placeData = null ;
  List get placeData => _placeData;
  set placeData(newData1) => _placeData = newData1;

  Icon _bookmarIcon = BookmarkIcon().normal;
  List _bookmarkedPlaces ;

  set bookmarkIcon (newBookmarkIcon){
    _bookmarIcon = newBookmarkIcon;
  }
  set bookmarkedPlaces(newValue) => _bookmarkedPlaces = newValue;
  List get bookmarkedPlaces => _bookmarkedPlaces;
  Icon get bookmarkIcon => _bookmarIcon;

  
  
 /* Future getBlogDataa() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');

    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = (snap.data() as Map)['bookmarked blogs'];

    _blogData.clear();

   FirebaseFirestore.instance
        .collection('blogs')
        .get()
        .then((QuerySnapshot snap) {
      var x = snap.docs;
      for (var item in x) {
        if (d.contains(item['timestamp'])) {
          _blogData.add(item);
        }
      }
     //  notifyListeners();
    });
  }*/

  Future getBookmarkedList() async{
    
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');

    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = (snap.data() as Map)['bookmarked places'];
    _bookmarkedPlaces = d ??[];
    notifyListeners();

  }
    Future bookmarkIconCheck(timestamp) async {
    if (_bookmarkedPlaces == null){
      _bookmarIcon = BookmarkIcon().normal;
    }else if(_bookmarkedPlaces.contains(timestamp)){
      _bookmarIcon = BookmarkIcon().bold;
    }else{
      _bookmarIcon = BookmarkIcon().normal;
    }
    notifyListeners();
  }
    void _addtoBookmark (timestamp, context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(_uid);
    
    List firstItem = [timestamp];
    
    if(_bookmarkedPlaces == null){
      ref.update({'bookmarked places': FieldValue.arrayUnion(firstItem)});
    } else{
      _bookmarkedPlaces.add(timestamp);
      ref.update({'bookmarked places' : FieldValue.arrayUnion(_bookmarkedPlaces)});
    }
    openToast(context, 'Added to your bookmark');
   ////  notifyListeners();
  }



  void _removeFromBookmark(timestamp, context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(_uid);
    List d = [timestamp];
    ref.update({'bookmarked places' : FieldValue.arrayRemove(d)});
    openToast(context, 'Removed from your bookmark');
  }
  
  Future posttPlaceData(timestamp) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');

    FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'loved places' : FieldValue.arrayUnion([timestamp])
    });
    notifyListeners();
  }

  Future getPlaceData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    final DocumentReference ref =FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = ((snap.data() as Map) as Map)['bookmarked places'];

    _placeData = [];

   FirebaseFirestore.instance
        .collection('places')
        .get()
        .then((QuerySnapshot snap) {
      var x = snap.docs;
      for (var item in x) {
        if (d.contains(item['timestamp'])) {
          _placeData.add(item);
        }
      }
       notifyListeners();
    });
  }

  Future bookmarkIconClicked(timestamp, context) async {
     if (_bookmarkedPlaces == null){
     await getBookmarkedList().then((value) async{ 
       bookMarkTemp(timestamp, context);
     });
     }else{
        bookMarkTemp(timestamp, context);        
     }
    
   // notifyListeners();

  }

Future bookMarkTemp(timestamp, context) async{
   if(_bookmarkedPlaces.contains(timestamp)){
      _removeFromBookmark(timestamp, context);
      await getBookmarkedList();
      bookmarkIconCheck(timestamp);
    } else{
      _addtoBookmark(timestamp,context);
      await getBookmarkedList();
      bookmarkIconCheck(timestamp);
    }
    
}







}
