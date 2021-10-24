import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/Colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:madeupu_app/helpers/constants.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = 'luis@yopmail.com';
  String _emailError = '';
  bool _emailShowError = false;

  String _password = '123456';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordShow = false;

  bool _showLoader = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                _showLogo(),
                SizedBox(
                  height: 20,
                ),
                _showEmail(),
                _showPassword(),
                _showRememberme(),
                _showButtons(),
                _showRegisterOption()
              ],
            ),
          ),
          _showLoader ? LoaderComponent(text: 'Please wait...') : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return const Image(
      image: AssetImage('assets/logo.png'),
      width: 250,
    );
  }

  Widget _showEmail() {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 50),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email...',
          labelText: 'Email',
          suffixIcon: const Icon(Icons.email_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showPassword() {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Enter your password...',
          labelText: 'Password',
          errorText: _passwordShowError ? _passwordError : null,
          suffixIcon: IconButton(
            icon: _passwordShow
                ? Icon(Icons.visibility)
                : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showRememberme() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 2, top: 10),
      child: CheckboxListTile(
        title: Text('Remember me'),
        value: _rememberme,
        onChanged: (value) {
          setState(() {
            _rememberme = value!;
          });
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _showLoginButton(),
        ],
      ),
    );
  }

  bool _validateFields() {
    bool isValid = true;

    if (_email.isEmpty) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'You must enter your email.';
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'You must enter a valid email.';
    } else {
      _emailShowError = false;
    }

    if (_password.isEmpty) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'You must enter your password .';
    } else if (_password.length < 6) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'You must enter a password of at least 6 characters.';
    } else {
      _passwordShowError = false;
    }

    setState(() {});
    return isValid;
  }

  Widget _showLoginButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Log in'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return AppColors.darkblue;
          }),
        ),
        onPressed: () => _login(),
      ),
    );
  }

  Widget _showRegisterOption() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: InkWell(
        child: Text(
          'You do not have an account, register here.',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
        ),
        onTap: () {},
      ),
    );
  }

  void _login() async {
    setState(() {
      _passwordShow = false;
    });

    if (!_validateFields()) {
      return;
    }

    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'userName': _email,
      'password': _password,
    };

    var url = Uri.parse('${Constants.apiUrl}/api/Account/CreateToken');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    print(response.body);

    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      setState(() {
        _passwordShowError = true;
        _passwordError = "Wrong email or password.";
      });
      return;
    }

    var body = response.body;

    if (_rememberme) {
      _storeUser(body);
    }

    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  token: token,
                )));
  }

  void _storeUser(String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', true);
    await prefs.setString('userBody', body);
  }
}
