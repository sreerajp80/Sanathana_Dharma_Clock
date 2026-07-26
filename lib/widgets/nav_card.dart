import 'package:flutter/material.dart';

/// A tappable menu card — icon, title, optional subtitle, and a trailing
/// chevron inside a [Card].
///
/// Shared by the Settings page and the Help page so every navigation card
/// looks identical. The card itself carries no navigation logic; the caller
/// passes an [onTap] that pushes the target route.
class NavCard extends StatelessWidget {
  const NavCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
  });

  /// The leading icon.
  final IconData icon;

  /// The card's main line.
  final String title;

  /// What happens on tap — usually `() => context.push('/…')`.
  final VoidCallback onTap;

  /// An optional second line under the title.
  final String? subtitle;

  /// An optional colour for the leading icon.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
