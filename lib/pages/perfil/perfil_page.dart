import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/pages/creditcard/credit_card_page.dart';
import 'package:coffee_shop/pages/historialpedidos/historial_pedidos_page.dart';
import 'package:coffee_shop/pages/login/authPage.dart';
import 'package:coffee_shop/pages/modificarperfil/modificar_perfil_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  const ProfilePage({super.key, this.user});
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final userCollection = FirebaseFirestore.instance.collection('Users');
  late Future<DocumentSnapshot?> userData;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final userRef = FirebaseFirestore.instance.collection('Users').doc(widget.user!.uid);
      print('User ID: ${widget.user!.uid}');
      userData = userRef.get();
    } else {
      print('User is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: widget.user == null
            ? const Center(child: Text('No user logged in'))
            : Container(
                color: Colors.white54,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: userCollection.doc(widget.user!.uid).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Algo salió mal");
                    }

                    if (snapshot.hasData && !snapshot.data!.exists) {
                      return const Text("El documento no existe");
                    }

                    if (snapshot.connectionState == ConnectionState.active) {
                      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                      DateTime fechaNacimiento = (data['fecha_nacimiento'] as Timestamp).toDate();
                      int edad = DateTime.now().year - fechaNacimiento.year;
                      if (DateTime.now().month < fechaNacimiento.month || (DateTime.now().month == fechaNacimiento.month && DateTime.now().day < fechaNacimiento.day)) {
                        edad--;
                      }
                      return Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          const ListTile(
                            leading: Icon(Icons.arrow_back),
                            trailing: Icon(Icons.menu),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  const CircleAvatar(
                                    maxRadius: 100,
                                    backgroundImage: AssetImage("assets/images/user.png"),
                                  ),
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 1),
                                      image: DecorationImage(
                                        image: NetworkImage(data['image']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${data['nombre'] ?? 'No name provided'}",
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text("${data['email'] ?? 'No email provided'}")],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "€${(data['saldo'] as num?)?.toStringAsFixed(2) ?? 'No balance provided'}",
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Expanded(
                              child: ListView(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ModificarPerfilPage(user: FirebaseAuth.instance.currentUser)),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
                                  color: Colors.white70,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  child: const ListTile(
                                    leading: Icon(
                                      Icons.person,
                                      color: Colors.black54,
                                    ),
                                    title: Text(
                                      'Mi perfil',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HistorialPedidosPage(user: FirebaseAuth.instance.currentUser!),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white70,
                                  margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  child: const ListTile(
                                    leading: Icon(
                                      Icons.history,
                                      color: Colors.black54,
                                    ),
                                    title: Text(
                                      'Mis Pedidos',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (edad >= 18)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CreditCardsPage()),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.white70,
                                    margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    child: const ListTile(
                                      leading: Icon(Icons.credit_card, color: Colors.black54),
                                      title: Text(
                                        'Mis tarjetas',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AuthPage()),
                                  );
                                },
                                child: Card(
                                  color: Colors.white70,
                                  margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  child: const ListTile(
                                    leading: Icon(
                                      Icons.logout,
                                      color: Colors.black54,
                                    ),
                                    title: Text(
                                      'Cerrar sesión',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios_outlined),
                                  ),
                                ),
                              )
                            ],
                          ))
                        ],
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
      ),
    );
  }
}
