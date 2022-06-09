import 'package:fattafatt_rider/util/dimensions.dart';
import 'package:flutter/material.dart';

extension ExtendedText on Widget {
  addBackGroundColorContainer({@required Color bgColor}){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions .PADDING_SIZE_EXTRA_SMALL,vertical: Dimensions .PADDING_SIZE_EXTRA_SMALL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius .circular(Dimensions.RADIUS_SMALL),
        color: bgColor,
      ),
      child: this,
    );
  }
}