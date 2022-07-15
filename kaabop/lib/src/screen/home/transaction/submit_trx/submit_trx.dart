import 'dart:ui';

import 'package:provider/provider.dart';
import 'package:wallet_apps/index.dart';
import 'package:wallet_apps/src/config/asset_names.dart';
import 'package:wallet_apps/src/screen/home/transaction/submit_trx/functional_trx.dart';

class SubmitTrx extends StatefulWidget {
  final String _walletKey;
  final String asset;
  final List<dynamic> _listPortfolio;
  final bool enableInput;

  const SubmitTrx(
      // ignore: avoid_positional_boolean_parameters
      this._walletKey,
      // ignore: avoid_positional_boolean_parameters
      this.enableInput,
      this._listPortfolio,
      {this.asset});

  @override
  State<StatefulWidget> createState() {
    return SubmitTrxState();
  }
}

class SubmitTrxState extends State<SubmitTrx> {
  TrxFunctional trxFunc;

  final ModelScanPay _scanPayM = ModelScanPay();

  FlareControls flareController = FlareControls();

  AssetInfoC c = AssetInfoC();

  bool disable = false;
  final bool _loading = false;

  @override
  void initState() {
    widget.asset != null
        ? _scanPayM.asset = widget.asset
        : _scanPayM.asset = shortSelKbg;

    AppServices.noInternetConnection(_scanPayM.globalKey);

    // Initalize Functional Of Trx
    trxFunc = TrxFunctional.init(
        context: context,
        enableAnimation: enableAnimation,
        validateAddress: validateAddress);

    _scanPayM.controlReceiverAddress.text = widget._walletKey;
    _scanPayM.portfolio = widget._listPortfolio;

    super.initState();
  }

  void removeAllFocus() {
    _scanPayM.nodeAmount.unfocus();
    _scanPayM.nodeMemo.unfocus();
  }

  Future<String> dialogBox() async {
    /* Show Pin Code For Fill Out */
    final String _result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Material(
            color: Colors.transparent,
            child: FillPin(),
          );
        });

    return _result;
  }

  Future<bool> validateAddress(String address) async {
    final res = await ApiProvider.sdk.api.keyring.validateAddress(address);
    return res;
  }

  String onChanged(String value) {
    if (_scanPayM.nodeReceiverAddress.hasFocus) {
    } else if (_scanPayM.nodeAmount.hasFocus) {
      _scanPayM.formStateKey.currentState.validate();
      if (_scanPayM.formStateKey.currentState.validate()) {
        enableButton();
      } else {
        setState(() {
          _scanPayM.enable = false;
        });
      }
    }
    return value;
  }

  String validateField(String value) {
    if (value == '' || double.parse(value.toString()) < 0 || value == '-0') {
      return 'Please fill in positive amount';
    }

    return null;
  }

  void onSubmit(BuildContext context) {
    if (_scanPayM.nodeReceiverAddress.hasFocus) {
      FocusScope.of(context).requestFocus(_scanPayM.nodeAmount);
    } else if (_scanPayM.nodeAmount.hasFocus) {
      FocusScope.of(context).requestFocus(_scanPayM.nodeMemo);
    } else {
      if (_scanPayM.enable == true) clickSend();
    }
  }

  void enableButton() {
    if (_scanPayM.controlAmount.text != '' && _scanPayM.asset != null) {
      setState(() => _scanPayM.enable = true);
    } else if (_scanPayM.enable) {
      setState(() => _scanPayM.enable = false);
    }
  }

  Future enableAnimation() async {
    // Close Dialog Loading
    Navigator.pop(context);
    setState(() {
      _scanPayM.isPay = true;
      disable = true;
    });
    flareController.play('Checkmark');

    Timer(const Duration(milliseconds: 3000), () {
      Navigator.pushNamedAndRemoveUntil(
          context, Home.route, ModalRoute.withName('/'));
    });
  }

  void popScreen() {
    /* Close Current Screen */
    Navigator.pop(context, null);
  }

  void resetAssetsDropDown(String data) {
    setState(() {
      _scanPayM.asset = data;
    });
    enableButton();
  }

  Future<void> clickSend() async {
    try {
      if (_scanPayM.formStateKey.currentState.validate()) {
        /* Send payment */

        // Unfocus All Field Input
        await Future.delayed(const Duration(milliseconds: 100), () {
          unFocusAllField();
        });

        // Start Loading Before Dialog Pin
        dialogLoading(context);

        // Init member variables of Trx Functional
        trxFunc.contract =
            Provider.of<ContractProvider>(context, listen: false);

        trxFunc.api = Provider.of<ApiProvider>(context, listen: false);

        trxFunc.encryptKey = await StorageServices()
            .readSecure(_scanPayM.asset == 'btcwif' ? 'btcwif' : 'private');

        // Close Dialog
        Navigator.pop(context);

        // Show Dialog Fill PIN
        await dialogBox().then((resPin) async {
          if (resPin != null) {
            // Second: Start Loading For Sending
            dialogLoading(context);

            trxFunc.pin = resPin;

            /* ------------------Check and Get Private------------ */

            // Get Private Key Only BTC Contract
            if (_scanPayM.asset == 'BTC') {
              await trxFunc.getBtcPrivateKey(resPin);
            }
            // Get Private Key For Other Contract
            else
              await trxFunc.getPrivateKey(resPin);

            /* ------------------Check PIN------------ */
            // Pin Incorrect And Private Key Response NULL
            if (trxFunc.privateKey == null) {
              // Close Second Dialog
              Navigator.pop(context);

              await trxFunc.customDialog('Opps', 'PIN verification failed');
            }
            // Pin Correct And Response With Private Key
            else if (trxFunc.privateKey != null) {
              /* -------------Processing Transactioin----------- */
              switch (_scanPayM.asset) {
                case shortSelKbg:
                  await trxFunc.sendTx(_scanPayM.controlReceiverAddress.text,
                      _scanPayM.controlAmount.text);
                  break;

                case "KMPI":
                  await trxFunc.sendTxKmpi(
                    _scanPayM.controlReceiverAddress.text,
                    _scanPayM.controlAmount.text,
                  );
                  break;

                case shortDotEdg:
                  await trxFunc.sendTxDot(_scanPayM.controlReceiverAddress.text,
                      _scanPayM.controlAmount.text);
                  break;

                case "$shortSelKbg (BEP-20)":
                  final chainDecimal = await ContractProvider()
                      .query(AppConfig.selV1MainnetAddr, 'decimals', []);
                  print("Chain decimal $chainDecimal");
                  if (chainDecimal != null) {
                    await trxFunc.sendTxAYF(
                        AppConfig.selV1MainnetAddr,
                        chainDecimal[0].toString(),
                        _scanPayM.controlReceiverAddress.text,
                        _scanPayM.controlAmount.text);
                  }
                  break;

                case "KGO (BEP-20)":
                  final chainDecimal = await ContractProvider()
                      .query(AppConfig.kgoAddr, 'decimals', []);
                  if (chainDecimal != null) {
                    await trxFunc.sendTxAYF(
                        AppConfig.kgoAddr,
                        chainDecimal[0].toString(),
                        _scanPayM.controlReceiverAddress.text,
                        _scanPayM.controlAmount.text);
                  }
                  break;

                case shortBnbEvm:
                  await trxFunc.sendTxBnb(_scanPayM.controlReceiverAddress.text,
                      _scanPayM.controlAmount.text);
                  break;

                case "ETH":
                  await trxFunc.sendTxEther(
                      _scanPayM.controlReceiverAddress.text,
                      _scanPayM.controlAmount.text);
                  break;

                case "BTC":
                  await trxFunc.sendTxBtc(_scanPayM.controlReceiverAddress.text,
                      _scanPayM.controlAmount.text);
                  break;

                default:
                  if (_scanPayM.asset.contains('ERC-20')) {
                    final contractAddr =
                        ContractProvider().findContractAddr(_scanPayM.asset);
                    final chainDecimal = await ContractProvider()
                        .queryEther(contractAddr, 'decimals', []);
                    await trxFunc.sendTxErc(
                        contractAddr,
                        chainDecimal[0].toString(),
                        _scanPayM.controlReceiverAddress.text,
                        _scanPayM.controlAmount.text);
                  } else {
                    final contractAddr =
                        ContractProvider().findContractAddr(_scanPayM.asset);
                    final chainDecimal = await ContractProvider()
                        .query(contractAddr, 'decimals', []);
                    await trxFunc.sendTxAYF(
                        contractAddr,
                        chainDecimal[0].toString(),
                        _scanPayM.controlReceiverAddress.text,
                        _scanPayM.controlAmount.text);
                  }

                  break;
              }
            }
          }
        });
      }
    } catch (e) {
      //Close Dialog
      Navigator.pop(context);

      // Condition For RPCError
      await trxFunc.customDialog("Oops",
          "${e.runtimeType.toString() == 'RPCError' ? 'insufficient funds for gas' : e}");
    }
  }

  void unFocusAllField() {
    _scanPayM.nodeAmount.unfocus();
    _scanPayM.nodeMemo.unfocus();
    _scanPayM.nodeReceiverAddress.unfocus();
  }

  PopupMenuItem item(List list) {
    /* Display Drop Down List */
    return PopupMenuItem(
      value: list,
      child: Align(
        child: Text(
          list.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scanPayM.globalKey,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: <Widget>[
                Consumer<WalletProvider>(
                  builder: (context, value, child) {
                    return SubmitTrxBody(
                      enableInput: widget.enableInput,
                      scanPayM: _scanPayM,
                      onChanged: onChanged,
                      onSubmit: onSubmit,
                      clickSend: clickSend,
                      validateField: validateField,
                      resetAssetsDropDown: resetAssetsDropDown,
                      list: value.listSymbol,
                    );
                  },
                ),
                if (_scanPayM.isPay == false)
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
                          child: CustomAnimation.flareAnimation(
                            flareController,
                            "assets/animation/check.flr",
                            "Checkmark",
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
