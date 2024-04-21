import 'package:coffee_shop/firestorelogic/login/login_page_logic.dart';
import 'package:coffee_shop/pages/recoveryaccount/account_recovery_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/menupage/my_button.dart';
import '../../components/menupage/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginPageLogic _loginPageLogic = LoginPageLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.lock, size: 100),
              const SizedBox(height: 50),
              const Text(
                'Login a la Cafetería del Instituto',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: _loginPageLogic.emailController, // Usar el controlador de la lógica de inicio de sesión
                hintText: 'Email',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: _loginPageLogic.passwordController, // Usar el controlador de la lógica de inicio de sesión
                hintText: 'Contraseña',
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountRecoveryPage()),
                      );
                    },
                    child: Text(
                      '¿Olvidaste tu correo electrónico?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              MyButton(
                text: "Sign In",
                onTap: () => _loginPageLogic.signUserIn(context, widget.onTap),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 50),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // Método para restablecer la contraseña
  void _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Muestra un mensaje al usuario para verificar su correo electrónico
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Por favor, verifica tu correo electrónico'),
            content: Text('Se ha enviado un correo electrónico de restablecimiento de contraseña a $email'),
          );
        },
      );
    } catch (e) {
      // Maneja el error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  // Dentro de la página de recuperación de cuenta (AccountRecoveryPage)
  // void _sendRecoveryRequest(BuildContext context) {
  //   // Obtener el nombre completo y la fecha de nacimiento ingresados por el usuario
  //   String Name = _fullNameController.text;
  //   String dateOfBirth = _dateOfBirthController.text;

  //   // Implementar la lógica para buscar la cuenta asociada con la información proporcionada
  //   // y enviar la información de recuperación (por ejemplo, restablecimiento de contraseña).
  // }
}
