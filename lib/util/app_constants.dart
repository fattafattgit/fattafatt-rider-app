import 'package:audioplayers/audioplayers.dart';
import 'package:fattafatt_rider/data/model/response/language_model.dart';
import 'package:fattafatt_rider/util/images.dart';

AudioPlayer audioPlayer = AudioPlayer();
class AppConstants {
  static const String APP_NAME = 'Fattafatt Delivery';
  static int APP_VERSION = 0;

  /// Production Server
  // static const String BASE_URL = 'https://fattafatt.pk';
  // static const String  SOCKET_URL = "http://137.184.224.244:3000/";

  /// Development Server
  static const String BASE_URL = 'https://dev-fattafatt.tk';
  // static const String  SOCKET_URL = "https://socket.dev-fattafatt.tk/";
  // static const String  SOCKET_URL = "http://dev-fattafatt.tk:3000/";
  // static const String  SOCKET_URL = "http://143.198.188.141:4000/";
  static const String  SOCKET_URL = "http://dev-fattafatt.tk:4000/";


  static const String CONFIG_URI = '/api/v1/config';
  static const String FORGET_PASSWORD_URI = '/api/v1/auth/delivery-man/forgot-password';
  static const String VERIFY_TOKEN_URI = '/api/v1/auth/delivery-man/verify-token';
  static const String RESET_PASSWORD_URI = '/api/v1/auth/delivery-man/reset-password';
  static const String LOGIN_URI = '/api/v1/auth/delivery-man/login';
  static const String TOKEN_URI = '/api/v1/delivery-man/update-fcm-token';
  static const String CURRENT_ORDERS_URI = '/api/v1/delivery-man/current-orders?token=';
  static const String ALL_ORDERS_URI = '/api/v1/delivery-man/all-orders';
  static const String LATEST_ORDERS_URI = '/api/v1/delivery-man/latest-orders?token=';
  static const String RECORD_LOCATION_URI = '/api/v1/delivery-man/record-location-data';
  static const String PROFILE_URI = '/api/v1/delivery-man/profile?token=';
  static const String UPDATE_ORDER_STATUS_URI = '/api/v1/delivery-man/update-order-status';
  static const String UPDATE_PAYMENT_STATUS_URI = '/api/v1/delivery-man/update-payment-status';
  static const String ORDER_DETAILS_URI = '/api/v1/delivery-man/order-details?token=';
  static const String ACCEPT_ORDER_URI = '/api/v1/delivery-man/accept-order';
  static const String ACTIVE_STATUS_URI = '/api/v1/delivery-man/update-active-status';
  static const String UPDATE_PROFILE_URI = '/api/v1/delivery-man/update-profile';
  static const String NOTIFICATION_URI = '/api/v1/delivery-man/notifications?token=';

  // Shared Key
  static const String THEME = 'theme';
  static const String TOKEN = 'efood_multivendor_driver_token';
  static const String COUNTRY_CODE = 'country_code';
  static const String LANGUAGE_CODE = 'language_code';
  static const String USER_PASSWORD = 'user_password';
  static const String USER_ADDRESS = 'user_address';
  static const String USER_NUMBER = 'user_number';
  static const String USER_COUNTRY_CODE = 'user_country_code';
  static const String NOTIFICATION = 'notification';
  static const String NOTIFICATION_COUNT = 'notification_count';
  static const String IGNORE_LIST = 'ignore_list';
  static const String TOPIC = 'all_zone_delivery_man';
  static const String ZONE_TOPIC = 'zone_topic';
  static const String LOCALIZATION_KEY = 'X-localization';
  /// Chat Module
  // static const String MESSAGE_URI = '/api/v1/customer/message/get';
  static const String MESSAGE_URI = '/api/v1/messages/get-messages-data';
  static const String SEND_MESSAGE_URI = '/api/v1/customer/message/send';
  static const String SEND_IMAGE_IN_CHAT = '/api/v1/messages/send-file-in-chat';


  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.english, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    // LanguageModel(imageUrl: Images.arabic, languageName: 'Arabic', countryCode: 'SA', languageCode: 'ar'),
  ];
}
