import 'package:cached_network_image/cached_network_image.dart';
import 'package:fattafatt_rider/controller/auth_controller.dart';
import 'package:fattafatt_rider/controller/message_controller.dart';
import 'package:fattafatt_rider/controller/splash_controller.dart';
import 'package:fattafatt_rider/data/model/response/message_model.dart';
import 'package:fattafatt_rider/util/dimensions.dart';
import 'package:fattafatt_rider/util/styles.dart';
import 'package:fattafatt_rider/view/base/custom_app_bar.dart';
import 'package:fattafatt_rider/view/base/my_text_field.dart';
import 'package:fattafatt_rider/view/base/no_data_screen.dart';
import 'package:fattafatt_rider/util/extention.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../main.dart';

class OrderChat extends StatefulWidget {
  final int orderId;
  final ChatType chatType;
  OrderChat({@required this.orderId,this.chatType});

  @override
  State<OrderChat> createState() => _OrderChatState();
}

class _OrderChatState extends State<OrderChat> {

  Size deviceSize;
  FocusNode _messageTextFieldFocusNode = FocusNode();
  TextEditingController _messageTextFieldController = TextEditingController();

  void _loadData() async {
    if(Get.find<AuthController>().profileModel == null) {
      await Get.find<AuthController>().getProfile();
    }

    await Get.find<MessageController>().getMessagesList(orderId: widget.orderId, chatType: widget.chatType);
    socketService.onMessageReceiveListener(({receivedMessage}) {
      if (mounted&&(ModalRoute.of(context)?.isCurrent??false)) {
      if(receivedMessage.order_id==widget.orderId){
        Get.find<MessageController>().addMessageAndScrollToBottom(
          messageToBeAdd: receivedMessage
        );
      }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    socketService.socketsConfiguration();
    _loadData();

  }



  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: widget.chatType==ChatType.CUSTOMER?'Customer':"Support", onBackPressed: () {
        Get.back();
      }),
      body: GetBuilder<MessageController>(builder: (messageController) {
        return Column(
          children: [
            Expanded(
                child: messageController.messageList != null ? messageController.messageList.length > 0 ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ScrollablePositionedList.builder(
                    itemCount: messageController.messageList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                          left: messageController.messageList[index].isMyMessage?deviceSize.width*.2:0,
                          right:messageController.messageList[index].isMyMessage?0:deviceSize.width*.2,
                          bottom: 5,
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: messageController
                                .messageList[index].isMyMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: messageController.messageList[index].isMyMessage
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  messageController.messageList[index].type==MessageType.TEXT?
                                  Flexible(child: _textMessage(messageController.messageList[index]))
                                  : Flexible(
                                      child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: Dimensions .PADDING_SIZE_EXTRA_SMALL,vertical: Dimensions .PADDING_SIZE_EXTRA_SMALL),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius .circular(Dimensions.RADIUS_SMALL),
                                            color: messageController.messageList[ index].isMyMessage
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).disabledColor,
                                          ),
                                          child:FittedBox(child: _imageMessage(messageController.messageList[index])),
                                      )),
                                ],
                              ),
                            ]),
                      );
                    },
                    itemScrollController: messageController.messageScrollController,
                    ),
                  ),
                ) : NoDataScreen(text: 'Chat is empty') :Center(child: CircularProgressIndicator()),
            ),
            messageController.messageList != null?
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              child: Row(
                children: [
                  messageController.isImageUploading?
                      Container(
                        height: GetPlatform.isMobile?deviceSize.width*.06:deviceSize.height*.05,
                        width:  GetPlatform.isMobile?deviceSize.width*.06:deviceSize.height*.05,
                        margin: const EdgeInsets.all(5.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ):
                  IconButton(
                    onPressed: (){
                      ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 75).then((XFile image) {
                        if(image!=null){
                          messageController.sendImageMessage(
                            pickedFile: image,
                            orderId: widget.orderId,
                            chatType: widget.chatType,
                          );
                        }
                      });
                    },
                    icon: Icon(Icons.image,color: Theme.of(context).primaryColor,),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey.shade200,)
                      ),
                      child: MyTextField(
                        hintText: 'Write message',
                        inputType: TextInputType.streetAddress,
                        focusNode: _messageTextFieldFocusNode,
                        controller: _messageTextFieldController,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: (){
                        String message = _messageTextFieldController.text.trim();
                        if(message.isNotEmpty){
                          if(_messageTextFieldFocusNode.hasFocus){
                            _messageTextFieldFocusNode.unfocus();
                          }
                          messageController.sendMessageToSocket(
                            messageTextOrFilePath: message,
                            orderId: widget.orderId,
                            messageType: MessageType.TEXT,
                            chatType: widget.chatType
                          );
                          _messageTextFieldController.clear();
                        }
                      },
                      icon: Icon(Icons.send,color: Theme.of(context).primaryColor,),
                  )
                ],
              ),
            )
                :const SizedBox(),
          ],
        );
      }),
    );
  }

  Widget _textMessage(MessageModel _message){
    return Align(
      alignment: (_message.isMyMessage?Alignment.topRight:Alignment.topLeft),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:  _message.isMyMessage
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor,
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${_message.message}".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).cardColor,
                )
            ),
            const SizedBox(height: 3,),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                    "${_message.created_at.substring(0,_message.created_at.length-3)}".tr,
                    style: robotoMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL, color: Theme.of(context).cardColor,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _imageMessage(MessageModel _message){
    return Stack(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 13,
          ),
          child:
          PinchZoomImage(
            image: CachedNetworkImage(
              key: Key("${_message.id}"),
              progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                  height: GetPlatform.isMobile?deviceSize.width*.8:deviceSize.height*.7,
                  width:  GetPlatform.isMobile?deviceSize.width*.8:deviceSize.height*.7,
                  child: Center(child: CircularProgressIndicator(value: downloadProgress.progress,backgroundColor: Colors.white,))),
              imageUrl: "${Get.find<SplashController>().configModel.baseUrls.chatImageUrl}/${_message.file_path}",
          ),
            zoomedBackgroundColor: Colors.transparent,
            hideStatusBarWhileZooming: false,
            onZoomStart: () {
              print('Zoom started');
            },
            onZoomEnd: () {
              print('Zoom finished');
            },
          ),
        ),
        Positioned(
          bottom: 1,
            right: 1,
            child: Text("${_message.created_at.substring(0,_message.created_at.length-3)}".tr, style: robotoMedium.copyWith(
              fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL, color: Theme.of(context).cardColor,
            )),
        ),
      ],
    );
  }

}
