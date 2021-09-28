import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/constans.dart';
import 'package:vehicles_app/models/token.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;
  String _password = '';
  String _passwordError = '';
  bool _passwordShowError = false;
  bool _rememberme = true;
  bool _PasswordShow = false;
  bool _ShowLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _showLogo(),
            SizedBox(
              height: 20,
            ),
            _showEmail(),
            _showPassword(),
            _showRememberme(),
            _showButtons(),
          ],
        ),
        _ShowLoader
            ? LoaderComponent(
                text: 'Por favor espere...',
              )
            : Container(),
      ],
    ));
  }

  Widget _showLogo() {
    return Image(
      image: AssetImage('assets/taller.png'),
      width: 300,
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: 'Ingresa tu email...',
            labelText: 'Email',
            errorText: _emailShowError ? _emailError : null,
            prefixIcon: Icon(Icons.alternate_email),
            suffixIcon: Icon(Icons.email),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showPassword() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_PasswordShow,
        decoration: InputDecoration(
            hintText: 'Ingresa tu contraseña...',
            labelText: 'Contraseña',
            errorText: _passwordShowError ? _passwordError : null,
            prefixIcon: Icon(Icons.lock),
            suffixIcon: IconButton(
                icon: _PasswordShow
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _PasswordShow = !_PasswordShow;
                  });
                }),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showRememberme() {
    return CheckboxListTile(
      title: Text('Recordarme'),
      value: _rememberme,
      onChanged: (value) {
        setState(() {
          _rememberme = value!;
        });
      },
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround, //distribuye el espacio entre botones
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Text('Iniciar Sesión'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Colors.green;
                }),
              ),
              onPressed: () => _login(),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: ElevatedButton(
              child: Text('Nuevo Usuario'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Colors.orange;
                }),
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _PasswordShow = false;
    });

    if (!_validateFields()) {
      return;
    }

    setState(() {
      _ShowLoader = true;
    });

    Map<String, dynamic> request = {
      "userName": _email,
      "password": _password,
    };

    var url = Uri.parse('${Constans.apiUrl}/api/Account/CreateToken');
    var response = await http.post(url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json'
        },
        body: jsonEncode(request));

    setState(() {
      _ShowLoader = false;
    });

    if (response.statusCode >= 400) {
      setState(() {
        _passwordShowError = true;
        _passwordError = "Email o Contraseña incorrectos.";
      });
      return;
    }

    var body = response.body;
    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);
  }

  bool _validateFields() {
    bool isValid = true;

    if (_email.isEmpty) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar tu email.';
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email valido.';
    } else {
      _emailShowError = false;
    }

    if (_password.isEmpty) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar tu contraseña.';
    } else if (_password.length < 6) {
      isValid = false;
      _passwordShowError = true;
      _passwordError =
          'Debes ingresar una contraseña de al menos 6 carácteres.';
    } else {
      _passwordShowError = false;
    }

    setState(() {});
    return isValid;
  }
}
