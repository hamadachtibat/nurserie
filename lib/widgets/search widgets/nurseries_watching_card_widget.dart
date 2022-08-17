import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Hathante/models/variables.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart' as eb;

class NurseriesWatchingCard extends StatefulWidget {
  NurseriesWatchingCard(this.placeData, this.kidsData, this.general);
  final DocumentSnapshot placeData;
  final List general;
  final  kidsData;

  @override
  _NurseriesWatchingCardState createState() => _NurseriesWatchingCardState();
}

class _NurseriesWatchingCardState extends State<NurseriesWatchingCard> {
  bool isExapnded = false ; 
  String todayActivity = "" ;
  @override
  Widget build(BuildContext context) {
    if (isActivityDate(widget.general[2]['timestamp'])){
      todayActivity = widget.general[2]['today activity'];
    }else{
      todayActivity = "no update today".tr();
    }
    return Card(
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Column(
          
          children: [
           Row(
             children: [
                IconButton(icon: Icon(isExapnded ?Icons.arrow_drop_up   :Icons.arrow_drop_down), onPressed: (){
                 setState(() {
                   isExapnded = !isExapnded ;
                 });
               }),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.placeData['place name'] , style:  TextStyle( fontSize: 18, fontWeight: FontWeight.w700,color: Colors.grey[800]), textAlign: TextAlign.right,),
                   // Text(widget.childreen, style: TextStyle(fontSize: 13,  fontWeight: FontWeight.w500, color: Colors.black), textAlign: TextAlign.right,),
                  ],
                ),

             ],
           ),
           SizedBox(height: 5,),
          !isExapnded?  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Expanded(flex: 2, child: Image.network(widget.placeData['url'],),),
                Spacer(),
                Expanded(flex: 3 , child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Align(
                  alignment: Alignment.bottomRight,
                  child:Text("today report".tr() , style: TextStyle( fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black), textAlign: TextAlign.right,)),
                   SizedBox(height: 5,),
                  isExapnded?Container() :
                  Align(
                  alignment: Alignment.centerRight,
                  child:Text(todayActivity , style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500, color: Colors.grey[500]), maxLines: 3, overflow: TextOverflow.ellipsis,  textAlign: TextAlign.right,)),
                  SizedBox(height: 2,), ],),)
           ],):Container(),
                 
                 //after expansion
                  isExapnded?  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                       Container(
                      child: Image.network(widget.placeData['url'],)),
                      SizedBox(height: 10,),
                        Align(
                        alignment: Alignment.centerRight,
                        child:Text("today report".tr() , style: TextStyle( fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black), textAlign: TextAlign.right,)),
                         Text(todayActivity , style: subtitleTextStyle, textAlign: TextAlign.right,) ,
                      SizedBox(height: 15,),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Container(
                        height: 150,
                        child: ListView.builder(
                        itemCount:widget.kidsData.length ,
                        itemBuilder: (context , index){
                          return  ListTile(
                                leading: CircleAvatar(   backgroundImage: NetworkImage(widget.kidsData[index]['img url'])),
                                title: Text(widget.kidsData[index]['name']),
                                isThreeLine: true,
                                subtitle: Text( (isActivityDate( int.parse(widget.kidsData[index]['timestamp'].toString())) ?(widget.kidsData[index]['attend'] ?"attend".tr() : "didn't attend".tr()) 
                                :"no record today".tr()) + "\n" + 
                                (!isActivityDate( int.parse(widget.kidsData[index]['notes timestamp'].toString())) ?widget.kidsData[index]['notes'] : "" 
                                ))   
                              );
                        }),),
                      ),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                  child: InkWell( onTap: () async{launch("tel://${widget.placeData['phone number']}"); },
                    child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.phone),SizedBox(width: 5,), Text("call".tr()) ],), ), ),
                     
                      Container(
              margin: EdgeInsets.symmetric(vertical: 10),
               width: 1,
               height: 40,
               color:Colors.grey,),

                     Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                       child: InkWell(
                          onTap: () async{
                           var url = "https://wa.me/?text=" + widget.placeData['whatsapp'];
                          if (await canLaunch(url)) {
                          await launch(url);
                           } else {
                          throw 'Could not launch $url';
                           }
                        },child: Row( mainAxisAlignment: MainAxisAlignment.center,
                        children: [ Icon(FontAwesomeIcons.whatsapp),SizedBox(width : 5), Text("واتساب")
                              ],),
                            ),
                     ),
                     ],)
                      ],
                    ),
                  ):Container(),
         ],),
       ),
    );
  }

  isActivityDate(timestamp){
  return  DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString())).day == DateTime.now().day ;
  }
}