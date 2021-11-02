import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/models/response.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({Key? key}) : super(key: key);

  @override
  _RecoverPasswordScreenState createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  bool _showLoader = false;

  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recover password'),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _showLogo(),
              _showEmail(),
              _showButtons(),
            ],
          ),
          _showLoader
              ? LoaderComponent(
                  text: 'Please wait...',
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return Container(
      padding: const EdgeInsets.all(50),
      child: const Image(
        image: AssetImage('assets/logo.png'),
        width: 200,
      ),
    );
  }

  Widget _showEmail() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email...',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          suffixIcon: const Icon(Icons.email_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _showRecoverButton(),
        ],
      ),
    );
  }

  Widget _showRecoverButton() {
    return Expanded(
      child: ElevatedButton(
        child: const Text('Recover password'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return AppColors.darkblue;
          }),
        ),
        onPressed: () => _recoverPassword(),
      ),
    );
  }

  void _recoverPassword() {
    if (!_validateFields()) {
      return;
    }

    _sendRecoverPassword();
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

    setState(() {});
    return isValid;
  }

  void _sendRecoverPassword() async {
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
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'email': _email,
    };

    Response response = await ApiHelper.postNoToken(
      '/api/Account/RecoverPassword',
      request,
    );

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    await showAlertDialog(
        context: context,
        title: 'Confirmation',
        message:
            'You have been sent an email with the instructions to recover your password.',
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: null, label: 'Accept'),
        ]);

    Navigator.pop(context);
  }
}
