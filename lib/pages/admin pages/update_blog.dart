import 'dart:developer';
import 'dart:io';
import 'dart:math' as mth;
import 'package:Hathante/pages/admin%20pages/classes_curriclum_adding_screen.dart';
import 'package:Hathante/widgets/search%20widgets/map_screen.dart';
import 'package:Hathante/widgets/search%20widgets/user_image_picker2.dart';
import 'package:Hathante/widgets/search%20widgets/user_input_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Hathante/blocs/place_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/utils/next_screen.dart';
import 'package:Hathante/utils/toast.dart';
import 'package:translator/translator.dart';
import '../../utils/dialog.dart';
import '../../utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

class EditBlog extends StatefulWidget {
  EditBlog({
    Key key,
  }) : super(key: key);

  @override
  _UploadBlogState createState() => _UploadBlogState();
}

class _UploadBlogState extends State<EditBlog> {
  var formKey = GlobalKey<FormState>();
  var nurseryName = TextEditingController();
  var whatsAppCtrl = TextEditingController();
  var instgramLinkCtrl = TextEditingController();
  var placeCtrl = TextEditingController();
  var imageUrlCtrl = TextEditingController();
  var imageUrl2Ctrl = TextEditingController();
  var imageUrl3Ctrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  PlaceBloc pb;
  UserBloc ub;

  var descriptionCtrl = TextEditingController();
  var termCtrl = TextEditingController();
  var phoneNumberCtrl = TextEditingController();
  var servicesCtrl = TextEditingController();
  var tagsCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var classesCtrl = TextEditingController();

  List<Widget> imagesHolder = [];
  List<String> _items = [];

  List<File> imageFiles = [];
  List<String> pathsToBeRemoved = [];
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
  var url, url2, url3, url4, url5, url6, url7;
  String file, file2, file3, file4, file5, file6, file7;
  
  List urls ;
  List paths;

  Reference refa = FirebaseStorage.instance.ref().child('blog_image');
  List imag = [];
  String logoFileUrl = "";
  var childrenNumberCtrl = TextEditingController();
  List<String> classesAr = [];
  List<String> classesEn = [];
  List<String> _tempclasses = [];
  List<String> _finalTempClass = [];

  File logoFile;
  bool deleteLogo = false;
  String logoUrl;

  DocumentReference ref;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      ub = Provider.of<UserBloc>(context, listen: false);
      pb = Provider.of<PlaceBloc>(context, listen: false);
      ref = FirebaseFirestore.instance.collection('places')
          .doc(pb.currentPlace['timestamp']);
      logoUrl = pb.currentPlace['logo'];
      nurseryName.text = pb.currentPlace['place name'];
      whatsAppCtrl.text = pb.currentPlace['whatsapp'];
      instgramLinkCtrl.text = pb.currentPlace['instgram'];
      placeCtrl.text = pb.currentPlace['location'];
      descriptionCtrl.text = pb.currentPlace['description'];
      phoneNumberCtrl.text = pb.currentPlace['phone number'];
      servicesCtrl.text = pb.currentPlace['services'];
      termCtrl.text = pb.currentPlace['terms'] ?? "";
      childrenNumberCtrl.text = pb.currentPlace['children number'].toString();
      logoFileUrl = pb.currentPlace['logo file'];
      emailCtrl.text = pb.currentPlace['user email'];
      classesAr = (pb.currentPlace['classesAr'] as List).cast<String>();
      classesEn = (pb.currentPlace['classesEn']).cast<String>();
      if (context.locale == Locale('ar')) {
        _finalTempClass = classesAr;
        _tempclasses = classesAr;
      } else {
        _finalTempClass = classesEn;
        _tempclasses = classesEn;
      }
      urls = [...pb.currentPlace['urls']];
      paths = [...pb.currentPlace['paths']];
      for (int i = 0 ; i < mth.min(3, urls.length) ; i++){
        if (paths[i] == "url") {
          imageUrlCtrl.text = urls[i];
       }
      }

      _currentAddress = pb.currentPlace['latitude'].toString() +
          "," +
          pb.currentPlace['longitude'].toString();
      position = Position(
          latitude: (pb.currentPlace['latitude'] as double),
          longitude: (pb.currentPlace['longitude'] as double));

      for (int i = 0; i < urls.length ; i++){
        imageFiles.add(File("url"));
        imagesHolder.add(Row(
          children: [
            UserImagePicker2(
              File(""),
              (i) {},
              indexFunction,
              isUrl: true,
              initialImage: urls[i],
              removeOnQeue: removeOnQeue,
              path: paths[i],
              showDelete: true,
            ),
            SizedBox(
              width: 13,
            ),
          ],
        ));
        indexFunction++;
      }
      (pb.currentPlace['curriculum'] as List).forEach((element) {
        _items.add(element as String);
      });

   
      setState(() {});
    });
    super.initState();
  }

  Future translateData() async {
    if (_tempclasses == _finalTempClass) {
      return;
    }
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

  void handleSubmit() async {
    if (formKey.currentState.validate() && _currentAddress != "") {
      formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      try {
        await translateData();
        await getDate();
        await saveToDatabase();
        await uploadImages();
        if (deleteLogo) {
          await updateLogo();
        }
        await removeUrlImages();
        openDialog(context, 'done'.tr(), '');
        pb.currentPlace['urls'] = urls;
        pb.currentPlace['paths'] = paths;
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void getDate() {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd MMMM yy').format(now);
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      date = _date;
      timestamp = _timestamp;
    });
  }

  Future<void> uploadImages() async {    
     for (int i = 0; i < imageFiles.length; i++) {
      if (imageFiles[i] != null  ) {
        if (imageFiles[i].path != 'url'){
        file = (i + 1).toString() +
            ' - ' +
            DateTime.now().millisecondsSinceEpoch.toString() +
            ub.getUid.substring(0, 5) +
            '.jpg';
        paths.add(file);
        print(imageFiles[i]);
        TaskSnapshot uploadTask = await refa.child(file).putFile(imageFiles[i]);
        url =  await uploadTask.ref.getDownloadURL();
        urls.add(url);
      }
    }
     }
    await ref.update({
            'urls': urls,
            'paths': paths
      });

  }

  Future updateLogo() async {
    Reference logoRef = FirebaseStorage.instance.ref().child('logos');
    int randomValue = mth.Random().nextInt(1000);
    String logoPath = randomValue.toString() +
        DateTime.now().millisecondsSinceEpoch.toString() +
        "file";
    TaskSnapshot uploadTask = await logoRef.child(logoPath).putFile(logoFile);
    var urlLogo = await uploadTask.ref.getDownloadURL();
    ref.update({
      'logo': urlLogo,
      'logo file': DateTime.now().millisecondsSinceEpoch.toString() + "file",
    });
    logoRef.child(logoFileUrl).delete();
  }

  Future saveToDatabase() async {
    await ref.update({
      'user name': ub.name,
      'user email': emailCtrl.text,
      'uid': ub.getUid,
      'isEnabled': false,
      'phone number': phoneNumberCtrl.text,
      'place name': nurseryName.text,
      'image url': imageUrl == null ? url : imageUrl,
      'description': descriptionCtrl.text,
      'instgram': instgramLinkCtrl.text ?? "",
      'whatsapp': whatsAppCtrl.text ?? "",
      'services': servicesCtrl.text,
      'location': placeCtrl.text,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'date': date,
      'isShown': false,
      "curriculum": _items,
      'terms': termCtrl.text,
      "children number": int.parse(childrenNumberCtrl.text),
      "classesAr": ub.classWithSubjectsAr,
      "classesEn": ub.classWithSubjectsEn,
    });
  }




  Future removeUrlImages() async{
    for(int i = 0 ; i  <pathsToBeRemoved.length ; i++){
      await refa.child(pathsToBeRemoved[i]).delete();
    }
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

  void remove(
    int index,
  ) {
    setState(() {
      imageFiles.removeAt(index);
      imagesHolder.removeAt(index);
      if (indexFunction > -1) {
        indexFunction--;
      }
    });
  }

  void removeOnQeue(int index, String path) {
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
      print("All are nulls");
      return;
    }
    setState(() {
        pathsToBeRemoved.add(paths[index]);
        paths.removeAt(index);
        urls.removeAt(index);
        imageFiles[index] = null;
        imagesHolder[index] = Container();
    });
  }

  bool checkIFThereIsImage() {
    return getEffectiveLength() != 0;
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
                                indexFunction, showDelete: true),
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
                                  remove, indexFunction, showDelete: true),
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
          "طلب تعديل حضانة".tr(),
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
      ),
      key: scaffoldKey,
      body: pb == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.only(top: 0, bottom: 8, left: 8, right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey[300],
                      blurRadius: 10,
                      offset: Offset(3, 3))
                ],
              ),
              child: Form(
                  key: formKey,
                  child: ListView(
                    children: <Widget>[
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
                            'place name'.tr(), 'place name'.tr(), placeCtrl),
                        controller: placeCtrl,
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
                            "email".tr(), "email".tr(), emailCtrl),
                        controller: emailCtrl,
                        textAlign: TextAlign.end,
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
                      Text("الموقع الجغرافي".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w500, /*fontFamily: 'Poppins'*/
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
                      TextFormField(
                        decoration: inputDecoration(
                            "enter image link (optional)".tr(),
                            "enter image link (optional)".tr(),
                            imageUrl3Ctrl),
                        controller: imageUrl3Ctrl,
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
                                if (indexFunction < 7) {
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
                      Text("Logo".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14 /*fontFamily: 'Poppins'*/)),
                      SizedBox(
                        height: 5,
                      ),
                      Center(
                          child: UserImagePicker(
                        logoFunc,
                        delete: deleteT,
                        initialImage: logoUrl,
                      )),
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
                        decoration: inputDecoration('رقم الجوال'.tr(),
                            'رقم الجوال'.tr(), phoneNumberCtrl),
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
                        decoration: inputDecoration('رقم الواتساب'.tr(),
                            'رقم الواتساب'.tr(), whatsAppCtrl),
                        controller: whatsAppCtrl,
                        onChanged: (String value) {
                          setState(() {
                            place = value;
                          });
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: inputDecoration(
                            'instgram link', 'instgram link', instgramLinkCtrl),
                        controller: instgramLinkCtrl,
                        onChanged: (String value) {
                          setState(() {
                            place = value;
                          });
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
                                    child: ClassesAddition(true,
                                        temp: context.locale == Locale('ar')
                                            ? pb.currentPlace['classesAr']
                                            : pb.currentPlace['classesEn'])));
                          } else {
                            nextScreen(
                                context,
                                ClassesAddition(true,
                                    temp: context.locale == Locale('ar')
                                        ? pb.currentPlace['classesAr']
                                        : pb.currentPlace['classesEn']));
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios),
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
                                      descriptionCtrl.clear();
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
                            labelText: 'terms'.tr(),
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
                       "your request will be reviewed and in case of acceptance it will publish automatically".tr(),
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
                                    'send edit'.tr(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () {
                                    handleSubmit();
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

  void deleteT(bool state) {
    deleteLogo = state;
    setState(() {
      logoUrl = null;
    });
  }
}
