import 'package:Hathante/widgets/search%20widgets/featured_places.dart';
import 'package:Hathante/widgets/search%20widgets/popular_places.dart';
import 'package:Hathante/widgets/search%20widgets/recent_places.dart';
import 'package:Hathante/widgets/search%20widgets/recommended_places.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/bookmark_bloc.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/sign_in_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:easy_localization/easy_localization.dart' as es;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Hathante/models/config.dart';
import 'package:Hathante/pages/search_pages/profile.dart';
import 'package:Hathante/pages/search_pages/search.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:Hathante/utils/toast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName, userEmail;
  String userProfilePic = '';
  int listIndex = 0;
  bool isLoading = false ;


  Widget searchBar(w) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 5),
      child: InkWell(
        child: Container(
          alignment: Alignment.centerLeft,
          height: 43,
          width: w,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[400], width: 0.5),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Icon(Icons.search),
                SizedBox(
                  width: 20,
                ),
                Text('أبحث عن الحضانات و أكتشف'.tr()),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchPage()));
        },
      ),
    );
  }

  Widget header(w) {
    final UserBloc ub = Provider.of<UserBloc>(context);
    print(ub.name);
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 10),
        child: SizedBox(
          height: 55,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    Config().appName.tr(),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[700]),
                  ),
                  Text(
                    // 'Explore ${Config().countryName}',
                    'دليل حضانات عمان'.tr(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600]),
                  )
                ],
              ),
              Spacer(),
              isLoading== true?CircularProgressIndicator() 
              :IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () async{
                  setState(() {
                    isLoading = true ;
                  });
                  await refresh();
                  setState(() {
                    isLoading = false ;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.place),
                onPressed: () async{
                  try {
                    final PlaceBloc pb = Provider.of<PlaceBloc>(context, listen: false);
                    await pb.getData();
                    await pb.getCountry();
                    await pb.filterByPlace(pb.lat, pb.lng, pb.location);
                    setState(() {
                   
                    });
                  } catch (e) {
                    openToast1(context, "error");
                    print(e);
                  }
                },
              ),
              InkWell(
                child: ub.imageUrl == null
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, size: 28),
                      )
                    : Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(ub.imageUrl),
                                fit: BoxFit.cover)),
                      ),
                onTap: () {
                  final SignInBloc ub =
                      Provider.of<SignInBloc>(context, listen: false);
                  if (ub.guestUser) {
                    openToast(context, "قم بتسجيل الدخول".tr());
                  } else {
                    nextScreen(context, ProfilePage(showBackButton : true));
                  }
                },
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    PlaceBloc pb = Provider.of<PlaceBloc>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        //backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Directionality(
                  textDirection: context.locale == Locale('ar')
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Column(
                    children: <Widget>[
                      header(w),
                      searchBar(w),
                      SizedBox(
                        height: 10,
                      ),
                      
                      pb.data==null? Container(child:CircularProgressIndicator() ,margin: EdgeInsets.all(20),)
                                    :Featured(pb),
                      pb.data==null?Container(child:CircularProgressIndicator() ,margin: EdgeInsets.all(20),)
                                    :PopularPlaces(pb),

                      pb.data==null?Container(child:CircularProgressIndicator() ,margin: EdgeInsets.all(20),)
                                  :RecentPlaces(pb),
                      pb.data==null?Container(child:CircularProgressIndicator() ,margin: EdgeInsets.all(20),)
                                  :RecommendedPlaces(pb)
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> refresh() async{
      final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
      PlaceBloc pb = Provider.of<PlaceBloc>(context, listen: false);
      final BookmarkBloc bb = Provider.of<BookmarkBloc>(context, listen: false);
      final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);

      if (!sb.guestUser) {
        try {
          await ub.getUserData();
        } catch (e) {
          print(e);
        }
      }

      try {
       await pb.getData();
      } catch (e) {
        print(e);
      }
      try {
       await pb.getLovedList();
      } catch (e) {
        print(e);
      }

      if (!sb.guestUser) {
        try {
         await bb.getBookmarkedList();
        } catch (e) {
          print(e);
        }
      }

      if (!sb.guestUser) {
        try {
         await bb.getPlaceData();
        } catch (e) {
          print(e);
        }
      }

      /* try{
      bgb.getBookmarkedList();
    }catch(e){
      print(e);
    }

      if (!sb.guestUser) {
        try {
          pb.getMyNurseriesActivitesNew();
        } catch (e) {
          print(e);
        }
      }*/
      // bb.getBlogData();
  }
}
