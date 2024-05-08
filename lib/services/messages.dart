import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _onSelectNotification(String? payload, BuildContext context) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    // Muestra un diálogo con los detalles del pedido
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del pedido'),
          content: Text('Pedido ID: $payload'), // Aquí puedes mostrar más detalles sobre el pedido
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void setupMessaging(BuildContext context) {
    FirebaseMessaging.instance.getToken().then((String? token) {
      assert(token != null);
      print('Token FCM: $token');
      // Aquí debes enviar el token a tu servidor
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print('Nuevo token FCM: $token');
      // Aquí debes enviar el nuevo token a tu servidor
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Maneja el mensaje cuando la aplicación está en primer plano
      print('Mensaje recibido: ${message.notification?.body}');

      // Muestra una notificación local
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'your_channel_id',
                'your_channel_name',
                icon: android.smallIcon,
                // other properties...
              ),
            ));
      }
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('Mensaje en segundo plano: ${message.notification?.body}');
  }
}
