import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Represents a dialog that is shown to the user.
/// It can only be dismissed by pressing the "OK" button.
class ESenseDialog {

  /// Builds a dialog with the given String title, text.
  /// The context is passed so that the dialog knows where to show up.
  ///
  /// return: The dialog.
  static Future<void> showBluetoothDialog(BuildContext context, String title, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
