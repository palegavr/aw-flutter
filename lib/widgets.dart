import 'package:flutter/material.dart';

AppBar awSimpleAppBar() {
  return AppBar(
    leading: const AWBackButton(),
    automaticallyImplyLeading: false,
  );
}

class AWBackButton extends StatelessWidget {
  const AWBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: 'Назад',
      onPressed: Navigator.of(context).pop,
    );
  }
}

class AWFloatingActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isEnabled;
  final void Function()? onPressed;

  const AWFloatingActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.isEnabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext ctx) {
    return FloatingActionButton.extended(
      label: Text(label),
      icon: Icon(icon),
      disabledElevation: isEnabled ? null : 0,
      mouseCursor:
          isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onPressed: isEnabled ? onPressed : null,
    );
  }
}
