import 'package:flutter/material.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
// Future<void> updateUserImage() async {
//   // Permite al usuario seleccionar una nueva imagen
//   final ImagePicker _picker = ImagePicker();
//   final XFile? newImageFile = await _picker.pickImage(source: ImageSource.gallery);

//   if (newImageFile != null) {
//     // Sube la nueva imagen a Firebase Storage
//     final ref = FirebaseStorage.instance.ref().child('user_images').child(user!.uid + '.jpg');
//     await ref.putFile(File(newImageFile.path));

//     // Obtiene la URL de la nueva imagen subida
//     final newImageUrl = await ref.getDownloadURL();

//     // Actualiza la URL de la imagen en Firestore
//     await FirebaseFirestore.instance.collection('Users').doc(user!.email).update({
//       'image': newImageUrl,
//     });

//     // Actualiza la imagen en la interfaz de usuario
//     setState(() {
//       imageFile = newImageFile;
//     });
//   }
// }