import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/recommanded_places_bloc.dart';
import 'package:Hathante/pages/search_pages/place_details.dart';
import 'package:Hathante/utils/cached_image.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart' ;


class OtherPlaces extends StatelessWidget {


  
  @override
  Widget build(BuildContext context) {
    final RecommandedPlacesBloc rpb = Provider.of<RecommandedPlacesBloc>(context);
    double w = MediaQuery.of(context).size.width;
    

    return NearbyCards(w: w, rpb: rpb);
  }
}

class NearbyCards extends StatelessWidget {
  const NearbyCards({
    Key key,
    @required this.w,
    @required this.rpb,
  }) : super(key: key);

  final double w;
  final RecommandedPlacesBloc rpb;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('You May Also Like'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, /*fontFamily: 'Poppins'*/)),
                  
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 20),
                    height: 3,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40)),
                  ),
        
        Container(
                  height: 205,
                  width: w,
                  child: ListView.separated(
                    
                    scrollDirection: Axis.horizontal,
                    itemCount: rpb.data.take(6).length,
                    separatorBuilder: (BuildContext context, int index){
                      return SizedBox(width: 10);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          child: Stack(
                            children: <Widget>[
                              Hero(
                                tag: 'other$index',
                                  child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  height: 200,
                                  width: w * 0.35,
                                  child: cachedImage(rpb.data[index]['urls'][0], 10),

                                  
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 15,
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

                                bottom: 30,
                                left: 10,
                                right: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(rpb.data[index]['place name'],
                                    
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                    
                                  ],
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            final PlaceBloc pb = Provider.of<PlaceBloc>(context);
                        pb.setCurrentPlace = rpb.data[index];
                            nextScreen(context, PlaceDetailsPage('other$index'));
                          },
                        );
                      
                    },
                  ),
                ),


                SizedBox(height: 20,)
      ],
    );
  }
}