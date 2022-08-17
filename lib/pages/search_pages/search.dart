import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/models/variables.dart';
import 'package:Hathante/pages/search_pages/place_details.dart';
import 'package:Hathante/utils/cached_image.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String txt = 'حضانات مقترحة';
  var formKey = GlobalKey<FormState>();
  var textFieldCtrl = TextEditingController();

  Widget beforeSearchUI() {
    final PlaceBloc pb = Provider.of<PlaceBloc>(context);
    double w = MediaQuery.of(context).size.width;
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(left: 5, right: 5),
        itemCount: pb.data.take(6).length,
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
                                    padding: const EdgeInsets.only(
                                        top: 15, right: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          pb.data[index]['place name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: titleTextStyle,
                                        ),
                                        Text(
                                          pb.data[index]['location'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: subtitleTextStyle,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 8, bottom: 20),
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
                                            Icon(
                                              LineIcons.heart,
                                              size: 18,
                                              color: Colors.orangeAccent,
                                            ),
                                            Text(
                                              pb.data[index]['loves']
                                                  .toString(),
                                              style: textStylicon,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Icon(
                                              LineIcons.comment,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              pb.data[index]['comments count']
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
                              tag: 'suggestion$index',
                              child: Container(
                                height: 120,
                                width: 120,
                                child:
                                    cachedImage(pb.data[index]['urls'][0], 10),
                              ),
                            ))
                      ],
                    ),
                    onTap: () {
                      final PlaceBloc pb = Provider.of<PlaceBloc>(context);
                      pb.setCurrentPlace = pb.data[index];
                      nextScreen(context, PlaceDetailsPage('suggestion$index'));
                    },
                  ))));
        },
      ),
    );
  }

  Widget afterSearchUI() {
    final PlaceBloc pb = Provider.of<PlaceBloc>(context);
    double w = MediaQuery.of(context).size.width;
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(left: 5, right: 5),
        itemCount: pb.filteredData.length,
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
                                    padding: const EdgeInsets.only(
                                        top: 15, left: 110),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          pb.filteredData[index]['place name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: titleTextStyle,
                                        ),
                                        Text(
                                          pb.filteredData[index]['location'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: subtitleTextStyle,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 8, bottom: 20),
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
                                            Icon(
                                              LineIcons.heart,
                                              size: 18,
                                              color: Colors.orangeAccent,
                                            ),
                                            Text(
                                              pb.filteredData[index]['loves']
                                                  .toString(),
                                              style: textStylicon,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Icon(
                                              LineIcons.comment,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              pb.filteredData[index]
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
                              tag: 'filtered$index',
                              child: Container(
                                height: 120,
                                width: 120,
                                child: cachedImage(
                                    pb.filteredData[index]['urls'][0], 10),
                              ),
                            ))
                      ],
                    ),
                    onTap: () {
                      final PlaceBloc pb = Provider.of<PlaceBloc>(context);
                      pb.setCurrentPlace = pb.filteredData[index];
                      nextScreen(context, PlaceDetailsPage('filtered$index'));
                    },
                  ))));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlaceBloc pb = Provider.of<PlaceBloc>(context);
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 24,
            ),

            // search bar

            Container(
              alignment: Alignment.center,
              height: 65,
              width: w,
              decoration: BoxDecoration(
                  //color: Colors.white
                  ),
              child: Form(
                key: formKey,
                child: TextFormField(
                  autofocus: true,
                  controller: textFieldCtrl,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "أبحث و أكتشف".tr(),
                    hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500]),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      child: IconButton(
                        icon: Icon(
                          Icons.keyboard_backspace,
                          color: Colors.grey[800],
                        ),
                        color: Colors.grey[800],
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[800],
                        size: 25,
                      ),
                      onPressed: () {
                        setState(() {
                          textFieldCtrl.clear();
                        });
                      },
                    ),
                  ),

                  //keyboardType: TextInputType.datetime,

                  validator: (value) {
                    if (value.length == 0)
                      return ("لا يمكن ان تكون التعليقات فارغة".tr());

                    return value = null;
                  },
                  // onSaved: (String value) {},
                  onChanged: (String value) {
                    pb.afterSearch(value);
                  },
                ),
              ),
            ),

            Container(
              height: 1,
              child: Divider(
                color: Colors.grey,
              ),
            ),

            // suggestion text

            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
              child: Text(
                txt.tr(),
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),

            //afterSearchUI()
            pb.filteredData.isEmpty ? beforeSearchUI() : afterSearchUI()
          ],
        ),
      ),
    );
  }
}
