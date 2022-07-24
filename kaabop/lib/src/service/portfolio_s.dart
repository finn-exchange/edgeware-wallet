import 'package:provider/provider.dart';
import 'package:wallet_apps/index.dart';

class PortfolioServices {

  void setPortfolio(BuildContext context) {

    final contract = Provider.of<ContractProvider>(context, listen: false);
    
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    walletProvider.clearPortfolio();

    final api = Provider.of<ApiProvider>(context, listen: false);
    if (contract.atd.isContain) {
      walletProvider.addAvaibleToken({
        'symbol': contract.atd.symbol,
        'balance': contract.atd.balance ?? '0',
      });
    }

    walletProvider.addAvaibleToken({
      'symbol': contract.bnbNative.symbol,
      'balance': contract.bnbNative.balance ?? '0',
    });

    if (api.btc.isContain) {
      walletProvider.addAvaibleToken({
        'symbol': api.btc.symbol,
        'balance': api.btc.balance ?? '0',
      });
    }

    if (api.dot.balance == null) {
      walletProvider.addAvaibleToken({
        'symbol': api.dot.symbol,
        'balance': '0',
      });
    } else {
      walletProvider.addAvaibleToken({
        'symbol': api.dot.symbol,
        'balance': api.dot.balance.replaceAll(RegExp(','), '') ?? '0',
      });
    }

    walletProvider.addAvaibleToken({
      'symbol': '${contract.kgoNative.symbol} (BEP-20)',
      'balance': contract.kgoNative.balance ?? '0',
    });

    walletProvider.addAvaibleToken({
      'symbol': '${contract.etherNative.symbol} (BEP-20)',
      'balance': contract.etherNative.balance ?? '0',
    });

    if (contract.token.isNotEmpty) {
      for (int i = 0; i < contract.token.length; i++) {
        walletProvider.addAvaibleToken({
          'symbol': '${contract.token[i].symbol} (BEP-20)',
          'balance': contract.token[i].balance ?? '0',
        });
      }
    }

    walletProvider.getPortfolio();
  }
}