import 'package:flutter/material.dart';

showLoadingDialog(BuildContext context, String title) {
  return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator()),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          ],
        );
      });
}
