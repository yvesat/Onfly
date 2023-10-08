import 'package:flutter/material.dart';

class Progress extends StatelessWidget {
  final Size size;
  final String loadingMessage;

  const Progress(this.size, {super.key, this.loadingMessage = ""});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        alignment: AlignmentDirectional.center,
        height: size.height,
        width: size.width,
        color: Colors.black.withOpacity(0.7),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle(
                style: const TextStyle(),
                child: Text(
                  loadingMessage,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
