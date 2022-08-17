import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/pages/search_pages/more_places.dart';
import 'package:Hathante/pages/search_pages/place_details.dart';
import 'package:Hathante/utils/cached_image.dart';
import 'package:Hathante/utils/loading_animation.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart' ;



class RecommendedPlaces extends StatefulWidget {
  RecommendedPlaces(this.rpb);
    final PlaceBloc rpb ;

  @override
  _RecommendedPlacesState createState() => _RecommendedPlacesState();
}

class _RecommendedPlacesState extends State<RecommendedPlaces> {


  @override
  Widget build(BuildContext context) {    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin:context.locale == Locale('ar') ?const EdgeInsets.only(right: 15, top: 10, bottom: 10 , left: 15) :const EdgeInsets.only(left: 15, top: 10, bottom: 10),
          child: 
            Row(
              children: [
                Text('other nurseries'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,/*fontFamily: 'Poppins',*/ color: Colors.grey[800]),),
                Spacer(),
                FlatButton(onPressed: () => nextScreen(context, MorePlacesPage(title: 'other nurseries'.tr())), child: Text('عرض الكل >>'.tr(), style: TextStyle(color: Colors.grey ,fontSize: 12 ),),)
              ],
            ),

          ), 
          widget.rpb.data.isEmpty ? Container(height: 320,child: LoadingWidget1()):
          ListView.builder(
                      primary: false,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.rpb.data.take(10).length,
                      itemBuilder: (BuildContext context, int index) {
                        return RecommListITem(rpb: widget.rpb, index: index,)  ;
                      },
                    ),


                  SizedBox(height: 50,)
                  
                
      ],
    );
  }
}

class RecommListITem extends StatelessWidget {
  final index ; 
  const RecommListITem({
    this.index ,
    Key key,
    @required this.rpb,
  }) : super(key: key);

  final PlaceBloc rpb;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Stack(
          children: <Widget>[
        
        Hero(
          tag: 'recommended$index',
          child: Container(
          margin: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 0),
          height: 245, //230
          width: double.infinity,
          
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[300],
                    blurRadius: 10,
                    offset: Offset(3, 3))
              ]),
          child: cachedImage(rpb.data[index]['urls'][0], 10) ),
        ),
        Positioned(
            right: 30,
            top: 30,
            height: 35,
            width: 80,
            child: FlatButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),),
              color: Colors.grey[600].withOpacity(0.5),
              icon: Icon(
                LineIcons.heart,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                rpb.data[index]['loves'].toString(),
                style: TextStyle(
                    color: Colors.white, fontSize: 13),
              ),
              onPressed: () {},
            ),
          ),
        Positioned(
          bottom: 0,
          width: MediaQuery.of(context).size.width,
          height: 80, 
          child: Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              color: Colors.grey[900].withOpacity(0.6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text(rpb.data[index]['place name'], style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w700),),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                  Expanded(child: Text(rpb.data[index]['location'] + " ", style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis,),)
                ],
              ),
            ],),
          ))
          ],
        ),
      
        onTap: (){
          final PlaceBloc pb = Provider.of<PlaceBloc>(context);
            pb.setCurrentPlace = rpb.data[index];
          nextScreen(context, PlaceDetailsPage('recommended$index'));
        },
                      );
  }
}