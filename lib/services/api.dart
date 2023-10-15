import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:polling_dapp/utils/globals.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class Api {
  DeployedContract? contract;
  late Web3Client ethClient;
  late EthPrivateKey privateKey;
  Api(String strPrivateKey) {
    ethClient = Web3Client(infuraUrl, Client());
    privateKey = EthPrivateKey.fromHex(strPrivateKey);
    loadContract();
  }

  Future<void> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');
    contract = DeployedContract(ContractAbi.fromJson(abi, "Poll"),
        EthereumAddress.fromHex(contractAddress));
  }

  Future<String> callFunction(String functionName, List<dynamic> args) async {
    if (contract == null) {
      await loadContract();
    }
    final result = ethClient.sendTransaction(
        privateKey,
        Transaction.callContract(
            contract: contract!,
            function: contract!.function(functionName),
            parameters: args),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    return result;
  }

  Future<String> createPoll(String title, List<String> options) async {
    final result = await callFunction("createPoll", [title, options]);
    print("Poll created successfully");
    print(result);
    return result;
  }

  Future<String> vote(int pollIndex, int optionIndex) async {
    final result = await callFunction(
        "vote", [BigInt.from(pollIndex), BigInt.from(optionIndex)]);
    print("Vote successfully submitted");
    print(result);
    return result;
  }

  Future<String> closePoll(int pollIndex) async {
    final result = await callFunction("closePoll", [BigInt.from(pollIndex)]);
    print("Poll closed successfully");
    print(result);
    return result;
  }

  Future<List<dynamic>> ask(String functionName, List<dynamic> args) async {
    if (contract == null) {
      await loadContract();
    }
    print("calling $functionName");
    final result = await ethClient.call(
        sender: privateKey.address,
        contract: contract!,
        function: contract!.function(functionName),
        params: args);
    print("Result $result");
    return result;
  }

  Future<List<dynamic>> getAvailablePollsIds() async {
    return await ask("getAvailablePollsIds", []);
  }

  Future<List<dynamic>> getVotedPollsIds() async {
    return await ask("getVotedPollsIds", []);
  }

  Future<List<dynamic>> getMyPollsIds() async {
    return await ask("getMyPollsIds", []);
  }

  Future<List<dynamic>> getPollDetailsFromId(int pollId) async {
    return await ask("getPollDetailsFromId", [BigInt.from(pollId)]);
  }
}
