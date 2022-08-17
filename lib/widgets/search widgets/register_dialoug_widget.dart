/*import 'dart:io';

import 'package:Hathante/widgets/search%20widgets/user_input_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/utils/styles.dart';
import 'package:Hathante/utils/toast.dart';
import 'package:easy_localization/easy_localization.dart' ;
import 'package:signature/signature.dart';


class RegisterDiloug extends StatefulWidget {
  final String timestamp;
  final Function function;
  final String terms ;
  final int childreNumber ;
  const RegisterDiloug(
     this.timestamp,
       this.terms,
       this.childreNumber,
     this.function,
   ) ;
 
  @override
  _RegisterDilougState createState() => _RegisterDilougState();
}

class _RegisterDilougState extends State<RegisterDiloug> {

  var formKey = GlobalKey<FormState>();
  TextEditingController parentCtrl = new TextEditingController();
  TextEditingController natIDCtrl = new TextEditingController();
  List<Widget> textFileds = [];
    List<Widget> textFiledsAge = [];
  List<File> files = [] ;
  int txtFildIndex = 1 ;
  int txtFildIndexAge = 1 ;
  String dateTime = "" ;

  List<TextEditingController> textFiledsControllers = [TextEditingController()];
  List<TextEditingController> textFiledsControllersAges = [TextEditingController()];
  bool isUploading = false ;
@override
  void initState() {
    txtFildIndex = 1 ;
    textFileds = [ Column(
      children: [
        TextFormField(                
                  decoration: inputDecoration('child name'.tr(), 'name'.tr(), textFiledsControllers[0]),
                  controller: textFiledsControllers[0],
                  textAlign: TextAlign.right,
                  validator: (value){
                    if(value.isEmpty) return 'required'.tr(); return null;
                  },
                  onChanged: (String value) {
                  },
                ),
                 SizedBox(height: 10,),
                 TextFormField(
                      
      decoration: inputDecoration('child age'.tr(), 'age'.tr(), textFiledsControllersAges[0]),
      controller:textFiledsControllersAges[0],
      textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
      validator: (value){
        if(value.isEmpty) return 'required'.tr(); return null;
      },
      onChanged: (String value) {
      },
    ),
     SizedBox(height: 10,),
     UserImagePicker((file){
        if (files.length == 0){
          files.insert(0, file);
       }else{
         files[0] =  file;
       }
         })
      ],
    ),];
    super.initState();
  }
    @override
    void dispose() { 
      textFiledsControllers.forEach((element) { 
        element.dispose();
      });
      super.dispose();
    }
  SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.grey[100],
);

  void saveSig(controller) async{
 FirebaseStorage.instance .ref().child('signatures').child("signa").putData(await (controller.toPngBytes()) ).onComplete.then((ref) =>
  print(ref.ref.getDownloadURL())
  );}

  @override
  Widget build(BuildContext context) {
    StorageReference  refa = FirebaseStorage.instance .ref().child('kids_image');
    StorageReference  refa2 = FirebaseStorage.instance .ref().child('signatures');
    
    final UserBloc ub = Provider.of<UserBloc>(context, listen : false );
    final PlaceBloc pb = Provider.of<PlaceBloc>(context);
  
    return AlertDialog( 
    title:  Column(
      children: [
        Text('register now'.tr() , textAlign: TextAlign.center, style : TextStyle(fontWeight: FontWeight.w700,)),
        Text(  " " +  'places are available'.tr() + " " + widget.childreNumber.toString(), textAlign: TextAlign.center, style : TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),

      ],
    ),   
    content: StatefulBuilder( 
    builder: (BuildContext context, StateSetter setState) {
     return  Container(
    height: 500,
     width: double.infinity,
     child: Form(
     
       key: formKey,
       child: ListView(children: <Widget>[
    TextFormField(
      decoration: inputDecoration('parent name'.tr(), 'name'.tr(), parentCtrl),
      controller: parentCtrl,
      textAlign: TextAlign.right,
      validator: (value){
        if(value.isEmpty) return 'required'. tr(); return null;
      },
      onChanged: (String value) {
      },
    ),
    SizedBox(height: 20,),

    TextFormField(
      decoration: inputDecoration('national id'.tr(), 'national id'.tr(), parentCtrl),
      controller: natIDCtrl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.right,
      validator: (value){
        if(value.isEmpty) return 'required'.tr(); return null;
      },
      onChanged: (String value) {
      },
    ),
    SizedBox(height: 20,),

    Row(
      children: [
          IconButton(icon: Icon(Icons.remove), onPressed:txtFildIndex == 0 ?null :(){
      setState(() {
        if (txtFildIndex != 0){
               txtFildIndex -- ;
           textFiledsControllers.removeLast();
           textFileds.removeLast();

          txtFildIndexAge -- ;
           textFiledsControllersAges.removeLast();
           textFiledsAge.removeLast();
        }
      });
    }),
        IconButton(icon : Icon(Icons.add, color: Colors.blue[300], ), onPressed: (){
          setState(() {
            textFiledsControllers.add(TextEditingController());
             textFiledsControllersAges.add(TextEditingController());
             final indexImage = txtFildIndex ;
             textFileds.add(
                Column(
                  children: [
                    TextFormField(
                      
      decoration: inputDecoration('child name'.tr(), 'child'.tr(), textFiledsControllers[txtFildIndex]),
      controller:textFiledsControllers[txtFildIndex],
      textAlign: TextAlign.right,
      validator: (value){
        if(value.isEmpty) return 'required'.tr(); return null;
      },
      onChanged: (String value) {
      },
    ),
    SizedBox(height: 10,),
     TextFormField(
                      
      decoration: inputDecoration('child age'.tr(), 'age'.tr(), textFiledsControllersAges[txtFildIndexAge]),
      controller:textFiledsControllersAges[txtFildIndexAge],
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      validator: (value){
        if(value.isEmpty) return 'required'.tr(); return null;
      },
      onChanged: (String value) {
      },
    ),
     SizedBox(height: 10,),
     
     UserImagePicker((file){
       if (files.length == indexImage){
          files.insert(indexImage, file);
       }else{
         files[indexImage] =  file;
       }
         }),
SizedBox(height: 20,),
                  ],
                ),
             );

             
                txtFildIndex ++ ;
                txtFildIndexAge ++ ;
          });
        },),
        Spacer(),
         Expanded(
            child: Text("children".tr(),textAlign: TextAlign.right, style : TextStyle(fontWeight: FontWeight.w700, /*fontFamily: 'Poppins'*/)),
        ),
      ],
    ),
    SizedBox(height: 20,),
    Column(children: textFileds,),
    SizedBox(height: 20,),
    Text("appointment date".tr() ,textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.w500, /*fontFamily: 'Poppins'*/)) ,
          OutlineButton.icon(    
          onPressed: () {      
              DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    onChanged: (DateTime date) {  
                      setState(() {
                          dateTime = date.month.toString()+ "-" +date.day.toString()+ "  " +date.hour.toString()+ ":"+date.minute.toString();      
                        });
                  });
          },
          highlightedBorderColor: Colors.blue,
         
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),        
          icon:  Icon(
            Icons.arrow_drop_down,
            size: 24.0,
            color: Colors.blue,
          ),    
          label: Text(dateTime == "" ?    "appointment date".tr():dateTime),
    ),
    SizedBox(height: 15,),
    Text("terms".tr() ,textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.w500, /*fontFamily: 'Poppins'*/)) ,
    Text(widget.terms),
    SizedBox(height: 5,),
    Text("accept and sign".tr() ,textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.w500, /*fontFamily: 'Poppins'*/)) ,
     Stack(
      children: [Signature(
  controller: _controller,
  width: 300,
  height: 300,
  backgroundColor: Colors.grey[200],

),
InkWell(
  onTap: (){
    _controller.clear();
  },
  child:   Positioned(
  right: 5,
  top: -2,
  child: CircleAvatar(child: Icon(Icons.clear), )),) ] ),
  SizedBox(height: 20,),



  !isUploading ?Row(
      children: [
          Container(
            padding: EdgeInsets.zero,
              color: Theme.of(context).primaryColor,
             width: MediaQuery.of(context).size.width * 0.3,
              height: 45,
              child: FlatButton(
                child: Text('book now!'.tr(), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),),
                onPressed: () async{
                if (files.length != 0 && _controller.isNotEmpty){
                  openToast(context , "uploading now".tr());
                   setState(() { 
                     isUploading = true ;
                   });
                  bool x = false ;
                  List children = [] ;
                  try{
                    for (int i = 0 ; i< files.length; i++){
                 
                   var file = (i+1).toString() +  ' - ' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpg' ;
                   StorageUploadTask  uploadTask =  refa.child(file).putFile(files[i]);
                    var url = await (await uploadTask.onComplete).ref.getDownloadURL();
                  children.add({
                  "name" : textFiledsControllers[i].text ,
                  "img url" :url,
                  "file" : file,
                  "age" : textFiledsControllersAges[i].text,
                  "attend" : false ,
                  "timestamp" : "0",
                  "notes timestamp" : "0",
                  "notes" : "",
                  "breakfast" : 0,
                  "rest" : 0 ,
                  "launch" : 0,
                  "milk" : 0,
                  "water" : 0,
                  "wc" : 0,
                  "pampers" : 0,
                  "meals": [],
                  });
                  }  
                StorageUploadTask  uploadTask =  refa2.child(widget.timestamp).putData( await (_controller.toPngBytes()));
                String sigUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
                  
                  if (parentCtrl.text.isEmpty || x ||dateTime.isEmpty ||natIDCtrl.text.isEmpty){
                    formKey.currentState.validate();
                    openToast(context, "fill all fields".tr());
                      setState(() { 
                     isUploading = false ;
                   });
                  }else{
                 
                  pb.reserveAppotiment(widget.timestamp, ub.getUid, {
                    "user name" : ub.name,
                    "email" : ub.email,
                    "user ID" : ub.getUid,
                    "img url" : ub.imageUrl,
                    "parent name" : parentCtrl.text,
                    "national id" : natIDCtrl.text,
                    "children" : children,
                    "appotment date" : dateTime,
                    "signature" :  sigUrl,
                    "approved" : false,
                   }).then((value) {
                      setState(() { 
                     isUploading = false ;
                   });
                     widget.function();
                   });
                  
                }
                 } catch(e){
                    setState(() { 
                     isUploading = false ;
                   });
                   openToast(context , "something wrong!".tr());
                }}else{
                  openToast(context , "You Should fill all fields".tr());
                }
                }
            )),
           SizedBox(width: 10,),
        Container(
              color: Colors.red,
              height: 45,
              width: MediaQuery.of(context).size.width * 0.3,
              child: FlatButton(
                child: Text('cancel'.tr(), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),),
                onPressed: (){
               Navigator.pop(context);
                }
            )),
      ],
    ):Center(child: CircularProgressIndicator(),),

    SizedBox(height: 25,),
    
    

       ],)),
     );
    },
    ),
  );
  }

}*/