import 'package:Hathante/blocs/sign_in_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/pages/admin%20pages/My_Nursery_screen.dart';
import 'package:Hathante/pages/search_pages/profile_edit.dart';
import 'package:Hathante/pages/search_pages/settings.dart';
import 'package:Hathante/pages/login%20screens/wellcome.dart';
import 'package:Hathante/utils/next_screen.dart';

class ProfilePage extends StatefulWidget {
  final bool showBackButton ;
  const ProfilePage({this.showBackButton = false});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserBloc ub;
  //PlaceBloc pb;
  SharedPreferences sp;
  var countryCtrl = TextEditingController();
  int x = 0;
  @override
  void didChangeDependencies() {
    if (x < 2) {
      x++;
      
      
      Future.delayed(Duration.zero, () async {
        await ub.getUserData();
        setState(() {});
      } );
      
    }
    super.didChangeDependencies();
  }

  void handleLogout() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'sign out?'.tr(),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Text('do you want to sign out'.tr()),
            actions: <Widget>[
              FlatButton(
                child: Text('yes'.tr()),
                onPressed: () async {
                  final SignInBloc ub =
                      Provider.of<SignInBloc>(context, listen: false);
                  final UserBloc uub =
                      Provider.of<UserBloc>(context, listen: false);

                  await auth.signOut().then((value) async {
                    await googleSignIn.signOut().then((value) {
                      ub.signOut();
                      uub.signOut();
                      clearAllData();
                      nextScreenCloseOthers(context, WellComePage());
                      // Navigator.pop(context);
                    });
                  });
                },
              ),
              FlatButton(
                child: Text('no'.tr()),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  @override
  Widget build(BuildContext context) {
    ub = Provider.of<UserBloc>(context, );
    PlaceBloc pb = Provider.of<PlaceBloc>(context,listen: false);
    return Scaffold(
        appBar: PreferredSize(
            child: Center(
              child: Directionality(
                textDirection: context.locale == Locale('ar')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: AppBar(
                  //leading: Container(),
                  centerTitle: false,
                  title: Text('my account'.tr(),
                      style: TextStyle(color: Colors.black)),
                  elevation: 1,
                  automaticallyImplyLeading: widget.showBackButton,
                  actions: <Widget>[
                    Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepPurpleAccent),
                          borderRadius: BorderRadius.circular(25)),
                      child: FlatButton.icon(
                          onPressed: () => handleLogout(),
                          icon: Icon(FontAwesomeIcons.arrowRightFromBracket),
                          label: Text('sign out'.tr())),
                    )
                  ],
                ),
              ),
            ),
            preferredSize: Size.fromHeight(60)),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 35,
          ),
          child: Directionality(
            textDirection: context.locale == Locale('ar')
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: ListView(
              children: <Widget>[
                ub.imageUrl == null
                    ? Container()
                    : CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.grey[800]),
                              color: Colors.grey[500],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      CachedNetworkImageProvider(ub.imageUrl),
                                  fit: BoxFit.cover)),
                        ),
                      ),
                Align(
                  heightFactor: 1.5,
                  child: FlatButton.icon(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      textColor: Colors.white,
                      color: Colors.blueAccent,
                      onPressed: () {
                     print(ub.imagePath + " inside prof");
                        nextScreen(
                            context,
                            ProfileEditPage(
                              imagePath: ub.imagePath,
                              imageUrl: ub.imageUrl,
                              name: ub.name,
                            ));
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                      ),
                      label: Text('edit account'.tr())),
                ),
                SizedBox(
                  height: 50,
                ),
                ListTile(
                  leading: Icon(LineIcons.user),
                  title: Text(
                    'الأسم'.tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    ub.name ?? "N/A",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Divider(
                  color: Colors.grey[500],
                ),
                ListTile(
                  leading: Icon(LineIcons.envelope),
                  title: Text(
                    'البريد الإليكتروني'.tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    ub.email ?? "N/A",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Divider(
                  color: Colors.grey[500],
                ),

                ListTile(
                  leading: Icon(LineIcons.flag),
                  title: Text(
                    "موقعك".tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    pb.country ?? "N/A",
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () async {
                    await pb.getCountry();
                    setState(() {});
                  },
                ),
                Divider(
                  color: Colors.grey[500],
                ),
                ListTile(
                  leading: Icon(LineIcons.language),
                  title: Text(
                    'lang'.tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  // subtitle: Text(ub.joiningDate, style: TextStyle(fontSize: 16),),
                  onTap: () {
                    if (context.locale == Locale('en')) {
                      print("done");
                      context.setLocale(Locale('ar')) ;
                    } else {
                      print("not done");
                      context.setLocale(Locale('en')) ;
                    }
                  },
                ),
                Divider(
                  color: Colors.grey[500],
                ),
                ListTile(
                  leading: Icon(Icons.more),
                  title: Text(
                    "معلومات عن التطبيق".tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    nextScreen(context, SettingsPage());
                  },
                ),
                Divider(
                  color: Colors.grey[500],
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.school),
                  title: Text(
                    "صاحب حضانة؟".tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    nextScreen(
                        context,
                        MyNurseryScreen(
                          showBack: true,
                        ));
                  },
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ));
  }
}
