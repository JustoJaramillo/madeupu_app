import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';

class CommentScreen extends StatefulWidget {
  final Token token;
  final Project project;
  const CommentScreen({Key? key, required this.token, required this.project})
      : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  bool _showLoader = false;
  String _comment = '';
  String _commentError = '';
  bool _commentShowError = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = _comment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New comment'),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              _showComment(),
              _showButtons(),
            ],
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

  Widget _showComment() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.multiline,
        minLines: 10,
        maxLines: 50,
        autofocus: true,
        controller: _commentController,
        decoration: InputDecoration(
          hintText: 'Enter a comment...',
          labelText: 'Comment',
          errorText: _commentShowError ? _commentError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _comment = value;
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
              child: const Text('Save'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return const Color(0xFF120E43);
                }),
              ),
              onPressed: () => _addRecord(),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateFields() {
    bool isValid = true;

    if (_comment.isEmpty) {
      isValid = false;
      _commentShowError = true;
      _commentError = 'You must enter a comment.';
    } else {
      _commentShowError = false;
    }

    setState(() {});
    return isValid;
  }

  _addRecord() async {
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
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'Message': _comment,
      'ProjectId': widget.project.id,
      'UserName': widget.token.user.userName
    };

    Response response =
        await ApiHelper.post('/api/Comments/', request, widget.token.token);

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

    Navigator.pop(context, 'yes');
  }
}
