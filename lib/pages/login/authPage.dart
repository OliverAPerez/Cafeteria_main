import 'package:coffee_shop/pages/main/main_page.dart';
import 'package:coffee_shop/pages/usuario/user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            // Verificar si el usuario es nuevo
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').doc(user.uid).snapshots(), // Utiliza el uid del usuario
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  // El usuario ya existe, mostrar la MainPage
                  return MainPage(navbarIndex: ValueNotifier<int>(0));
                } else {
                  // El usuario es nuevo, mostrar la UserPage
                  return UserPage(user: user);
                }
              },
            );
          } else {
            // No hay un usuario autenticado, mostrar la LoginPage
            return LoginPage(
              onTap: () {
                print('Inicio de sesión exitoso!');
              },
            );
          }
        },
      ),
    );
  }
}
