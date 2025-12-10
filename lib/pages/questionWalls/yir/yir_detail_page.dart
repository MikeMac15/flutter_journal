import 'package:flutter/material.dart';
import 'package:journal/pages/questionWalls/yir/yir_ranked_lists.dart';
import 'package:journal/pages/questionWalls/yir/yir_recap_wall.dart';
import 'package:journal/pages/questionWalls/yir_classes.dart';
import 'package:provider/provider.dart';
import 'package:journal/providers/db_provider.dart';

class YirDetailPage extends StatefulWidget {
  final String year;
  const YirDetailPage({super.key, required this.year});

  @override
  State<YirDetailPage> createState() => _YirDetailPageState();
}

class _YirDetailPageState extends State<YirDetailPage> {
  bool _messagesCollapsed = false;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DBProvider>(
      builder: (context, db, _) {
        final yir = db.allYir.firstWhere((y) => y.year == widget.year);
        final hasMessages = yir.recaps.isNotEmpty;

        return Scaffold(
          appBar: AppBar(title: Text('${yir.year} • Year in Review')),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            onPressed: () => _showActionsSheet(context, db, yir),
          ),
          body: SafeArea(
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                // ===== Messages Section =====
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSize(
                      // <-- page height animates as this changes
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: SectionCard(
                        title: 'Messages',
                        count: yir.recaps.length,
                        collapsible: hasMessages,
                        collapsed: _messagesCollapsed,
                        onToggle: hasMessages
                            ? () => setState(
                                () => _messagesCollapsed = !_messagesCollapsed)
                            : null,
                        child: hasMessages
                            ? AnimatedCrossFade(
                                crossFadeState: _messagesCollapsed
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 220),
                                firstChild: SizedBox(
                                  height:
                                      260, // bounded -> smooth & predictable
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: YirRecapWall(
                                      year: yir.year,
                                      yirRecaps: yir.recaps,
                                    ),
                                  ),
                                ),
                                secondChild: const SizedBox.shrink(),
                              )
                            : const EmptyStateCard(
                                icon: Icons.message_outlined,
                                title: 'No messages yet',
                                subtitle:
                                    'Reflect on the year—add your first recap.',
                                height: 120,
                              ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ===== Categories Section =====
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: SectionCard(
                        title: 'Categories',
                        count: yir.categories.length,
                        collapsible: false,
                        // IMPORTANT: do NOT use Expanded here.
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          // Make this list NON-scrollable; let the page scroll.
                          child: YirRankedLists(yir: yir),
                        ),
                      ),
                    ),
                  ),
                ),
                // Padding so content doesn't sit under the FAB
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 88),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Bottom sheet with actions (wire up later as needed)
  void _showActionsSheet(BuildContext context, DBProvider db, Yir yir) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.note_add_outlined),
                title: const Text('Add Message'),
                subtitle: const Text('Write a recap for this year'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddMessageSheet(context, db, yir.year);
                },
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Add YIR Category'),
                subtitle: const Text('Create a new ranked list'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: implement your "add category" flow
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Category tapped')),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Bottom sheet to input a new message (cleaner than dialog for this flow)
  void _showAddMessageSheet(BuildContext context, DBProvider db, String year) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('New Message',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Share a highlight, lesson, or memory.'),
              ),
              TextField(
                controller: controller,
                maxLines: 6,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Write your recap…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Save'),
                      onPressed: () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        await db.addRecap(
                          year,
                          YirRecap(
                            date: DateTime.now().toIso8601String(),
                            recapText: text,
                          ),
                        );
                        if (context.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.count,
    this.collapsible = false,
    this.collapsed = false,
    this.onToggle,
    this.expandChild = false, // <— NEW
  });

  final String title;
  final Widget child;
  final int? count;
  final bool collapsible;
  final bool collapsed;
  final VoidCallback? onToggle;
  final bool expandChild; // <— NEW

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget body = AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      firstChild: child,
      secondChild: const SizedBox.shrink(),
      crossFadeState: (collapsible && collapsed)
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
    );

    if (expandChild) {
      body = Expanded(child: body); // <— Only place Expanded HERE
    }

    return Material(
      elevation: 1.5,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row ...
            Row(
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                if (count != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('$count', style: theme.textTheme.labelSmall),
                  ),
                const Spacer(),
                if (collapsible)
                  IconButton(
                    icon:
                        Icon(collapsed ? Icons.expand_more : Icons.expand_less),
                    onPressed: onToggle,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            body, // <— now either Expanded(body) or plain body
          ],
        ),
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.height = 140,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
