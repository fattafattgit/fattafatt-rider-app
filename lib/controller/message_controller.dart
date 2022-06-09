import 'package:fattafatt_rider/controller/auth_controller.dart';
import 'package:fattafatt_rider/data/api/api_checker.dart';
import 'package:fattafatt_rider/data/model/response/message_model.dart';
import 'package:fattafatt_rider/data/repository/message_repo.dart';
import 'package:fattafatt_rider/util/chat_helpers.dart';
import 'package:fattafatt_rider/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../main.dart';

class MessageController extends GetxController implements GetxService {
  final MessageRepo messageRepo;
  bool isImageUploading = false;
  MessageController({@required this.messageRepo});

  List<MessageModel> _messageList;
  MessageModel _messageModel;
  final ItemScrollController messageScrollController = ItemScrollController();


  MessageModel get message => _messageModel;
  List<MessageModel> get messageList => _messageList;

  void addMessageAndScrollToBottom({MessageModel messageToBeAdd}){
    _messageList.add(messageToBeAdd);
    messageScrollController.scrollTo(index: _messageList.length-1, duration: const Duration(milliseconds: 300));
    update();
  }

  bool sendMessageToSocket({String messageTextOrFilePath,int orderId,MessageType messageType,ChatType chatType,}){
    SendMessageFormat messageFormat = SendMessageFormat(
      type: messageType,
      chatType: chatType,
      messageTextOrFilePath: messageType==MessageType.TEXT? messageTextOrFilePath: null,
      filePath: messageType==MessageType.IMAGE? messageTextOrFilePath: null,
      orderId: orderId,
    );

    bool isSentToSocket = socketService.sendMessageToUser(msg: messageFormat, onEmitAck: (ack){
      debugPrint("Message Acknowledgement :-> $ack");
      if(ack!=null&&ack['status']){
        _messageList.add(
          MessageModel(
            id: ack["data"]["id"],
            message: messageType==MessageType.TEXT? messageTextOrFilePath:'',
            from_user_id: Get.find<AuthController>().profileModel.id,
            file_path: messageType==MessageType.IMAGE?messageTextOrFilePath:'',
            order_id: orderId,
            type: messageType,
            chat_type: chatType,
            created_at: DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
            isMyMessage: true,
          )
        );
        messageScrollController.scrollTo(index: _messageList.length-1, duration: const Duration(milliseconds: 20));
        update();
      }
    });
    if(!isSentToSocket){
      showCustomSnackBar("Failed to send message. Try again later,",isError: true);
    }
    return isSentToSocket;

  }
  Future<bool>sendImageMessage({XFile pickedFile,int orderId,ChatType chatType,})async{
    isImageUploading = true;
    update();
    Response response = await messageRepo.uploadAndGetImageMessagePath(
      pickedFile: pickedFile,
      chatType: chatType,
      orderId: orderId,
    );
    isImageUploading = false;
    if (response.statusCode == 200) {
      return sendMessageToSocket(
        messageTextOrFilePath: response.body['fileName'],
        chatType: chatType,
        orderId: orderId,
        messageType: MessageType.IMAGE,
      );
    } else {
      ApiChecker.checkApi (response);
      return false;
    }
  }

  Future<void> getMessagesList({int orderId,ChatType chatType}) async {
    _messageList = null;
    Response response = await messageRepo.getMessagesList(chatType: chatType, orderId: orderId);
    if (response.statusCode == 200) {
      _messageList = [];
      response.body.forEach((messageJson) => _messageList.add(MessageModel.fromJson(messageJson)));
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }
}