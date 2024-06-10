import 'package:coffee_shop/widgets/menu/menu_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatefulWidget {
  final User user;

  // Constructor sin parámetros
  FavoritesPage({super.key}) : user = FirebaseAuth.instance.currentUser!;

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  TextEditingController searchController = TextEditingController();

  Future<List<DocumentSnapshot>> getFavorites() async {
    var snapshot = await FirebaseFirestore.instance.collection('Users').doc(widget.user.uid).collection('favoritos').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 77, 69),
        title: const Text(
          'Favoritos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar productos',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // Manejar la lógica de búsqueda aquí
                },
              ),
            ),
          ),
          // Sección del grid de ítems
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: getFavorites(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tienes ningún artículo en tus favoritos.'));
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      physics: const ScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4 / 6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final itemData = snapshot.data![index].data() as Map<String, dynamic>;
                        return MenuItem(
                          name: itemData['nombre'] ?? 'Nombre no disponible',
                          price: (itemData['precio'] as num?)?.toDouble(),
                          imageUrl: itemData['image'] as String?,
                          isFavorite: itemData['isFavorite'] as bool? ?? false,
                          toggleFavorite: () {
                            // Lógica para eliminar de favoritos
                          },
                          addToCart: () {
                            // Lógica para añadir al carrito
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
