
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hathante/blocs/place_bloc.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:Hathante/models/variables.dart';
import 'package:Hathante/pages/search_pages/place_details.dart';
import 'package:Hathante/utils/cached_image.dart';
import 'package:Hathante/utils/loading_animation.dart';
import 'package:Hathante/utils/next_screen.dart';

class Featured extends StatefulWidget {
  final PlaceBloc pb;
  Featured(this.pb);

  _FeaturedState createState() => _FeaturedState();
}

class _FeaturedState extends State<Featured> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0)).then((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final PlaceBloc pb = Provider.of<PlaceBloc>(context, listen: false);
      if (prefs.getDouble("lat") == null || prefs.getDouble("lng") == null) {
        pb.getCountry().then((value) {
          setState(() {
            pb.filterByPlace(prefs.getDouble("lat"), prefs.getDouble("lng"),
                prefs.getString("location"));
          });
        });
      } else {
        pb.filterByPlace(prefs.getDouble("lat"), prefs.getDouble("lng"),
            prefs.getString("location"));
      }
    });
    super.initState();
  }

  int listIndex = 2;

  openMapsSheet(double lang, double lat) async {
    try {
      var coords = Coords(lat, lang);
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
                          title: "حضانة".tr(),
                          coords: coords,
                        ),
                        title: Text(map.mapName),
                        leading: Image(
                          image: AssetImage(map.icon),
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlaceBloc pb = Provider.of<PlaceBloc>(context, listen: false);
    double w = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: context.locale == Locale('ar')
              ? EdgeInsets.only(right: 15, top: 10, bottom: 15)
              : EdgeInsets.only(left: 15, top: 10, bottom: 15),
          child: Text(
            'حضانات قريبة'.tr(),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                /*fontFamily: 'Poppins',*/ color: Colors.grey[800]),
          ),
        ),
        Container(
          height: 280, //280
          width: w,
          child: pb.dataByPlace == null
              ? LoadingWidget2()
              : pb.dataByPlace.isEmpty == null
                  ? LoadingWidget2()
                  : PageView.builder(
                      controller: PageController(initialPage: 2),
                      scrollDirection: Axis.horizontal,
                      itemCount: pb.dataByPlace.take(5).length,
                      onPageChanged: (index) {
                        setState(() {
                          listIndex = index;
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        if (pb.dataByPlace[index]['order'] != null) {
                          if (pb.dataByPlace[index]['order'] != "") {
                            return featuredSlideItem(
                                w, index, pb, openMapsSheet, context);
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: SizedBox(
                            width: w,
                            child: InkWell(
                              child: Stack(
                                children: <Widget>[
                                  Hero(
                                    tag: 'featured$index',
                                    child: Container(
                                      height: 230,
                                      width: w,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: cachedImage(
                                          pb.dataByPlace[index]['urls'][0],
                                          10),
                                    ),
                                  ),
                                  Positioned(
                                    height: 120,
                                    width: w * 0.80,
                                    left: w * 0.05,
                                    bottom: 15,
                                    child: Container(
                                      //margin: EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.grey[200],
                                                offset: Offset(0, 2),
                                                blurRadius: 2)
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                pb.dataByPlace[index]['place name'],
                                                style: textStyleFeaturedtitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    pb.dataByPlace[index]['location'],
                                                    style: subtitleTextStyle,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                /*  Icon(
                                        Icons.flag,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      Expanded(
                                        flex: 3,
                                            child: Text(pb.dataByPlace[index]['country'] + ", " + pb.dataByPlace[index]['continent'],
                                            style: subtitleTextStyle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,),
                                      ),*/
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey[300],
                                              height: 20,
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(
                                                    LineIcons.heart,
                                                    size: 18,
                                                    color: Colors.orange,
                                                  ),
                                                  Text(
                                                    pb.dataByPlace[index]['loves']
                                                        .toString(),
                                                    style: textStylicon,
                                                  ),
                                                  SizedBox(
                                                    width: 30,
                                                  ),
                                                  Icon(
                                                    LineIcons.comment,
                                                    size: 18,
                                                    color: Colors.orange,
                                                  ),
                                                  Text(
                                                    pb.dataByPlace[index]['comments count']
                                                        .toString(),
                                                    style: textStylicon,
                                                  ),
                                                  Spacer(),
                                                  IconButton(
                                                      icon: Icon(
                                                        Icons.location_on,
                                                        size: 20,
                                                        color: Colors.orange,
                                                      ),
                                                      onPressed: () async {
                                                        /*print(pb.dataByPlace[index]['latitude'] );
                                            print(pb.dataByPlace[index]['longitude']);*/
                                                        openMapsSheet(
                                                            pb.dataByPlace[index]
                                                                        ['latitude']
                                                                as double,
                                                            pb.dataByPlace[index]['longitude']
                                                                as double);
                                                      }),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                final PlaceBloc pb =
                                    Provider.of<PlaceBloc>(context, listen: false);
                                pb.setCurrentPlace = pb.dataByPlace[index];
                                nextScreen(
                                    context,
                                    PlaceDetailsPage('featured$index' ));
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
        Center(
          child: DotsIndicator(
            dotsCount: 5,
            position: listIndex.toDouble(),
            decorator: DotsDecorator(
              color: Colors.black26,
              activeColor: Colors.black,
              spacing: EdgeInsets.only(left: 6),
              size: const Size.square(7.0),
              activeSize: const Size(25.0, 5.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
          ),
        )
      ],
    );
  }

  Padding featuredSlideItem(double w, int index, PlaceBloc pb,
      openMapsSheet(double lang, double lat), BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SizedBox(
        width: w,
        child: InkWell(
          child: Stack(
            children: <Widget>[
              Hero(
                tag: 'featured$index',
                child: Container(
                  height: 230,
                  width: w,
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10)),
                  child: cachedImage(pb.dataByPlace[index]['urls'][0], 10),
                ),
              ),
              Positioned(
                height: 120,
                width: w * 0.80,
                left: w * 0.05,
                bottom: 15,
                child: Container(
                  //margin: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey[200],
                            offset: Offset(0, 2),
                            blurRadius: 2)
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            pb.dataByPlace[index]['place name'],
                            style: textStyleFeaturedtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                pb.dataByPlace[index]['location'],
                                style: subtitleTextStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.grey[300],
                          height: 20,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                LineIcons.heart,
                                size: 18,
                                color: Colors.orange,
                              ),
                              Text(
                                pb.dataByPlace[index]['loves'].toString(),
                                style: textStylicon,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Icon(
                                LineIcons.comment,
                                size: 18,
                                color: Colors.orange,
                              ),
                              Text(
                                pb.dataByPlace[index]['comments count']
                                    .toString(),
                                style: textStylicon,
                              ),
                              Spacer(),
                              IconButton(
                                  icon: Icon(
                                    Icons.location_on,
                                    size: 20,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () async {
                                    openMapsSheet(
                                        pb.dataByPlace[index]['latitude']
                                            as double,
                                        pb.dataByPlace[index]['longitude']
                                            as double);
                                  }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            final PlaceBloc pb = Provider.of<PlaceBloc>(context);
            pb.setCurrentPlace = pb.dataByPlace[index];
            nextScreen(
                context,
                PlaceDetailsPage('featured$index' ));
          },
        ),
      ),
    );
  }
}
