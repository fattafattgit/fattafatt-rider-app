
import 'package:fattafatt_rider/controller/auth_controller.dart';
import 'package:fattafatt_rider/data/api/api_client.dart';
import 'package:fattafatt_rider/data/model/response/message_model.dart';
import 'package:fattafatt_rider/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';

class MessageRepo {
  final ApiClient apiClient;
  MessageRepo({@required this.apiClient});

  Future<Response> getMessagesList({@required ChatType chatType, @required int orderId}) async {
    return await apiClient.postData(
      AppConstants.MESSAGE_URI,
      {
        "order_id": orderId,
        'user_id': Get.find<AuthController>().profileModel.id,
        "chat_type": chatType==ChatType.CUSTOMER?"normal_chat":"support_chat",
      },
    );
  }
  Future<Response> uploadAndGetImageMessagePath({@required ChatType chatType, @required int orderId,@required XFile pickedFile}) async {
    return await apiClient.postMultipartData(
      AppConstants.SEND_IMAGE_IN_CHAT,
      {},
      [MultipartBody('file', pickedFile)],
    );
  }
}