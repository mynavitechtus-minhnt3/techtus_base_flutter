import 'package:flutter/material.dart';

import '../../index.dart';

class MaintenanceModeDialog extends StatelessWidget {
  const MaintenanceModeDialog({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      body: Padding(
        padding: EdgeInsets.all(24.rps),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: CommonImage.asset(
                path: image.imageAppIcon,
                width: 128.rps,
                height: 128.rps,
              ),
            ),
            SizedBox(height: 32.rps),
            CommonText(
              l10n.maintenanceTitle,
              style: style(
                height: 1.18,
                color: color.black,
                fontSize: 16.rps,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.rps),
            CommonText(
              message,
              style: style(
                height: 1.5,
                color: color.black,
                fontSize: 14.rps,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
