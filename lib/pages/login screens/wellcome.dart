import 'package:Hathante/config/config.dart';
import 'package:Hathante/widgets/search%20widgets/loading_signin_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:Hathante/blocs/internet_bloc.dart';
import 'package:Hathante/blocs/sign_in_bloc.dart';
import 'package:Hathante/pages/login%20screens/login_screen.dart';
import 'package:Hathante/pages/login%20screens/success.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:Hathante/utils/snacbar.dart';
import 'package:Hathante/utils/toast.dart';
import 'package:easy_localization/easy_localization.dart';

class WellComePage extends StatefulWidget {
  WellComePage({Key key}) : super(key: key);

  _WellComePageState createState() => _WellComePageState();
}

class _WellComePageState extends State<WellComePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signInStart = false;
  String brandName;
  bool isLoading = false;
  final auth = FirebaseAuth.instance;


  void handleGoogleLogin() async {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false );
    final InternetBloc ib = Provider.of<InternetBloc>(context, listen: false);
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      openSnacbar(_scaffoldKey, 'No internet available'.tr());
    } else {
      setState(() {
        signInStart = true;
        brandName = 'google';
      });

      await sb.signInWithGoogle().then((_) {
        if (sb.hasError == true) {
          print(sb.errorCode);
          openToast1(context, 'Something is wrong. Please try again.'.tr());
          setState(() {
            signInStart = false;
          });
        } else {
          sb.checkUserExists().then((value) {
            if (sb.userExists == true) {
              sb.getUserData(sb.uid).then((value) => sb.saveDataToSP().then(
                  (value) => sb.setSignIn().then((value) =>
                      nextScreenReplace(context, SuccessPage()))));
            } else {
              sb.getJoiningDate().then((value) => sb.saveDataToSP().then(
                  (value) => sb.saveToFirebase().then((value) => sb
                      .setSignIn()
                      .then((value) =>
                          nextScreenReplace(context, SuccessPage())))));
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            signInStart == true
                ? Container()
                : TextButton(
                    onPressed: () => handleSkip(),
                    child: Text('تخطي'.tr(),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
          ],
          leading: IconButton(
              icon: Icon(Icons.language),
              onPressed: () async{
                if (context.locale == Locale('en')) {
                  print("done");
                  await context.setLocale(Locale('ar'));
                } else {
                  print("not done");
                  await context.setLocale(Locale('en'));
                }
              }),
        ),
        backgroundColor: Colors.white,
        body: signInStart == false ? welcomeUI() : loadingUI(brandName));
  }

  var selected = TextStyle(
      color: Colors.grey[900], fontWeight: FontWeight.bold, fontSize: 14);
  var unSelected = TextStyle(color: Colors.black, fontSize: 14);
  
  Widget welcomeUI() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Text(
              "welcome to".tr(),
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                context.locale == Locale('ar')? Config().appNameAr :Config().appNameEn,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 3,
              width: 100,
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(40)),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Text(
                'عبر هذا التطبيق يمكنك البحث بين العديد من الحضانات التي تتناسب معك و مع أطفالك, كما يتيح العديد من الحضانات التي تتناسب معك و مع أطفالك كما يتيح العديد من خيارات البحث التي تمكنك من الوصول إلى الحضانة المثالية لطفلك'
                    .tr()
                ,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600]),
              ),
            ),
            Spacer(),
            Container(
              height: 45,
              width: w * 0.70,
              child: FlatButton.icon(
                icon: Icon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                label: Text(
                  'تسجيل الدخول بجوجل'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16),
                ),
                color: Colors.grey[800],
                onPressed: () {
                  handleGoogleLogin();
                },
              ),
            ),
           
            SizedBox(
              height: 10,
            ),
            Container(
              height: 45,
              width: w * 0.70,
              child: FlatButton.icon(
                icon: Icon(
                  Icons.mail,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                label: Text(
                  'Sign in/up using email'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16),
                ),
                color: Colors.redAccent,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LoginScreen()));
                },
              ),
            ),
            SizedBox(
              height: h * 0.05,
            )
          ],
        ),
      ),
    );
  }

  handleSkip() {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false );
    sb.setGuestUserF();
    nextScreenReplace(context, SuccessPage());
  }
}
