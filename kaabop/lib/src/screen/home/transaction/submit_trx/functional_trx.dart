import 'dart:math';

import 'package:intl/intl.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:provider/provider.dart';
import 'package:wallet_apps/index.dart';

import '../../../../config/asset_names.dart';

class TrxFunctional {

  ApiProvider api;

  String pin;

  String encryptKey;

  String privateKey;

  ContractProvider contract;

  final BuildContext context;

  final Function enableAnimation;

  final Function validateAddress;

  TrxFunctional.init({this.context, this.enableAnimation, this.validateAddress});


  /*  ---------------Message-------------- */
  Future<void> customDialog(String text1, String text2) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Align(
            child: MyText(text: text1, fontWeight: FontWeight.w600,),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Text(text2, textAlign: TextAlign.center,),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /* --------------Local Storage----------------- */

  Future<String> getBtcPrivateKey(String pin) async {

    // String privateKey;

    try {
      privateKey = await ApiProvider.keyring.store.decryptPrivateKey(encryptKey, pin);
    } catch (e) {
      await customDialog('Opps', 'PIN verification failed');
    }

    return privateKey;
  }

  Future<String> getPrivateKey(String pin) async {
    
    try {
      privateKey = await ApiProvider.keyring.store.decryptPrivateKey(encryptKey, pin);
    } catch (e) {
      await customDialog('Opps', '$e');
    }

    return privateKey;
  }

  Future<void> saveTxHistory(TxHistory txHistory) async {
    await StorageServices.addTxHistory(txHistory, 'txhistory');
  }

  /* ------------------Transaction--------------- */

  Future<void>  sendTxBnb(String reciever, String amount) async {

    print("BNB");
    if (privateKey != null) {

      final hash = await contract.sendTxBnb(privateKey, reciever, amount);

      print("has $hash");
     
      if (hash != null) {
        await contract.getPending(hash).then((value) async {
          if (value == false){
            await Provider.of<ContractProvider>(context, listen: false).getBscBalance();
            Navigator.pop(context);
            await customDialog('Transaction failed', 'Something went wrong with your transaction.');
          } else {
            enableAnimation();
          }
        });
      } else {
        throw hash;
      }
    } else {

      // Close Dialog
      Navigator.pop(context);
      await customDialog("Oops", "The PIN you entered is incorrect");
    }
  }

  Future<void> sendTxBtc(String to, String amount) async {

    final resAdd = await api.validateBtcAddr(to);

    if (resAdd) {
      final res = await api.sendTxBtc(context, api.btcAdd, to, double.parse(amount), privateKey);
      if (res == 200) {
        enableAnimation();
      } else {
        Navigator.pop(context);
        await customDialog('Opps', 'Something went wrong!');
      }
    } else {
      Navigator.pop(context);
      await customDialog('Opps', 'Invalid Address');
    }
  }

  Future<void> sendTxEther(String reciever, String amount) async {

    try {

      if (privateKey != null) {
        final hash = await contract.sendTxEther(privateKey, reciever, amount);
        if (hash != null) {
          await contract.getPending(hash).then((value) async {
            if (value == false){
              Navigator.pop(context);
              await customDialog('Transaction failed', 'Something went wrong with your transaction.');
            } else {
              enableAnimation();
            }
          });
        } else {
          Navigator.pop(context);
          await customDialog('Opps', 'Something went wrong!');
        }
      }
    } catch (e) {
      Navigator.pop(context);
      await customDialog('Opps', e.message.toString());
    }
  }

  Future<void> sendTxAYF(String contractAddr, String chainDecimal, String reciever, String amount) async {

    final contract = Provider.of<ContractProvider>(context, listen: false);

    try {

      if (privateKey != null) {
        final hash = await contract.sendTxBsc(
          contractAddr,
          chainDecimal,
          privateKey,
          reciever,
          amount,
        );

        print("Trx hash $hash");
       
        if (hash != null) {

          await contract.getPending(hash).then((value) async {
            if (value == false){
              await Provider.of<ContractProvider>(context, listen: false).getBscBalance();
              Navigator.pop(context);
              await customDialog('Transaction failed', 'insufficient funds for gas');
            } else {
              enableAnimation();
            }
          });

        } else {
          Navigator.pop(context);
          await customDialog('Opps', 'Something went wrong!');
        }
      }
      // Res equal NULL 
      else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      await customDialog('Opps', e.message.toString());
    }
  }

  Future<void> sendTxErc(String contractAddr, String chainDecimal, String reciever, String amount) async {
    try {

      if (privateKey != null) {
        final hash = await contract.sendTxEthCon(
          contractAddr,
          chainDecimal,
          privateKey,
          reciever,
          amount,
        );

        if (hash != null) {
          await contract.getPending(hash).then((value) async {
            if (value == false){
              await Provider.of<ContractProvider>(context, listen: false).getBscBalance();
              Navigator.pop(context);
              await customDialog('Transaction failed', 'Something went wrong with your transaction.');
            } else {
              enableAnimation();
            }
          });
        } else {
          Navigator.pop(context);
          await customDialog('Opps', 'Something went wrong!');
        }
      }
    } catch (e) {
      Navigator.pop(context);
      await customDialog('Opps', e.message.toString());
    }
  }



  Future<void> sendTxKmpi(String to, String amount) async {
    // dialogLoading(
    //   context,
    //   content: 'Please wait! This might be taking some time.',
    // );

    try {
      final res = await ApiProvider.sdk.api.keyring.contractTransfer(
        ApiProvider.keyring.keyPairs[0].pubKey,
        to,
        amount,
        pin,
        Provider.of<ContractProvider>(context, listen: false).kmpi.hash,
      );

      if (res['status'] != null) {
        
        Provider.of<ContractProvider>(context, listen: false).fetchKmpiBalance();

        await saveTxHistory(
          TxHistory(
            date: DateFormat.yMEd().add_jms().format(DateTime.now()).toString(),
            symbol: 'KMPI',
            destination: to,
            sender: ApiProvider.keyring.current.address,
            org: 'KOOMPI',
            amount: amount.trim(),
          )
        );

        await enableAnimation();
      }
    } catch (e) {
      Navigator.pop(context);
      await customDialog('Opps', e.message.toString());
    }
  }

  Future<String> sendTx(String target, String amount) async {

    String mhash;

    final res = await validateAddress(target);

    if (res) {

      final sender = TxSenderData(
        ApiProvider.keyring.current.address,
        ApiProvider.keyring.current.pubKey,
      );
      final txInfo = TxInfoData('balances', 'transfer', sender);
      final chainDecimal = Provider.of<ApiProvider>(context, listen: false).nativeM.chainDecimal;
      try {
        final hash = await ApiProvider.sdk.api.tx.signAndSend(
          txInfo,
          [
            target,
            Fmt.tokenInt(
              amount.trim(),
              int.parse(chainDecimal),
            ).toString(),
          ],
          pin,
          onStatusChange: (status) async {}
        );

        if (hash != null) {

          await saveTxHistory(
            TxHistory(
              date: DateFormat.yMEd().add_jms().format(DateTime.now()).toString(),
              symbol: shortSelKbg,
              destination: target,
              sender: ApiProvider.keyring.current.address,
              org: 'SELENDRA',
              amount: amount.trim(),
            )
          );

          await enableAnimation();
        } else {
          
          Navigator.pop(context);
          await customDialog('Opps', 'Something went wrong!');
        }
      } catch (e) {
       
        Navigator.pop(context);
        await customDialog('Opps', e.message.toString());
      }
    } else {
      Navigator.pop(context);
      await customDialog('Opps', 'Invalid Address');
    }

    return mhash;
  }

  Future<String> sendTxDot(String target, String amount) async {

    String mhash;
    
    final sender = TxSenderData(
      ApiProvider.keyring.current.address,
      ApiProvider.keyring.current.pubKey,
    );
    final txInfo = TxInfoData('balances', 'transfer', sender);

    try {
      final hash = await ApiProvider.sdk.api.tx.signAndSendDot(
        txInfo, [target, pow(double.parse(amount) * 10, 12)], pin,
        onStatusChange: (status) async {
          
        }
      );

      if (hash != null) {
        await enableAnimation();
      } else {
        Navigator.pop(context);
        await customDialog('Opps', 'Something went wrong!');
      }
    } catch (e) {
      Navigator.pop(context);

      await customDialog('Opps', e.message.toString());
    }

    return mhash;
  }
}