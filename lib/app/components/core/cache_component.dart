import 'package:flutter/material.dart';

import '../../dialogs/core/index.dart';
import '../../services/core/index.dart';
import '../../utils/index.dart';
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
    if (getCacheCount() == 0) {
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
              await cleanCache();
              setState(() {});
              if (!mounted) return;
              showMessage(context, 'Cache Cleaned');
            },
          ),
        );
      },
      leading: const Icon(Icons.delete_forever),
      title: 'Clean Cache',
      desc:
          'Cache - Count:${getCacheCount()} - Size:${getParseFileSize(getCacheSize().toDouble())} ',
    );
  }
}
