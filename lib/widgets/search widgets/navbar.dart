import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/sign_in_bloc.dart';
import 'package:Hathante/pages/login%20screens/Sign_In_Page.dart';

import 'package:easy_localization/easy_localization.dart' as eb;
import 'package:Hathante/pages/search_pages/bookmark.dart';
import 'package:Hathante/pages/search_pages/home.dart';
import 'package:Hathante/pages/search_pages/profile.dart';

class NavBar extends StatefulWidget {
  NavBar({Key key}) : super(key: key);

  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int x = 0;
  bool isGust = false;
  @override
  void didChangeDependencies() {
    /* if (x <3){
        x++ ;
       final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false );
       sb.checkSignIn();
       setState(() {
          isGust = sb.guestUser ;
       });
      }*/

    super.didChangeDependencies();
  }

  Widget page =
      Directionality(textDirection: TextDirection.rtl, child: HomePage());
  int currentIndex = 0;

  whenBackButtonClicked() {
    if (currentIndex == 0) {
      SystemNavigator.pop();
    } else {
      setState(() {
        currentIndex = 0;
        page = HomePage();
      });
    }
  }

  Widget notSignedInNavBar() {
    return Container(
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(color: Colors.black12, blurRadius: 10)
      ]),
      child: BottomNavyBar(
        selectedIndex: currentIndex,
        showElevation: true,
        itemCornerRadius: 25,
        onItemSelected: (index) => setState(() {
          currentIndex = index;
          if (index == 0) {
            page = HomePage();
          } else if (index == 1 && context.locale == Locale('ar')) {
            page = Directionality(
                textDirection: TextDirection.rtl, child: SignInPage());
          } else if (index == 1 && context.locale == Locale('en')) {
            page = Directionality(
                textDirection: TextDirection.ltr, child: SignInPage());
          }
        }),
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.explore),
            title: Text('search'.tr()),
            activeColor: Colors.grey[900],
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.login),
            title: Text(
              'Sign In'.tr(),
            ),
            activeColor: Colors.grey[900],
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget customNavBar() {
    return Container(
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(color: Colors.black12, blurRadius: 10)
      ]),
      child: BottomNavyBar(
        selectedIndex: currentIndex,
        showElevation: true,
        itemCornerRadius: 25,
        onItemSelected: (index) => setState(() {
          currentIndex = index;
          if (index == 0 && context.locale == Locale('ar')) {
            page = Directionality(
                textDirection: TextDirection.rtl, child: HomePage());
          } else if (index == 0 && context.locale == Locale('en')) {
            page = Directionality(
                textDirection: TextDirection.ltr, child: HomePage());
          } else if (index == 1 && context.locale == Locale('ar')) {
            page = Directionality(
                textDirection: TextDirection.rtl, child: BookmarkPage());
          } else if (index == 1 && context.locale == Locale('en')) {
            page = Directionality(
                textDirection: TextDirection.ltr, child: BookmarkPage());
          } else if (index == 2) {
            page = ProfilePage();
          }
        }),
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.explore),
            title: Text('search'.tr()),
            activeColor: Colors.grey[900],
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.bookmark_border),
            title: Text(
              'favourite'.tr(),
            ),
            activeColor: Colors.grey[900],
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(LineIcons.user),
            title: Text("account".tr()),
            activeColor: Colors.grey[900],
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

 /* Widget customNavBarAdmin() {
    return Container(
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(color: Colors.black12, blurRadius: 10)
      ]),
      child: BottomNavyBar(
        selectedIndex: currentIndex,
        showElevation: true,
        itemCornerRadius: 25,
        onItemSelected: (index) => setState(() {
          currentIndex = index;
          if (index == 0) {
            page = HomePage();
          } else if (index == 1 && context.locale == Locale('ar')) {
            page = Directionality(
                textDirection: TextDirection.rtl, child: BookmarkPage());
          } else if (index == 1 && context.locale == Locale('en')) {
            page = Directionality(
                textDirection: TextDirection.ltr, child: BookmarkPage());
          } else if (index == 2) {
            page = ProfilePage();
          }
        }),
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.explore),
            title: Text('search'.tr()),
            activeColor: Colors.grey[900],
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.bookmark_border),
            title: Text(
              'favourite'.tr(),
            ),
            activeColor: Colors.grey[900],
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(LineIcons.user),
            title: Text('my account'.tr()),
            activeColor: Colors.grey[900],
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = Provider.of<SignInBloc>(context);
    return WillPopScope(
      onWillPop: () {
        return whenBackButtonClicked();
      },
      child: Scaffold(
          bottomNavigationBar:
              sb.guestUser ? notSignedInNavBar() : customNavBar(),
          body: page),
    );
  }
}
