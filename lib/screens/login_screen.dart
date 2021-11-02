import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:email_validator/email_validator.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/helpers/constants.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/home_screen.dart';
import 'package:madeupu_app/screens/recover_password_screen.dart';
import 'package:madeupu_app/screens/register_user_screen.dart';
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
                _showForgotPassword(),
                _showRegisterOption(),
              ],
            ),
          ),
          _showLoader ? LoaderComponent(text: 'Please wait...') : Container(),
        ],
      ),
    );
  }

  Widget _showForgotPassword() {
    return InkWell(
      onTap: () => _goForgotPassword(),
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 20),
        child: Text(
          '¿Have you forgotten your password?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
        ),
      ),
    );
  }

  void _goForgotPassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RecoverPasswordScreen()));
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
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _showLoginButton(),
            ],
          ),
          _showGoogleLoginButton(),
          _showFacebookLoginButton(),
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
          'You do not have an account, sign up.',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RegisterUserScreen()));
        },
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

  Widget _showGoogleLoginButton() {
    return Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton.icon(
                onPressed: () => _loginGoogle(),
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
                label: Text('Iniciar sesión con Google'),
                style: ElevatedButton.styleFrom(
                    primary: Colors.white, onPrimary: Colors.black)))
      ],
    );
  }

  void _loginGoogle() async {
    var googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    var user = await googleSignIn.signIn();

    Map<String, dynamic> request = {
      'email': user?.email,
      'id': user?.id,
      'loginType': 1,
      'fullName': user?.displayName,
      'photoURL': user?.photoUrl,
      'photoURL': user?.displayName,
    };

    await _socialLogin(request);
  }

  Widget _showFacebookLoginButton() {
    return Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton.icon(
                onPressed: () => _loginFacebook(),
                icon: FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.white,
                ),
                label: Text('Iniciar sesión con Facebook'),
                style: ElevatedButton.styleFrom(
                    primary: Color(0xFF3B5998), onPrimary: Colors.white)))
      ],
    );
  }

  void _loginFacebook() async {
    await FacebookAuth.i.login();
    var result = await FacebookAuth.i.login(
      permissions: ["public_profile", "email"],
    );
    if (result.status == LoginStatus.success) {
      final requestData = await FacebookAuth.i.getUserData(
        fields:
            "email, name, picture.width(800).heigth(800), first_name, last_name",
      );

      var picture = requestData['picture'];
      var data = picture['data'];

      Map<String, dynamic> request = {
        'email': requestData['email'],
        'id': requestData['id'],
        'loginType': 2,
        'fullName': requestData['name'],
        'photoURL': data['url'],
        'firtsName': requestData['first_name'],
        'lastName': requestData['last_name'],
      };

      await _socialLogin(request);
    }
  }

  Future _socialLogin(Map<String, dynamic> request) async {
    var url = Uri.parse('${Constants.apiUrl}/api/Account/SocialLogin');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message:
              'El usuario ya inció sesión previamente por email o por otra red social.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
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
}
