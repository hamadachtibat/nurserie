import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/pages/search_pages/more_places.dart';
import 'package:Hathante/pages/search_pages/place_details.dart';
import 'package:Hathante/utils/cached_image.dart';
import 'package:Hathante/utils/loading_animation.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class PopularPlaces extends StatelessWidget {
  PopularPlaces(this.ppb);
  final PlaceBloc ppb;

  @override
  Widget build(BuildContext context) {
    //  final PopularPlacesBloc ppb = Provider.of<PopularPlacesBloc>(context);

    double w = MediaQuery.of(context).size.width;

    return Column(
      children: <Widget>[
        Container(
          margin: context.locale == Locale('ar')
              ? const EdgeInsets.only(right: 15, top: 10, bottom: 10)
              : const EdgeInsets.only(left: 15, top: 10, bottom: 10),
          child: Row(
            children: <Widget>[
              Text(
                'top nursries'.tr(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    /*fontFamily: 'Poppins',*/ color: Colors.grey[800]),
              ),
              Spacer(),
              FlatButton(
                onPressed: () => nextScreen(
                    context, MorePlacesPage(title: 'top nursries'.tr())),
                child: Text(
                  'عرض الكل >>'.tr(),
                  style: TextStyle(color: Colors.grey),
                ),
              )
            ],
          ),
        ),
        Container(
          height: 200,
          width: w,
          child: ppb.data.isEmpty
              ? LoadingWidget1()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ppb.data.take(6).length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: context.locale == Locale('ar')
                          ? const EdgeInsets.only(right: 15, left: 15)
                          : EdgeInsets.only(left: 15),
                      child: InkWell(
                        child: Stack(
                          children: <Widget>[
                            Hero(
                              tag: 'Popular$index',
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10)),
                                height: 200,
                                width: w * 0.35,
                                child:
                                    cachedImage(ppb.data[index]['urls'][0], 10),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 15,
                              height: 35,
                              width: 80,
                              child: FlatButton.icon(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                ),
                                color: Colors.grey[600].withOpacity(0.5),
                                icon: Icon(
                                  LineIcons.heart,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: Text(
                                  ppb.data[index]['loves'].toString(),
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
                                  Text(ppb.data[index]['place name'],
                                      maxLines: 1,
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
                          ppb.setCurrentPlace = ppb.data[index];
                          nextScreen(context, PlaceDetailsPage('Popular$index'));
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
