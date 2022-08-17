import 'dart:io';
import 'package:Hathante/pages/login%20screens/splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/bookmark_bloc.dart';
import 'package:Hathante/blocs/comments_bloc.dart';
import 'package:Hathante/blocs/internet_bloc.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/popular_places_bloc.dart';
import 'package:Hathante/blocs/recent_places_bloc.dart';
import 'package:Hathante/blocs/recommanded_places_bloc.dart';
import 'package:Hathante/blocs/sign_in_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:toast/toast.dart';


void main() async{
 WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
    runApp(EasyLocalization( 
      supportedLocales: [Locale('ar') , Locale('en') ],
      path: 'assets/translations',
      fallbackLocale: Locale('ar'),
      startLocale:Locale('ar') ,
     // useOnlyLangCode: true,
      child: MyApp(),
    ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return MultiProvider(
      providers: [
                                     
        ChangeNotifierProvider<InternetBloc>(
          create: (context) => InternetBloc(),
        ),
        ChangeNotifierProvider<SignInBloc>(
          create: (context) => SignInBloc(),
        ),

        ChangeNotifierProvider<CommentsBloc>(
          create: (context) => CommentsBloc(),
        ),
        ChangeNotifierProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(),
        ),
        ChangeNotifierProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        ChangeNotifierProvider<PlaceBloc>(
          create: (context) => PlaceBloc(),
        ),
        ChangeNotifierProvider<PopularPlacesBloc>(
          create: (context) => PopularPlacesBloc(),
        ),
        ChangeNotifierProvider<RecentPlacesBloc>(
          create: (context) => RecentPlacesBloc(),
        ),
        ChangeNotifierProvider<RecommandedPlacesBloc>(
          create: (context) => RecommandedPlacesBloc(),
        ),
  
      ],
      child: MaterialApp(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily:  context.locale == Locale('ar')?'tajawal' : "Poppins", /*Muli */
        appBarTheme: AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          systemOverlayStyle :
              Platform.isAndroid ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
          textTheme: TextTheme(
              headline6: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontFamily:  context.locale == Locale('ar')?'tajawal' : "Muli")),
        )),
            debugShowCheckedModeBanner: false,
            home: SplashPage() 
            ),
    );
  }
}
