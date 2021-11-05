import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Token token;

  // ignore: use_key_in_widget_constructors
  const ChangePasswordScreen({required this.token});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _showLoader = false;
  bool _passwordShow = false;

  String _currentPassword = '';
  String _currentPasswordError = '';
  bool _currentPasswordShowError = false;
  //TextEditingController _currentPasswordController = TextEditingController();

  String _newPassword = '';
  String _newPasswordError = '';
  bool _newPasswordShowError = false;
  //TextEditingController _newPasswordController = TextEditingController();

  String _confirmPassword = '';
  String _confirmPasswordError = '';
  bool _confirmPasswordShowError = false;
  //TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change of password'),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showLogo(),
                _showCurrentPassword(),
                _showNewPassword(),
                _showConfirmPassword(),
                _showButtons(),
              ],
            ),
          ),
          _showLoader
              ? const LoaderComponent(
                  text: 'Please wait...',
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Image(
        image: AssetImage('assets/logo.png'),
        width: 150,
      ),
    );
  }

  Widget _showCurrentPassword() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Enter your current password...',
          labelText: 'Current password',
          errorText: _currentPasswordShowError ? _currentPasswordError : null,
          suffixIcon: IconButton(
            icon: _passwordShow
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _currentPassword = value;
        },
      ),
    );
  }

  Widget _showNewPassword() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Enter your new password...',
          labelText: 'New password',
          errorText: _newPasswordShowError ? _newPasswordError : null,
          suffixIcon: IconButton(
            icon: _passwordShow
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _newPassword = value;
        },
      ),
    );
  }

  Widget _showConfirmPassword() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Enter the confirmation of the new password...',
          labelText: 'Password confirmation ',
          errorText: _confirmPasswordShowError ? _confirmPasswordError : null,
          suffixIcon: IconButton(
            icon: _passwordShow
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _confirmPassword = value;
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
          Expanded(
            child: ElevatedButton(
              child: const Text('Change password'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return AppColors.darkblue;
                }),
              ),
              onPressed: () => _save(),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    _changePassword();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_currentPassword.length < 6) {
      isValid = false;
      _currentPasswordShowError = true;
      _currentPasswordError =
          'You must enter your current password of at least 6 characters.';
    } else {
      _currentPasswordShowError = false;
    }

    if (_newPassword.length < 6) {
      isValid = false;
      _newPasswordShowError = true;
      _newPasswordError =
          'You must enter your new password of at least 6 characters.';
    } else {
      _newPasswordShowError = false;
    }

    if (_confirmPassword.length < 6) {
      isValid = false;
      _confirmPasswordShowError = true;
      _confirmPasswordError =
          'You must enter a confirmation of your new password of at least 6 characters.';
    } else {
      _confirmPasswordShowError = false;
    }

    if (_confirmPassword != _newPassword) {
      isValid = false;
      _confirmPasswordShowError = true;
      _confirmPasswordError =
          'The new password and the confirmation are not the same.';
    } else {
      _confirmPasswordShowError = false;
    }

    setState(() {});
    return isValid;
  }

  void _changePassword() async {
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
      'oldPassword': _currentPassword,
      'newPassword': _newPassword,
      'confirm': _confirmPassword,
    };

    Response response = await ApiHelper.post(
        '/api/Account/ChangePassword', request, widget.token.token);

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
        message: 'Your password has been changed successfully.',
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: null, label: 'Accept'),
        ]);

    Navigator.pop(context, 'yes');
  }
}
