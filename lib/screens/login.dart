import 'package:flutter/material.dart';
import 'package:polling_dapp/screens/home_page.dart';
import 'package:polling_dapp/services/api.dart';
import 'package:polling_dapp/utils/app_button.dart';
import 'package:polling_dapp/utils/app_testfield.dart';
import 'package:polling_dapp/utils/loading_dialog.dart';
import 'package:polling_dapp/utils/validator.dart';

import '../utils/globals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController privateKeyController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  void login() {
    if (formKey.currentState!.validate()) {
      Api api = Api(privateKeyController.text);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage(api: api,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 1000),
          margin: const EdgeInsets.symmetric(vertical: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.poll_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                Text("Polling DApp",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(
                  height: 100,
                ),
                AppTextField(
                  controller: privateKeyController,
                  hintText: "Enter Private Key",
                  labelText: 'Private Key',
                  validator: Validators.emptyTextValidator,
                ),
                const SizedBox(
                  height: 20,
                ),
                AppButton(onPressed: login, title: "Login")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
