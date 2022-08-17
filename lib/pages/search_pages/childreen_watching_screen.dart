import 'dart:io';

import 'package:Hathante/widgets/search%20widgets/nurseries_watching_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:easy_localization/easy_localization.dart' as Es;

class ChildreenWatchingScreen extends StatefulWidget {
  const ChildreenWatchingScreen({Key key}) : super(key: key);

  @override
  _MyNurseryScreenState createState() => _MyNurseryScreenState();
}

class _MyNurseryScreenState extends State<ChildreenWatchingScreen> {
int x = 0 ;
List data = [] ;
PlaceBloc ab;
  @override
  void didChangeDependencies() {
  if (x < 1){
    ab = Provider.of<PlaceBloc>(context, listen: false);
    ab.getMyNurseriesActivitesNew();
    x++ ;
    setState(() {
      
    });
      }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: PreferredSize(
           preferredSize: Size.fromHeight(60),
        child: Center(
          child: Directionality(
        textDirection: TextDirection.rtl,
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          systemOverlayStyle: Platform.isAndroid ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
          centerTitle: false,
          automaticallyImplyLeading: false,
          leading: IconButton(icon: Icon(Icons.refresh), onPressed: (){
             ab.getMyNurseriesActivitesNew();
             setState(() {
             
            });
           /* ab.getMyNurseriesActivites().then((value){
            setState(() {
             
            });  });*/
          }),
          title: Text("My Nurseries".tr() , textAlign: TextAlign.right,))))),
          body: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey[300], blurRadius: 10, offset: Offset(3, 3))
            ],
          ),
          child: ab.mySubscribedNuersries.isEmpty
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.no_sim, size: 60, color: Colors.grey,),
                        SizedBox(height: 10,),
                        Text('You are not subscribed to any nurseries'.tr(), style: TextStyle(fontSize: 18, color:Colors.grey, fontWeight: FontWeight.w700),),
                        Text( ab.errorMsg.tr(), style: TextStyle(fontSize: 16, color:Colors.grey, fontWeight: FontWeight.w500), textAlign: TextAlign.center,)

                      ],
                    )
                  ),
              )
              : ListView.separated(
                //  padding: EdgeInsets.only(top: 50, bottom: 50),
                  itemCount: ab.mySubscribedNuersries.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 30,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                   
                    return NurseriesWatchingCard(ab.mySubscribedNuersries[index][0], ab.mySubscribedNuersries[index][1]['children'] , ab.mySubscribedNuersries[index][2]) ;
                  },
                )),
    );
  }
}

