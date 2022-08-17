import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

//sort length
void openToast(context, message) {
  if (context != null) {
    ToastContext().init(context);
    Toast.show(message,
        textStyle: TextStyle(color: Colors.white),
        backgroundRadius: 20,
        duration: Toast.lengthShort);
  }
}

//long length
void openToast1(context, message) {
  if (context != null){
    ToastContext().init(context);
    Toast.show(message,
      textStyle: TextStyle(color: Colors.white),
      backgroundRadius: 20,
      duration: Toast.lengthLong);
  }
}
