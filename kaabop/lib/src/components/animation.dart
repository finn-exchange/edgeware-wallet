import 'package:wallet_apps/index.dart';

class CustomAnimation{

  static Widget flareAnimation(FlareControls flareControls, String filePath, String animation){
    return FlareActor(
      filePath,
      fit: BoxFit.cover,
      animation: animation,
      controller: flareControls,
    );
  }
}