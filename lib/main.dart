
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'firebase_options.dart';

// ============================================================
// NOTIFICATION CHANNELS
// ============================================================

const String kOrderChannelId = 'orders_channel';
const String kOrderChannelName = 'Order Notifications';
const int kOrderNotificationId = 2001;

const String kChatChannelId = 'chat_channel';
const String kChatChannelName = 'Chat Notifications';

final FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const MethodChannel _notificationChannel =
    MethodChannel('food_go/notifications');

bool _openChatAfterLaunch = false;

// ============================================================
// APP ICON BADGE
// ============================================================

Future<void> updateAppBadge(int count) async {
  try {
    if (count > 0) {
      await AppBadgePlus.updateBadge(count);
      debugPrint('APP ICON BADGE UPDATED: $count');
    } else {
      await AppBadgePlus.updateBadge(0);
      debugPrint('APP ICON BADGE CLEARED');
    }
  } catch (e) {
    debugPrint('APP BADGE ERROR: $e');
  }
}

Future<void> clearAppBadge() async {
  try {
    await AppBadgePlus.updateBadge(0);
    debugPrint('APP ICON BADGE CLEARED');
  } catch (e) {
    debugPrint('CLEAR APP BADGE ERROR: $e');
  }
}

// ============================================================
// CREATE NOTIFICATION CHANNELS
// ============================================================

Future<void> _createNotificationChannels() async {
  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin == null) {
    return;
  }

  const AndroidNotificationChannel orderChannel =
      AndroidNotificationChannel(
    kOrderChannelId,
    kOrderChannelName,
    description:
        'Notifications for Food Go order updates.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  const AndroidNotificationChannel chatChannel =
      AndroidNotificationChannel(
    kChatChannelId,
    kChatChannelName,
    description:
        'Notifications for Food Go chat messages.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  await androidPlugin.createNotificationChannel(
    orderChannel,
  );

  await androidPlugin.createNotificationChannel(
    chatChannel,
  );

  await androidPlugin.requestNotificationsPermission();
}

// ============================================================
// LOCAL NOTIFICATION INITIALIZATION
// ============================================================

Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse:
        (NotificationResponse response) {
      debugPrint(
        'LOCAL NOTIFICATION TAP: ${response.payload}',
      );

      if (response.payload == 'chat_message') {
        clearAppBadge();
        _openChatScreen();
      }
    },
  );

  await _createNotificationChannels();

  final NotificationAppLaunchDetails? launchDetails =
      await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();

  if (launchDetails?.didNotificationLaunchApp == true) {
    final String? payload =
        launchDetails?.notificationResponse?.payload;

    debugPrint(
      'APP LAUNCHED FROM LOCAL NOTIFICATION: $payload',
    );

    if (payload == 'chat_message') {
      _openChatAfterLaunch = true;
    }
  }
}

// ============================================================
// BACKGROUND FCM MESSAGE
// ============================================================

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('==========================================');
    debugPrint('BACKGROUND FCM RECEIVED');
    debugPrint('DATA: ${message.data}');
    debugPrint('==========================================');

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
    );

    await _createNotificationChannels();

    final String type =
        message.data['type']?.toString() ?? '';

    if (type == 'chat_message') {
      await _showChatNotification(message);
      return;
    }

    if (type == 'status_update') {
      await _showOrderNotification(message);
      return;
    }
  } catch (e) {
    debugPrint(
      'Background FCM error: $e',
    );
  }
}

// ============================================================
// SHOW ORDER NOTIFICATION
// ============================================================

Future<void> _showOrderNotification(
    RemoteMessage message) async {
  try {
    final String status =
        message.data['status']?.toString() ?? 'Updated';

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

    final String title =
        '$emoji Order $status';

    final String shortOrderId =
        orderId.isNotEmpty
            ? orderId.substring(
                0,
                orderId.length > 6
                    ? 6
                    : orderId.length,
              )
            : '';

    final String body =
        shortOrderId.isNotEmpty
            ? 'Your order #$shortOrderId is now $status.'
            : 'Your order is now $status.';

    const AndroidNotificationDetails androidDetails =
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
    );

    await flutterLocalNotificationsPlugin.show(
      kOrderNotificationId,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
      ),
      payload: 'order_notification',
    );

    debugPrint(
      'ORDER NOTIFICATION SHOWN: $status',
    );
  } catch (e) {
    debugPrint(
      'Order notification error: $e',
    );
  }
}

// ============================================================
// SHOW CHAT NOTIFICATION
// ============================================================

Future<void> _showChatNotification(
    RemoteMessage message) async {
  try {
    final String senderName =
        message.data['senderName']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? message.data['senderName'].toString()
            : 'Food Go Support';

    final String messageText =
        message.data['messageText']?.toString() ?? '';

    final String body =
        messageText.length > 120
            ? '${messageText.substring(0, 120)}…'
            : messageText;

    // ----------------------------------------------------------
    // MESSAGE ID
    // ----------------------------------------------------------

    final String messageId =
        message.data['messageId']?.toString() ?? '';

    // ----------------------------------------------------------
    // BADGE COUNT FROM BACKEND
    // ----------------------------------------------------------

    final int badgeCount =
        int.tryParse(
              message.data['badgeCount']?.toString() ?? '',
            ) ??
            1;

    // ----------------------------------------------------------
    // APP ICON BADGE
    // ----------------------------------------------------------

    await updateAppBadge(badgeCount);

    // ----------------------------------------------------------
    // UNIQUE NOTIFICATION ID
    // ----------------------------------------------------------

    final int notificationId =
        messageId.isNotEmpty
            ? messageId.hashCode.abs()
            : DateTime.now()
                .millisecondsSinceEpoch
                .remainder(100000);

    // ----------------------------------------------------------
    // CHAT NOTIFICATION DETAILS
    // ----------------------------------------------------------

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      kChatChannelId,
      kChatChannelName,
      channelDescription:
          'Notifications for Food Go chat messages.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      autoCancel: true,

      // Notification number
      number: badgeCount,

      styleInformation:
          BigTextStyleInformation(
        body.isEmpty ? 'New message' : body,
      ),
    );

    // ----------------------------------------------------------
    // SHOW CHAT NOTIFICATION
    // ----------------------------------------------------------

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      '💬 $senderName',
      body.isEmpty ? 'New message' : body,
      NotificationDetails(
        android: androidDetails,
      ),
      payload: 'chat_message',
    );

    debugPrint(
      'CHAT NOTIFICATION SHOWN - BADGE COUNT: $badgeCount',
    );
  } catch (e) {
    debugPrint(
      'Chat notification error: $e',
    );
  }
}

// ============================================================
// SAVE USER FCM TOKEN
// ============================================================

Future<void> saveUserFCMToken({
  String? providedToken,
}) async {
  try {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint(
        'FCM TOKEN NOT SAVED: No logged-in user.',
      );
      return;
    }

    final String? token =
        providedToken ??
            await FirebaseMessaging.instance.getToken();

    if (token == null || token.isEmpty) {
      debugPrint(
        'FCM TOKEN NOT SAVED: Token is null/empty.',
      );
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

    debugPrint('==========================================');
    debugPrint('USER FCM TOKEN');
    debugPrint(token);
    debugPrint(
      'USER FCM TOKEN SAVED SUCCESSFULLY',
    );
    debugPrint('==========================================');
  } catch (e) {
    debugPrint(
      'USER FCM TOKEN SAVE ERROR: $e',
    );
  }
}

// ============================================================
// FCM INITIALIZATION
// ============================================================

Future<void> _initializeFCM() async {
  final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  final NotificationSettings permission =
      await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  debugPrint(
    'FCM AUTHORIZATION STATUS: '
    '${permission.authorizationStatus}',
  );

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // ----------------------------------------------------------
  // FOREGROUND
  // ----------------------------------------------------------

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      debugPrint('==========================================');
      debugPrint('FOREGROUND FCM RECEIVED');
      debugPrint('DATA: ${message.data}');
      debugPrint(
        'NOTIFICATION: ${message.notification?.title}',
      );
      debugPrint('==========================================');

      final String type =
          message.data['type']?.toString() ?? '';

      if (type == 'chat_message') {
        await _showChatNotification(message);
      } else if (type == 'status_update') {
        await _showOrderNotification(message);
      }
    },
  );

  // ----------------------------------------------------------
  // BACKGROUND -> TAP
  // ----------------------------------------------------------

  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {
      debugPrint(
        'NOTIFICATION OPENED: ${message.data}',
      );

      final String type =
          message.data['type']?.toString() ?? '';

      if (type == 'chat_message') {
        clearAppBadge();
        _openChatScreen();
      }
    },
  );

  // ----------------------------------------------------------
  // TERMINATED -> FCM TAP
  // ----------------------------------------------------------

  final RemoteMessage? initialMessage =
      await messaging.getInitialMessage();

  if (initialMessage != null) {
    debugPrint(
      'APP OPENED FROM FCM NOTIFICATION: '
      '${initialMessage.data}',
    );

    if (initialMessage.data['type'] ==
        'chat_message') {
      clearAppBadge();
      _openChatAfterLaunch = true;
    }
  }

  // ----------------------------------------------------------
  // TOKEN
  // ----------------------------------------------------------

  final String? token =
      await messaging.getToken();

  if (token != null) {
    await saveUserFCMToken(
      providedToken: token,
    );
  }

  // ----------------------------------------------------------
  // TOKEN REFRESH
  // ----------------------------------------------------------

  messaging.onTokenRefresh.listen(
    (String newToken) async {
      debugPrint(
        'FCM TOKEN REFRESHED',
      );

      await saveUserFCMToken(
        providedToken: newToken,
      );
    },
  );
}

// ============================================================
// AUTH STATE -> SAVE TOKEN AFTER LOGIN
// ============================================================

void _listenForAuthAndSaveToken() {
  FirebaseAuth.instance.authStateChanges().listen(
    (User? user) async {
      if (user == null) {
        debugPrint(
          'AUTH STATE: No logged-in user.',
        );
        return;
      }

      debugPrint(
        'AUTH STATE: User logged in: ${user.uid}',
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      await saveUserFCMToken();
    },
  );
}

// ============================================================
// NATIVE NOTIFICATION TAP
// ============================================================

Future<void> _checkNativeNotificationTap() async {
  try {
    final Map<dynamic, dynamic>? data =
        await _notificationChannel.invokeMethod(
      'getNotificationData',
    );

    if (data != null &&
        data['type']?.toString() ==
            'chat_message') {
      clearAppBadge();
      _openChatScreen();
    }
  } catch (e) {
    debugPrint(
      'Notification tap data error: $e',
    );
  }
}

// ============================================================
// OPEN CHAT SCREEN
// ============================================================

void _openChatScreen() {
  WidgetsBinding.instance.addPostFrameCallback(
    (_) {
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

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorage.init();

  // ----------------------------------------------------------
  // FIREBASE
  // ----------------------------------------------------------

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ----------------------------------------------------------
  // BACKGROUND FCM
  // ----------------------------------------------------------

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // ----------------------------------------------------------
  // LOCAL NOTIFICATIONS
  // ----------------------------------------------------------

  await _initializeLocalNotifications();

  // ----------------------------------------------------------
  // FCM
  // ----------------------------------------------------------

  await _initializeFCM();

  // ----------------------------------------------------------
  // AUTH TOKEN LISTENER
  // ----------------------------------------------------------

  _listenForAuthAndSaveToken();

  // ----------------------------------------------------------
  // STRIPE
  // ----------------------------------------------------------

  Stripe.publishableKey =
      'pk_test_51U61yA31XAVPYuneJXmxrdbRDy3ZSCoXAgoY2sVRcjZcJHj6UN0D5odYlGaaKHfjMQjOJRU8iKXZG1PQQNmqFCXS00ZxWIkS6Z';

  debugPrint(
    'Stripe publishable key initialized.',
  );

  await Stripe.instance.applySettings();

  // ----------------------------------------------------------
  // CART
  // --------------------------------------------------

  Get.put<CartController>(
    CartController(),
    permanent: true,
  );

  // ----------------------------------------------------------
  // APP
  // ----------------------------------------------------------

  runApp(
    const MyApp(),
  );

  // ----------------------------------------------------------
  // OPEN CHAT AFTER LAUNCH
  // ----------------------------------------------------------

  WidgetsBinding.instance.addPostFrameCallback(
    (_) {
      _checkNativeNotificationTap();

      if (_openChatAfterLaunch) {
        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            _openChatScreen();
          },
        );

        _openChatAfterLaunch = false;
      }
    },
  );
}

// ============================================================
// MY APP
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler:
            const TextScaler.linear(1.0),
      ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,

        // ----------------------------------------------------
        // LIGHT THEME
        // ----------------------------------------------------

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

        // ----------------------------------------------------
        // DARK THEME
        // ----------------------------------------------------

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

        // ----------------------------------------------------
        // HOME
        // ----------------------------------------------------

        home: const SplashScreen(),

        // ----------------------------------------------------
        // ROUTES
        // ----------------------------------------------------

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

