import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker3 extends StatefulWidget {
  final String initialImage ;
  final File placeHolderFile ;
  final Function(File image) imagePickedFn ;
  final Function(bool delete) delete;
  UserImagePicker3(this.imagePickedFn ,{this.initialImage, this.delete , this.placeHolderFile });

  @override
  _UserImagePickerState createState() => _UserImagePickerState(this.initialImage);
}

class _UserImagePickerState extends State<UserImagePicker3> {

_UserImagePickerState(this.initialImage);
File _pickedImage ;
String initialImage ;



@override
  void initState() {
  _pickedImage = widget.placeHolderFile ;
    super.initState();
  }
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
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Camera'),
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
                  child: Text('Use Gallery'),
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
      _pickedImage = widget.placeHolderFile ;

    return Stack(
      children: [
       GestureDetector(
         onTap: _openImagePickerModal ,
         child: CircleAvatar(
         radius: 50,
         backgroundImage: _pickedImage != null ?FileImage( _pickedImage) : null, 
         child:  _pickedImage == null  ?Icon(Icons.add , size: 40,) : null,),
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
            // widget.placeHolderFile = null ;
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