import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserLogic {
  final User? user;

  UserLogic({this.user});

  Stream<DocumentSnapshot> getUserData() {
    if (user == null) {
      throw Exception('User is null');
    }
    return FirebaseFirestore.instance.collection('Users').doc(user!.uid).snapshots();
  }

  Future<void> createUserData(String uid, String email, String nombre, DateTime fechaNacimiento, String? imagePath) async {
    print('createUserData called');
    // Comprueba si el nombre y la fecha de nacimiento están completos
    if (nombre.isEmpty) {
      throw Exception('Por favor, completa tu nombre y fecha de nacimiento para continuar.');
    }

    // Comprueba si ya existe un documento con el mismo UID
    final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    if (doc.exists) {
      throw Exception('Ya existe un usuario con este UID');
    }

    String imageUrl = '';
    if (imagePath != null && File(imagePath).existsSync()) {
      // Sube la imagen a Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('user_images').child('$uid.jpg');
      await ref.putFile(File(imagePath));

      // Obtiene la URL de la imagen subida
      imageUrl = await ref.getDownloadURL();
    }

    // Crear referencia al documento del usuario
    final userRef = FirebaseFirestore.instance.collection('Users').doc(uid);

    // Crear subcolecciones 'historialpedidos' e 'historialrecargas'
    final historialPedidosRef = userRef.collection('historialpedidos');
    final historialRecargasRef = userRef.collection('historialrecargas');
    final favoritosRef = userRef.collection('favoritos');

    // Crear un documento "placeholder" en cada subcolección
    await historialPedidosRef.doc('placeholder').set({});
    await historialRecargasRef.doc('placeholder').set({});
    await favoritosRef.doc('placeholder').set({});

    await userRef.set({
      'nombre': nombre,
      'fecha_nacimiento': fechaNacimiento,
      'saldo': 0, // saldo se establece automáticamente a 0
      'image': imageUrl, // añade el campo de imagen
      'email': email, // añade el campo de correo electrónico
    }, SetOptions(merge: true));
  }

  void showProfileCompletionDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Completa tu perfil'),
            content: const Text('Por favor, completa tu perfil para continuar.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // La línea que redirige al usuario a la página de edición de perfil ha sido eliminada
                },
              ),
            ],
          );
        },
      );
    });
  }
}
