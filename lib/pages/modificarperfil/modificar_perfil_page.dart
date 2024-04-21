import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ModificarPerfilPage extends StatefulWidget {
  final User? user;

  const ModificarPerfilPage({Key? key, this.user}) : super(key: key);

  @override
  State<ModificarPerfilPage> createState() => _ModificarPerfilPageState();
}

class _ModificarPerfilPageState extends State<ModificarPerfilPage> {
  final userCollection = FirebaseFirestore.instance.collection('Users');
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController imageController;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    imageController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
  }

  Future<void> updateImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('Users').child(widget.user!.uid).child('profile.jpg');
      await ref.putFile(file);

      final url = await ref.getDownloadURL();
      imageController.text = url;

      await userCollection.doc(widget.user!.uid).update({'image': url});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar perfil'),
        ),
        body: const Center(
          child: Text("No hay usuario conectado"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: userCollection.doc(widget.user!.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Algo salió mal");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Text("El documento no existe");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            nameController.text = data['nombre'];
            emailController.text = data['email'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: updateImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: data['image'] != null ? NetworkImage(data['image']) : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> updateData = {
                        'nombre': nameController.text,
                        'email': emailController.text,
                      };

                      if (imageController.text.isNotEmpty) {
                        updateData['image'] = imageController.text;
                      }

                      await userCollection.doc(widget.user!.uid).update(updateData);
                    },
                    child: const Text('Guardar cambios'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
