import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:polkawallet_sdk/kabob_sdk.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:provider/provider.dart';
import 'package:wallet_apps/src/config/asset_names.dart';
import 'package:wallet_apps/src/models/token.m.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';
import '../../index.dart';

class ContractProvider with ChangeNotifier {
  final WalletSDK sdk = ApiProvider.sdk;

  final Keyring keyring = ApiProvider.keyring;

  String ethAdd = '';
  bool std;

  Atd atd = Atd();
  Kmpi kmpi = Kmpi();
  bool isReady = false;
  NativeM bscNative = NativeM(
    id: 'selendra',
    logo: 'assets/SelendraCircle-Blue.png',
    symbol: 'SEL',
    org: 'BEP-20',
    isContain: true,
  );
  NativeM bscNativeV2 = NativeM(
    id: 'selendra v2',
    logo: 'assets/SelendraCircle-Blue.png',
    symbol: 'SEL (v2)',
    org: 'BEP-20',
    isContain: true,
  );

  NativeM kgoNative = NativeM(
    id: 'kiwigo',
    logo: 'assets/Kiwi-GO-White-1.png',
    symbol: 'KGO',
    org: 'BEP-20',
    isContain: true,
  );

  NativeM etherNative = NativeM(
    id: 'ethereum',
    logo: 'assets/eth.png',
    symbol: 'ETH',
    org: '',
    isContain: true,
  );

  NativeM bnbNative = NativeM(
    id: 'binance smart chain',
    logo: 'assets/bnb.png',
    symbol: bnbEvm,
    org: 'Smart Chain',
    isContain: true,
  );

  Client _httpClient;

  Web3Client _web3client, _etherClient;

  final String _wsBscUrl = "wss://bsc-ws-node.nariox.org:443";

  final String _wsEthUrl =
      "wss://mainnet.infura.io/ws/v3/93a7248515ca45d0ba4bbbb8c33f1bda";

  List<TokenModel> token = [];

  Future<void> initClient() async {
    _httpClient = Client();
    _web3client =
        Web3Client(AppConfig.bscMainNet, _httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(_wsBscUrl).cast<String>();
    });
  }

  Future<void> initEtherClient() async {
    _httpClient = Client();
    _etherClient =
        Web3Client(AppConfig.etherMainet, _httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(_wsEthUrl).cast<String>();
    });
  }

  Future<bool> getPending(String txHash) async {
    // Re-Initialize
    std = null;

    await initClient();

    await _web3client
        .addedBlocks()
        .asyncMap((_) async {
          try {
            // This Method Will Run Again And Again Until we return something
            await _web3client.getTransactionReceipt(txHash).then((d) {
              print("getTransactionReceipt ${d.status}");
              // Give Value To std When Request Successfully
              if (d != null) {
                print("Pending ${d.status}");
                print("Get Transaction has ${d.from}");
                std = d.status;
              }
            });

            // Return Value For True Value And Method GetTrxReceipt Also Terminate
            if (std != null) return std;
          } on FormatException catch (e) {
            // This Error Because can't Convert Hexadecimal number to integer.
            // Note: Transaction is 100% successfully And It's just error becuase of Failure Parse that hexa
            // Example-Error: 0xc, 0x3a, ...
            // Example-Success: 0x1, 0x2, 0,3 ...

            // return True For Facing This FormatException
            if (e.message.toString() == 'Invalid radix-10 number') {
              std = true;
              return std;
            }
          } catch (e) {
            print("Error $e");
          }
        })
        .where((receipt) => receipt != null)
        .first;

    return std;
  }

  void subscribeBscbalance() async {
    await initClient();
    try {
      final res = _web3client.addedBlocks();

      res.listen((event) {
        getBscBalance();
        getBscV2Balance();
        getBnbBalance();
        getKgoBalance();
      });
    } catch (e) {
      print(e.message);
    }
  }

  void subscribeEthbalance() async {
    await initEtherClient();
    try {
      final res = _etherClient.addedBlocks();

      res.listen((event) {
        getEtherBalance();
      });
    } catch (e) {
      print(e.message);
    }
  }

  Future<void> getEtherBalance() async {
    await initEtherClient();

    final ethAddr = await StorageServices().readSecure('etherAdd');
    final EtherAmount ethbalance =
        await _etherClient.getBalance(EthereumAddress.fromHex(ethAddr));
    etherNative.balance = ethbalance.getValueInUnit(EtherUnit.ether).toString();

    notifyListeners();
  }

  Future<DeployedContract> initBsc(String contractAddr) async {
    final String abiCode = await rootBundle.loadString('assets/abi/abi.json');
    final contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'BEP-20'),
      EthereumAddress.fromHex(contractAddr),
    );

    return contract;
  }

  Future<DeployedContract> initSwapSel(String contractAddr) async {
    final String abiCode = await rootBundle.loadString('assets/abi/swap.json');
    final contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'Swap'),
      EthereumAddress.fromHex(contractAddr),
    );

    return contract;
  }

  Future<DeployedContract> initEtherContract(String contractAddr) async {
    final String abiCode = await rootBundle.loadString('assets/abi/erc20.json');

    final contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'ERC-20'),
      EthereumAddress.fromHex(contractAddr),
    );

    return contract;
  }

  Future<String> approveSwap(String privateKey) async {
    final contract = await initBsc(AppConfig.selV1MainnetAddr);
    final ethFunction = contract.function('approve');

    final credentials = await _web3client.credentialsFromPrivateKey(privateKey);

    final ethAddr = await StorageServices().readSecure('etherAdd');

    final gasPrice = await _web3client.getGasPrice();

    final maxGas = await _web3client.estimateGas(
      sender: EthereumAddress.fromHex(ethAddr),
      to: contract.address,
      data: ethFunction.encodeCall(
        [
          EthereumAddress.fromHex(AppConfig.swapMainnetAddr),
          BigInt.parse('1000000000000000042420637374017961984'),
        ],
      ),
    );

    final approve = await _web3client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        gasPrice: gasPrice,
        maxGas: maxGas.toInt(),
        parameters: [
          EthereumAddress.fromHex(AppConfig.swapMainnetAddr),
          BigInt.parse('1000000000000000042420637374017961984'),
        ],
      ),
      fetchChainIdFromNetworkId: true,
    );

    return approve;
  }

  Future<dynamic> checkAllowance() async {
    final ethAddr = await StorageServices().readSecure('etherAdd');
    final res = await query(
      AppConfig.selV1MainnetAddr,
      'allowance',
      [
        EthereumAddress.fromHex(ethAddr),
        EthereumAddress.fromHex(AppConfig.swapMainnetAddr)
      ],
    );

    return res.first;
  }

  Future<String> swap(String amount, String privateKey) async {
    await initClient();

    final contract = await initSwapSel(AppConfig.swapMainnetAddr);

    final ethAddr = await StorageServices().readSecure('etherAdd');

    final gasPrice = await _web3client.getGasPrice();

    final ethFunction = contract.function('swap');

    final credentials = await _web3client.credentialsFromPrivateKey(privateKey);

    final maxGas = await _web3client.estimateGas(
      sender: EthereumAddress.fromHex(ethAddr),
      to: contract.address,
      data: ethFunction
          .encodeCall([BigInt.from(double.parse(amount) * pow(10, 18))]),
    );

    final swap = await _web3client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        from: EthereumAddress.fromHex(ethAddr),
        function: ethFunction,
        gasPrice: gasPrice,
        maxGas: maxGas.toInt(),
        parameters: [BigInt.from(double.parse(amount) * pow(10, 18))],
      ),
      fetchChainIdFromNetworkId: true,
    );

    return swap;
  }

  // Future<BigInt> getEtherTokenBalance(String contractAddr, EthereumAddress from) async {
  //   await initEtherClient();
  //   final contract =
  //       await initEtherContract(contractAddr);
  //   final ethFunction = contract.function('balanceOf');
  //   final response = await _etherClient.call(
  //     contract: contract,
  //     function: ethFunction,
  //     params: [from],
  //   );

  //   print(response.first);

  //   return response.first as BigInt;
  // }

  // Future<String> getEtherTokenSymbol(
  //     String contractAddr, EthereumAddress from) async {
  //   await initEtherClient();
  //   final contract = await initEtherContract(contractAddr);
  //   final ethFunction = contract.function('symbol');
  //   final response = await _etherClient.call(
  //     contract: contract,
  //     function: ethFunction,
  //     params: [],
  //   );

  //   print(response.first);

  //   return response.first as String;
  // }

  Future<List> queryEther(
      String contractAddress, String functionName, List args) async {
    await initEtherClient();
    final contract = await initEtherContract(contractAddress);

    final ethFunction = contract.function(functionName);

    final res = await _etherClient.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );
    return res;
  }

  Future<List> query(
      String contractAddress, String functionName, List args) async {
    initClient();
    final contract = await initBsc(contractAddress);
    final ethFunction = contract.function(functionName);

    final res = await _web3client.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );
    return res;
  }

  Future<void> getKgoSymbol() async {
    final res = await query(AppConfig.kgoAddr, 'symbol', []);

    kgoNative.symbol = res[0].toString();
    kgoNative.isContain = true;
    notifyListeners();
  }

  Future<void> getKgoDecimal() async {
    final res = await query(AppConfig.kgoAddr, 'decimals', []);
    kgoNative.chainDecimal = res[0].toString();

    notifyListeners();
  }

  Future<void> getKgoBalance() async {
    bscNative.isContain = true;

    if (ethAdd != '') {
      final res = await query(
          AppConfig.kgoAddr, 'balanceOf', [EthereumAddress.fromHex(ethAdd)]);

      String chainDecimal =
          kgoNative.chainDecimal != null ? kgoNative.chainDecimal : "0";
      kgoNative.balance = Fmt.bigIntToDouble(
        res[0] as BigInt,
        int.parse(chainDecimal),
      ).toString();
    }

    notifyListeners();
  }

  Future<void> getBscDecimal() async {
    final res = await query(AppConfig.selV1MainnetAddr, 'decimals', []);

    bscNative.chainDecimal = res[0].toString();

    notifyListeners();
  }

  Future<void> getSymbol() async {
    final res = await query(AppConfig.selV1MainnetAddr, 'symbol', []);

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

  Future<void> getEtherAddr() async {
    final ethAddr = await StorageServices().readSecure('etherAdd');
    ethAdd = ethAddr;

    notifyListeners();
  }

  Future<void> getBnbBalance() async {
    bnbNative.isContain = true;
    final ethAddr = await StorageServices().readSecure('etherAdd');
    final balance = await _web3client.getBalance(
      EthereumAddress.fromHex(ethAddr),
    );

    bnbNative.balance = balance.getValueInUnit(EtherUnit.ether).toString();

    notifyListeners();
  }

  Future<void> getBscV2Balance() async {
    bscNativeV2.isContain = true;
    await getBscDecimal();
    if (ethAdd != '') {
      final res = await query(AppConfig.selv2MainnetAddr, 'balanceOf',
          [EthereumAddress.fromHex(ethAdd)]);
      bscNativeV2.balance = Fmt.bigIntToDouble(
        res[0] as BigInt,
        int.parse(bscNative.chainDecimal),
      ).toString();
    }

    notifyListeners();
  }

  Future<void> getBscBalance() async {
    bscNative.isContain = true;
    await getBscDecimal();
    if (ethAdd != '') {
      final res = await query(AppConfig.selV1MainnetAddr, 'balanceOf',
          [EthereumAddress.fromHex(ethAdd)]);
      bscNative.balance = Fmt.bigIntToDouble(
        res[0] as BigInt,
        int.parse(bscNative.chainDecimal),
      ).toString();
    }

    notifyListeners();
  }

  Future<void> fetchNonBalance() async {
    initClient();
    for (int i = 0; i < token.length; i++) {
      if (token[i].org == 'ERC-20') {
        final contractAddr = findContractAddr(token[i].symbol);
        final decimal = await query(contractAddr, 'decimals', []);

        final balance = await query(
            contractAddr, 'balanceOf', [EthereumAddress.fromHex(ethAdd)]);

        token[i].balance = Fmt.bigIntToDouble(
          balance[0] as BigInt,
          int.parse(decimal[0].toString()),
        ).toString();
      }
    }

    notifyListeners();
  }

  Future<void> fetchEtherNonBalance() async {
    initEtherClient();
    for (int i = 0; i < token.length; i++) {
      if (token[i].org == 'ERC-20') {
        final contractAddr = findContractAddr(token[i].symbol);

        final decimal = await queryEther(contractAddr, 'decimals', []);

        final balance = await queryEther(
            contractAddr, 'balanceOf', [EthereumAddress.fromHex(ethAdd)]);

        token[i].balance = Fmt.bigIntToDouble(
          balance[0] as BigInt,
          int.parse(decimal[0].toString()),
        ).toString();
      }
    }

    notifyListeners();
  }

  Future<String> sendTxBnb(
    String privateKey,
    String reciever,
    String amount,
  ) async {
    await initClient();
    final credentials = await _web3client.credentialsFromPrivateKey(
      privateKey.substring(2),
    );

    final res = await _web3client.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(reciever),
        value:
            EtherAmount.inWei(BigInt.from(double.parse(amount) * pow(10, 18))),
      ),
      fetchChainIdFromNetworkId: true,
    );

    print("Res $res");

    return res;
  }

  Future<String> sendTxEther(
    String privateKey,
    String reciever,
    String amount,
  ) async {
    initEtherClient();
    final credentials = await _web3client.credentialsFromPrivateKey(
      privateKey.substring(2),
    );

    final res = await _etherClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(reciever),
        value:
            EtherAmount.inWei(BigInt.from(double.parse(amount) * pow(10, 18))),
      ),
      fetchChainIdFromNetworkId: true,
    );
    return res;
  }

  Future<String> sendTxBsc(
    String contractAddr,
    String chainDecimal,
    String privateKey,
    String reciever,
    String amount,
  ) async {
    await initClient();

    final contract = await initBsc(contractAddr);
    final txFunction = contract.function('transfer');
    final credentials = await _web3client.credentialsFromPrivateKey(privateKey);

    final res = await _web3client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: txFunction,
        parameters: [
          EthereumAddress.fromHex(reciever),
          BigInt.from(double.parse(amount) * pow(10, 18))
        ],
      ),
      fetchChainIdFromNetworkId: true,
    );

    return res;
  }

  Future<String> sendTxEthCon(
    String contractAddr,
    String chainDecimal,
    String privateKey,
    String reciever,
    String amount,
  ) async {
    initEtherClient();

    final contract = await initEtherContract(contractAddr);
    final txFunction = contract.function('transfer');
    final credentials =
        await _etherClient.credentialsFromPrivateKey(privateKey);

    final res = await _etherClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: txFunction,
        parameters: [
          EthereumAddress.fromHex(reciever),
          BigInt.from(double.parse(amount) * pow(10, 18))
        ],
      ),
      fetchChainIdFromNetworkId: true,
    );

    return res;
  }

  Future<void> initKmpi() async {
    kmpi.isContain = true;
    kmpi.logo = 'assets/koompi_white_logo.png';
    kmpi.symbol = 'KMPI';
    kmpi.org = 'KOOMPI';
    kmpi.id = 'koompi';

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

    notifyListeners();
  }

  Future<void> initAtd() async {
    atd.isContain = true;
    atd.logo = 'assets/FingerPrint1.png';
    atd.symbol = 'ATD';
    atd.org = 'KOOMPI';
    atd.id = 'koompi';

    await sdk.api.initAttendant();
    notifyListeners();
  }

  Future<void> fetchAtdBalance() async {
    final res = await sdk.api.getAToken(keyring.current.address);
    atd.balance = BigInt.parse(res).toString();

    notifyListeners();
  }

  Future<void> addToken(String symbol, BuildContext context,
      {String contractAddr, String network}) async {
    if (symbol == 'KMPI') {
      if (!kmpi.isContain) {
        initKmpi().then((value) async {
          await StorageServices.saveBool(kmpi.symbol, true);
        });
        Provider.of<WalletProvider>(context, listen: false)
            .addTokenSymbol(symbol);
      }
    } else if (symbol == 'SEL') {
      if (!bscNative.isContain) {
        bscNative.isContain = true;

        await StorageServices.saveBool('SEL', true);

        Provider.of<WalletProvider>(context, listen: false)
            .addTokenSymbol("$symbol (BEP-20)");

        await getSymbol();
        await getBscDecimal();
        await getBscBalance();
      }
    } else if (symbol == 'BNB') {
      if (!bnbNative.isContain) {
        bnbNative.isContain = true;

        await StorageServices.saveBool('BNB', true);

        Provider.of<WalletProvider>(context, listen: false)
            .addTokenSymbol(symbol);

        await getBscDecimal();
        getBnbBalance();
      }
    } else if (symbol == 'ATD') {
      if (!atd.isContain) {
        initAtd().then((value) async {
          await StorageServices.saveBool(atd.symbol, true);
          Provider.of<WalletProvider>(context, listen: false)
              .addTokenSymbol(symbol);
        });
      }
    } else if (symbol == 'DOT') {
      if (!ApiProvider().dot.isContain) {
        await StorageServices.saveBool('DOT', true);

        ApiProvider().connectPolNon();
        //Provider.of<ApiProvider>(context, listen: false).isDotContain();
        Provider.of<WalletProvider>(context, listen: false)
            .addTokenSymbol(symbol);
      }
    } else {
      if (network != null) {
        if (network == 'Ethereum') {
          final symbol = await queryEther(contractAddr, 'symbol', []);
          final decimal = await queryEther(contractAddr, 'decimals', []);
          final balance = await queryEther(
              contractAddr, 'balanceOf', [EthereumAddress.fromHex(ethAdd)]);

          final TokenModel mToken = TokenModel();

          mToken.symbol = symbol.first.toString();
          mToken.decimal = decimal.first.toString();
          mToken.balance = balance.first.toString();
          mToken.contractAddr = contractAddr;
          mToken.org = 'ERC-20';

          if (token.isEmpty) {
            addContractToken(mToken);

            await StorageServices.saveEthContractAddr(contractAddr);
            Provider.of<WalletProvider>(context, listen: false)
                .addTokenSymbol('${symbol[0]} (ERC-20)');
          }

          if (token.isNotEmpty) {
            if (!token.contains(mToken)) {
              addContractToken(mToken);

              await StorageServices.saveEthContractAddr(contractAddr);
              Provider.of<WalletProvider>(context, listen: false)
                  .addTokenSymbol('${symbol[0]} (ERC-20)');
            }
          }
        } else {
          final symbol = await query(contractAddr, 'symbol', []);
          final decimal = await query(contractAddr, 'decimals', []);
          final balance = await query(
              contractAddr, 'balanceOf', [EthereumAddress.fromHex(ethAdd)]);

          if (token.isNotEmpty) {
            final TokenModel item = token.firstWhere(
                (element) =>
                    element.symbol.toLowerCase() ==
                    symbol[0].toString().toLowerCase(),
                orElse: () => null);

            if (item == null) {
              addContractToken(
                TokenModel(
                  contractAddr: contractAddr,
                  decimal: decimal[0].toString(),
                  symbol: symbol[0].toString(),
                  balance: balance[0].toString(),
                  org: 'BEP-20',
                ),
              );

              await StorageServices.saveContractAddr(contractAddr);
              Provider.of<WalletProvider>(context, listen: false)
                  .addTokenSymbol('${symbol[0]} (BEP-20)');
            }
          } else {
            token.add(TokenModel(
                contractAddr: contractAddr,
                decimal: decimal[0].toString(),
                symbol: symbol[0].toString(),
                balance: balance[0].toString(),
                org: 'BEP-20'));

            await StorageServices.saveContractAddr(contractAddr);
            Provider.of<WalletProvider>(context, listen: false)
                .addTokenSymbol(symbol[0].toString());
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> addContractToken(TokenModel tokenModel) async {
    token.add(tokenModel);
    notifyListeners();
  }

  Future<void> removeEtherToken(String symbol, BuildContext context) async {
    final mContractAddr = findContractAddr(symbol);
    if (mContractAddr != null) {
      await StorageServices.removeEthContractAddr(mContractAddr);
      token.removeWhere(
        (element) => element.symbol.toLowerCase().startsWith(
              symbol.toLowerCase(),
            ),
      );

      Provider.of<WalletProvider>(context, listen: false)
          .removeTokenSymbol(symbol);
    }
    notifyListeners();
  }

  Future<void> removeToken(String symbol, BuildContext context) async {
    if (symbol == 'KMPI') {
      kmpi.isContain = false;
      await StorageServices.removeKey('KMPI');
    } else if (symbol == 'ATD') {
      atd.isContain = false;
      await StorageServices.removeKey('ATD');
    } else if (symbol == 'SEL') {
      bscNative.isContain = false;
      await StorageServices.removeKey('SEL');
    } else if (symbol == 'BNB') {
      bnbNative.isContain = false;
      await StorageServices.removeKey('BNB');
    } else if (symbol == 'DOT') {
      await StorageServices.removeKey('DOT');
      Provider.of<ApiProvider>(context, listen: false).dotIsNotContain();
    } else {
      final mContractAddr = findContractAddr(symbol);
      await StorageServices.removeContractAddr(mContractAddr);
      token.removeWhere(
        (element) => element.symbol.toLowerCase().startsWith(
              symbol.toLowerCase(),
            ),
      );
    }
    if (symbol == 'SEL') {
      Provider.of<WalletProvider>(context, listen: false)
          .removeTokenSymbol("$symbol (BEP-20)");
    } else {
      Provider.of<WalletProvider>(context, listen: false)
          .removeTokenSymbol(symbol);
    }
    notifyListeners();
  }

  String findContractAddr(String symbol) {
    final item = token.firstWhere(
      (element) => element.symbol.toLowerCase().startsWith(
            symbol.toLowerCase(),
          ),
    );
    return item.contractAddr;
  }

  Future<void> getAStatus() async {
    final res = await sdk.api.getAStatus(keyring.keyPairs[0].address);
    atd.status = res;
    notifyListeners();
  }

  void setEtherMarket(Market ethMarket, List<List<double>> lineChart,
      String currentPrice, String priceChange24h) {
    etherNative.marketData = ethMarket;
    etherNative.marketPrice = currentPrice;
    etherNative.change24h = priceChange24h;
    etherNative.lineChartData = lineChart;
    notifyListeners();
  }

  void setBnbMarket(Market bnbMarket, List<List<double>> lineChart,
      String currentPrice, String priceChange24h) {
    bnbNative.marketData = bnbMarket;
    bnbNative.marketPrice = currentPrice;
    bnbNative.change24h = priceChange24h;
    bnbNative.lineChartData = lineChart;
    notifyListeners();
  }

  void setkiwigoMarket(Market kgoMarket, List<List<double>> lineChart,
      String currentPrice, String priceChange24h) {
    kgoNative.marketData = kgoMarket;
    kgoNative.lineChartData = lineChart;
    kgoNative.marketPrice = currentPrice;
    kgoNative.change24h = priceChange24h;
    notifyListeners();
  }

  void setReady() {
    isReady = true;

    notifyListeners();
  }

  void resetConObject() {
    atd = Atd();
    kmpi = Kmpi();
    bscNative = NativeM(
      id: 'selendra',
      symbol: 'SEL',
      logo: 'assets/SelendraCircle-Blue.png',
      org: 'BEP-20',
      isContain: true,
    );
    bnbNative = NativeM(
      id: 'binance smart chain',
      logo: 'assets/bnb.png',
      symbol: 'BNB',
      // org: 'Smart Chain',
      isContain: true,
    );

    token.clear();

    notifyListeners();
  }
}
