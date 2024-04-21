// import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';

import 'package:coffee_shop/widgets/menu/menu_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuPage extends StatefulWidget {
  final String? category;
  final User user = FirebaseAuth.instance.currentUser!;
  MenuPage({super.key, this.category});

  @override
  State createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? selectedCategory;
  final List<String> categories = ['Cafe', 'Bebidas', 'Bocadillos', 'Snacks', 'Bolleria'];
  // final List<String> imgList = [
  //   'assets/images/img1.png',
  //   'assets/images/img2.png',
  //   'assets/images/img3.png',
  // ];
  TextEditingController searchController = TextEditingController();
  late Future<List<String>> categoriesFuture;

  @override
  void initState() {
    super.initState();

    selectedCategory = widget.category ?? categories.first;
  }

  Future<List<DocumentSnapshot>> getItems(String category) async {
    var snapshot = await FirebaseFirestore.instance.collection('Productos').doc('tipos').collection(category).get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 77, 69),
        title: const Text(
          'Menú Cafetería',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white, // Color de fondo del contenedor de búsqueda
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
            DefaultTabController(
              length: categories.length,
              child: Column(
                children: <Widget>[
                  //MARK: Sección de pestañas
                  Container(
                    constraints: const BoxConstraints.expand(height: 50),
                    child: TabBar(
                      isScrollable: true,
                      tabs: categories.map((String category) => Tab(text: category)).toList(),
                      onTap: (index) {
                        setState(() {
                          selectedCategory = categories[index];
                        });
                      },
                    ),
                  ),

                  // MARK: Sección de contenido de pestañas
                  SizedBox(
                    height: 700, // Ajusta esta altura según tus necesidades
                    child: TabBarView(
                      children: categories.map((String category) {
                        return FutureBuilder<List<DocumentSnapshot>>(
                          future: getItems(category),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
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
                                        unawaited(() async {
                                          final user = FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            // Buscamos el producto en la colección de productos por su nombre.
                                            final productSnapshot = await FirebaseFirestore.instance.collection('Productos').doc('tipos').collection(category).where('nombre', isEqualTo: itemData['nombre']).get();
                                            print('nombre: ${itemData['nombre']}');
                                            if (productSnapshot.docs.isNotEmpty) {
                                              final productData = productSnapshot.docs[0].data();

                                              // Buscamos el producto en la colección de favoritos del usuario por su nombre.
                                              final favoriteSnapshot = await FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('favoritos').where('nombre', isEqualTo: itemData['nombre']).get();

                                              if (favoriteSnapshot.docs.isNotEmpty) {
                                                // Si el producto ya es favorito, lo eliminamos de los favoritos.
                                                favoriteSnapshot.docs[0].reference.delete().then((value) => Fluttertoast.showToast(msg: 'Producto eliminado de favoritos')).catchError((error) => Fluttertoast.showToast(msg: 'Error al eliminar el producto de favoritos: $error'));
                                              } else {
                                                // Si el producto no es favorito, lo agregamos a los favoritos.
                                                FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(user.uid)
                                                    .collection('favoritos')
                                                    .add({
                                                      'nombre': productData['nombre'],
                                                      'precio': productData['precio'],
                                                      'image': productData['image'],
                                                      'isFavorite': true,
                                                    })
                                                    .then((value) => Fluttertoast.showToast(msg: 'Producto añadido a favoritos'))
                                                    .catchError((error) => Fluttertoast.showToast(msg: 'Error al añadir el producto a favoritos: $error'));
                                              }
                                            } else {
                                              Fluttertoast.showToast(msg: 'Producto no encontrado');
                                            }
                                          } else {
                                            Fluttertoast.showToast(msg: 'Necesitas iniciar sesión para añadir productos a favoritos');
                                          }
                                        }());
                                      },
                                      addToCart: () {
                                        final user = FirebaseAuth.instance.currentUser;
                                        if (user != null) {
                                          FirebaseFirestore.instance
                                              .collection('Carrito')
                                              .doc(user.uid)
                                              .collection('Productos')
                                              .add({
                                                'nombre': itemData['nombre'],
                                                'precio': itemData['precio'],
                                                'image': itemData['image'],
                                                'isFavorite': itemData['isFavorite'],
                                              })
                                              .then((value) => Fluttertoast.showToast(msg: 'Producto añadido al carrito'))
                                              .catchError((error) => Fluttertoast.showToast(msg: 'Error al añadir el producto: $error'));
                                        } else {
                                          Fluttertoast.showToast(msg: 'Necesitas iniciar sesión para añadir productos al carrito');
                                        }
                                      },
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
