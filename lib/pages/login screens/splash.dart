import 'package:Hathante/blocs/bookmark_bloc.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/widgets/search%20widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blocs/sign_in_bloc.dart';
import 'wellcome.dart';
import 'package:firebase_core/firebase_core.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController _controller;
  nextPage() async {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    await sb.checkSignIn();
    var page = sb.isSignedIn == true || sb.guestUser == true
        ? NavBar()
        : WellComePage();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.forward();

    Future.delayed(Duration(milliseconds: 500)).then((value) async {
      await Firebase.initializeApp();
      await fetchAndSetData();
      nextPage();
    });
  }

  Future<void> fetchAndSetData() async {
    final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
    PlaceBloc pb = Provider.of<PlaceBloc>(context, listen: false);
    final BookmarkBloc bb = Provider.of<BookmarkBloc>(context, listen: false);
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);

    if (!sb.guestUser) {
      try {
        ub.isUserDataEmpty() ? await ub.getUserData() : null;
      } catch (e) {
        print(e);
      }
    }

    try {
      pb.lovedPlaces == null ? await pb.getLovedList() : null;
    } catch (e) {
      print(e);
    }
    try {
      if (pb.myNursries == null || pb.data == null || pb.dataByPlace == null) {
        await pb.getData();
      }
    } catch (e) {
      print(e);
    }

     if (!sb.guestUser) {
        try {
          bb.bookmarkedPlaces== null?  await bb.getBookmarkedList():null;
        } catch (e) {
          print(e);
        }
      }

    if (!sb.guestUser) {
      try {
        bb.placeData == null ? await bb.getPlaceData() : null;
      } catch (e) {
        print(e);
      }
    }

    await ub.getUserData();

    /*if (!sb.guestUser) {
        try {
          pb.getMyNurseriesActivitesNew();
        } catch (e) {
          print(e);
        }
      }*/
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child: Image.asset('assets/images/splash.jpeg'))
        /*  body: Center(
      child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: Image(
                image: AssetImage(Config().splashIcon),
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              )
            ),
    )*/
        );
  }
}
