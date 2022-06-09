import 'package:fattafatt_rider/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MessageType{TEXT,IMAGE}
enum ChatType{CUSTOMER,SUPPORT}

class MessageModel {

  int id;
  String message;
  int from_user_id;
  String file_path;
  int order_id;
  MessageType type;
  ChatType chat_type;
  String created_at;
  bool isMyMessage;

  MessageModel({
    this.id,
    this.message,
    this.from_user_id,
    this.file_path,
    this.order_id,
    this.type,
    this.chat_type,
    this.created_at,
    this.isMyMessage,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    debugPrint("${int.parse(json['from_user_id']??"0")}==${Get.find<AuthController>().profileModel.id}");
    id = json['id'];
    message = json['message'];
    from_user_id = int.parse(json['from_user_id']??'0');
    file_path = json['file_path'];
    order_id = int.parse(json['order_id']??"0");
    isMyMessage = int.parse(json['from_user_id']??"0")==Get.find<AuthController>().profileModel.id;
    type = json['type']=='Text'?MessageType.TEXT:MessageType.IMAGE;
    chat_type = json['chat_type']=="normal_chat"?ChatType.CUSTOMER:ChatType.SUPPORT;
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message'] = this.message;
    data['from_user_id'] = this.from_user_id;
    data['file_path'] = this.file_path;
    data['order_id'] = this.order_id;
    data['type'] = this.type;
    data['chat_type'] = this.chat_type;
    data['created_at'] = this.created_at;
    return data;
  }
}
