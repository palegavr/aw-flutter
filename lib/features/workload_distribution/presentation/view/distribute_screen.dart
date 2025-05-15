import 'package:flutter/material.dart';

import 'package:aw_flutter/widgets.dart';

class DistributeScreen extends StatelessWidget {
  static const routeName = '/distribute';

  const DistributeScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    const enableExport = true;

    return Scaffold(
      appBar: awSimpleAppBar(),
      body: const Column(children: [Text('Import Screen')]),
      floatingActionButton: const FloatingActionButton.extended(
        label: Text('Експорт'),
        icon: Icon(Icons.file_download_rounded),
        disabledElevation: enableExport ? null : 0,
        mouseCursor:
            enableExport ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onPressed: null,
      ),
    );
  }
}
