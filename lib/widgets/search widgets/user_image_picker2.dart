import 'dart:io';
import 'package:flutter/material.dart';

class UserImagePicker2 extends StatefulWidget {
  final String initialImage ;
  final File _pickedImage ;
  final Function(int index) remove ;
  final bool showDelete ;
  final int index ;
  bool isUrl ;
  final Function(int index , String path) removeOnQeue ;
  final String path ;
  UserImagePicker2( this._pickedImage, this.remove, this.index ,{this.initialImage, this.isUrl = false, this.removeOnQeue , this.path , this.showDelete = false});

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker2> {

  @override
  Widget build(BuildContext context) {
  File pickedImage =  widget._pickedImage ;
    return Stack(
      children: [
       widget.isUrl?Container(
                   width: 88,
                 height: 88,
                                     decoration: new BoxDecoration(
                                     color: Theme.of(context).primaryColor,
                                      image: new DecorationImage(
                 image: new NetworkImage(widget.initialImage),
                 fit: BoxFit.cover,
               ),
               borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
               border: new Border.all(
                 color: Theme.of(context).accentColor,
                 width: 2.0,
               ),
             ),
           )
       
       :CircleAvatar(
       radius: 50, backgroundImage:(pickedImage != null ?FileImage(pickedImage) :(widget.initialImage != null ?NetworkImage(widget.initialImage , scale: 1) :null)) 
       ,child: (pickedImage == null && widget.initialImage == null ) ?Icon(Icons.add , size: 40,) : null,),
       widget.showDelete ?Positioned(
        right:-10,
        top: 0,
        
  child:RawMaterialButton(
  elevation: 10,
  onPressed: (){
    setState(() {
      if (widget.isUrl){
  widget.removeOnQeue(widget.index , widget.path) ;
      }else{
  widget.remove(widget.index) ;
      }
          
    });
            
  } ,
  fillColor: Colors.grey,
  constraints: BoxConstraints(maxWidth: 60),
  child: Icon(    
    Icons.remove,
    size: 25.0,
    color: Colors.white,
  ),
  shape: CircleBorder()
),
       ):Container()
      ],
    );
  }
}