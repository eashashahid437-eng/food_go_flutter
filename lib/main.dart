
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_go/Screens/BottomNavbar/message_screen.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:food_go/Screens/splash_screen.dart';
import 'package:food_go/Controllers/cartcontroller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

const String kOrderChannelId = 'orders_channel';
const String kOrderChannelName = 'Order Notifications';
const int kOrderNotificationId = 2001;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const MethodChannel _notificationChannel =
MethodChannel('food_go/notifications');

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
RemoteMessage message) async {
try {
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

```
if (message.data['type'] == 'status_update') {
  debugPrint(
    'BACKGROUND ORDER STATUS: ${message.data['status']}',
  );
}
```

} catch (e) {
debugPrint('Background FCM error: $e');
}
}

Future<void> _initializeOrderNotifications() async {
const AndroidInitializationSettings androidSettings =
AndroidInitializationSettings('@mipmap/ic_launcher');

const InitializationSettings settings =
InitializationSettings(
android: androidSettings,
);

await flutterLocalNotificationsPlugin.initialize(
settings,
);

const AndroidNotificationChannel orderChannel =
AndroidNotificationChannel(
kOrderChannelId,
kOrderChannelName,
description: 'Notifications for Food Go order updates.',
importance: Importance.max,
);

final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
flutterLocalNotificationsPlugin
.resolvePlatformSpecificImplementation<
AndroidFlutterLocalNotificationsPlugin>();

await androidPlugin?.createNotificationChannel(orderChannel);
}

Future<void> _showForegroundOrderNotification(
RemoteMessage message) async {
try {
final String status =
message.data['status']?.toString() ?? 'Updated';

```
final String orderId =
    message.data['orderId']?.toString() ?? '';

String emoji = '📦';

switch (status) {
  case 'Pending':
    emoji = '⏳';
    break;
  case 'Preparing':
    emoji = '👨‍🍳';
    break;
  case 'On the Way':
  case 'Out for Delivery':
    emoji = '🚴';
    break;
  case 'Delivered':
    emoji = '✅';
    break;
  case 'Cancelled':
    emoji = '❌';
    break;
}

final String title = '$emoji Order $status';

final String shortOrderId = orderId.isNotEmpty
    ? orderId.substring(
        0,
        orderId.length > 6 ? 6 : orderId.length,
      )
    : '';

final String body = shortOrderId.isNotEmpty
    ? 'Your order #$shortOrderId is now $status.'
    : 'Your order is now $status.';

final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
  kOrderChannelId,
  kOrderChannelName,
  channelDescription:
      'Notifications for Food Go order updates.',
  importance: Importance.max,
  priority: Priority.high,
  playSound: true,
  enableVibration: true,
  autoCancel: true,
  styleInformation: BigTextStyleInformation(body),
);

await flutterLocalNotificationsPlugin.show(
  kOrderNotificationId,
  title,
  body,
  NotificationDetails(
    android: androidDetails,
  ),
  payload: 'order_notification',
);
```

} catch (e) {
debugPrint('Order notification error: $e');
}
}

Future<void> _initializeFCM() async {
final FirebaseMessaging messaging =
FirebaseMessaging.instance;

await messaging.requestPermission(
alert: true,
badge: true,
sound: true,
provisional: false,
);

FirebaseMessaging.onMessage.listen(
(RemoteMessage message) async {
debugPrint(
'FOREGROUND FCM: ${message.data}',
);

```
  if (message.data['type'] == 'status_update') {
    await _showForegroundOrderNotification(message);
  }
},
```

);

FirebaseMessaging.onMessageOpenedApp.listen(
(RemoteMessage message) {
debugPrint(
'NOTIFICATION OPENED: ${message.data}',
);

```
  if (message.data['type'] == 'chat_message') {
    _openChatScreen();
  }
},
```

);

final RemoteMessage? initialMessage =
await messaging.getInitialMessage();

if (initialMessage != null) {
if (initialMessage.data['type'] == 'chat_message') {
Future.delayed(
const Duration(milliseconds: 700),
() {
_openChatScreen();
},
);
}
}

await _saveFCMToken();

messaging.onTokenRefresh.listen(
(String newToken) async {
await _saveFCMToken(newToken);
},
);
}

Future<void> _checkNativeNotificationTap() async {
try {
final Map<dynamic, dynamic>? data =
await _notificationChannel.invokeMethod(
'getNotificationData',
);

```
if (data != null &&
    data['type']?.toString() == 'chat_message') {
  Future.delayed(
    const Duration(milliseconds: 700),
    () {
      _openChatScreen();
    },
  );
}
```

} catch (e) {
debugPrint(
'Notification tap data error: $e',
);
}
}

void *openChatScreen() {
WidgetsBinding.instance.addPostFrameCallback(
(*) {
try {
Get.to(
() => const UserChatScreen(),
);
} catch (e) {
debugPrint(
'Unable to open chat screen: $e',
);
}
},
);
}

Future<void> _saveFCMToken([
String? providedToken,
]) async {
try {
final String? token =
providedToken ??
await FirebaseMessaging.instance.getToken();

```
if (token == null) {
  return;
}

final User? user =
    FirebaseAuth.instance.currentUser;

if (user == null) {
  return;
}

await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set(
  {
    'fcmToken': token,
    'tokenUpdatedAt':
        FieldValue.serverTimestamp(),
  },
  SetOptions(merge: true),
);
```

} catch (e) {
debugPrint(
'FCM token save error: $e',
);
}
}

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

await SystemChrome.setPreferredOrientations([
DeviceOrientation.portraitUp,
DeviceOrientation.portraitDown,
]);

await GetStorage.init();

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

FirebaseMessaging.onBackgroundMessage(
_firebaseMessagingBackgroundHandler,
);

await _initializeOrderNotifications();

await _initializeFCM();

Stripe.publishableKey =
"pk_test_51U61yA31XAVPYuneJXmxrdbRDy3ZSCoXAgoY2sVRcjZcHj6UN0D5odYlGaaKHfjMQjOJRU8iKXZG1PQQNmqFCXS00ZxWIkS6Z";

await Stripe.instance.applySettings();

Get.put<CartController>(
CartController(),
permanent: true,
);

runApp(
const MyApp(),
);

WidgetsBinding.instance.addPostFrameCallback(
(_) {
_checkNativeNotificationTap();
},
);
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MediaQuery(
data: MediaQuery.of(context).copyWith(
textScaler: const TextScaler.linear(1.0),
),
child: GetMaterialApp(
debugShowCheckedModeBanner: false,
theme: ThemeData(
brightness: Brightness.light,
scaffoldBackgroundColor: Colors.white,
colorScheme: ColorScheme.fromSeed(
seedColor: Colors.red,
),
appBarTheme: const AppBarTheme(
backgroundColor: Colors.white,
foregroundColor: Colors.black,
),
),
darkTheme: ThemeData(
brightness: Brightness.dark,
scaffoldBackgroundColor: Colors.black,
colorScheme: ColorScheme.fromSeed(
seedColor: Colors.red,
brightness: Brightness.dark,
),
appBarTheme: const AppBarTheme(
backgroundColor: Colors.black,
foregroundColor: Colors.white,
),
),
themeMode: ThemeMode.light,
home: const SplashScreen(),
getPages: [
GetPage(
name: '/login',
page: () => const LoginScreen(),
),
],
),
);
}
}
