import 'package:flutter/material.dart';
import 'package:madeupu_app/helpers/app_colors.dart';

class LoaderComponent extends StatelessWidget {
  final String text;

  // ignore: use_key_in_widget_constructors
  const LoaderComponent({this.text = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 150,
        decoration: BoxDecoration(
            color: AppColors.blue, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 30,
            ),
            Text(
              text,
              style: const TextStyle(fontSize: 30),
            )
          ],
        ),
      ),
    );
  }
}
