import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:wallet_apps/index.dart';

class AddAsset extends StatefulWidget {
  static const route = '/addasset';
  @override
  State<StatefulWidget> createState() {
    return AddAssetState();
  }
}

class AddAssetState extends State<AddAsset> {
  final ModelAsset _modelAsset = ModelAsset();

  final FlareControls _flareController = FlareControls();

  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  FlareControls flareController = FlareControls();
  String _tokenSymbol = '', initialValue = 'Ethereum';

  @override
  void initState() {
    _modelAsset.result = {};
    _modelAsset.match = false;
    AppServices.noInternetConnection(globalKey);

    super.initState();
  }

  // Future<void> dialog(String text1, String text2, {Widget action}) async {
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  //         title: Align(
  //           child: Text(text1),
  //         ),
  //         content: Padding(
  //           padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
  //           child: Text(text2),
  //         ),
  //         actions: <Widget>[
  //           FlatButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<bool> validateEtherAddress(String address) async {
    final res = await ApiProvider.sdk.api.validateEtherAddr(address);
    return res;
  }

  Future<bool> validateAddress(String address) async {
    final res = await ApiProvider.sdk.api.keyring.validateAddress(address);
    return res;
  }

  void validateAllFieldNotEmpty() {
    // Validator 1 : All Field Not Empty
    if (_modelAsset.controllerAssetCode.text.isNotEmpty &&
        _modelAsset.controllerIssuer.text.isNotEmpty) {
      validateAllFieldNoError();
    } else if (_modelAsset.enable) {
      enableButton(false);
    } // Disable Button If All Field Not Empty
  }

  void validateAllFieldNoError() {
    if (_modelAsset.responseAssetCode == null &&
        _modelAsset.responseIssuer == null) {
      enableButton(true); // Enable Button If All Field Not Empty
    } else if (_modelAsset.enable) {
      enableButton(false);
    } // Disable Button If All Field Not Empty
  }

  // ignore: avoid_positional_boolean_parameters
  void enableButton(bool enable) {
    setState(() {
      _modelAsset.enable = enable;
    });
  }

  Future<void> addAsset() async {
    dialogLoading(context);
    if (_modelAsset.match) {
      Provider.of<ContractProvider>(context, listen: false)
          .addToken(ContractProvider().kmpi.symbol, context);
    } else {
      Provider.of<ContractProvider>(context, listen: false).addToken(
        _tokenSymbol,
        context,
        network: initialValue,
        contractAddr: _modelAsset.controllerAssetCode.text,
      );
    }
    await enableAnimation();
  }

  Future<void> submitAsset() async {

    setState(() {
      _modelAsset.loading = true;
    });

    final resEther = await validateEtherAddress(_modelAsset.controllerAssetCode.text);
    final res = await validateAddress(_modelAsset.controllerAssetCode.text);

    if (res || resEther) {
      if (res) {
        if (_modelAsset.controllerAssetCode.text == AppConfig.kmpiAddr) {
          setState(() {
            _modelAsset.match = true;
            _modelAsset.loading = false;
          });
        }
      } else {
        if (initialValue == 'Ethereum') {
          searchEtherContract();
        } else {
          final res = await Provider.of<ContractProvider>(context, listen: false).query(_modelAsset.controllerAssetCode.text, 'symbol', []);
          if (res != null) {
            setState(() {
              _tokenSymbol = res[0].toString();
              _modelAsset.loading = false;
            });
          }
        }
      }
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Align(
                child: Text('Opps'),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Text('Invalid token contract address!'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ]);
        },
      );
      //await dialog('Invalid token contract address!', 'Opps');
      setState(() {
        _modelAsset.loading = false;
      });
    }
  }

  Future<void> searchEtherContract() async {
    try {
      final res = await Provider.of<ContractProvider>(context, listen: false)
          .queryEther(_modelAsset.controllerAssetCode.text, 'symbol', []);

      if (res != null) {
        setState(() {
          _tokenSymbol = res[0].toString();
          _modelAsset.loading = false;
        });
      }
    } catch (e) {}
  }

  void onSubmit() {
    if (_modelAsset.formStateAsset.currentState.validate()) {
      submitAsset();
    }
  }

  String onChanged(String textChange) {
    if (_modelAsset.formStateAsset.currentState.validate()) {
      enableButton(true);
    } else {
      enableButton(false);
    }

    return null;
  }

  void onChangeDropDown(String network) {
    setState(() {
      initialValue = network;
    });
  }

  void qrRes(String value) {
    if (value != null) {
      setState(() {
        _modelAsset.controllerAssetCode.text = value;
        _modelAsset.enable = true;
      });
    }
  }

  void popScreen() {
    Navigator.pop(context, {});
  }

  Future<void> enableAnimation() async {
    Navigator.pop(context);
    setState(() {
      _modelAsset.added = true;
    });
    flareController.play('Checkmark');

    Timer(const Duration(milliseconds: 2500), () {
      Navigator.pushNamedAndRemoveUntil(
          context, Home.route, ModalRoute.withName('/'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      key: globalKey,
      body: Stack(
        children: [
          AddAssetBody(
            assetM: _modelAsset,
            initialValue: initialValue,
            onChangeDropDown: onChangeDropDown,
            addAsset: addAsset,
            popScreen: popScreen,
            onChanged: onChanged,
            qrRes: qrRes,
            tokenSymbol: _tokenSymbol,
            onSubmit: onSubmit,
            submitAsset: submitAsset,
          ),
          if (_modelAsset.added == false)
            Container()
          else
            BackdropFilter(
              // Fill Blur Background
              filter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: CustomAnimation.flareAnimation(_flareController,
                        "assets/animation/check.flr", "Checkmark"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
