import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileLogic extends StatefulWidget {
  final User user;

  const ProfileLogic({super.key, required this.user});

  @override
  _ProfileLogicState createState() => _ProfileLogicState();
}

class _ProfileLogicState extends State<ProfileLogic> {
  late Future<DocumentSnapshot?> userData;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    final userRef = FirebaseFirestore.instance.collection('Users').doc(widget.user.uid);
    print('User ID: ${widget.user.uid}');
    userData = userRef.get();
  }

  void _toggleCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: userData,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && !snapshot.data!.exists) {
          return const Center(child: Text('No se encontraron datos del usuario'));
        } else {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final birthDate = (data['fecha_nacimiento'] as Timestamp).toDate();
          final age = DateTime.now().difference(birthDate).inDays ~/ 365;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleCard,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showFront ? _buildFrontCard(data) : _buildBackCard(data),
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  const Text('Tus acciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  age < 18
                      ? Container() // Si el usuario es menor de 18 años, no mostramos el botón
                      : _buildButton(context, 'Recargar Saldo', Icons.attach_money, '/recargarSaldo'),
                  _buildButton(context, 'Historial de Pedidos', Icons.history, '/historialPedidos'),
                  _buildButton(context, 'Historial de Recargas', Icons.receipt, '/historialRecargas'),
                  _buildButton(context, 'Modificar Perfil', Icons.edit, '/modificarPerfil'),
                ],
              ),
            ),
          ); // Y esto
        }
      },
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 375,
        height: 50, // Ajusta el ancho máximo aquí
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(route);
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(), // Este SizedBox añade espacio entre el texto y el borde derecho
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Tooltip(
        message: 'Haz clic para ver tus datos',
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: double.infinity,
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Perfil ID',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: (data['image'] as String).isEmpty
                            ? const Text(
                                'Aún no tienes imagen',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              )
                            : Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                  image: DecorationImage(
                                    image: NetworkImage(data['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.info, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(pi),
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            width: double.infinity,
            height: 200,
            child: Transform(
              transform: Matrix4.identity()..rotateY(pi),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    //NOMBRE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          '${data['nombre']}',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
//EMAIL
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.email, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          '${data['email']}',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.cake, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('dd/MM/yyyy').format(data['fecha_nacimiento'].toDate()),
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                    //SALDO
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.euro_outlined, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          'Saldo: €${data['saldo']}',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
