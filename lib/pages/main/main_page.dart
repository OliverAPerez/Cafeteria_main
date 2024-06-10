import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/firestorelogic/carrito/carrito_logic.dart';
import 'package:coffee_shop/pages/carrito/carrito_page.dart';
import 'package:coffee_shop/pages/favoritos/favoritos_page.dart';
import 'package:coffee_shop/pages/menu/menu_page.dart';
import 'package:coffee_shop/pages/perfil/perfil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final ValueNotifier<int> navbarIndex;
  CarritoLogic carritoLogic = CarritoLogic();

  MainPage({required this.navbarIndex, super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    MenuPage(), // Menu()
    const CarritoPage(), // Carrito()
    FavoritesPage(), // Favoritos()
    ProfilePage(user: FirebaseAuth.instance.currentUser), // Perfil()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      body: _children[_currentIndex],
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: widget.navbarIndex,
        builder: (context, value, child) {
          return BottomNavigationBar(
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                widget.navbarIndex.value = index;
              });
            },
            currentIndex: _currentIndex,
            selectedItemColor: Colors.blue, // Color cuando el ítem está seleccionado
            unselectedItemColor: Colors.grey, // Color cuando el ítem no está seleccionado
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant, size: _currentIndex == 0 ? 30 : 20),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.shopping_basket_outlined, size: _currentIndex == 1 ? 30 : 20),
                    StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: widget.carritoLogic.getCartItems(),
                      builder: (BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(); // Muestra un contenedor vacío mientras se espera el resultado
                        } else {
                          if (snapshot.hasError) {
                            return const Icon(Icons.error); // Muestra un ícono de error si hay un error
                          } else {
                            return Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                child: Text(
                                  snapshot.data!.length.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                label: 'Carrito',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline_sharp, size: _currentIndex == 2 ? 30 : 20),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: _currentIndex == 3 ? 30 : 20),
                label: 'Perfil',
              ),
            ],
          );
        },
      ),
    );
  }
}
