import 'package:flutter/material.dart';

class ListTileWithDesc extends StatelessWidget {
  String title;
  String desc;
  Widget? trailing;
  Widget? leading;
  double spacing;
  void Function()? onClick;
  ListTileWithDesc({
    super.key,
    required this.title,
    this.trailing,
    this.desc = '',
    this.leading,
    this.spacing = 10,
    this.onClick,
  });

  Widget _getLeading() {
    if (leading == null) {
      return SizedBox.shrink();
    }
    return leading!;
  }

  Widget _getTrailing() {
    if (trailing == null) {
      return SizedBox.shrink();
    }
    return trailing!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onClick != null) {
          onClick!();
        }
      },
      child: MouseRegion(
        cursor: onClick != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: spacing,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getLeading(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                      ),
                      desc.isEmpty
                          ? const SizedBox(height: 5)
                          : SizedBox.shrink(),
                      desc.isEmpty
                          ? SizedBox.shrink()
                          : Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w100,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                    ],
                  ),
                ),
                _getTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
