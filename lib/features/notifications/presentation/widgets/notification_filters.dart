import 'package:flutter/material.dart';
import '../models/notification_model.dart';

/// Notification filters widget
class NotificationFilters extends StatefulWidget {
  final String searchQuery;
  final NotificationType? selectedType;
  final bool? showOnlyUnread;
  final Function(String) onSearchChanged;
  final Function(NotificationType?) onTypeChanged;
  final Function(bool?) onReadFilterChanged;
  final VoidCallback onClearFilters;

  const NotificationFilters({
    super.key,
    required this.searchQuery,
    required this.selectedType,
    required this.showOnlyUnread,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onReadFilterChanged,
    required this.onClearFilters,
  });

  @override
  State<NotificationFilters> createState() => _NotificationFiltersState();
}

class _NotificationFiltersState extends State<NotificationFilters> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(NotificationFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search notifications...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: widget.onSearchChanged,
          ),

          const SizedBox(height: 24),

          // Type filter
          Text(
            'Filter by Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // All types option
              FilterChip(
                label: const Text('All Types'),
                selected: widget.selectedType == null,
                onSelected: (selected) {
                  widget.onTypeChanged(selected ? null : null);
                },
              ),

              // Individual type options
              ...NotificationType.values.map((type) => FilterChip(
                label: Text(type.displayName),
                selected: widget.selectedType == type,
                avatar: Icon(type.icon, size: 16),
                onSelected: (selected) {
                  widget.onTypeChanged(selected ? type : null);
                },
              )),
            ],
          ),

          const SizedBox(height: 24),

          // Read status filter
          Text(
            'Read Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('All'),
                  selected: widget.showOnlyUnread == null,
                  onSelected: (selected) {
                    if (selected) widget.onReadFilterChanged(null);
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: FilterChip(
                  label: const Text('Unread Only'),
                  selected: widget.showOnlyUnread == true,
                  onSelected: (selected) {
                    widget.onReadFilterChanged(selected ? true : null);
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: FilterChip(
                  label: const Text('Read Only'),
                  selected: widget.showOnlyUnread == false,
                  onSelected: (selected) {
                    widget.onReadFilterChanged(selected ? false : null);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Active filters summary
          if (_hasActiveFilters()) ...[
            Text(
              'Active Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActiveFiltersChips(context),
            ),

            const SizedBox(height: 16),
          ],

          // Clear filters button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _hasActiveFilters() ? widget.onClearFilters : null,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filter statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Results',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // This would normally show actual counts from the viewmodel
                  Text(
                    'Showing filtered notifications based on your criteria.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return widget.searchQuery.isNotEmpty ||
           widget.selectedType != null ||
           widget.showOnlyUnread != null;
  }

  List<Widget> _buildActiveFiltersChips(BuildContext context) {
    final chips = <Widget>[];

    if (widget.searchQuery.isNotEmpty) {
      chips.add(
        Chip(
          label: Text('Search: "${widget.searchQuery}"'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            _searchController.clear();
            widget.onSearchChanged('');
          },
        ),
      );
    }

    if (widget.selectedType != null) {
      chips.add(
        Chip(
          label: Text('Type: ${widget.selectedType!.displayName}'),
          avatar: Icon(widget.selectedType!.icon, size: 16),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () => widget.onTypeChanged(null),
        ),
      );
    }

    if (widget.showOnlyUnread != null) {
      chips.add(
        Chip(
          label: Text(widget.showOnlyUnread! ? 'Unread Only' : 'Read Only'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () => widget.onReadFilterChanged(null),
        ),
      );
    }

    return chips;
  }
}

/// Quick filter buttons for the main notification page
class NotificationQuickFilters extends StatelessWidget {
  final NotificationType? selectedType;
  final bool? showOnlyUnread;
  final Function(NotificationType?) onTypeChanged;
  final Function(bool?) onReadFilterChanged;

  const NotificationQuickFilters({
    super.key,
    required this.selectedType,
    required this.showOnlyUnread,
    required this.onTypeChanged,
    required this.onReadFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Unread filter
          FilterChip(
            label: const Text('Unread'),
            selected: showOnlyUnread == true,
            onSelected: (selected) {
              onReadFilterChanged(selected ? true : null);
            },
          ),

          const SizedBox(width: 8),

          // Type filters
          ...NotificationType.values.take(4).map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type.displayName),
              selected: selectedType == type,
              avatar: Icon(type.icon, size: 16),
              onSelected: (selected) {
                onTypeChanged(selected ? type : null);
              },
            ),
          )),
        ],
      ),
    );
  }
}
