import 'package:wallet_apps/index.dart';
import 'package:wallet_apps/src/models/m_import_acc.dart';

class ImportAccBody extends StatelessWidget {
  final bool enable;
  final String reImport;
  final ImportAccModel importAccModel;
  final String Function(String) onChanged;
  final Function onSubmit;
  final Function clearInput;
  final Function submit;

  const ImportAccBody({
    this.importAccModel,
    this.onChanged,
    this.onSubmit,
    this.clearInput,
    this.enable,
    this.reImport,
    this.submit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyScaffold(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            MyAppBar(
              color: hexaCodeToColor(AppColors.cardColor),
              title: 'Import Account',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: importAccModel.formKey,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: MyText(
                        text: 'Source Type',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: "#FFFFFF",
                        bottom: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: hexaCodeToColor(AppColors.secondary),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: const MyText(
                              text: "Seed Phrase",
                              color: "#FFFFFF",
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            child: const MyText(
                              text: "Keystore (json)",
                              // color: "#FFFFFF",
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: MyInputField(
                        pLeft: 0,
                        pRight: 0,
                        pBottom: 16.0,
                        labelText: "Seed Phrase",
                        textInputFormatter: [
                          LengthLimitingTextInputFormatter(
                              TextField.noMaxLength)
                        ],
                        controller: importAccModel.mnemonicCon,
                        focusNode: importAccModel.mnemonicNode,
                        maxLine: null,
                        onChanged: onChanged,
                        //inputAction: TextInputAction.done,
                        onSubmit: reImport!=null ? (){} : onSubmit,
                      ),
                    ),
                    if (reImport!=null) MyInputField(
                      pLeft: 0,
                      pRight: 0,
                      pBottom: 16.0,
                      labelText: "Pin",
                      textInputFormatter: [
                        LengthLimitingTextInputFormatter(4)
                      ],
                      controller: importAccModel.pwCon,
                      focusNode: importAccModel.pwNode,
                      validateField: (value) =>
                          value.isEmpty ? 'Please fill in pin' : null,
                      maxLine: null,
                      onChanged: onChanged,
                      //inputAction: TextInputAction.done,
                      onSubmit: onSubmit,
                    ) else Container(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            MyFlatButton(
              edgeMargin:
                  const EdgeInsets.only(left: 66, right: 66, bottom: 16),
              textButton: AppText.next,
              action: enable == false
                  ? null
                  : () async {
                      submit();
                    },
            )
          ],
        ),
      ),
    );
  }
}
