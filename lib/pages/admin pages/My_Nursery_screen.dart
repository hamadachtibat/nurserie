import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/pages/search_pages/comments.dart';
import 'package:Hathante/pages/admin%20pages/update_blog.dart';
import 'package:Hathante/pages/admin%20pages/upload_blog.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart' as es;

class MyNurseryScreen extends StatelessWidget {
  final bool showBack;
  MyNurseryScreen({Key key, this.showBack = false});

  navigateToCommentsPage(context, comment, timestamp2) {
    nextScreen(context, CommentsPage(title: 'المستخدم', timestamp: timestamp2));
  }

  @override
  Widget build(BuildContext context) {
    PlaceBloc  ab = Provider.of<PlaceBloc>(context);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Center(
              child: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 1,
                  brightness:
                      Platform.isAndroid ? Brightness.dark : Brightness.light,
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          ab.getData();
                          
                        }),
                  ],
                  leading:showBack
                      ? IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      : Container(),
                  title: Text(
                    "My Nurseries".tr(),
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.right,
                  )))),
      floatingActionButton: /*ab.myNursries.length == 0 ?*/ FloatingActionButton
          .extended(
              icon: Icon(Icons.add),
              onPressed: () {
                nextScreen(context, UploadBlog());
              },
              label: Text("أضف حضانتك".tr())) /*:Container()*/,
      body: ab == null
          ? Container()
          : Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey[300],
                      blurRadius: 10,
                      offset: Offset(3, 3))
                ],
              ),
              child: ab.myNursries.isEmpty
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.no_sim,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'No Data Available'.tr(),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ))
                  : ListView.separated(
                      //  padding: EdgeInsets.only(top: 50, bottom: 50),
                      itemCount: ab.myNursries.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 20,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        bool canEdit = false;
                        String editText = "";
                        String removeToDelete = "طلب حذف الحضانة";
                        if (ab.myNursries[index]['canEdit']) {
                          canEdit = true;
                          editText = "تعديل";
                        } else if (ab.myNursries[index]['requestToEdit']) {
                          editText = "تم الطلب";
                        } else {
                          editText = "طلب تعديل";
                        }

                        if (ab.myNursries[index]['requestToDelete'] ?? false) {
                          removeToDelete = "تم طلب الحذف";
                        }

                        return Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(6),
                          height: 255,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[200]),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 200,
                                width: 110,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            ab.myNursries[index]['urls'][0]))),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      ab.myNursries[index]['place name'],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.location_on,
                                            size: 20, color: Colors.grey),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(ab.myNursries[index]['location']),
                                        SizedBox(
                                          width: 2,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                   Column(children: [
                                            Text(ab.myNursries[index]
                                                    ['isEnabled']
                                                ? "تمت الموافقة"
                                                : "تحت المراجعة"),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                SizedBox(width: 10),
                                                InkWell(
                                                  child: Container(
                                                    height: 35,
                                                    width: 45,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.comment,
                                                          size: 16,
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                        Text(
                                                          ab.myNursries[index][
                                                                      'comments count']
                                                                  .toString() ??
                                                              "0",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[800],
                                                              fontSize: 13),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () =>
                                                      navigateToCommentsPage(
                                                          context,
                                                          ab.myNursries[index]
                                                              ['comment'],
                                                          ab.myNursries[index]
                                                              ['timestamp']),
                                                ),
                                                SizedBox(width: 10),
                                                InkWell(
                                                  onTap: () {
                                                    if (canEdit) {
                                                      ab.setCurrentPlace =
                                                          ab.myNursries[index];
                                                      nextScreen(
                                                          context, EditBlog());
                                                    } else if (!ab
                                                            .myNursries[index]
                                                        ['requestToEdit']) {
                                                      ab.requestEdit(
                                                          ab.myNursries[index]
                                                              ['timestamp']);
                                                      ab.getData();
                                                     
                                                    }
                                                  },
                                                  child: Container(
                                                      height: 35,
                                                      // width: 45,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 3,
                                                          ),
                                                          Icon(Icons.edit),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(editText.tr())
                                                        ],
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ]),
                                        Column(children: [
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                SizedBox(width: 10),
                                                InkWell(
                                                  onTap: () {
                                                    if (ab.myNursries[index][
                                                                'requestToDelete'] ==
                                                            null ||
                                                        !ab.myNursries[index][
                                                            'requestToDelete']) {
                                                      ab.requestDelte(ab
                                                          .myNursries[index]
                                                          .documentID);
                                                      ab.getData();
                                                     // setState(() {});
                                                    }
                                                  },
                                                  child: Container(
                                                      height: 35,
                                                      // width: 45,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 3,
                                                          ),
                                                          Icon(Icons.delete),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(removeToDelete
                                                              .tr())
                                                        ],
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ])
                                        

                                 
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    )),
    );
  }
}

