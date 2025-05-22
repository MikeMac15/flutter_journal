import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

PreferredSizeWidget buildCustomAppBar(BuildContext context) {
  final theme = Theme.of(context);
  return AppBar(
    elevation: 4,
    backgroundColor: Colors.transparent,
    // curved bottom edge
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(24),
      ),
    ),
    // gradient fill
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
    ),
    // custom title with a bit of padding & style
    title: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        'Jamie’s Journal',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),
    centerTitle: true,
    // optional leading avatar, plus your logout
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/avatar.jpg'),
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
        onPressed: () {
          // TODO: search action
        },
      ),
      IconButton(
        icon: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
        onPressed: () async {
          await Provider.of<UserProvider>(context, listen: false).signOut();
        },
      ),
    ],
  );
}
