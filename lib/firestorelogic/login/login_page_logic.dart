import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/pages/main/main_page.dart';
import 'package:coffee_shop/pages/perfil/perfil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPageLogic {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<int> navbarIndex = ValueNotifier<int>(0);

  Future<bool> checkUserProfile(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['nombre'] != null && data['email'] != null) {
        // El perfil del usuario está completo
        return true;
      }
    }
    // El perfil del usuario no está completo
    return false;
  }

  Future<void> signUserIn(BuildContext context, Function()? onTap) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      String email = emailController.text.trim();
      if (!RegExp(r"^[a-zA-Z0-9.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$").hasMatch(email)) {
        throw FirebaseAuthException(code: 'invalid-email', message: 'El correo electrónico proporcionado no es válido.');
      }
      print('Logging in as $email');
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text,
      );

      // Comprueba si el perfil del usuario está completo
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        bool isProfileComplete = await checkUserProfile(uid);
        if (isProfileComplete) {
          // Cambia el índice del BottomNavigationBar a la posición de la página de perfil
          navbarIndex.value = 2;
          // Navega a MainPage
          Navigator.pushNamed(context, '/main');
        } else {
          // Si el perfil no está completo, muestra un mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontró un perfil para este usuario.')));
        }

        if (onTap != null) {
          onTap();
        }
      }
    } on FirebaseAuthException catch (e) {
      showmessage(context, e.code);
    } catch (e) {
      // Maneja cualquier otra excepción que pueda ocurrir
      showmessage(context, e.toString());
    } finally {
      // Cerrar el diálogo después de un breve retraso para asegurarse de que se cierre el diálogo
      if (context != null && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo
      }
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        Navigator.of(context).pushReplacementNamed('/home'); // Navega de vuelta al menú
      } else {
        Navigator.of(context).pushNamed('/home'); // Navega de vuelta al menú
      }
    }
  }

  void showmessage(BuildContext context, String errorMessage) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: Text(errorMessage));
        });
  }

  void showErrorMessage(BuildContext context, String errorCode) {
    String errorMessage;
    switch (errorCode) {
      case 'invalid-email':
        errorMessage = 'El correo electrónico proporcionado no es válido.';
        break;
      case 'user-not-found':
        errorMessage = 'No se encontró un usuario con ese correo electrónico.';
        break;
      case 'wrong-password':
        errorMessage = 'La contraseña proporcionada es incorrecta.';
        break;
      // Añade más casos según sea necesario
      default:
        errorMessage = 'Ocurrió un error desconocido.';
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: Text(errorMessage));
        });
  }
}
