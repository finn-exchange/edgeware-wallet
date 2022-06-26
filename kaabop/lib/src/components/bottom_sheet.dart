import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/kabob_sdk.dart';
import 'package:provider/provider.dart';
import 'package:wallet_apps/index.dart';

class MyBottomSheet {
  dynamic response;

  Future<dynamic> trxOptions({
    BuildContext context,
    List portfolioList,
    WalletSDK sdk,
    Keyring keyring,
  }) {
    final isDarkTheme =
        Provider.of<ThemeProvider>(context, listen: false).isDark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkTheme
                ? hexaCodeToColor(AppColors.darkBgd)
                : hexaCodeToColor(AppColors.bgdColor),
          ),
          height: 153,
          child: Column(
            children: [
              Align(
                child: MyText(
                  color: isDarkTheme
                      ? AppColors.whiteColorHexa
                      : AppColors.textColor,
                  top: 20,
                  bottom: 33,
                  text: "Transaction options",
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: MyBottomSheetItem(
                      subTitle: "Scan wallet",
                      icon: "icons/qr_code.svg",
                      action: () async {
                        try {
                          await TrxOptionMethod.scanQR(
                            context,
                            portfolioList,
                          );
                        } catch (e) {
                          //  print(e.message);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: MyBottomSheetItem(
                      icon: "icons/form.svg",
                      subTitle: "Fill wallet",
                      action: () {
                        TrxOptionMethod.navigateFillAddress(
                          context,
                          portfolioList,
                          sdk,
                          keyring,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: MyBottomSheetItem(
                      icon: "icons/contact.svg",
                      subTitle: "Invite friend",
                      action: () async {
                        // TrxOptionMethod.selectContact(
                        //     context, portfolioList);
                        await dialog(
                          context,
                          'Coming Soon!',
                          'Invite friend',
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> dialog(BuildContext context, String text1, String text2,
      {Widget action}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Align(
            child: Text(text1),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Text(
              text2,
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> notification({BuildContext context}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(color: hexaCodeToColor(AppColors.bgdColor)),
          height: MediaQuery.of(context).size.height - 107,
          child: Column(
            children: [
              const Align(
                child: MyText(
                  color: "#FFFFFF",
                  top: 20,
                  bottom: 33,
                  text: "Notification",
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/no_data.svg', height: 200),
                    const MyText(text: "There are no notification found")
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
