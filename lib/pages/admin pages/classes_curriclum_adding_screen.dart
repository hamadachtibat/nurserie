import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Hathante/utils/styles.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';
import '../../utils/toast.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/user_bloc.dart';

class ClassesAddition extends StatefulWidget {
  final bool isEdit ;
  final List temp ;
  ClassesAddition(this.isEdit, {this.temp});

  @override
  _ClassesAdditionState createState() => _ClassesAdditionState();
}

class _ClassesAdditionState extends State<ClassesAddition> {
  
   TextEditingController classesCtrl = TextEditingController();
  bool isLoading = false ;
  List<Item> classes = [] ;
  List<Map<String, dynamic>> classesWithSubjectAr = [];
  List<Map<String, dynamic>> classesWithSubjectEn = [];

  @override
  void initState() { 
    if (widget.isEdit){
          for (int i =0 ; i<widget.temp.length ; i++){
            final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
            classes.add(Item(data: {
                         "class name" : widget.temp[i]['class'],
                         "tag ctrl" : TextEditingController(),
                         "class subjects" :  widget.temp[i]['subjects'] ,
                         "tag key" : _tagStateKey ,
                       }));
      }
    }
    super.initState();
    
  }
   Future<void> translate() async{
  final translator = await GoogleTranslator();
      Translation classs;
      List<String> _temp = [] ;
      classesWithSubjectEn = [] ;
      classesWithSubjectAr = [] ;
    if (context.locale == Locale('en')){ //generate arabic
      for (int i = 0 ; i < classes.length ; i ++){
       classesWithSubjectEn.add({
         "class" : classes[i].data['class name'],
         "subjects" : classes[i].data['class subjects']
        });
          classs =  await translator.translate(classes[i].data['class name'] , from: 'en', to: 'ar');
           List tempList = (classes[i].data['class subjects'] as List);
           for(int j = 0; j < tempList.length ; j++){
             Translation temp = await translator.translate(tempList[j].t , from: 'en', to: 'ar');
            _temp.add(temp.text);
           }
    
          classesWithSubjectAr.add({
           "class" : classs.text,
           "subjects" : _temp
          });
         }
  }else{ //generate english
    for (int i = 0 ; i < classes.length ; i++){
       classesWithSubjectAr.add({
         "class" : classes[i].data['class name'],
         "subjects" : classes[i].data['class subjects']
        });
          classs =  await translator.translate(classes[i].data['class name'] , from: 'ar', to: 'en');
           List tempList = (classes[i].data['class subjects'] as List);
           for(int j = 0 ; j <tempList.length ; j ++){
            Translation temp = await translator.translate(tempList[j] , from: 'ar', to: 'en');
            _temp.add(temp.text);
          }
          classesWithSubjectEn.add({
           "class" : classs.text,
           "subjects" : _temp
          });
         };
  }
    final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
      ub.setClassWithSubjectsAr(classesWithSubjectAr);
      ub.setClassWithSubjectsEn(classesWithSubjectEn);    
  }

  Future<void> translate2() async{
  final translator = GoogleTranslator();
      Translation classs;
      List<String> _temp = [] ;
      classesWithSubjectEn = [] ;
      classesWithSubjectAr = [] ;
    if (context.locale == Locale('en')){ //generate arabic
      classes.forEach((element) async{
       classesWithSubjectEn.add({
         "class" : element.data['class name'],
         "subjects" : element.data['class subjects']
        });
          classs =  await translator.translate(element.data['class name'] , from: 'en', to: 'ar');
           (element.data['class subjects'] as List).forEach((element) async{
            Translation temp = await translator.translate(element , from: 'en', to: 'ar');
            _temp.add(temp.text);
          });
          
          classesWithSubjectAr.add({
           "class" : classs.text,
           "subjects" : _temp
          });
         });
  }else{ //generate english
      classes.forEach((element) async{
       classesWithSubjectAr.add({
         "class" : element.data['class name'],
         "subjects" : element.data['class subjects']
        });
          classs =  await translator.translate(element.data['class name'] , from: 'ar', to: 'en');
           (element.data['class subjects'] as List).forEach((element) async{
            Translation temp = await translator.translate(element , from: 'ar', to: 'en');
            _temp.add(temp.text);
          });
          classesWithSubjectEn.add({
           "class" : classs.text,
           "subjects" : _temp
          });
         });
  }
    final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
      ub.setClassWithSubjectsAr(classesWithSubjectAr);
      ub.setClassWithSubjectsEn(classesWithSubjectEn);    
  }

  void addSpinner(){
      setState(() {
                       if (classesCtrl.text != ""){
                       final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
                       classes.add(Item(
                         
                         data :{
                         "class name" : classesCtrl.text,
                         "tag ctrl" : TextEditingController(),
                         "class subjects" : [] ,
                         "tag key" : _tagStateKey ,
                       }));
                        classesCtrl.text = "";
                          }
                         });
  }

  @override
  Widget build(BuildContext context) {
    print(context);
  var mainTilteTextStyle = TextStyle( color: Theme.of(context).primaryColor , fontWeight: FontWeight.bold , fontSize: 18);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color :Colors.white), onPressed: ()=> Navigator.pop(context)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("add classes and curriculum".tr() , style: TextStyle(/*fontFamily: 'Poppins',*/ fontWeight: FontWeight.w800,fontSize: 18, color: Colors.white),),
      ),
      body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                SizedBox(height: 5,),
                 Row(
                   children: [
                        Container(
                       width: MediaQuery.of(context).size.width *0.8,
                       child: TextFormField(
                decoration: inputDecoration( "add class".tr() ,"add class".tr(),classesCtrl),
                controller:classesCtrl,
                onSaved: (_){addSpinner();},
                onChanged: (String value) {
                        setState(() {
                       
                        });
              },
            ),
                     ),
                     Spacer(),
                     IconButton(icon: Icon(Icons.done), onPressed:addSpinner),
                   ],
                 ),
                 SizedBox(height: 15,),
                _buildPanel(mainTilteTextStyle , classes,  /*context.locale == Locale('ar')? ib.mealsAr : ib.mealsEn*/),
               SizedBox(height: 15,),
               isLoading?Center(child: CircularProgressIndicator()) :Container(
                  color: Theme.of(context).primaryColor,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 45,
                  child: FlatButton(
                    child: Text('Save Data'.tr(), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),),
                    onPressed: (){
                        setState(() {
                          isLoading = true ;
                           // openToast(context , "error".tr());
                        });
                     try{
                      translate().then((value) {
                        setState(() {
                          isLoading = false ;
                        });
                            openToast(context , "done".tr());
                            Future.delayed(Duration(milliseconds: 800)).then((value) => Navigator.pop(context));
                      }).catchError((e){
                        print(e.toString() + " ggg");
                        setState(() {
                          isLoading = false ;
                            openToast(context , "error".tr());
                        });
                      });
                      }catch(e){
                        print(e.toString() + " gg");
                        setState(() {
                          isLoading = false ;

                            openToast(context , "error".tr());
                        });
                      }
                      
                  // clearTextFeilds();
                   //handleSubmit();
                    }
                )),
                 SizedBox(height: 15,),

            ],),
              ),
          ),
    );
  }

       Widget _buildPanel(mainTilteTextStyle  , _data) {
    return  ExpansionPanelList(
        dividerColor: Theme.of(context).dividerColor.withOpacity(0.5),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _data[index].isExpanded = !isExpanded;
          });
        },
        children: _data.map<ExpansionPanel>((Item item,) {
         
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(title: Text(item.data['class name'].toString().tr(), style: mainTilteTextStyle , textAlign: TextAlign.right,));
            },
            body: Container(
              padding: EdgeInsets.symmetric(horizontal :8),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tags(
      key:  item.data['tag key'],
      textField: TagsTextField(
        inputDecoration: inputDecoration('add curriculum'.tr() ,'البرامج التعليمية'.tr(), item.data['tag ctrl']),
        textStyle: TextStyle(fontSize: 16),
        hintText: "add curriculum".tr() ,
        width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 10),
        onSubmitted: (String str) {
          setState(() {
            item.data['class subjects'].add(str);
          });
        },
      ),
      itemCount:  item.data['class subjects'].length, // required
      itemBuilder: (int index){          
            final _item =  item.data['class subjects'][index];
    
            return ItemTags(
              activeColor: Theme.of(context).primaryColor,
                  key: Key(index.toString()),
                  index: index, // required
                  title: _item,
                  textStyle: TextStyle( fontSize: 16, ),
                  combine: ItemTagsCombine.withTextBefore,
                  removeButton: ItemTagsRemoveButton(
                    onRemoved: (){
                        setState(() {
                             item.data['class subjects'].removeAt(index);
                        });
                        return true;
                    },
                  ), 
            );
    
      },
    ),
                  SizedBox(height: 20,),
              ],
              )),
            isExpanded: item.isExpanded,
          );
        }).toList(),
    );
  }
}
class Item {
  Item({
    this.data,
    this.isExpanded = false,
  });

  Map data;
  bool isExpanded;
}