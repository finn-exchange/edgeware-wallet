import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:polkawallet_sdk/kabob_sdk.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:wallet_apps/src/models/atd.dart';
import 'package:wallet_apps/src/models/kmpi.dart';
import 'package:wallet_apps/src/models/native.m.dart';
import 'package:wallet_apps/src/provider/api_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import '../../index.dart';

class ContractProvider with ChangeNotifier {
  final WalletSDK sdk = ApiProvider.sdk;
  final Keyring keyring = ApiProvider.keyring;
  String ethAdd;

  Atd atd = Atd();
  Kmpi kmpi = Kmpi();
  NativeM bscNative = NativeM();
  NativeM bnbNative =
      NativeM(logo: 'assets/bnb-2.png', symbol: 'BNB', org: 'testnet');
  Client _httpClient;
  Web3Client _web3client;

  Future<void> initClient() async {
    _httpClient = Client();
    _web3client = Web3Client(AppConfig.bscTestNet, _httpClient);
  }

  Future<DeployedContract> initBsc(String contractAddr) async {
    final String abiCode = await rootBundle.loadString('assets/abi/abi.json');
    final contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'AYC'),
      EthereumAddress.fromHex(contractAddr),
    );

    return contract;
  }

  Future<List> query(String functionName, List args) async {
    final contract = await initBsc(AppConfig.bscAddr);
    final ethFunction = contract.function(functionName);

    final res = await _web3client.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );
    return res;
  }

  Future<void> getBscDecimal() async {
    final res = await query('decimals', []);

    bscNative.chainDecimal = res[0].toString();
    bnbBalance();
    getBscBalance();
    notifyListeners();
  }

  Future<void> getSymbol() async {
    final res = await query('symbol', []);

    bscNative.symbol = res[0].toString();
    notifyListeners();
  }

  Future<void> extractAddress(String privateKey) async {
    initClient();
    final credentials = await _web3client.credentialsFromPrivateKey(
      privateKey,
    );

    if (credentials != null) {
      final addr = await credentials.extractAddress();
      await StorageServices().writeSecure('etherAdd', addr.toString());
    }
  }

  Future<void> bnbBalance() async {
    final ethAddr = await StorageServices().readSecure('etherAdd');
    ethAdd = ethAddr;
    final balance = await _web3client.getBalance(
      EthereumAddress.fromHex(ethAddr),
    );

    bnbNative.balance = balance.getValueInUnit(EtherUnit.ether).toString();
    notifyListeners();
  }

  Future<void> getBscBalance() async {
    final ethAddr = await StorageServices().readSecure('etherAdd');
    ethAdd = ethAddr;
    final res = await query('balanceOf', [EthereumAddress.fromHex(ethAddr)]);
    bscNative.balance = Fmt.bigIntToDouble(
      res[0] as BigInt,
      int.parse(bscNative.chainDecimal),
    ).toString();
    notifyListeners();
  }

  Future<String> sendTxBnb(
    String privateKey,
    String reciever,
    String amount,
  ) async {
    initClient();

    final credentials =
        await _web3client.credentialsFromPrivateKey(privateKey.substring(2));

    final res = await _web3client.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(reciever),
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount),
      ),
      fetchChainIdFromNetworkId: true,
    );

    return res;
  }

  Future<String> sendTxBsc(
    String privateKey,
    String reciever,
    String amount,
  ) async {
    initClient();

    final contract = await initBsc(AppConfig.bscAddr);
    final txFunction = contract.function('transfer');
    final credentials = await _web3client.credentialsFromPrivateKey(privateKey);

    final res = await _web3client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: txFunction,
        parameters: [
          EthereumAddress.fromHex(reciever),
          BigInt.from(pow(
              double.parse(amount) * 10, int.parse(bscNative.chainDecimal))),
        ],
      ),
      fetchChainIdFromNetworkId: true,
    );

    print(res);

    return res;
  }

  Future<void> initKmpi() async {
    kmpi.isContain = true;
    kmpi.logo = 'assets/koompi_white_logo.png';
    kmpi.symbol = 'KMPI';
    kmpi.org = 'KOOMPI';
    kmpi.balanceReady = false;

    await sdk.api.callContract();
    await fetchKmpiHash();
    fetchKmpiBalance();
    notifyListeners();
  }

  Future<void> fetchKmpiHash() async {
    final res =
        await sdk.api.getHashBySymbol(keyring.current.address, kmpi.symbol);
    kmpi.hash = res.toString();
  }

  Future<void> fetchKmpiBalance() async {
    final res = await sdk.api.balanceOfByPartition(
        keyring.current.address, keyring.current.address, kmpi.hash);
    kmpi.balance = BigInt.parse(res['output'].toString()).toString();
    kmpi.balanceReady = true;
    notifyListeners();
  }

  Future<void> initAtd() async {
    atd.isContain = true;
    atd.logo = 'assets/FingerPrint1.png';
    atd.symbol = 'ATD';
    atd.org = 'KOOMPI';
    atd.balanceReady = false;

    await sdk.api.initAttendant();
    notifyListeners();
  }

  Future<void> fetchAtdBalance() async {
    final res = await sdk.api.getAToken(keyring.current.address);
    atd.balance = BigInt.parse(res).toString();
    atd.balanceReady = true;

    notifyListeners();
  }

  Future<void> addToken(
    String symbol,
    BuildContext context,
  ) async {
    if (symbol == 'KMPI') {
      initKmpi().then((value) async {
        await StorageServices.saveBool(kmpi.symbol, true);
      });
    } else {
      initAtd().then((value) async {
        await StorageServices.saveBool(atd.symbol, true);
      });
    }
    Navigator.pushNamedAndRemoveUntil(
        context, Home.route, ModalRoute.withName('/'));
  }

  Future<void> removeToken(String symbol) async {
    if (symbol == 'KMPI') {
      kmpi.isContain = false;
      await StorageServices.removeKey('KMPI');
    } else {
      atd.isContain = false;
      await StorageServices.removeKey('ATD');
    }
    notifyListeners();
  }

  Future<void> getAStatus() async {
    final res = await sdk.api.getAStatus(keyring.keyPairs[0].address);
    atd.status = res;
    notifyListeners();
  }

  void resetConObject() {
    atd = Atd();
    kmpi = Kmpi();
    bscNative = NativeM();
    bnbNative = NativeM(
      logo: 'assets/bnb-2.png',
      symbol: 'BNB',
      org: 'testnet',
    );

    notifyListeners();
  }
}
