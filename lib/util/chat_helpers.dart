import 'package:fattafatt_rider/controller/auth_controller.dart';
import 'package:fattafatt_rider/data/model/response/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'app_constants.dart';

Socket socketConnection = io(AppConstants.SOCKET_URL, <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': true,
});

class  Sockets{
  Socket socket;
  bool isUserAdded = false;
  Sockets({@required this.socket}){
    debugPrint("Socket object is initialized:-> ${!this.socket.isBlank}");
  }


  bool sendMessageToUser({@required SendMessageFormat msg,@required Function onEmitAck,}){
    String messageText = '';
    if(msg.type==MessageType.TEXT){
      String msgAfterFirstHandel = msg.messageTextOrFilePath.replaceAll("\\", '\\\\');
      messageText = msgAfterFirstHandel?.replaceAll("'", "\\'");
    }

    if(socket.connected) {
      Map<String,dynamic>messageObject = {
        "type": "message",
        "order_id": msg.orderId,
        "chat_type" : msg.chatType==ChatType.CUSTOMER?'normal_chat':'support_chat',   // type = "normal_chat","support_chat";
        "user_type" : 'riders',	      //  user_type :"riders", "customers",'supports' connected user;
        "data": {
          "id" : 0,
          "message": messageText,
          "type": msg.type==MessageType.TEXT?'Text':'Image',
          "from_user_id": Get.find<AuthController>().profileModel.id,
          "from_user_name": "${Get.find<AuthController>().profileModel.fName??''} ${Get.find<AuthController>().profileModel.lName??''}".trim(),
          "order_id": msg.orderId,
          "file_path": msg.filePath,
          "duration": 0,
          "to_user_type" : msg.chatType==ChatType.CUSTOMER?'customers':'supports',   // to_user_type = "riders","customers","supports"   // receiving side ;
        }
      };
      String event = "sendMessage";
      debugPrint("Sending Message--->>>$messageObject");
      // socket.emit(event, [data],);
      socket.emitWithAck(event, [messageObject],ack: (ack){
        debugPrint("MessageSent callback---->>>$ack");
        if(ack!=null) {
          onEmitAck(ack);
        }
      });
      return true;
    }else{
      return false;
    }
  }

  void socketsConfiguration(){
    if(Get.find<AuthController>().profileModel!=null){

      if(!isUserAdded)
      {
        debugPrint("socketsConfiguration Started");
        socket.disconnect();
        socket.connect();
        socket.onError((data){
          isUserAdded = false;
        });
        socket.onConnectError((data)
        {
          isUserAdded = false;
          debugPrint("Exception in onConnectError: $data");
        });
        socket.onDisconnect((data) {
          isUserAdded = false;
          debugPrint("Socket onDisconnect called: $data");
        });
        socket.onConnect((data) {
          isUserAdded = true;
          debugPrint("Socket Connected with onConnect");
          socket.emitWithAck(
            "addUser",[
            {
              "userId": Get.find<AuthController>().profileModel.id,
              "user_type": "riders",
            }
          ],ack: (ack){
            debugPrint("addUser callback---->>>$ack");
          }
          );
        });
      }
    }
  }

  void onMessageReceiveListener(void Function({MessageModel receivedMessage}) onMessageReceived){
    print("onMessageReceiveListener is attached");
    socket.on('message', (data) {
      print("received Message:-> $data");
      Map<String,dynamic> receivedMessage = data['data'];
      MessageModel message = MessageModel(
        id: receivedMessage['id'],
        message: receivedMessage['message'],
        from_user_id: receivedMessage['from_user_id'],
        file_path: receivedMessage['file_path'],
        order_id: receivedMessage['order_id'],
        type: receivedMessage['type']=='Text'?MessageType.TEXT:MessageType.IMAGE,
        chat_type: receivedMessage['chat_type']=="normal_chat"?ChatType.CUSTOMER:ChatType.SUPPORT,
        created_at: DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
        isMyMessage: false,
      );
      onMessageReceived(receivedMessage: message);
    });
  }

  void disconnect() {
    if(socket.connected) {
      socket.disconnect();
    }
  }
  bool checkConnection(){
    return socket.connected;
  }

}

class SendMessageFormat{
  final String messageTextOrFilePath;
  final MessageType type;
  final ChatType chatType; // Normal or support
  final int fromUserId;
  final int orderId;
  final String filePath;
  SendMessageFormat({
    this.type,
    this.chatType,
    // this.toUserType,
    this.messageTextOrFilePath,
    this.filePath,
    this.fromUserId,
    this.orderId,
  });
}