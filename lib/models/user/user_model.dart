class Usuario {
  final String id; // Agrega este campo
  final String nombre;
  final String email;
  final String password;
  final int edad;
  final double saldo;

  Usuario({
    required this.id, // Agrega este parámetro
    required this.nombre,
    required this.email,
    required this.password,
    required this.edad,
    required this.saldo,
  });

  // Actualiza los métodos fromMap y toMap para incluir el id
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'], // Agrega esta línea
      nombre: map['nombre'],
      email: map['email'],
      password: map['password'],
      edad: map['edad'],
      saldo: map['saldo'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Agrega esta línea
      'nombre': nombre,
      'email': email,
      'password': password,
      'edad': edad,
      'saldo': saldo,
    };
  }
}
