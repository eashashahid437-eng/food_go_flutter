import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:food_go/Screens/splash_screen.dart';
import 'package:food_go/Controllers/cartcontroller.dart';

// Fixed notification ID - UserChatScreen mein bhi yehi ID use hoti hai,
// taake foreground/background/killed - har state mein sirf EK hi
// notification update hoti rahe, WhatsApp jaisa.
const int kChatNotificationId = 1001;

// Background isolate ke liye alag plugin instance
final FlutterLocalNotificationsPlugin
    _backgroundNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Agar chat message hai, to badge increment karo aur single updating
  // notification dikhao (app band ho tab bhi)
  if (message.data['type'] == 'chat_message') {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ---- Unread count Firestore se update/fetch karo (source of truth) ----
      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(user.uid);

      final chatDoc = await chatDocRef.get();

      int unreadCount = 1;
      if (chatDoc.exists) {
        unreadCount = (chatDoc.data()?['unreadAdminCount'] ?? 0) + 1;
      }

      await chatDocRef.set(
        {'unreadAdminCount': unreadCount},
        SetOptions(merge: true),
      );

      // ---- App icon badge update ----
      bool isSupported = await AppBadgePlus.isSupported();
      if (isSupported) {
        AppBadgePlus.updateBadge(unreadCount);
      }

      // ---- Local notification: WhatsApp jaisi single updating notification ----
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _backgroundNotificationsPlugin.initialize(initializationSettings);

      final String messageText =
          (message.data['text'] as String?)?.trim().isNotEmpty == true
              ? message.data['text']
              : (message.notification?.body ?? "You have a new message");

      final String displayBody =
          unreadCount > 1 ? "$unreadCount new messages" : messageText;

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'admin_chat_channel',
        'Admin Chat Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        onlyAlertOnce: false,
        styleInformation: BigTextStyleInformation(
          messageText,
          contentTitle: "FoodGo",
          summaryText: unreadCount > 1 ? "$unreadCount new messages" : null,
        ),
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _backgroundNotificationsPlugin.show(
        kChatNotificationId, // <-- Same fixed ID jo UserChatScreen mein use ho raha hai
        "FoodGo",
        displayBody,
        platformChannelSpecifics,
        payload: 'chat_notification',
      );
    } catch (e) {
      print("Background badge/notification update error: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- Lock Orientation to Portrait Only ----
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ---- Stripe setup ----
  Stripe.publishableKey = "pk_test_51U61yA31XAVPYuneJXmxrdbRDy3ZSCoXAgoY2sVRcjZcJHj6UN0D5odYlGaaKHfjMQjOJRU8iKXZG1PQQNmqFCXS00ZxWIkS6Z";
  await Stripe.instance.applySettings();

  Get.put<CartController>(CartController(), permanent: true);

  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("===== MY FCM TOKEN IS: $token =====");

    if (token != null) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
              'fcmToken': token,
              'tokenUpdatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    }
  } catch (e) {
    print("Error getting FCM token: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- Font size fix / Text scale override ----
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
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
        getPages: [GetPage(name: '/login', page: () => const LoginScreen())],
      ),
    );
  }
}
