import 'package:flutter/material.dart';
import '../../extensions/double_extension.dart';

import '../../dialogs/core/index.dart';
import '../../services/core/index.dart';
import '../../widgets/index.dart';
import '../index.dart';

class CacheComponent extends StatefulWidget {
  const CacheComponent({super.key});

  @override
  State<CacheComponent> createState() => _CacheComponentState();
}

class _CacheComponentState extends State<CacheComponent> {
  @override
  Widget build(BuildContext context) {
    if (CacheServices.getCacheCount() == 0) {
      return SizedBox.shrink();
    }
    return ListTileWithDesc(
      onClick: () {
        showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            contentText: 'Clean Cache',
            submitText: 'Clean',
            onCancel: () {},
            onSubmit: () async {
              showMessage(context, 'Cache Cleanning...');
              await CacheServices.cleanCache();
              setState(() {});
            },
          ),
        );
      },
      leading: const Icon(Icons.delete_forever),
      title: 'Clean Cache',
      desc:
          'Cache - Count:${CacheServices.getCacheCount()} - Size:${CacheServices.getCacheSize().toDouble().toFileSizeLabel()} ',
    );
  }
}
