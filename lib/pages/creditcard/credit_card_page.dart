import 'package:flutter/material.dart';

class CreditCardsPage extends StatelessWidget {
  const CreditCardsPage({super.key, Key? customKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tarjetas de Crédito'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0), // Agrega un padding alrededor de la página
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // Envuelve el título y el subtítulo en un contenedor
                color: const Color.fromARGB(255, 253, 253, 253), // Ajusta el color de fondo según tu preferencia
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Añade un padding interno
                child: _buildTitleSection(title: "Administra tus tarjetas de pago", subTitle: "Agrega o elimina tarjetas de crédito"),
              ),
              const SizedBox(height: 15), // Agrega espacio entre el título y las tarjetas de crédito
              _buildCreditCard(color: const Color(0xFF090943), cardExpiration: "08/2022", cardHolder: "HOUSSEM SELMI", cardNumber: "3546 7532 XXXX 9742"),
              const SizedBox(height: 15), // Agrega espacio entre las tarjetas de crédito
              _buildCreditCard(color: const Color(0xFF000000), cardExpiration: "05/2024", cardHolder: "HOUSSEM SELMI", cardNumber: "9874 4785 XXXX 6548"),
              const SizedBox(height: 15), // Agrega espacio entre las tarjetas de crédito
              _buildAddCardButton(icon: const Icon(Icons.add), color: const Color.fromARGB(255, 90, 182, 57)),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildTitleSection({required String title, required String subTitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            subTitle,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        )
      ],
    );
  }

  Card _buildCreditCard({required Color color, required String cardNumber, required String cardHolder, required String cardExpiration}) {
    return Card(
      elevation: 4.0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildLogosBlock(),
            Text(
              cardNumber,
              style: const TextStyle(color: Colors.white, fontSize: 21, fontFamily: 'CourrierPrime'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildDetailsBlock(
                  label: 'CARDHOLDER',
                  value: cardHolder,
                ),
                _buildDetailsBlock(label: 'VALID THRU', value: cardExpiration),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row _buildLogosBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Image.asset(
          "assets/images/contact_less.png",
          height: 20,
          width: 18,
        ),
        Image.asset(
          "assets/images/mastercard.png",
          height: 50,
          width: 50,
        ),
      ],
    );
  }

  Column _buildDetailsBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Container _buildAddCardButton({required Icon icon, required Color color}) {
    return Container(
      alignment: Alignment.center,
      child: FloatingActionButton(
        elevation: 2.0,
        onPressed: () {
          print("Add a credit card");
        },
        backgroundColor: color,
        mini: false,
        child: icon,
      ),
    );
  }
}
