

import 'package:flutter/material.dart';

InputDecoration inputDecoration (hint, label, clearEvent, {showError}){
    return InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(),
                labelText: label,
                
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.only(right: 0, left: 10),
                suffixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey[300],
                  child: IconButton(icon: Icon(Icons.close, size: 15), onPressed: (){
                    clearEvent.clear();
                  }),
                ),
                  )
                
              );
              
  }
  ButtonStyle buttonStyle(Color color) {
  return ButtonStyle(
    padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15)),
      backgroundColor: MaterialStateProperty.resolveWith((states) => color),
      shape: MaterialStateProperty.resolveWith((states) =>
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))));
}
  TextStyle boldTextStyle (color){
    return  TextStyle(   
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: color
    );
  }

    TextStyle regSmallTextStyle (color){
    return  TextStyle(   
      fontSize: 12,
      color: color
    );
  }

    TextStyle regMedTextStyle (color){
    return  TextStyle(   
      fontSize: 14,
      color: color
    );
  }

      TextStyle regLargeTextStyle (color){
    return  TextStyle(   
      fontSize: 16,
      color: color
    );
  }
    TextStyle boldMedTextStyle (color){
    return  TextStyle(   
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: color
    );
  }

  TextStyle boldSmallTextStyle (color){
    return  TextStyle(   
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: color
    );
  }