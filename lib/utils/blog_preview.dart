/*import 'dart:io';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';




showBlogPreview(context, title, description, date, imageUrl, loves, timestamp  ,place ,File title1 ,File title2 ,File title3 ,File title4 , {title1url , title2url , title3url , title4url} ) {
   List<dynamic> curoselImages = [] ;
   title1 != null ?  curoselImages.add(FileImage(title1)) : title1url.toString().length != null ?  curoselImages.add(NetworkImage(title1url)) :null ;
   title2 != null ?  curoselImages.add(FileImage(title2)) : title2url.toString().length != null ?  curoselImages.add(NetworkImage(title2url)) :null ;
   title3 != null ?  curoselImages.add(FileImage(title3)) : title3url.toString().length != null ?  curoselImages.add(NetworkImage(title3url)) :null ;
   title4 != null ? curoselImages.add(FileImage(title4))  : title4url.toString().length != null ?  curoselImages.add(NetworkImage(title4url)) :null ;
 
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            
            width: MediaQuery.of(context).size.width * 0.50,
            child: ListView(
              
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                  height: 350,
                  width: MediaQuery.of(context).size.width,
                  child:
                    imageUrl.toString().length != null ? Image(fit: BoxFit.cover, image: NetworkImage(imageUrl)) :Carousel(
                        dotBgColor: Colors.transparent,
                        showIndicator: true,
                        dotSize: 5,
                        dotSpacing: 15,

                        boxFit: BoxFit.cover,
                        images: curoselImages
                      )
                ),

                Positioned(
                  top: 10,
                  right: 20,
                  child: CircleAvatar(
                    child: IconButton(icon: Icon(Icons.close), onPressed:() => Navigator.pop(context) ),
                  ),
                )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                    Text(
                    title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 10),
                    height: 3,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent,
                      borderRadius: BorderRadius.circular(15)),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.favorite, size: 16, color: Colors.grey),
                      Text(loves.toString(), style: TextStyle(color: Colors.grey, fontSize: 13),),
                      SizedBox(width: 15,),
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      Text(date, style: TextStyle(color: Colors.grey, fontSize: 13),),
                      
                      SizedBox(width: 5,),

                      Icon(Icons.landscape, size: 16, color: Colors.grey),
                      Text(place, style: TextStyle(color: Colors.grey, fontSize: 13),),
                      SizedBox(width: 15,),
                      Icon(Icons.flag, size: 16, color: Colors.grey),

                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Html(
                      defaultTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600]),
                      data: '''$description'''),


                  ],
                  ),
                ),
                SizedBox(height: 20,),
                
              ],
            ),
          ),
        );
      });
}
*/