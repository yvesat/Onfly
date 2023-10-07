import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/enums/alert_type.dart';

class Alert {
  dialog(BuildContext context, {required AlertType alertType, required String message, VoidCallback? onPressed}) {
    String title = alertType.text;
    String okButton = "OK";
    String? cancelButton = "CANCELAR";

    if (alertType == AlertType.warning) {
      okButton = "CONFIRMAR";
      cancelButton = "CANCELAR";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      if (alertType == AlertType.warning) {
                        onPressed == null ? Navigator.pop(context) : onPressed();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(okButton),
                  ),
                  if (alertType == AlertType.warning)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(cancelButton!),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  snack(BuildContext context, String mensagem, {String? botao}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(
          mensagem,
        ),
      ),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(label: (botao ?? "OK"), onPressed: () {}),
    ));
  }
}

final alertaProvider = Provider((_) => Alert());
