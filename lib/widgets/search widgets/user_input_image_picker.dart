import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final String initialImage ;
  final File placeHolderFile ;
  final Function(File image) imagePickedFn ;
  final Function(bool delete) delete;
  UserImagePicker(this.imagePickedFn ,{this.initialImage, this.delete , this.placeHolderFile });

  @override
  _UserImagePickerState createState() => _UserImagePickerState(this.initialImage);
}

class _UserImagePickerState extends State<UserImagePicker> {
_UserImagePickerState(this.initialImage);
File _pickedImage ;
String initialImage ;

  void pickImage() async{
  PickedFile pickedFile =  await ImagePicker.platform.pickImage(source: ImageSource.camera , 
  imageQuality:  50, //from 0 100
  maxWidth: 150 ,
  );
  
  File pickedImage = File(pickedFile.path);
  setState(() {
  _pickedImage  = pickedImage;
  });
  widget.imagePickedFn(_pickedImage);
  }

   void _openImagePickerModal() {
    final flatButtonColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Camera'.tr()),
                  onPressed: () async{
              PickedFile pickedFile =  await ImagePicker.platform.pickImage(source: ImageSource.camera , 
              imageQuality:  50, //from 0 100
              maxWidth: 150 ,
               );
                File pickedImage = File(pickedFile.path);
               setState(() {
                _pickedImage  = pickedImage;
              });
             widget.imagePickedFn(_pickedImage);
             Navigator.pop(context);

                  },
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Gallery'.tr()),
                  onPressed: () async{
                 PickedFile pickedFile =  await ImagePicker.platform.pickImage(source: ImageSource.gallery);    
                File pickedImage = File(pickedFile.path);
               setState(() {
                _pickedImage  = pickedImage;
                
              });
             widget.imagePickedFn(_pickedImage);
             Navigator.pop(context);

                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
  
    return
    /* Container(
       child: Column(children: <Widget>[
       CircleAvatar(radius: 40, backgroundImage:(_pickedImage != null ?FileImage(_pickedImage) :(widget.initialImage != null ?NetworkImage(widget.initialImage , scale: 1) :null)) ),
        FlatButton.icon(icon: Icon(Icons.image), label: Text("Add Your image" ,) ,
        textColor: Theme.of(context).primaryColor,
         onPressed:_openImagePickerModal , ),
         _pickedImage == null ?SizedBox(): 
        FlatButton(child: Text("Remove" ,) ,
        textColor: Theme.of(context).primaryColor,
         onPressed:(){
           setState(() {
             _pickedImage = null;
           });
         } , ),
       ],),
    );*/
    Stack(
      children: [
       GestureDetector(
         onTap: _openImagePickerModal ,
         child: CircleAvatar(
         radius: 50, backgroundImage:(_pickedImage != null ?FileImage(_pickedImage) :(initialImage != null ?NetworkImage(initialImage , scale: 1) : widget.placeHolderFile != null ?FileImage( widget.placeHolderFile) : null)) 
         ,child: (_pickedImage == null && initialImage == null  ) ?Icon(Icons.add , size: 40,) : null,),
       ),
       Positioned(
        right:-10,
        top: 0,
        
  child:RawMaterialButton(
  elevation: 10,
  onPressed: (){
      setState(() {
             _pickedImage = null;
             initialImage = null ;
             widget.imagePickedFn(_pickedImage);
             widget.delete(true);
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
       )
      ],
    );
  }
}