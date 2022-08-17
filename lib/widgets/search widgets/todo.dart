/*import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:Hathante/pages/comments.dart';

import 'package:Hathante/utils/next_screen.dart';

openMapsSheet(double lang , double lat , context , String name ) async {
    try {

     var coords = Coords(lang,lat);
     var availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: name ,
                        ),
                        title: Text(map.mapName),
                        leading: Image(
                          image: map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),],),),),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }
  
Widget todo (context, timestamp, lat, lng , place){
  return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('To Do', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                  
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40)),
                  ),
          Container(
            
            //color: Colors.brown,
            height: 330,
            //width: w,
            child: GridView.count(
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                InkWell(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[200],
                                  offset: Offset(5, 5),
                                  blurRadius: 2)
                            ]),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.blueAccent[400],
                                    offset: Offset(5, 5),
                                    blurRadius: 2)
                              ]),
                          child: Icon(
                            LineIcons.hand_o_left,
                            size: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Text(
                          /*'Travel Guide',*/ 'Google Maps' ,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
        openMapsSheet(lat, lng , context , place);
        // Find the Scaffold in the widget tree and use it to show a SnackBar.
       // final snackBar = SnackBar(content: Text('Install uber !'));
      //  Scaffold.of(context).showSnackBar(snackBar);

      
                   // nextScreen(context, GuidePage(timestamp: timestamp, lat: lat, lng: lng,));
                  },
                ),
                InkWell(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[200],
                                  offset: Offset(5, 5),
                                  blurRadius: 2)
                            ]),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.orangeAccent[400],
                                    offset: Offset(5, 5),
                                    blurRadius: 2)
                              ]),
                          child: Icon(
                            LineIcons.hotel,
                            size: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Text(
                          'Nearby Hotels',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                //   nextScreen(context, HotelPage(lat: lat, lng: lng , timestamp: timestamp , ));

                  },
                ),
                InkWell(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[200],
                                  offset: Offset(5, 5),
                                  blurRadius: 2)
                            ]),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.pinkAccent[400],
                                    offset: Offset(5, 5),
                                    blurRadius: 2)
                              ]),
                          child: Icon(Icons.restaurant),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Text(
                          'Nearby Restaurents',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                 //   nextScreen(context, RestaurantPage(lat: lat, lng: lng , timestamp :timestamp));
                  },
                ),
                InkWell(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[200],
                                  offset: Offset(5, 5),
                                  blurRadius: 2)
                            ]),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.indigoAccent[400],
                                    offset: Offset(5, 5),
                                    blurRadius: 2)
                              ]),
                          child: Icon(
                            LineIcons.comments,
                            size: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Text(
                          'User Reviews',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    nextScreen(context, CommentsPage(title: 'User Reviews', timestamp: timestamp,));
                  },
                ),
              ],
            ),
          )
        ],
      
    );
}*/