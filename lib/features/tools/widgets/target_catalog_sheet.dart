import 'package:flutter/material.dart';

import 'package:flutter/services.dart';



import '../data/paper_target_catalog.dart';

import '../data/paper_target_library_service.dart';

import '../models/paper_target_type.dart';

import 'target_type_preview.dart';



/// Searchable bottom sheet to pick a paper target.

Future<PaperTargetType?> showTargetCatalogSheet(
  BuildContext context, {
  PaperTargetType? selected,
  List<PaperTargetType> savedTargets = const [],
  required PaperTargetLibraryService library,
}) {
  return showModalBottomSheet<PaperTargetType>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _TargetCatalogSheet(
      initialSelection: selected,
      savedTargets: savedTargets,
      library: library,
    ),
  );
}



class _TargetCatalogSheet extends StatefulWidget {

  const _TargetCatalogSheet({
    this.initialSelection,
    this.savedTargets = const [],
    required this.library,
  });

  final PaperTargetType? initialSelection;
  final List<PaperTargetType> savedTargets;
  final PaperTargetLibraryService library;



  @override

  State<_TargetCatalogSheet> createState() => _TargetCatalogSheetState();

}



class _TargetCatalogSheetState extends State<_TargetCatalogSheet> {

  final _searchCtrl = TextEditingController();

  PaperTargetCategory? _categoryFilter;

  late String _query;

  late List<PaperTargetType> _savedTargets;



  @override

  void initState() {

    super.initState();

    _query = '';

    _savedTargets = List.of(widget.savedTargets);

    _searchCtrl.addListener(() {

      setState(() => _query = _searchCtrl.text.trim().toLowerCase());

    });

  }



  @override

  void dispose() {

    _searchCtrl.dispose();

    super.dispose();

  }



  Iterable<PaperTargetType> get _filteredCatalog {

    return paperTargetCatalog.where((target) {

      if (_categoryFilter != null && target.category != _categoryFilter) {

        return false;

      }

      if (_query.isEmpty) return true;

      final haystack =

          '${target.name} ${target.description} ${target.sizeLabel}'.toLowerCase();

      return haystack.contains(_query);

    });

  }



  Iterable<PaperTargetType> get _filteredSaved {

    return _savedTargets.where((target) {

      if (_query.isEmpty) return true;

      final haystack =

          '${target.name} ${target.description} ${target.sizeLabel}'.toLowerCase();

      return haystack.contains(_query);

    });

  }



  Future<void> _importFromClipboard() async {

    final data = await Clipboard.getData('text/plain');

    final text = data?.text;

    if (text == null || text.trim().isEmpty) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Clipboard is empty')),

      );

      return;

    }

    final parsed = widget.library.parseShareCode(text);

    if (parsed == null) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('No valid target code on clipboard')),

      );

      return;

    }

    final saved = parsed.copyWith(

      id: 'user-${DateTime.now().millisecondsSinceEpoch}',

      isUserSaved: true,

    );

    await widget.library.save(saved);

    if (!mounted) return;

    setState(() => _savedTargets = [..._savedTargets, saved]);

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text('Imported "${saved.name}"')),

    );

  }



  Future<void> _copyShareCode(PaperTargetType target) async {

    await Clipboard.setData(

      ClipboardData(text: widget.library.shareCodeFor(target)),

    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text('Share code copied — paste for others to import')),

    );

  }



  Future<void> _deleteSaved(PaperTargetType target) async {

    await widget.library.remove(target);

    if (!mounted) return;

    setState(() {

      _savedTargets = _savedTargets.where((t) => t.id != target.id).toList();

    });

  }



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final catalog = _filteredCatalog.toList();

    final saved = _filteredSaved.toList();



    return DraggableScrollableSheet(

      expand: false,

      initialChildSize: 0.88,

      minChildSize: 0.5,

      maxChildSize: 0.95,

      builder: (context, scrollController) {

        return Column(

          children: [

            Padding(

              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    'Paper targets',

                    style: theme.textTheme.titleLarge?.copyWith(

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                  const SizedBox(height: 4),

                  Text(

                    'Built-in catalog plus your saved targets. Saved targets sync to your account when signed in.',

                    style: theme.textTheme.bodySmall?.copyWith(

                      color: theme.colorScheme.onSurfaceVariant,

                    ),

                  ),

                  const SizedBox(height: 12),

                  TextField(

                    controller: _searchCtrl,

                    decoration: const InputDecoration(

                      hintText: 'Search targets…',

                      prefixIcon: Icon(Icons.search),

                      border: OutlineInputBorder(),

                      isDense: true,

                    ),

                  ),

                  const SizedBox(height: 8),

                  Row(

                    children: [

                      TextButton.icon(

                        onPressed: _importFromClipboard,

                        icon: const Icon(Icons.download_outlined, size: 18),

                        label: const Text('Import from clipboard'),

                      ),

                    ],

                  ),

                  SingleChildScrollView(

                    scrollDirection: Axis.horizontal,

                    child: Row(

                      children: [

                        FilterChip(

                          label: const Text('All'),

                          selected: _categoryFilter == null,

                          onSelected: (_) =>

                              setState(() => _categoryFilter = null),

                        ),

                        for (final cat in PaperTargetCategory.values)

                          Padding(

                            padding: const EdgeInsets.only(left: 8),

                            child: FilterChip(

                              label: Text(cat.label),

                              selected: _categoryFilter == cat,

                              onSelected: (_) =>

                                  setState(() => _categoryFilter = cat),

                            ),

                          ),

                      ],

                    ),

                  ),

                ],

              ),

            ),

            Expanded(

              child: ListView(

                controller: scrollController,

                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),

                children: [

                  if (saved.isNotEmpty) ...[

                    Text(

                      'My saved targets',

                      style: theme.textTheme.titleSmall?.copyWith(

                        fontWeight: FontWeight.w600,

                      ),

                    ),

                    const SizedBox(height: 8),

                    for (final target in saved) ...[

                      _TargetTile(

                        target: target,

                        isSelected: widget.initialSelection?.id == target.id,

                        trailing: Row(

                          mainAxisSize: MainAxisSize.min,

                          children: [

                            IconButton(

                              tooltip: 'Copy share code',

                              onPressed: () => _copyShareCode(target),

                              icon: const Icon(Icons.share_outlined),

                            ),

                            IconButton(

                              tooltip: 'Remove',

                              onPressed: () => _deleteSaved(target),

                              icon: const Icon(Icons.delete_outline),

                            ),

                          ],

                        ),

                        onTap: () => Navigator.pop(context, target),

                      ),

                      const SizedBox(height: 8),

                    ],

                    const SizedBox(height: 16),

                  ],

                  Text(

                    'Catalog',

                    style: theme.textTheme.titleSmall?.copyWith(

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                  const SizedBox(height: 8),

                  if (catalog.isEmpty)

                    Padding(

                      padding: const EdgeInsets.symmetric(vertical: 24),

                      child: Center(

                        child: Text(

                          'No catalog targets match your search.',

                          style: theme.textTheme.bodyMedium?.copyWith(

                            color: theme.colorScheme.onSurfaceVariant,

                          ),

                        ),

                      ),

                    )

                  else

                    for (final target in catalog) ...[

                      _TargetTile(

                        target: target,

                        isSelected: widget.initialSelection?.id == target.id,

                        onTap: () => Navigator.pop(context, target),

                      ),

                      const SizedBox(height: 8),

                    ],

                ],

              ),

            ),

          ],

        );

      },

    );

  }

}



class _TargetTile extends StatelessWidget {

  const _TargetTile({

    required this.target,

    required this.isSelected,

    required this.onTap,

    this.trailing,

  });



  final PaperTargetType target;

  final bool isSelected;

  final VoidCallback onTap;

  final Widget? trailing;



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Material(

      color: isSelected

          ? theme.colorScheme.primaryContainer

          : theme.colorScheme.surfaceContainerHighest,

      borderRadius: BorderRadius.circular(12),

      child: InkWell(

        borderRadius: BorderRadius.circular(12),

        onTap: onTap,

        child: Padding(

          padding: const EdgeInsets.all(12),

          child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              TargetTypePreview(target: target, size: 80),

              const SizedBox(width: 12),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      target.name,

                      style: theme.textTheme.titleSmall?.copyWith(

                        fontWeight: FontWeight.w600,

                      ),

                    ),

                    const SizedBox(height: 4),

                    Text(

                      target.sizeLabel,

                      style: theme.textTheme.labelLarge?.copyWith(

                        color: theme.colorScheme.primary,

                      ),

                    ),

                    const SizedBox(height: 4),

                    Text(

                      target.category.label,

                      style: theme.textTheme.labelSmall?.copyWith(

                        color: theme.colorScheme.onSurfaceVariant,

                      ),

                    ),

                    if (target.description.isNotEmpty) ...[

                      const SizedBox(height: 6),

                      Text(

                        target.description,

                        style: theme.textTheme.bodySmall?.copyWith(

                          color: theme.colorScheme.onSurfaceVariant,

                        ),

                      ),

                    ],

                  ],

                ),

              ),

              if (isSelected)

                Icon(Icons.check_circle, color: theme.colorScheme.primary),

              if (trailing != null) trailing!,

            ],

          ),

        ),

      ),

    );

  }

}


