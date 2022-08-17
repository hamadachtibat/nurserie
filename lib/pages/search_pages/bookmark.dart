import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/bookmark_bloc.dart';
import 'package:Hathante/blocs/place_bloc.dart';

import 'package:Hathante/models/variables.dart';
import 'package:Hathante/pages/search_pages/place_details.dart';
import 'package:Hathante/utils/cached_image.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class BookmarkPage extends StatefulWidget {
  BookmarkPage({Key key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  BookmarkBloc bb;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((f) {
      bb = Provider.of<BookmarkBloc>(context, listen: false);
      setState(() {});
      //  bb.getPlaceData();
      //  bb.getBlogData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            // leading: Container(),
            backgroundColor: Colors.white,
            elevation: 1,
            systemOverlayStyle: Platform.isAndroid
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              "favourite".tr(),
              style: TextStyle(color: Colors.black),
            )),
        body: bb == null
            ? Container()
            : bb.placeData.length == 0
                ? Container(width: double.infinity, child: _emptyUI())
                : PlaceUI(),
      ),
    );
  }

  Widget _emptyUI() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image(
            height: 200,
            width: 200,
            image: AssetImage('assets/images/empty.png'),
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'لا يوجد'.tr(),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
          )
        ],
      ),
    );
  }
}

class PlaceUI extends StatelessWidget {
  const PlaceUI({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookmarkBloc bb = Provider.of<BookmarkBloc>(context);
    double w = MediaQuery.of(context).size.width;
    return ListView.builder(
      padding: EdgeInsets.only(left: 5, right: 5),
      itemCount: bb.placeData.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 375),
            child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                    child: InkWell(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.bottomRight,
                        height: 160,
                        width: w,
                        //color: Colors.cyan,
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                alignment: Alignment.topLeft,
                                height: 120,
                                width: w * 0.87,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.grey[200],
                                      blurRadius: 2,
                                      offset: Offset(5, 5),
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, left: 110),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        bb.placeData[index]['place name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: titleTextStyle,
                                      ),
                                      Text(
                                        bb.placeData[index]['location'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: subtitleTextStyle,
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 8, bottom: 20),
                                        height: 2,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            color: Colors.blueAccent,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[

                                          SizedBox(
                                            width: 20,
                                          ),
                                          Icon(
                                            LineIcons.comment,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            bb.placeData[index]
                                                    ['comments count']
                                                .toString(),
                                            style: textStylicon,
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 25,
                          left: 12,
                          child: Hero(
                            tag: 'bookmarkPlace$index',
                            child: Container(
                              height: 120,
                              width: 120,
                              child: cachedImage(
                                  bb.placeData[index]['urls'][0], 10),
                            ),
                          ))
                    ],
                  ),
                  onTap: () {
                    final PlaceBloc pb =
                        Provider.of<PlaceBloc>(context, listen: false);
                    pb.setCurrentPlace = bb.placeData[index];
                    nextScreen(context, PlaceDetailsPage('bookmarkPlace$index'));
                  },
                ))));
      },
    );
  }
}

class BlogUI extends StatelessWidget {
  const BlogUI({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookmarkBloc bb = Provider.of<BookmarkBloc>(context);
    return ListView.separated(
      padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 20),
      itemCount: bb.blogData.length,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 10,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 375),
            child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                    child: InkWell(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    height: 120,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              blurRadius: 10,
                              color: Colors.grey[200],
                              offset: Offset(2, 0))
                        ]),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                            flex: 2,
                            child: Hero(
                              tag: 'bookmarkReport$index',
                              child: Container(
                                  child: cachedImage(
                                      bb.blogData[index]['image url'], 10)),
                            )),
                        Flexible(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, top: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  bb.blogData[index]['title'],
                                  style: titleTextStyle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Spacer(),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.access_time,
                                        size: 16, color: Colors.grey),
                                    Text(
                                      bb.blogData[index]['date'],
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Spacer(),
                                    Icon(Icons.favorite,
                                        size: 18, color: Colors.grey),
                                    Text(
                                      bb.blogData[index]['loves'].toString(),
                                      style: textStylicon,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    /*   nextScreen(context, BlogDetailsPage(
                              title: bb.blogData[index]['title'],
                              description: bb.blogData[index]['description'],
                              imageUrl: bb.blogData[index]['image url'],
                              date: bb.blogData[index]['date'],
                              loves: bb.blogData[index]['loves'],
                              timestamp: bb.blogData[index]['timestamp'],
                              tag: 'bookmarkBlog$index',
                              userName: bb.blogData[index]['user name'],
                              place: bb.blogData[index]['place'] ,
                             images: [bb.blogData[index]['url'] ,bb.blogData[index]['url2'] , bb.blogData[index]['url3'] ,bb.blogData[index]['url4']],
                              ));*/
                  },
                ))));
      },
    );
  }
}
