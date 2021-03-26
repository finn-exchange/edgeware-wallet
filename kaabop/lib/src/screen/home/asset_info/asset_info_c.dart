import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wallet_apps/src/provider/api_provider.dart';


import '../../../../index.dart';

class AssetInfoC {
  bool transferFrom = false;

  void showRecieved(
    BuildContext context,
    GetWalletMethod _method,
    {String symbol}
  ) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        final _keyQrShare = GlobalKey();
        final _globalKey = GlobalKey<ScaffoldState>();
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Scaffold(
            key: _globalKey,
            body: Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.only(top: 27.0),
                color: Color(AppUtils.convertHexaColor(AppColors.bgdColor)),
                child: symbol != null ? Consumer<ContractProvider>(
                  builder: (context,value,child){
                     return ReceiveWalletBody(
                      method: _method,
                      globalKey: _globalKey,
                      keyQrShare: _keyQrShare,
                      name: ApiProvider.keyring.current.name,
                      wallet: value.ethAdd
                    );
                  },
                ): Consumer<ApiProvider>(
                  builder: (context, value, child) {
                    return ReceiveWalletBody(
                      method: _method,
                      globalKey: _globalKey,
                      keyQrShare: _keyQrShare,
                      name: value.accountM.name,
                      wallet: value.accountM.address,
                    );
                  },
                )),
          ),
        );
      },
    );
  }
}
