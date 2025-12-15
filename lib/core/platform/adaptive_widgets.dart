import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Helper para detectar plataforma y crear widgets adaptativos.
class AdaptiveWidgets {
  AdaptiveWidgets._();

  /// Retorna true si la plataforma es iOS.
  static bool get isIOS => Platform.isIOS;

  /// Retorna true si la plataforma es Android.
  static bool get isAndroid => Platform.isAndroid;
}

/// Scaffold adaptativo (Material/Cupertino).
class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBackButton;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (AdaptiveWidgets.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          leading: showBackButton
              ? CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                )
              : leading,
          trailing: actions != null
              ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
              : null,
        ),
        child: Column(
          children: [
            Expanded(child: SafeArea(child: body)),
            if (bottomNavigationBar != null) bottomNavigationBar!,
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: leading,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Indicador de carga adaptativo.
class AdaptiveLoadingIndicator extends StatelessWidget {
  const AdaptiveLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AdaptiveWidgets.isIOS
          ? const CupertinoActivityIndicator(radius: 16)
          : const CircularProgressIndicator(),
    );
  }
}

/// TextField adaptativo para búsqueda.
class AdaptiveSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AdaptiveSearchField({
    super.key,
    required this.controller,
    this.placeholder = 'Buscar...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (AdaptiveWidgets.isIOS) {
      return CupertinoSearchTextField(
        controller: controller,
        placeholder: placeholder,
        onChanged: onChanged,
        onSuffixTap: onClear,
      );
    }

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}

/// Botón de icono adaptativo (favorito).
class AdaptiveFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const AdaptiveFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (AdaptiveWidgets.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(
          isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: isFavorite ? CupertinoColors.systemRed : null,
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : null,
      ),
    );
  }
}

/// Diálogo de error adaptativo.
Future<void> showAdaptiveErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  if (AdaptiveWidgets.isIOS) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
