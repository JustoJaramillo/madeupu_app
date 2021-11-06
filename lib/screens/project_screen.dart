import 'package:flutter/material.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/token.dart';

class ProjectScreen extends StatefulWidget {
  final Token token;
  final Project project;
  // ignore: use_key_in_widget_constructors
  const ProjectScreen({required this.token, required this.project});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.project.name),
        ),
        body: Text(widget.project.name));
  }
}
