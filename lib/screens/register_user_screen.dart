import 'dart:convert';
import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/models/document_type.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/screens/take_picture_screen.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({Key? key}) : super(key: key);

  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  bool _showLoader = false;
  bool _passwordShow = false;
  bool _photoChanged = false;
  late XFile _image;

  String _firstName = '';
  String _firstNameError = '';
  bool _firstNameShowError = false;
  final TextEditingController _firstNameController = TextEditingController();

  String _lastName = '';
  String _lastNameError = '';
  bool _lastNameShowError = false;
  final TextEditingController _lastNameController = TextEditingController();

  int _documentTypeId = 0;
  String _documentTypeIdError = '';
  bool _documentTypeIdShowError = false;
  List<DocumentType> _documentTypes = [];

  String _document = '';
  String _documentError = '';
  bool _documentShowError = false;
  final TextEditingController _documentController = TextEditingController();

  String _address = '';
  String _addressError = '';
  bool _addressShowError = false;
  final TextEditingController _addressController = TextEditingController();

  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;
  final TextEditingController _emailController = TextEditingController();

  String _phoneNumber = '';
  String _phoneNumberError = '';
  bool _phoneNumberShowError = false;
  final TextEditingController _phoneNumberController = TextEditingController();

  String _password = '';
  String _passwordError = '';
  bool _passwordShowError = false;
  final TextEditingController _passwordController = TextEditingController();

  String _confirm = '';
  String _confirmError = '';
  bool _confirmShowError = false;
  final TextEditingController _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDocumentTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New user'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showPhoto(),
                _showFirstName(),
                _showLastName(),
                _showDocumentType(),
                _showDocument(),
                _showEmail(),
                _showAddress(),
                _showPhoneNumber(),
                _showPassword(),
                _showConfirm(),
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

  Future<void> _getDocumentTypes() async {
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

    Response response = await ApiHelper.getDocumentTypes();

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

    setState(() {
      _documentTypes = response.result;
    });
  }

  List<DropdownMenuItem<int>> _getComboDocumentTypes() {
    List<DropdownMenuItem<int>> list = [];

    list.add(const DropdownMenuItem(
      child: Text('Select a document type...'),
      value: 0,
    ));

    // ignore: avoid_function_literals_in_foreach_calls
    _documentTypes.forEach((documnentType) {
      list.add(DropdownMenuItem(
        child: Text(documnentType.description),
        value: documnentType.id,
      ));
    });

    return list;
  }

  Widget _showPhoto() {
    return Stack(children: <Widget>[
      Container(
        margin: const EdgeInsets.only(top: 10),
        child: !_photoChanged
            ? const Image(
                image: AssetImage('assets/noimage.png'),
                height: 160,
                width: 160,
                fit: BoxFit.cover,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: Image.file(
                  File(_image.path),
                  height: 160,
                  width: 160,
                  fit: BoxFit.cover,
                )),
      ),
      Positioned(
          bottom: 0,
          left: 100,
          child: InkWell(
            onTap: () => _takePicture(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.green[50],
                height: 60,
                width: 60,
                child: const Icon(
                  Icons.photo_camera,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
          )),
      Positioned(
          bottom: 0,
          left: 0,
          child: InkWell(
            onTap: () => _selectPicture(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.green[50],
                height: 60,
                width: 60,
                child: const Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
          )),
    ]);
  }

  Widget _showFirstName() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _firstNameController,
        decoration: InputDecoration(
          hintText: 'Enter names...',
          labelText: 'Names',
          errorText: _firstNameShowError ? _firstNameError : null,
          suffixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _firstName = value;
        },
      ),
    );
  }

  Widget _showLastName() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _lastNameController,
        decoration: InputDecoration(
          hintText: 'Enter surname ...',
          labelText: 'Surname',
          errorText: _lastNameShowError ? _lastNameError : null,
          suffixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _lastName = value;
        },
      ),
    );
  }

  Widget _showDocumentType() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: _documentTypes.isEmpty
            ? const Text('Loading document types...')
            : DropdownButtonFormField(
                items: _getComboDocumentTypes(),
                value: _documentTypeId,
                onChanged: (option) {
                  setState(() {
                    _documentTypeId = option as int;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select a document type...',
                  labelText: 'Document type',
                  errorText:
                      _documentTypeIdShowError ? _documentTypeIdError : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ));
  }

  Widget _showDocument() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _documentController,
        decoration: InputDecoration(
          hintText: 'Enter document...',
          labelText: 'Document',
          errorText: _documentShowError ? _documentError : null,
          suffixIcon: const Icon(Icons.assignment_ind),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _document = value;
        },
      ),
    );
  }

  Widget _showEmail() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter email...',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          suffixIcon: const Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showAddress() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _addressController,
        keyboardType: TextInputType.streetAddress,
        decoration: InputDecoration(
          hintText: 'Enter address ...',
          labelText: 'Address',
          errorText: _addressShowError ? _addressError : null,
          suffixIcon: const Icon(Icons.home),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _address = value;
        },
      ),
    );
  }

  Widget _showPhoneNumber() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _phoneNumberController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'Enter phone ...',
          labelText: 'Phone',
          errorText: _phoneNumberShowError ? _phoneNumberError : null,
          suffixIcon: const Icon(Icons.phone),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _phoneNumber = value;
        },
      ),
    );
  }

  Widget _showPassword() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        controller: _passwordController,
        decoration: InputDecoration(
          hintText: 'Enter a password...',
          labelText: 'Password',
          errorText: _passwordShowError ? _passwordError : null,
          prefixIcon: const Icon(Icons.lock),
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
          _password = value;
        },
      ),
    );
  }

  Widget _showConfirm() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        controller: _confirmController,
        decoration: InputDecoration(
          hintText: 'Enter a password confirmation...',
          labelText: 'Password confirmation',
          errorText: _confirmShowError ? _confirmError : null,
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
          _confirm = value;
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
          _showRegisterButton(),
        ],
      ),
    );
  }

  void _takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    Response? response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(
                  camera: cameras,
                )));
    if (response != null) {
      setState(() {
        _photoChanged = true;
        _image = response.result;
      });
    }
  }

  void _selectPicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoChanged = true;
        _image = image;
      });
    }
  }

  Widget _showRegisterButton() {
    return Expanded(
      child: ElevatedButton(
        child: const Text('Register user'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return AppColors.darkblue;
          }),
        ),
        onPressed: () => _register(),
      ),
    );
  }

  void _register() async {
    if (!_validateFields()) {
      return;
    }

    _addRecord();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_firstName.isEmpty) {
      isValid = false;
      _firstNameShowError = true;
      _firstNameError = 'You must enter at least one name.';
    } else {
      _firstNameShowError = false;
    }

    if (_lastName.isEmpty) {
      isValid = false;
      _lastNameShowError = true;
      _lastNameError = 'You must enter at least one last name.';
    } else {
      _lastNameShowError = false;
    }

    if (_documentTypeId == 0) {
      isValid = false;
      _documentTypeIdShowError = true;
      _documentTypeIdError = 'You must select the type of document.';
    } else {
      _documentTypeIdShowError = false;
    }

    if (_document.isEmpty) {
      isValid = false;
      _documentShowError = true;
      _documentError = 'You must enter the document number.';
    } else {
      _documentShowError = false;
    }

    if (_email.isEmpty) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'You must enter an email.';
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'You must enter a valid email.';
    } else {
      _emailShowError = false;
    }

    if (_address.isEmpty) {
      isValid = false;
      _addressShowError = true;
      _addressError = 'You must enter an address.';
    } else {
      _addressShowError = false;
    }

    if (_phoneNumber.isEmpty) {
      isValid = false;
      _phoneNumberShowError = true;
      _phoneNumberError = 'You must enter a phone.';
    } else {
      _phoneNumberShowError = false;
    }

    if (_password.length < 6) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'You must enter a password of at least 6 characters.';
    } else {
      _passwordShowError = false;
    }

    if (_confirm.length < 6) {
      isValid = false;
      _confirmShowError = true;
      _confirmError =
          'You must enter a password confirmation of at least 6 characters.';
    } else {
      _confirmShowError = false;
    }

    if (_confirm != _password) {
      isValid = false;
      _confirmShowError = true;
      _confirmError = 'Password and confirmation are not the same.';
    } else {
      _confirmShowError = false;
    }

    setState(() {});
    return isValid;
  }

  void _addRecord() async {
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
            const AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    String base64image = '';
    if (_photoChanged) {
      List<int> imageBytes = await _image.readAsBytes();
      base64image = base64Encode(imageBytes);
    }

    Map<String, dynamic> request = {
      'firstName': _firstName,
      'lastName': _lastName,
      'documentTypeId': _documentTypeId,
      'document': _document,
      'email': _email,
      'userName': _email,
      'address': _address,
      'phoneNumber': _phoneNumber,
      'image': base64image,
      'password': _password,
    };

    Response response = await ApiHelper.postNoToken(
      '/api/Account/',
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
            'An email has been sent with the instructions to activate the user. Please activate it to be able to enter the application.',
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: null, label: 'Accept'),
        ]);

    Navigator.pop(context, 'yes');
  }
}
