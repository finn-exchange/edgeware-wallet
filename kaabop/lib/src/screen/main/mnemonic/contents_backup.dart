import 'package:polkawallet_sdk/kabob_sdk.dart';
import 'package:provider/provider.dart';
import 'package:wallet_apps/index.dart';

class ContentsBackup extends StatefulWidget {
  //static const route = '/contentsBackup';

  @override
  _ContentsBackupState createState() => _ContentsBackupState();
}

class _ContentsBackupState extends State<ContentsBackup> {

  final double bpSize = 16.0;
  String _passPhrase = '';
  List _passPhraseList = [];

  Future<void> _generateMnemonic() async {
    try {
      print("Generate");
      
      print("Generating");
      _passPhrase = await ApiProvider.sdk.api.keyring.generateMnemonic();
      print("passPhrase $_passPhrase");
      _passPhraseList = _passPhrase.split(' ');

      // setState(() {});
    } on PlatformException catch (p) {
      print("Platform $p");
    }  catch (e){
      print("error $e");
    }
  }

  @override
  void initState() {
    _generateMnemonic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      body: BodyScaffold(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [

            MyAppBar(
              title: AppText.createAccTitle,
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MyText(
                      text: AppText.backup,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme
                        ? AppColors.whiteColorHexa
                        : AppColors.textColor,
                      bottom: bpSize,
                    )
                  ),
                  MyText(
                    textAlign: TextAlign.left,
                    text: AppText.getMnemonic,
                    fontWeight: FontWeight.w500,
                    color: isDarkTheme
                      ? AppColors.whiteColorHexa
                      : AppColors.textColor,
                    bottom: bpSize,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MyText(
                      text: AppText.backupPassphrase,
                      textAlign: TextAlign.left,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme
                        ? AppColors.whiteColorHexa
                        : AppColors.textColor,
                      bottom: bpSize,
                    )
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MyText(
                      textAlign: TextAlign.left,
                      text: AppText.keepMnemonic,
                      fontWeight: FontWeight.w500,
                      color: isDarkTheme
                        ? AppColors.whiteColorHexa
                        : AppColors.textColor,
                      bottom: bpSize,
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: MyText(
                        text: AppText.offlineStorage,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme
                            ? AppColors.whiteColorHexa
                            : AppColors.textColor,
                        bottom: bpSize,
                      )),
                  MyText(
                    textAlign: TextAlign.left,
                    text: AppText.mnemonicAdvise,
                    fontWeight: FontWeight.w500,
                    color: isDarkTheme
                        ? AppColors.whiteColorHexa
                        : AppColors.textColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            MyFlatButton(
              edgeMargin: const EdgeInsets.only(left: 66, right: 66, bottom: 16),
              hasShadow: true,
              textButton: AppText.next,
              action: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateMnemonic(
                      _passPhrase,
                      _passPhraseList,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
