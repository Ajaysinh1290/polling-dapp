import 'package:flutter/material.dart';
import 'package:polling_dapp/services/api.dart';
import 'package:polling_dapp/utils/app_button.dart';
import 'package:polling_dapp/utils/app_testfield.dart';
import 'package:polling_dapp/utils/validator.dart';

import '../utils/globals.dart';
import '../utils/loading_dialog.dart';
import '../utils/snakebar.dart';

class CreatePoll extends StatefulWidget {
  final Api api;
  const CreatePoll({Key? key,required this.api}) : super(key: key);

  @override
  State<CreatePoll> createState() => _CreatePollState();
}

class _CreatePollState extends State<CreatePoll> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> optionsController = [
    TextEditingController(),
    TextEditingController()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Poll"),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600, maxHeight: 1000),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  labelText: "Title",
                  hintText: "Enter Title",
                  validator: Validators.emptyTextValidator,
                  controller: titleController,
                ),
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: optionsController.length + 1,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return index < optionsController.length
                          ? Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5)),
                              // margin: EdgeInsets.all(value),
                              child: ListTile(
                                title: AppTextField(
                                    controller: optionsController[index],
                                    hintText: "Enter option ${index + 1}",
                                    labelText: "Option ${index + 1}",
                                    validator: Validators.emptyTextValidator),
                                trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        optionsController.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.delete)),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(top: 20, bottom: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              width: double.infinity,
                              height: 60,
                              child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      optionsController
                                          .add(TextEditingController());
                                    });
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Add Option"),
                                    ],
                                  )),
                            );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                AppButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        showLoadingDialog(context, "Creating new poll");
                        final response = await widget.api.createPoll(
                            titleController.text.trim(),
                            optionsController
                                .map((e) => e.text.trim())
                                .toList(growable: false));
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(response));
                      }
                    },
                    title: "Create Poll")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
