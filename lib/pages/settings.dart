import 'package:flutter/material.dart';

import 'package:journal/providers/user_provider.dart';
import 'package:journal/providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// A settings page that displays user information,
/// allows changing the header image, and customizing app theme.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProv = context.watch<UserProvider>();
    final themeProv = context.watch<ThemeProvider>();

    return Scaffold(
      // Make the Scaffold transparent so the gradient shows through
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeProv.primary,
              themeProv.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Information
                Text(
                  'Account Information',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(userProv.userDisplayName ?? 'No name'),
                  subtitle: const Text('Display Name'),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(userProv.userEmail ?? 'No email'),
                  subtitle: const Text('Email'),
                ),
                const Divider(height: 32),

                // Header Image Section
                Text(
                  'Header Image',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      child: userProv.headerImageUrl != null
                          ? Image.network(
                              userProv.headerImageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (c, w, p) => p == null
                                  ? w
                                  : const Center(
                                      child: CircularProgressIndicator()),
                              errorBuilder: (c, e, s) => const Center(
                                  child: Icon(Icons.broken_image, size: 48)),
                            )
                          : const Center(child: Icon(Icons.image, size: 48)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Change Header Image'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      userProv.pickAndUploadHeaderImage();
                    },
                  ),
                ),
                const Divider(height: 32),

                // Theme Customization Section
                Text(
                  'Customize Theme',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),

                const ThemeCustomizerSection(),

                const Divider(height: 32),

                // Sign Out Button
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      userProv.signOut();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
