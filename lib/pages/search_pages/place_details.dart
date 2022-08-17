
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/pages/search_pages/childewn_reg_form_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hathante/blocs/bookmark_bloc.dart';
import 'package:Hathante/blocs/comments_bloc.dart';
import 'package:Hathante/blocs/internet_bloc.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/sign_in_bloc.dart';
import 'package:Hathante/pages/search_pages/comments.dart';
import 'package:Hathante/utils/cached_image.dart';
import 'package:Hathante/utils/empty.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:Hathante/utils/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:easy_localization/easy_localization.dart' as es;

class PlaceDetailsPage extends StatefulWidget {
  final String tag;
  const PlaceDetailsPage(this.tag); //{Key key, @required this.placeName, this.location, this.timestamp, this.description,/* this.images,*/ this.tag, this.phone , this.website, this.places , this.instgram, this.services, this.whatsapp,}*/) : super(key: key);

  @override
  _PlaceDetailsPageState createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  List nearby = [];
  bool isMyNursery = false;
  var currentPlace;
  String services = "Loading...";
  String about = "Loading...";

  List images = [];

  PlaceBloc pb;
  CommentsBloc cb;
  SignInBloc ub;

  bool isRegistired = false;
  String registerDate = "";
  int x = 0;
 // final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
  List<Item> classes = [];

  String terms = "";

  @override
  void didChangeDependencies() {
    pb = Provider.of<PlaceBloc>(context, listen: false);
    cb = Provider.of<CommentsBloc>(context, listen: false);
    ub = Provider.of<SignInBloc>(context, listen: false);
    final sb = Provider.of<UserBloc>(context, listen: false);
    currentPlace = pb.currentPlace;
    Future.delayed(Duration.zero, () async {
      if (x < 5) {
        x++;
        var y = await FirebaseFirestore.instance
            .collection('places')
            .doc(currentPlace['timestamp'])
            .collection("appointment")
            .doc(sb.getUid)
            .get();
        if (y.data != null) {
          isRegistired = true;
          Map<String, dynamic> value = (await (FirebaseFirestore.instance
                  .collection('places')
                  .doc(currentPlace['timestamp'])
                  .collection("appointment")
                  .doc(sb.getUid)
                  .get()))
              .data();
          value != null ? registerDate = value['appotment date'] : null;
          setState(() {});
        }
      }
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((_) async {
      final PlaceBloc _pb = Provider.of<PlaceBloc>(context, listen: false);
      final BookmarkBloc _bb = Provider.of<BookmarkBloc>(context, listen: false);

      _pb.loveIconCheck(currentPlace['timestamp']);
      _bb.bookmarkIconCheck(currentPlace['timestamp']);
      _pb.getLovesAmount(currentPlace['timestamp']);
      _pb.getCommentsAmount(currentPlace['timestamp']);
      currentPlace = _pb.currentPlace;
      final translator = GoogleTranslator();
      List imagesUrl  = currentPlace['urls'] ??[];
     for(int i = 0 ; i <imagesUrl.length ; i++){
        images.add(cachedImage(imagesUrl[i]));
     }
      images.add(cachedImage(currentPlace['logo']));

      setState(() {
        isMyNursery =
            _pb.mySubscribedNurseriesId.contains(currentPlace['timestamp']);
      });

      try {
        if (context.locale == Locale('ar')) {
          for (int i = 0; i < currentPlace['classesAr'].length; i++) {
            final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
            classes.add(Item(data: {
              "class name": currentPlace['classesAr'][i]['class'],
              "class subjects": currentPlace['classesAr'][i]['subjects'],
              "tag key": _tagStateKey,
            }));
          }
          translator
              .translate(currentPlace['terms'], from: 'en', to: 'ar')
              .then((s) {
            terms = s.text;
            translator
                .translate(currentPlace['description'], from: 'en', to: 'ar')
                .then((s) {
              about = s.text;
              translator
                  .translate(currentPlace['services'], from: 'en', to: 'ar')
                  .then((s) async {
                services = s.text;
                setState(() {});
              });
            });
          });
        } else {
          for (int i = 0; i < currentPlace['classesEn'].length; i++) {
            final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
            classes.add(Item(data: {
              "class name": currentPlace['classesEn'][i]['class'],
              "class subjects": currentPlace['classesEn'][i]['subjects'],
              "tag key": _tagStateKey,
            }));
          }
          translator
              .translate(currentPlace['terms'], from: 'ar', to: 'en')
              .then((s) {
            terms = s.text;
            translator
                .translate(currentPlace['description'], from: 'ar', to: 'en')
                .then((s) {
              about = s.text;
              translator
                  .translate(currentPlace['services'], from: 'ar', to: 'en')
                  .then((s) async {
                services = s.text;
                setState(() {});
              });
            });
          });
        }
      } catch (e) {
        print(e);
      }
      setState(() {});
    });
  }

  handleSource(link) async {
    await launchUrl(link);
  }

  Widget cachedImage(imgUrl) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      imageBuilder: (context, imageProvider) => Container(
        height: 280,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Icon(
        LineIcons.image,
        size: 30,
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  handleLoveClick(timestamp) {
    final InternetBloc ib = Provider.of<InternetBloc>(context);
    final PlaceBloc pb = Provider.of<PlaceBloc>(context);
    ib.checkInternet();
    if (ib.hasInternet == false) {
      openToast(context, 'No internet available'.tr());
    } else {
      pb.loveIconClicked(timestamp);
    }
  }

  openMapsSheet(double lang, double lat) async {
    try {
      var coords = Coords(lang, lat);
      var availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: currentPlace['placeName'],
                        ),
                        title: Text(map.mapName),
                        leading: Image(
                          image: AssetImage(map.icon),
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  handleBookmarkClick(timestamp) async{
    final InternetBloc ib = Provider.of<InternetBloc>(context, listen: false);
    //final PlaceBloc pb = Provider.of<PlaceBloc>(context, listen: false);
    final BookmarkBloc bb = Provider.of<BookmarkBloc>(context, listen: false);
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      openToast(context, 'No internet available'.tr());
    } else {
      bb.bookmarkIconClicked(timestamp, context);
      bb.getPlaceData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.locale == Locale('ar')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: ub.guestUser ||
                currentPlace['children number'] == 0
            ? Container()
            : FloatingActionButton.extended(
                label: Text("سجل الآن".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700, /*fontFamily: 'Poppins'*/
                    )),
                onPressed: () {
                  nextScreen(
                      context,
                      ChildrenRegisterDilougPage(currentPlace['timestamp'],
                          terms, currentPlace['children number'], () {
                        Navigator.pop(context);
                        openToast(context, "done".tr());
                      },
                          context.locale == Locale('ar')
                              ? (currentPlace['classesAr'] as List).cast<Map>()
                              : (currentPlace['classesEn'] as List).cast<Map>(),
                          currentPlace['user email']));
                },
                icon: Icon(
                  Icons.login,
                ),
                isExtended: true,
              ),
        body: SingleChildScrollView(
          child: Column(
           // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Hero(
                    tag: widget.tag,
                    child: Container(
                      color: Colors.white,
                      child: Container(
                        height: 320,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Carousel(
                          dotBgColor: Colors.transparent,
                          showIndicator: true,
                          dotSize: 5,
                          dotSpacing: 15,
                          autoplayDuration: Duration(seconds: 10),
                          boxFit: BoxFit.cover,
                          images: images.isEmpty
                              ? [cachedImage(currentPlace['urls'][0])]
                              : images,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 15,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.9),
                      child: IconButton(
                        icon: Icon(
                          LineIcons.arrowLeft,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
                child: Column(
                  crossAxisAlignment: context.locale == Locale('en')
                                       ? CrossAxisAlignment.end :CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      //icons and location holder
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                     textDirection: context.locale != Locale('ar')?TextDirection.rtl  :TextDirection.ltr,
                      children: <Widget>[
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.location_on),
                            onPressed: () => openMapsSheet(
                                currentPlace['latitude'],
                                currentPlace['longitude'])),
                        currentPlace['instgram'] == null 
                            ? Container():
                         currentPlace['instgram']== "" 
                            ? Container()
                            : IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(FontAwesomeIcons.instagram),
                                onPressed: () async {
                                  Uri url =Uri.parse(currentPlace['instgram']);
                                  await launchUrl(url);
                                 
                                }),
                        currentPlace['whatsapp'].isEmpty
                            ? Container()
                            : IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(FontAwesomeIcons.whatsapp),
                                onPressed: () async {
                                  var url = "https://wa.me/?" +
                                      currentPlace['whatsapp'];
                                    Uri u = Uri.parse(url);
                                    await launchUrl(u);
                                }),
                                //TODO
                        Consumer<BookmarkBloc>(
                          builder: (context, bb , _) =>
                           IconButton(
                              icon:  bb.bookmarkIcon,
                              onPressed: () =>
                                  handleBookmarkClick(currentPlace['timestamp'])),
                        ),
                        isMyNursery
                            ? IconButton(
                                icon: Icon(Icons.star),
                                onPressed: () => openRateDiloug())
                            : Container(),
                        Spacer(),
                        Expanded(
                            child: Text(
                          currentPlace['location'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        )),
                        SizedBox(
                          width: 3,
                        ),
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ],//.reversed.toList(),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        currentPlace['place name'],
                        style: TextStyle(
                          
                          fontSize: 22,
                          fontWeight: FontWeight.w800, /*fontFamily: 'Poppins'*/
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 10),
                      height: 3,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                  

                        double.parse(currentPlace['rate'].toString()) == 0
                            ? Container()
                            // ignore: missing_required_param
                            : RatingBar.builder(
                                itemSize: 18,
                                initialRating: double.parse(
                                        (currentPlace['rate'] ?? 0.0)
                                            .toString()) ??
                                    3.6,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                //  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                              ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "نبذة".tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700, /*fontFamily: 'Poppins'*/
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Html(
                        
                          data: '''$about''',
                          defaultTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          customTextAlign: (x) {
                            return  context.locale == Locale('ar')? TextAlign.right: TextAlign.left;
                          }),
                    ),

                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "الخدمات".tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700, /*fontFamily: 'Poppins'*/
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Html(
                          data: '''${services}''',
                          defaultTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          customTextAlign: (x) {
                            return  context.locale == Locale('ar')? TextAlign.right: TextAlign.left;
                          }),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  

                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 5, top: 10, bottom: 10),
                      child: Row(
                        textDirection: context.locale == Locale('ar')? TextDirection.ltr :TextDirection.rtl ,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FlatButton(
                            onPressed: ub.guestUser
                                ? () {
                                    openToast(context, "قم بتسجيل الدخول".tr());
                                  }
                                : () {
                                    nextScreen(
                                        context,
                                        CommentsPage(
                                          title: 'User Reviews',
                                          timestamp: currentPlace['timestamp'],
                                        ));
                                  },
                            child: Text(
                              '<< عرض الكل'.tr(),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'comments'.tr(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                /*fontFamily: 'Poppins',*/ color:
                                    Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey[50],
                      height: 250,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: FutureBuilder(
                              future: cb.getData(
                                  currentPlace['timestamp'], 'places'),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List> snap) {
                                if (snap.connectionState ==
                                    ConnectionState.none)
                                  return emptyPage(
                                      Icons.signal_wifi_off, 'No Internet');
                                else {
                                  if (!snap.hasData)
                                    return Center(
                                        child: CircularProgressIndicator());
                                  if (snap.hasError)
                                    return emptyPage(Icons.error_outline,
                                        'something wrong!'.tr());
                                  if (snap.data.isEmpty)
                                    return emptyPage(
                                        Icons.mode_comment, 'no comments'.tr());

                                  List d = snap.data;
                                  d.sort((a, b) =>
                                      b['timestamp'].compareTo(a['timestamp']));

                                  return ListView.builder(
                                    padding: EdgeInsets.all(15),
                                    itemCount: snap.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          margin: EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black12),
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              radius: 25,
                                              backgroundColor: Colors.grey[200],
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      d[index]['image url']),
                                            ),
                                            title: Row(
                                              children: <Widget>[
                                                Text(
                                                  d[index]['name'],
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(d[index]['date'],
                                                    style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ],
                                            ),
                                            subtitle: Text(
                                              d[index]['comment'],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            onLongPress: () {
                                              //   handleDelete(d[index]['uid'], d[index]['timestamp']);
                                            },
                                          ));
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void openRateDiloug() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    double rate = sp.getDouble("rate") ?? 0;
    double initailRate = sp.getDouble("rate") ?? 0;
    bool rateBefore = sp.getBool("rate before") ?? false;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: RatingBar.builder(
              itemSize: 36,
              initialRating: rate,
              onRatingUpdate: (_rate) {
                setState(() {
                  rate = _rate;
                });
              },
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              //  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
            title: Text("Post Your Rate".tr()),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    if (rateBefore) {
                      await FirebaseFirestore.instance
                          .collection('places')
                          .doc(currentPlace['timestamp'])
                          .get()
                          .then((value) async {
                        await FirebaseFirestore.instance
                            .collection('places')
                            .doc(currentPlace['timestamp'])
                            .update({
                          "pepole rate":
                              (value['pepole rate'] ?? 0 - initailRate),
                          "pepole number": (value['pepole number'] - 1),
                          "rate": value['rate'] -
                              (value['pepole rate'] ?? 0 - initailRate) /
                                  (value['pepole number'] <= 2
                                      ? 1
                                      : value['pepole number'] - 1)
                        });
                      }).then((value) {
                        sp.setDouble("rate", 0);
                        sp.setBool("rate before", false);
                        openToast(context, "تم");
                        Navigator.pop(context);
                      });
                    } else {
                      sp.setDouble("rate", rate);
                      sp.setBool("rate before", true);
                      await FirebaseFirestore.instance
                          .collection('places')
                          .doc(currentPlace['timestamp'])
                          .get()
                          .then((value) async {
                        await FirebaseFirestore.instance
                            .collection('places')
                            .doc(currentPlace['timestamp'])
                            .update({
                          "pepole rate": (value['pepole rate'] + rate),
                          "pepole number": (value['pepole number'] + 1),
                          "rate": (value['pepole rate'] + rate) /
                              (value['pepole number'] + 1)
                        });
                      }).then((value) {
                        openToast(context, "done".tr());
                        Navigator.pop(context);
                      });
                    }
                  },
                  child:
                      Text(rateBefore ? 'remove last rate'.tr() : 'post'.tr()))
            ],
          );
        });
  }

 /* Widget _buildPanel(mainTilteTextStyle, _data) {
    return ExpansionPanelList(
      dividerColor: Theme.of(context).dividerColor.withOpacity(0.5),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((
        Item item,
      ) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
                title: Text(
              item.data['class name'].toString().tr(),
              style: mainTilteTextStyle,
              textAlign: TextAlign.right,
            ));
          },
          body: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tags(
                    key: item.data['tag key'],
                    itemCount: item.data['class subjects'].length, // required
                    itemBuilder: (int index) {
                      final _item = item.data['class subjects'][index];

                      return ItemTags(
                        activeColor: Theme.of(context).primaryColor,
                        key: Key(index.toString()),
                        index: index, // required
                        title: _item,
                        textStyle: TextStyle(
                          fontSize: 16,
                        ),
                        combine: ItemTagsCombine.withTextBefore,
                      );
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }*/
}

class NearbyPlaceItem extends StatelessWidget {
  const NearbyPlaceItem({
    Key key,
    @required this.w,
    @required this.rpb,
    this.index,
  }) : super(key: key);

  final double w;
  final rpb;
  final index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: <Widget>[
          Hero(
            tag: 'oooother$index',
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10)),
              height: 200,
              width: w * 0.35,
              child: cachedImage(rpb['urls'][0], 10),
            ),
          ),
          Positioned(
            right: 10,
            top: 15,
            height: 35,
            width: 80,
            child: FlatButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              color: Colors.grey[600].withOpacity(0.5),
              icon: Icon(
                LineIcons.heart,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                rpb['loves'].toString(),
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () {},
            ),
          ),
          Positioned(
            bottom: 30,
            left: 10,
            right: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(rpb['place name'],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
      onTap: () {
        final PlaceBloc pb = Provider.of<PlaceBloc>(context);
        pb.setCurrentPlace = rpb[index];
        nextScreen(context, PlaceDetailsPage('oooother$index'));
      },
    );
  }
}

class Item {
  Item({
    this.data,
    this.isExpanded = false,
  });

  Map data;
  bool isExpanded;
}

//REPO

     //start from here
    /*  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('You May Also Like', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                  
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 20),
                    height: 3,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40)),
                  ),
        
        Container(
                  height: 205,
                  width: w,
                  child: ListView.separated(
                    
                    scrollDirection: Axis.horizontal,
                    itemCount: pb.dataId.take(6).length,
                    separatorBuilder: (BuildContext context, int index){
                      return SizedBox(width: 10);
                    },
                    itemBuilder: (BuildContext context, int index) {                    
               return FutureBuilder<Map<String, dynamic>>(
                future: pb.findNyId(pb.dataId[index]),  
                builder: (BuildContext context, AsyncSnapshot snapshot) {

                    if (snapshot.connectionState == ConnectionState.done) {
                        print("snapshot.data['place name']");
                        return NearbyPlaceItem(w:w ,rpb:snapshot.data ,index : index );
                    } else {
                        return Center(child:CircularProgressIndicator() ,) ;
                    }
                }
            );
                    },
                  ),
                ),
                SizedBox(height: 20,)
      ],
    ),*/
  
/*class NearbyCards extends StatelessWidget {
  const NearbyCards({
    Key key,
    @required this.w,
    @required this.rpb,
  }) : super(key: key);

  final double w;
  final Map<dynamic, dynamic> rpb;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('You May Also Like', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                  
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 20),
                    height: 3,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40)),
                  ),
        
        Container(
                  height: 205,
                  width: w,
                  child: ListView.separated(
                    
                    scrollDirection: Axis.horizontal,
                    itemCount: rpb.take(6).length,
                    separatorBuilder: (BuildContext context, int index){
                      return SizedBox(width: 10);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return NearbyPlaceItem(w: w, rpb: rpb);
                      
                    },
                  ),
                ),


                SizedBox(height: 20,)
      ],
    );
  }
}*/