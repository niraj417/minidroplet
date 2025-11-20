import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NormalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NormalAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.share_up),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(CupertinoIcons.bookmark),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
