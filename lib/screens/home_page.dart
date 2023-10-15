import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polling_dapp/screens/create_poll.dart';
import 'package:polling_dapp/screens/login.dart';
import 'package:polling_dapp/services/api.dart';
import 'package:polling_dapp/utils/app_button.dart';
import 'package:polling_dapp/utils/loading_dialog.dart';
import 'package:web3dart/credentials.dart';

import '../utils/snakebar.dart';

class HomePage extends StatefulWidget {
  final Api api;
  const HomePage({Key? key, required this.api}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;

  Future<dynamic> getCurrentPageApi() {
    switch (currentPage) {
      case 0:
        return widget.api.getAvailablePollsIds();
      case 1:
        return widget.api.getVotedPollsIds();
      case 2:
        return widget.api.getMyPollsIds();
    }
    return widget.api.getAvailablePollsIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polling App"),
        actions: [
          TextButton.icon(
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 1000),
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder(
            future: getCurrentPageApi(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              List ids = snapshot.data![0];
              print("Ids is $ids");
              return ListView.builder(
                itemCount: ids.length + 1,
                itemBuilder: (context, index) {
                  if (index >= ids.length) {
                    return const SizedBox(
                      height: 70,
                    );
                  }
                  return FutureBuilder(
                    future: widget.api
                        .getPollDetailsFromId(int.parse(ids[index].toString())),
                    builder: (context, pollSnapshot) {
                      if (pollSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Card(
                            child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                            ],
                          ),
                        ));
                      }

                      return _buildOptionsCard(
                          pollSnapshot.data!, int.parse(ids[index].toString()));
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreatePoll(
                    api: widget.api,
                  )));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (newIndex) {
          setState(() {
            currentPage = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.poll_outlined), label: 'Active Polls'),
          BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Voted Polls'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Your Polls'),
        ],
      ),
    );
  }

  _buildOptionsCard(List<dynamic> poll, int pollIndex) {
    String title = poll[0];
    List<dynamic> options = poll[1];
    List<dynamic> votes = poll[2];
    EthereumAddress owner = poll[3];
    bool isClosed = poll[4];
    bool isOwner = owner == widget.api.privateKey.address;
    BigInt totalVotes = votes.fold(
        BigInt.from(0), (previousValue, element) => previousValue + element);
    print("Total Votes is ${totalVotes}");

    return Card(
      color: isClosed ? Colors.grey[200] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              "Question : $title ",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            for (int i = 0; i < options.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  shape: Border.all(color: Colors.grey[300]!),
                  title: Text(options[i]),
                  trailing: isClosed || isOwner || currentPage == 1
                      ? Text(
                          '${((votes[i] / (totalVotes == BigInt.from(0) ? BigInt.from(1) : totalVotes)) * 100).toInt()} %')
                      : ElevatedButton(
                          onPressed: () async {
                            showLoadingDialog(context, "Sending your vote");
                            var response = await widget.api.vote(pollIndex, i);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(getSnackBar(response));
                            setState(() {});
                          },
                          child: const Text("Vote")),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            if (owner == widget.api.privateKey.address && !isClosed)
              AppButton(
                title: "Close Poll",
                onPressed: () async {
                  showLoadingDialog(context, "Closing Poll");
                  var response = await widget.api.closePoll(pollIndex);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(response));
                  setState(() {});
                },
              ),
            if (isClosed) const Text("This poll is closed")
          ],
        ),
      ),
    );
  }
}
