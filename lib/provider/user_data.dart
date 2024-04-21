import 'package:coffee_shop/models/user/user_model.dart';
import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  Usuario _usuario;

  UserData(this._usuario);

  Usuario get usuario => _usuario;

  void setUsuario(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
  }
}
