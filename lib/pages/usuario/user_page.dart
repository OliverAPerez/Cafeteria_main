import 'dart:io';

import 'package:coffee_shop/firestorelogic/user/user_logic.dart';
import 'package:coffee_shop/pages/menu/menu_page.dart';
import 'package:coffee_shop/pages/perfil/perfil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UserPage extends StatefulWidget {
  final User? user;

  const UserPage({super.key, this.user});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? get user => widget.user;
  UserLogic? userLogic;
  final _formKey = GlobalKey<FormState>();
  String? nombre;
  DateTime? fechaNacimiento;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    userLogic = UserLogic(user: user);
  }

  void navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MenuPage(category: 'alguna-categoria')),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != fechaNacimiento) {
      setState(() {
        fechaNacimiento = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Perfil de Usuario'),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (imageFile != null)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.file(File(imageFile!.path)).image,
                      ),
                    ),
                  ),
                CupertinoButton(
                  onPressed: _pickImage,
                  child: const Text('Añadir foto'),
                ),
                CupertinoTextField(
                  placeholder: 'Nombre',
                  onChanged: (value) {
                    nombre = value;
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CupertinoTextField(
                      placeholder: 'Fecha de Nacimiento',
                      controller: TextEditingController(
                        text: fechaNacimiento != null ? DateFormat('dd/MM/yyyy').format(fechaNacimiento!) : '',
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  child: const Text('Guardar'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (fechaNacimiento != null) {
                        if (imageFile != null) {
                          await userLogic!.createUserData(user!.uid, user!.email!, nombre!, fechaNacimiento!, imageFile!.path);
                        } else {
                          await userLogic!.createUserData(user!.uid, user!.email!, nombre!, fechaNacimiento!, null);
                        }
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
                          );
                        }
                      } else {
                        // Manejar el caso en que fechaNacimiento es nulo
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
