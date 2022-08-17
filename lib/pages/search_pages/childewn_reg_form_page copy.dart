import 'dart:io';
import 'package:Hathante/widgets/search%20widgets/user_image_picker3.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/utils/styles.dart';
import 'package:Hathante/utils/toast.dart';
import 'package:easy_localization/easy_localization.dart' as es ;
import 'package:signature/signature.dart';


class ChildrenRegisterDilougPageCopy extends StatefulWidget {
  final String timestamp;
  final Function function;
  final String terms ;
  final int childreNumber ;
  final List<Map> classes ;
  const ChildrenRegisterDilougPageCopy(
       this.timestamp,
       this.terms,
       this.childreNumber,
       this.function,
       this.classes,
   ) ;
 
  @override
  _RegisterDilougState createState() => _RegisterDilougState();
}

class _RegisterDilougState extends State<ChildrenRegisterDilougPageCopy> {

  var formKey = GlobalKey<FormState>();
  TextEditingController parentCtrl = new TextEditingController();
  TextEditingController natIDCtrl = new TextEditingController();
  List<String> _classes = [] ;
  List<File> files = [] ;
  int txtFildIndex = 1 ;
  int txtFildIndexAge = 1 ;
  String dateTime = "" ;
  bool isParent = true ;
  int currentIndex = 0 ;
  List<TextEditingController> textFiledsControllers = [];
  List<TextEditingController> textFiledsControllersAges = [];
  bool isUploading = false ;
  String classNursery  = "";
  UserBloc ub ;
  PlaceBloc pb ;

@override
  void initState() { 
    Future.delayed(Duration.zero , (){
    ub = Provider.of<UserBloc>(context, listen : false );
    pb = Provider.of<PlaceBloc>(context, listen: false);
    widget.classes.forEach((element) {
      _classes.add(element['class']);
    });
    });
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
  TaskSnapshot ref = await FirebaseStorage.instance .ref().child('signatures').child("signa").putData(await (controller.toPngBytes()) );
 //. onComplete.then((ref) =>
  print(ref.ref.getDownloadURL());
  }

  void changeData(int index){
    setState(() {
       isParent = false ;
      if (index == -1){
        textFiledsControllers.add(TextEditingController());
        textFiledsControllersAges.add(TextEditingController());
        files.add(null);
          currentIndex = textFiledsControllers.length - 1;
         
      }else{
        currentIndex = index ;
      }

    });
  }
    Reference  refa = FirebaseStorage.instance .ref().child('kids_image');
    Reference  refa2 = FirebaseStorage.instance .ref().child('signatures');
    
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
    appBar: AppBar(title: Text('register now'.tr() + " " +  'places are available'.tr() + " " + widget.childreNumber.toString(), textAlign: TextAlign.center, style : TextStyle(fontWeight: FontWeight.w700, color: Colors.white)) ,
            backgroundColor: Theme.of(context).primaryColor,
            iconTheme: IconThemeData(color: Colors.white),

    ),

    body :  SingleChildScrollView(
        child: Directionality(
                  textDirection: context.locale == Locale('ar')?TextDirection.rtl :TextDirection.ltr ,
                  child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
            children: [
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(  " "+  widget.childreNumber.toString() + " ", textAlign: TextAlign.center, style : TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(  " " +  'places are available'.tr() + " " , textAlign: TextAlign.center, style : TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text("children".tr(), style : TextStyle(fontWeight: FontWeight.w700, /*fontFamily: 'Poppins'*/)),
                  Spacer(),
                  files.length == 0 ? Container() :
                  IconButton(icon: Icon(Icons.remove), onPressed:(){
                  setState(() {
                   if (files.length != 0){
                      textFiledsControllers.removeLast();
                      textFiledsControllersAges.removeLast();
                    //  textFiledsAge.removeLast();
                      files.removeLast();
                      currentIndex = 0 ;
                      if (files.length == 0){
                        isParent = true ;
                      }
               }
               });
              }),
             isParent?Container() : IconButton(icon: Icon(Icons.close), onPressed:(){
               setState(() {
                 isParent = true ;
               });
             }),

                ],
              ),
              Container(height: MediaQuery.of(context).size.height * 0.15,
              child: ListView.separated(
              scrollDirection:Axis.horizontal,
              itemCount: files.length + 1 ,
              separatorBuilder: (context, _){
                return SizedBox(width: 10,);
              },
              itemBuilder: (_, index){
                  if (index == 0) {
                    return GestureDetector(
                      onTap: (){changeData(-1);},                      
                      child: CircleAvatar(
                      radius:  MediaQuery.of(context).size.height * 0.06 ,
                      child: Icon(Icons.person_add, size:  MediaQuery.of(context).size.height * 0.05,),),
                    );
                  }
                  if (files[index -1]== null){
                       return GestureDetector(
                  onTap: (){changeData(index - 1);},
                  child: CircleAvatar( 
                    backgroundColor: Colors.grey,
                 radius:  MediaQuery.of(context).size.height * 0.06 ,
                 child: Icon(Icons.person,color: Colors.white, size:  MediaQuery.of(context).size.height * 0.05,),),
                  );
                  }
                  return GestureDetector(
                  onTap: (){changeData(index - 1);},
                  child: CircleAvatar(   backgroundImage: FileImage(files[index -1]), radius:  MediaQuery.of(context).size.height * 0.06 ,));
              }),),
                
             isParent?parentData():childData(),
             
             !isUploading ?Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Container(
                   padding: EdgeInsets.zero,
                     color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width * 0.46,
                     height: 45,
                     child: FlatButton(
                       child: Text('book now!'.tr(), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),),
                       onPressed: () async{
                       if (files.length != 0 && _controller.isNotEmpty && isComplete()){
                         openToast(context , "uploading now".tr());
                          setState(() { 
                            isUploading = true ;
                          });
                         bool x = false ;
                         List children = [] ;
                         try{
                           for (int i = 0 ; i< files.length; i++){
                        
                          var file = (i+1).toString() +  ' - ' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpg' ;
                          TaskSnapshot  uploadTask =  await refa.child(file).putFile(files[i]);
                           var url = await uploadTask.ref.getDownloadURL();
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
                         });
                         }  
                       TaskSnapshot   uploadTask =  await refa2.child(widget.timestamp).putData( await (_controller.toPngBytes()));
                       String sigUrl = await  uploadTask.ref.getDownloadURL();
                         
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
                     width: MediaQuery.of(context).size.width * 0.46,
                     child: FlatButton(
                       child: Text('cancel'.tr(), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),),
                       onPressed: (){
                      Navigator.pop(context);
                       }
                   )),
               ],
              ):Center(child: CircularProgressIndicator(),),

              SizedBox(height: 25,),
            ],
      ),
          ),
        ),
    ));
  }


  //child widget
  Column childData() {
    return Column(children: [               
             TextFormField(    
             decoration: inputDecoration('child name'.tr(), 'child'.tr(), textFiledsControllers[currentIndex]),
             controller:textFiledsControllers[currentIndex],
             textAlign: TextAlign.right,
             validator: (value){
             if(value.isEmpty) return 'required'.tr(); return null;
             },
             onChanged: (String value) {
             },
            ),
            SizedBox(height: 10,),
            TextFormField(
                           
             decoration: inputDecoration('child age'.tr(), 'age'.tr(), textFiledsControllersAges[currentIndex]),
             controller:textFiledsControllersAges[currentIndex],
             textAlign: TextAlign.right,
             keyboardType: TextInputType.number,
             validator: (value){
             if(value.isEmpty) return 'required'.tr(); return null;
             },
             onChanged: (String value) {
             },
            ),
            SizedBox(height: 10,),
          
            UserImagePicker3(  (file){
              setState(() {
            if (files.length == currentIndex){
               files.insert(currentIndex, file);
            }else{
              files[currentIndex] =  file;
            }
            }); },
            placeHolderFile:files[currentIndex] ,
            ),
            SizedBox(height: 10,),
           /* Container(
            width: double.infinity * 0.8,
            child: new DropdownButton<String>(
            hint: Text(classNursery == "" ? ("choose class".tr()) : classNursery , style: regMedTextStyle(Colors.black), ),
            items: _classes.map((String value) {
    return new DropdownMenuItem<String>(
      value: value,
      child: new Text(value),
    );
  }).toList(),
  onChanged: (value) {
      setState(() {
        classNursery = value ;
      });
  },
),
          ),
          SizedBox(height: 20,),*/

                       ],
                
            );
  }

Column parentData(){
  return Column(children: [
   SizedBox(height: 20,),
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
              Text("appointment date".tr() ,textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.w500, /*fontFamily: 'Poppins'*/)) ,
                 OutlinedButton.icon(    
                 onPressed: () {      
                     DatePicker.showDateTimePicker(context,
                           showTitleActions: true,
                           onChanged: (DateTime date) {  
                             setState(() {
                                 dateTime = date.month.toString()+ "-" +date.day.toString()+ "  " +date.hour.toString()+ ":"+date.minute.toString();      
                               });
                         });
                 },

                style: OutlinedButton.styleFrom(
                  backgroundColor:  Colors.blue,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(10.0),
                 ), 
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
              Text(widget.terms.isEmpty ? "N/A" : widget.terms),
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
  ],);
}

bool isComplete(){
  files.forEach((element) { 
    if (element == null){
      return false ;
    }
  });
  textFiledsControllers.forEach((element) {
    if (element.text.isEmpty){
      return false ;
    }
  });

    textFiledsControllersAges.forEach((element) {
    if (element.text.isEmpty){
      return false ;
    }
  });
    return true ;
}

}


              /*Row(
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
              Column(children: textFileds,),*/