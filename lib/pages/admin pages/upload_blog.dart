import 'dart:math' as mth;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/widgets/search%20widgets/map_screen.dart';
import 'package:Hathante/widgets/search%20widgets/user_image_picker2.dart';
import 'package:Hathante/widgets/search%20widgets/user_input_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './classes_curriclum_adding_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:Hathante/utils/toast.dart';
import 'package:translator/translator.dart';
import '../../utils/dialog.dart';
import '../../utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' as eb;

class UploadBlog extends StatefulWidget {
  UploadBlog({Key key}) : super(key: key);

  @override
  _UploadBlogState createState() => _UploadBlogState();
}

class _UploadBlogState extends State<UploadBlog> {
  var formKey = GlobalKey<FormState>();
  var nurseryName = TextEditingController();
  var whatsAppCtrl = TextEditingController();
  var instgramLinkCtrl = TextEditingController();
  var placeCtrl = TextEditingController();
  var imageUrlCtrl = TextEditingController();
  var imageUrl2Ctrl = TextEditingController();
  var imageUrl3Ctrl = TextEditingController();
  var childrenNumberCtrl = TextEditingController();
  var termCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  var classesCtrl = TextEditingController();

  var descriptionCtrl = TextEditingController();
  var servicesCtrl = TextEditingController();
  var phoneNumberCtrl = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();
  File logoFile;
  List<String> classesAr = [];
  List<String> classesEn = [];
  List<String> _tempclasses = [];

  int state = 0; // 0 not loading 1 loading 2 save
  String _currentAddress = "";
  String urlData = "";
  Position position = Position(latitude: 0, longitude: 0);
  String imageUrl;
  String description;
  String date;
  String timestamp;
  String place;
  bool isImagesShown = false;
  int indexFunction = 0;
  bool isLoading = false;
  bool thumbnailIsEmpty = true;
  List<String> urls = [] ;
  List<String> paths =[] ;
 // var url, url2, url3, url4, url5, url6, url7;
//  String file, file2, file3, file4, file5, file6, file7;
  int counter = 0;
  var tagsCtrl = TextEditingController();
  DocumentReference ref;
  Reference refa = FirebaseStorage.instance.ref().child('blog_image');
  //List<Media> imag = [];
  UserBloc ub;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      ub = Provider.of<UserBloc>(context, listen: false);
    });
    super.initState();
  }

  void submitFn(String respoanse, int stateFn) {
    List<String> locationWithZoom = respoanse.split('@');
    List<String> locations = locationWithZoom[1].split(',');
    //isLoading = true ;
    setState(() {
      _currentAddress = locations[0].substring(0, locations[0].length - 3) +
          ',' +
          locations[1].substring(0, locations[0].length - 3);
      position = Position(
          latitude: double.parse(locations[0]),
          longitude: double.parse(locations[1]));
      state = stateFn;
    });

    urlData = respoanse;
  }

  bool validate() {
    return nurseryName.text.isNotEmpty &&
        placeCtrl.text.isNotEmpty &&
        emailCtrl.text.isNotEmpty &&
        (checkIFThereIsImage() || imageUrlCtrl.text.isNotEmpty) &&
        phoneNumberCtrl.text.isNotEmpty &&
        descriptionCtrl.text.isNotEmpty &&
        servicesCtrl.text.isNotEmpty &&
        termCtrl.text.isNotEmpty &&
        childrenNumberCtrl.text.isNotEmpty &&
        // classesCtrl.text.isNotEmpty &&
        logoFile != null &&
        // _items.length != 0 &&
        position.latitude != null &&
        position.longitude != null &&
        ub.classWithSubjectsAr.length != 0 &&
        ub.classWithSubjectsEn.length != 0;
  }

  Future handleSubmit() async {
    if (validate()) {
      formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
     try {
        await translateData();
        await getDate();
        await saveToDatabase();
        await uploadImages();
        await uploadLogo();
        openDialog(context, 'تم الإرسال'.tr(), '');
        clearTextFeilds();
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        // clearTextFeilds();
        setState(() {
          isLoading = false;
        });
        print("error "  + e.toString() );
        openToast(context, "something wrong!".tr());
      }
    } else {
      if (ub.classWithSubjectsAr.length == 0 ||
          ub.classWithSubjectsEn.length == 0) {
        openToast(context, "add classes and curriculum".tr());
      } else {
        openToast(context, "fill all fields".tr());
      }
    }
  }

  Future translateData() async {
    final translator = GoogleTranslator();
    if (context.locale == Locale('en')) {
      for (int i = 0; i < _tempclasses.length; i++) {
        Translation transle =
            await translator.translate(_tempclasses[i], from: 'en', to: 'ar');
        classesAr.add(transle.text);
      }
      classesEn = _tempclasses;
    } else {
      for (int i = 0; i < _tempclasses.length; i++) {
        Translation transle =
            await translator.translate(_tempclasses[i], from: 'ar', to: 'en');
        print(_tempclasses[i]);
        classesEn.add(transle.text);
      }
      classesAr = _tempclasses;
    }
  }

  bool checkIFThereIsImage() {
    return getEffectiveLength() != 0;
  }

  Future getDate() async {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd MMMM yy').format(now);
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      date = _date;
      timestamp = _timestamp;
    });
  }

  Future<void> uploadImages() async {
    int x = 0;
    for (int i = 0; i < imageFiles.length; i++) {
      if (imageFiles[i] != null) {
        await paths.add( (x + 1).toString() + ' - ' +timestamp +
            ub.getUid.substring(0, 5) +
            '.jpg');
        TaskSnapshot uploadTask = await refa.child(paths[x]).putFile(imageFiles[x]);
        await urls.add(await uploadTask.ref.getDownloadURL());
        x++;
      }
    }
     await ref.update({
            'urls': urls,
            'paths': paths
    });
  }

  Future<void> uploadLogo() async {
    Reference logoPath = FirebaseStorage.instance.ref().child('logos');
    int random = mth.Random().nextInt(1000);
    String logFile = random.toString() +
        ' - ' +
        timestamp +
        ub.getUid.substring(2, 5) +
        '.jpg';
    TaskSnapshot uploadTask = await logoPath.child(logFile).putFile(logoFile);
    String logoLink = await uploadTask.ref.getDownloadURL();
    await ref.update({'logo file': logFile, 'logo': logoLink});
  }

  Future saveToDatabase() async {
    ref = FirebaseFirestore.instance.collection('places').doc(timestamp);

    ref.set({
      'image-1': "",
      'url': "",
      'url2': "",
      'url3': "",
      'url4': "",
      'url5': "",
      'url6': "",
      'url7': "",
      'file': "",
      'file2': "",
      'file3': "",
      'file4': "",
      'file5': "",
      'file6': "",
      'file7': "",
      "paths" : [],
      "urls" : [],
      "logo": "",
      "logo file": "",
      "has account": true,
    });

    ref.collection("general").doc("today activity").set({
      "timestamp": 0,
      "today activity": "",
    });
    /*ref.collection("general").doc("food table ar").set({
      "friday": {"breakfast": "", "lunch": "", "snack": ""},
      "monday": {"breakfast": "", "lunch": "", "snack": ""},
      "saturday": {"breakfast": "", "lunch": "", "snack": ""},
      "sunday": {"breakfast": "", "lunch": "", "snack": ""},
      "thursday": {"breakfast": "", "lunch": "", "snack": ""},
      "tuesday": {"breakfast": "", "lunch": "", "snack": ""},
      "wednesday": {"breakfast": "", "lunch": "", "snack": ""},
    });*/

    /*ref.collection("general").doc("food table en").set({
      "friday": {"breakfast": "", "lunch": "", "snack": ""},
      "monday": {"breakfast": "", "lunch": "", "snack": ""},
      "saturday": {"breakfast": "", "lunch": "", "snack": ""},
      "sunday": {"breakfast": "", "lunch": "", "snack": ""},
      "thursday": {"breakfast": "", "lunch": "", "snack": ""},
      "tuesday": {"breakfast": "", "lunch": "", "snack": ""},
      "wednesday": {"breakfast": "", "lunch": "", "snack": ""},
    });*/

    await ref.update({
      'user name': ub.name,
      'user email': ub.email,
      'uid': ub.getUid,
      'rate': 0,
      'pepole rate': 0,
      'pepole number': 0,
      'phone number': phoneNumberCtrl.text,
      "comments count": "0",
      'isEnabled': false,
      'place name': nurseryName.text,
      //'image url': imageUrl == null ? url : imageUrl,
      'description': description,
      'instgram': instgramLinkCtrl.text ?? "",
      'whatsapp': whatsAppCtrl.text ?? "",
      'services': servicesCtrl.text,
      'location': placeCtrl.text,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'loves': 0,
      "curriculum": [],
      'date': date,
      'timestamp': timestamp,
      'canEdit': false,
      'requestToEdit': false,
      'requestToDelete': false,

      "classesAr": ub.classWithSubjectsAr,
      "classesEn": ub.classWithSubjectsEn,
      'daily images': [],
      "terms": termCtrl.text,
      "children number": int.parse(childrenNumberCtrl.text)
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(ub.getUid)
        .update({"nursery admin": timestamp});
  }

  clearTextFeilds() {
    imageFiles = [];
    imagesHolder = [];
    indexFunction = 0;
    _currentAddress = "";
    nurseryName.clear();
    whatsAppCtrl.clear();
    instgramLinkCtrl.clear();
    placeCtrl.clear();
    imageUrlCtrl.clear();
    descriptionCtrl.clear();
    servicesCtrl.clear();
    descriptionCtrl.clear();
    imageUrlCtrl.clear();
    setState(() {});
  }

  List<Widget> imagesHolder = [];
  List<File> imageFiles = [];

  void remove(int index) {
    int counter = 0;
    for (int i = 0; i < imageFiles.length; i++) {
      if (imageFiles[i] != null) {
        break;
      } else {
        counter++;
      }
    }
    if (counter >= imageFiles.length) {
      //all are null s
      return;
    }
    setState(() {
      imageFiles[index] = null;
      imagesHolder[index] = Container();
    });
  }

  int getEffectiveLength() {
    int length = 0;
    for (int i = 0; i < imageFiles.length; i++) {
      if (imageFiles[i] != null) {
        length++;
      }
    }
    return length;
  }

  void _openImagePickerModal() {
    final flatButtonColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Camera'.tr()),
                  onPressed: () async {
                    PickedFile pickedFile =
                        await ImagePicker.platform.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 75, //from 0 100
                      maxWidth: 720,
                    );
                    File pickedImage = File(pickedFile.path);
                    if (pickedImage != null) {
                      setState(() {
                        imageFiles.add(pickedImage);
                        imagesHolder.add(Row(
                          children: [
                            UserImagePicker2(imageFiles[indexFunction], remove,
                                indexFunction,
                                showDelete: true),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ));
                        if (indexFunction < 6) {
                          indexFunction++;
                        }
                        // _userImageFile4  = pickedImage;
                      });
                    } else {
                      openToast(context, "error while picking photo".tr());
                    }
                  },
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Gallery'.tr()),
                  onPressed: () async {
                    try {
                      PickedFile pickedFile =
                          await ImagePicker.platform.pickImage(
                        source: ImageSource.gallery,
                      );
                      File pickedImage = File(pickedFile.path);
                      if (pickedImage != null) {
                        setState(() {
                          imageFiles.add(pickedImage);
                          imagesHolder.add(Row(
                            children: [
                              UserImagePicker2(imageFiles[indexFunction],
                                  remove, indexFunction,
                                  showDelete: true),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          ));
                          if (indexFunction < 6) {
                            indexFunction++;
                          }
                        });
                      } else {
                        openToast(context, "error while picking photo".tr());
                      }
                    } catch (e) {
                      openToast(context, "error".tr());
                    }

                    //Navigator.pop(context);
                  },
                ),
                /*  FlatButton(
                    textColor: flatButtonColor,
                    child: Text('multiple images from gallery'.tr()),
                    onPressed: () async {
                      imag = await ImagesPicker.pick(count: 7, pickType:PickType.image, language: Language.English  );

                      setState(() {
                        imag.forEach((pickedImage) {
                            File image = File(pickedImage.path) ;
                            imageFiles.add(image);
                            imagesHolder.add(Row(
                              children: [
                                UserImagePicker2(
                                  image,
                                  remove,
                                  indexFunction,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                              ],
                            ));
                            indexFunction++;
                            setState(() {});
                          
                        });
                      });

                      Navigator.pop(context);
                    }),*/
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "طلب تقديم حضانة".tr(),
          style: TextStyle(
              /*fontFamily: 'Poppins',*/ fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.white),
        ),
      ),
      key: scaffoldKey,
      body: Container(
        padding: EdgeInsets.only(top: 0, bottom: 8, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[300], blurRadius: 10, offset: Offset(3, 3))
          ],
        ),
        child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: inputDecoration(
                      'nursery name'.tr(), 'name'.tr(), nurseryName),
                  controller: nurseryName,
                  textAlign: TextAlign.end,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty'.tr();
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      //  title = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: inputDecoration(
                      "place name".tr(), "place name".tr(), placeCtrl),
                  controller: placeCtrl,
                  textAlign: TextAlign.end,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty'.tr();
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      //  title = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration:
                      inputDecoration("email".tr(), "email".tr(), emailCtrl),
                  controller: emailCtrl,
                  textAlign: TextAlign.end,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty'.tr();
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      //  title = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text("الموقع الجغرافي".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500, /*fontFamily: 'Poppins'*/
                    )),
                OutlinedButton.icon(
                  onPressed: () {
                    nextScreen(context, FindOnMap(submitFn));
                  },
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 24.0,
                    color: Colors.blue,
                  ),
                  label: Text(_currentAddress == ""
                      ? "الموقع الجغرافي".tr()
                      : _currentAddress),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: inputDecoration(
                            "enter image link (optional)".tr(),
                            "enter image link (optional)".tr(),
                            imageUrlCtrl),
                        controller: imageUrlCtrl,
                        onChanged: (String value) {
                          setState(() {
                            imageUrl = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.image,
                        color: Colors.blue[300],
                      ),
                      onPressed: () {
                        setState(() {
                          if (getEffectiveLength() < 7) {
                            _openImagePickerModal();
                          } else {
                            openToast(context, "وصلت للحد الأقصى".tr());
                          }
                        });
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: imagesHolder,
                        )),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                TextFormField(
                  decoration: inputDecoration(
                      "enter image link (optional)".tr(),
                      "enter image link (optional)".tr(),
                      imageUrl2Ctrl),
                  controller: imageUrl2Ctrl,
                  textAlign: TextAlign.end,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty';
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      //  title = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: inputDecoration(
                      "enter image link (optional)".tr(),
                      "enter image link (optional)".tr(),
                      imageUrl2Ctrl),
                  controller: imageUrl2Ctrl,
                  textAlign: TextAlign.end,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty'.tr();
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      //  title = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Logo".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14 /*fontFamily: 'Poppins'*/)),
                SizedBox(
                  height: 5,
                ),
                Center(
                    child:
                        UserImagePicker(logoFunc, placeHolderFile: logoFile)),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration('children number'.tr(),
                      'children number'.tr(), childrenNumberCtrl),
                  controller: childrenNumberCtrl,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty'.tr();
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration(
                      'رقم الجوال'.tr(), 'رقم الجوال'.tr(), phoneNumberCtrl),
                  controller: phoneNumberCtrl,
                  onChanged: (String value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration(
                      'رقم الواتساب'.tr(), 'رقم الواتساب'.tr(), whatsAppCtrl),
                  controller: whatsAppCtrl,
                  onChanged: (String value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: inputDecoration('instgram link'.tr(),
                      'instgram link'.tr(), instgramLinkCtrl),
                  controller: instgramLinkCtrl,
                  onChanged: (String value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    if (context.locale == Locale('ar')) {
                      nextScreen(
                          context,
                          Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: ClassesAddition(false)));
                    } else {
                      nextScreen(context, ClassesAddition(false));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      textDirection: context.locale == Locale('en')
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      children: [
                        Icon(
                          context.locale == Locale('en')
                              ? Icons.arrow_back_ios
                              : Icons.arrow_forward_ios,
                        ),
                        Spacer(),
                        Text("add classes and curriculum".tr(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16 /*fontFamily: 'Poppins'*/)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'نبذة عن الحضانة'.tr(),
                      contentPadding: EdgeInsets.only(
                          right: 0, left: 10, top: 15, bottom: 5),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey[300],
                          child: IconButton(
                              icon: Icon(Icons.close, size: 15),
                              onPressed: () {
                                descriptionCtrl.clear();
                              }),
                        ),
                      )),
                  textAlignVertical: TextAlignVertical.top,
                  minLines: 10,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: descriptionCtrl,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty'.tr();
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      description = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'خدمات الحضانة'.tr(),
                      contentPadding: EdgeInsets.only(
                          right: 0, left: 10, top: 15, bottom: 5),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey[300],
                          child: IconButton(
                              icon: Icon(Icons.close, size: 15),
                              onPressed: () {
                                servicesCtrl.clear();
                              }),
                        ),
                      )),
                  textAlignVertical: TextAlignVertical.top,
                  minLines: 10,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: servicesCtrl,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty'.tr();
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      // description = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "terms".tr(),
                      contentPadding: EdgeInsets.only(
                          right: 0, left: 10, top: 15, bottom: 5),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey[300],
                          child: IconButton(
                              icon: Icon(Icons.close, size: 15),
                              onPressed: () {
                                termCtrl.clear();
                              }),
                        ),
                      )),
                  textAlignVertical: TextAlignVertical.top,
                  minLines: 10,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: termCtrl,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty'.tr();
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "your request will be reviewed and in case of acceptance it will publish automatically"
                      .tr(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        color: Theme.of(context).primaryColor,
                        height: 45,
                        child: FlatButton(
                            child: Text(
                              'send request'.tr(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: () async {
                              // clearTextFeilds();
                              await handleSubmit();
                              await Provider.of<PlaceBloc>(context,
                                      listen: false)
                                  .getData();
                            })),
                SizedBox(
                  height: 25,
                ),
              ],
            )),
      ),
    );
  }

  void logoFunc(File file) {
    setState(() {
      logoFile = file;
    });
  }
}

 /* Future<File> getImageFileFromAsset(var asset) async {
    final byteData = await asset.getByteData();
//final List<File> images = await ImagePicker.pickMultiImage(source: ImageSource.gallery);

    final file = File('${(await getTemporaryDirectory()).path}/${asset.name}');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }*/