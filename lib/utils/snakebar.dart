import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

SnackBar getSnackBar(String txn) {
  return SnackBar(
    content: Text(txn.contains(" ") ? txn : "Your transaction is in process. be patient !"),
    duration: const Duration(seconds: 10),
    action: txn.contains(" ")
        ? null
        : SnackBarAction(
            label: 'Track',
            onPressed: () async {
              String url = "https://sepolia.etherscan.io/tx/$txn";
              if (!await launchUrl(Uri.parse(url))) {}
            }),
  );
}
