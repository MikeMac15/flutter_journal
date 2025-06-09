import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/pages/settings.dart';

/// A home menu avatar that opens a cascading menu
/// with an animated icon + fade-in menu items.
class HomeMenu extends StatefulWidget {
  final double avatarSize;
  const HomeMenu({super.key, this.avatarSize = 48});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(debugLabel: 'Settings Avatar');
  late final AnimationController _iconController;
  late final AnimationController _menuFadeController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _menuFadeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: MenuAnchor(
        childFocusNode: _focusNode,
        onOpen: () {
          _iconController.forward();
          _menuFadeController.forward();
        },
        onClose: () {
          _iconController.reverse();
          _menuFadeController.reverse();
        },
        menuChildren: [
          FadeTransition(
            opacity: _menuFadeController,
            child: MenuItemButton(
              onPressed: () {
                Navigator.of(context).push(fadeRoute(const SettingsPage()));
              },
              leadingIcon: const Icon(Icons.settings),
              child: const Text('Settings'),
            ),
          ),
          FadeTransition(
            opacity: _menuFadeController,
            child: MenuItemButton(
              onPressed: () {
                // TODO: navigate to profile
              },
              leadingIcon: const Icon(Icons.person),
              child: const Text('Profile'),
            ),
          ),
          FadeTransition(
            opacity: _menuFadeController,
            child: MenuItemButton(
              onPressed: () {
                // TODO: log out
              },
              leadingIcon: const Icon(Icons.logout),
              child: const Text('Sign out'),
            ),
          ),
        ],
        builder: (BuildContext context, MenuController controller, Widget? child) {
          // on each rebuild, animate icon to match controller state
          controller.isOpen ? _iconController.forward() : _iconController.reverse();

          return InkWell(
            focusNode: _focusNode,
            borderRadius: BorderRadius.circular(widget.avatarSize),
            onTap: () {
              controller.isOpen ? controller.close() : controller.open();
            },
            child: Container(
              width: widget.avatarSize,
              height: widget.avatarSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _iconController,
                size: widget.avatarSize * 0.6,
                color: theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
