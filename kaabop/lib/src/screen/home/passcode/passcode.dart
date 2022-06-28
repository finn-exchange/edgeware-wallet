import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:wallet_apps/index.dart';

class Passcode extends StatefulWidget {
  final String isHome;
  final bool isAppBar;

  const Passcode({this.isAppBar = false, this.isHome});

  //static const route = '/passcode';

  @override
  _PasscodeState createState() => _PasscodeState();
}

class _PasscodeState extends State<Passcode> {
  final TextEditingController pinOneController = TextEditingController();

  final TextEditingController pinTwoController = TextEditingController();

  final TextEditingController pinThreeController = TextEditingController();

  final TextEditingController pinFourController = TextEditingController();

  final TextEditingController pinFiveController = TextEditingController();

  final TextEditingController pinSixController = TextEditingController();

  final localAuth = LocalAuthentication();

  GlobalKey<ScaffoldState> globalkey;

  int pinIndex = 0;

  String firstPin;

  bool _isFirst = false;

  List<String> currentPin = ["", "", "", "", "", ""];

  final outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(80),
    borderSide: const BorderSide(
      color: Colors.transparent,
    ),
  );

  @override
  void initState() {
    authToHome();
    super.initState();
  }

  Future<void> authToHome() async {
    if (widget.isHome != null) {
      final bio = await StorageServices.readSaveBio();
      if (bio) {
        authenticate();
      }
    }
  }

  // Check User Had Set PassCode
  Future<void> passcodeAuth(String pin) async {
    final res = await StorageServices().readSecure('passcode');

    if (res == pin) {
      Navigator.pushReplacementNamed(context, Home.route);
    } else {
      clearAll();
      Vibration.vibrate(amplitude: 500);
    }
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
  //           action
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> authenticate() async {
    bool authenticate = false;

    try {
      authenticate = await localAuth.authenticate(
        localizedReason: '',
        stickyAuth: true,
      );

      if (authenticate) {
        // Pop With Data For Refresh Menu
        Navigator.pop(context, true);
      }
    } on SocketException catch (e) {
      await Future.delayed(const Duration(milliseconds: 300), () {});
      AppServices.openSnackBar(globalkey, e.message);
    } catch (e) {
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
              child: Text(e.message.toString()),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      key: globalkey,
      body: BodyScaffold(
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                children: <Widget>[
                  // Show AppBar Only In Landing Pages
                  if (widget.isAppBar)
                    MyAppBar(
                      title: "Set Passcode",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  else
                    Container(),
                  Container(
                    height: MediaQuery.of(context).size.height - 130,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 54,
                        ),
                        Text(
                          _isFirst
                              ? 'Enter 6-Digits Code'
                              : 'Re-enter 6-Digits Code',
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildPinRow(),
                        const SizedBox(height: 52),
                        ReuseNumPad(pinIndexSetup, clearPin),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ReusePinNum(outlineInputBorder, pinOneController),
        SizedBox(width: 16),
        ReusePinNum(outlineInputBorder, pinTwoController),
        SizedBox(width: 16),
        ReusePinNum(outlineInputBorder, pinThreeController),
        SizedBox(width: 16),
        ReusePinNum(outlineInputBorder, pinFourController),
        SizedBox(width: 16),
        ReusePinNum(outlineInputBorder, pinFiveController),
        SizedBox(width: 16),
        ReusePinNum(outlineInputBorder, pinSixController),
      ],
    );
  }

  void clearPin() {
    if (pinIndex == 0) {
      pinIndex = 0;
    } else if (pinIndex == 6) {
      setPin(pinIndex, "");
      pinIndex--;
    } else {
      setPin(pinIndex, "");
      currentPin[pinIndex - 1] = "";
      pinIndex--;
    }
  }

  Future<void> pinIndexSetup(String text) async {
    if (pinIndex == 0) {
      pinIndex = 1;
    } else if (pinIndex < 6) {
      pinIndex++;
    }
    setPin(pinIndex, text);
    currentPin[pinIndex - 1] = text;
    String strPin = "";
    // ignore: avoid_function_literals_in_foreach_calls
    currentPin.forEach((element) {
      strPin += element;
    });
    if (pinIndex == 6) {
      final res = await StorageServices().readSecure('passcode');

      if (widget.isHome != null) {
        passcodeAuth(strPin);
      } else {
        if (res == null) {
          setVerifyPin(strPin);
        } else {
          clearVerifyPin(strPin);
        }
      }
    }
  }

  Future<void> clearVerifyPin(String pin) async {
    if (firstPin == null) {
      firstPin = pin;

      clearAll();
      setState(() {
        _isFirst = true;
      });
    } else {
      if (firstPin == pin) {
        await StorageServices().clearKeySecure('passcode');
        Navigator.pop(context, false);
      } else {
        clearAll();
        Vibration.vibrate(amplitude: 500);
      }
    }
  }

  Future<void> setVerifyPin(String pin) async {
    if (firstPin == null) {
      firstPin = pin;

      clearAll();
      setState(() {
        _isFirst = true;
      });
    } else {
      if (firstPin == pin) {
        print("Set pin");
        await StorageServices().writeSecure('passcode', pin);
        Navigator.pop(context, true);
      } else {
        clearAll();
        Vibration.vibrate(amplitude: 500);
      }
    }
  }

  void clearAll() {
    for (int i = 0; i < 6; i++) {
      clearPin();
    }
  }

  void setPin(int n, String text) {
    switch (n) {
      case 1:
        pinOneController.text = text;
        break;
      case 2:
        pinTwoController.text = text;
        break;
      case 3:
        pinThreeController.text = text;
        break;
      case 4:
        pinFourController.text = text;
        break;
      case 5:
        pinFiveController.text = text;
        break;
      case 6:
        pinSixController.text = text;
        break;
    }
  }
}

class ReusePinNum extends StatelessWidget {
  final OutlineInputBorder outlineInputBorder;

  final TextEditingController textEditingController;

  const ReusePinNum(this.outlineInputBorder, this.textEditingController);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.0,
      height: 40.0,
      child: TextField(
        controller: textEditingController,
        enabled: false,
        obscureText: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            bottom: 2,
            left: 3,
            top: 5,
            right: 0,
          ),
          border: outlineInputBorder,
          filled: true,
          fillColor: Colors.grey[300],
        ),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 42,
          color: hexaCodeToColor(
            AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

class ReuseNumPad extends StatelessWidget {
  final Function pinIndexSetup;
  final Function clearPin;

  const ReuseNumPad(this.pinIndexSetup, this.clearPin);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildNumberPad(context),
    );
  }

  Widget _buildNumberPad(context) {
    final isDarkTheme =
        Provider.of<ThemeProvider>(context, listen: false).isDark;
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ReuseKeyBoardNum(1, () {
                pinIndexSetup('1');
              }),
              ReuseKeyBoardNum(2, () {
                pinIndexSetup('2');
              }),
              ReuseKeyBoardNum(3, () {
                pinIndexSetup('3');
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ReuseKeyBoardNum(4, () {
                pinIndexSetup('4');
              }),
              ReuseKeyBoardNum(5, () {
                pinIndexSetup('5');
              }),
              ReuseKeyBoardNum(6, () {
                pinIndexSetup('6');
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ReuseKeyBoardNum(7, () {
                pinIndexSetup('7');
              }),
              ReuseKeyBoardNum(8, () {
                pinIndexSetup('8');
              }),
              ReuseKeyBoardNum(9, () {
                pinIndexSetup('9');
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                width: 60.0,
                child: MaterialButton(
                  onPressed: null,
                  child: SizedBox(),
                ),
              ),
              ReuseKeyBoardNum(0, () {
                pinIndexSetup('0');
              }),
              SizedBox(
                width: 60,
                child: MaterialButton(
                  height: 60,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60.0),
                  ),
                  onPressed: () {
                    clearPin();
                  },
                  child: Icon(
                    Icons.backspace,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ReuseKeyBoardNum extends StatelessWidget {
  final int n;
  final Function() onPressed;

  const ReuseKeyBoardNum(this.n, this.onPressed);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<ThemeProvider>(context).isDark;
    return Container(
      width: 120,
      height: 120,
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: MaterialButton(
        shape: CircleBorder(side: BorderSide.none),
        color: hexaCodeToColor(AppColors.secondary),
        padding: const EdgeInsets.all(8.0),
        onPressed: onPressed,
        child: Center(
          child: Text(
            '$n',
            style: TextStyle(
              fontSize: 28 * MediaQuery.of(context).textScaleFactor,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
