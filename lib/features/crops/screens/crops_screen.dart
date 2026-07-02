import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  CropStatus? _statusFilter;
  String _sortBy = 'name';
  bool _gridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  List<CropModel> get _filteredCrops {
    var crops = List<CropModel>.from(MockData.crops);

    if (_searchQuery.isNotEmpty) {
      crops = crops
          .where((c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.variety.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_statusFilter != null) {
      crops = crops.where((c) => c.status == _statusFilter).toList();
    }

    switch (_sortBy) {
      case 'harvest':
        crops.sort((a, b) => a.daysToHarvest.compareTo(b.daysToHarvest));
        break;
      case 'name':
        crops.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'progress':
        crops.sort((a, b) => b.harvestProgress.compareTo(a.harvestProgress));
        break;
    }

    return crops;
  }

  List<CropModel> _byStatus(CropStatus? status) {
    if (status == null) return _filteredCrops;
    return _filteredCrops.where((c) => c.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: const Text('My Crops'),
        actions: [
          IconButton(
            icon: Icon(
                _gridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _gridView = !_gridView),
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: _showSortSheet,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search crops, varieties…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    fillColor: AppColors.parchment,
                  ),
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  Tab(text: 'All (${_filteredCrops.length})'),
                  Tab(
                      text:
                          '🌾 Harvest (${_byStatus(CropStatus.readyToHarvest).length})'),
                  Tab(
                      text:
                          '🌿 Growing (${_byStatus(CropStatus.vegetative).length})'),
                  Tab(
                      text:
                          '⚠️ Attention (${_byStatus(CropStatus.concern).length})'),
                  const Tab(text: '✅ Done'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CropList(crops: _filteredCrops, gridView: _gridView),
          _CropList(
              crops: _byStatus(CropStatus.readyToHarvest), gridView: _gridView),
          _CropList(
              crops: _filteredCrops
                  .where((c) => [
                        CropStatus.vegetative,
                        CropStatus.flowering,
                        CropStatus.fruiting,
                        CropStatus.sprouting
                      ].contains(c.status))
                  .toList(),
              gridView: _gridView),
          _CropList(crops: _byStatus(CropStatus.concern), gridView: _gridView),
          _CropList(
              crops: _byStatus(CropStatus.harvested), gridView: _gridView),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/crops/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Crop'),
        backgroundColor: AppColors.forest,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _SortOption('Name A–Z', 'name', _sortBy, (v) {
              setState(() => _sortBy = v);
              Navigator.pop(context);
            }),
            _SortOption('Days to Harvest', 'harvest', _sortBy, (v) {
              setState(() => _sortBy = v);
              Navigator.pop(context);
            }),
            _SortOption('Progress', 'progress', _sortBy, (v) {
              setState(() => _sortBy = v);
              Navigator.pop(context);
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label, value, current;
  final ValueChanged<String> onSelect;

  const _SortOption(this.label, this.value, this.current, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:
          Text(label, style: AppTextStyles.body(14, weight: FontWeight.w500)),
      trailing: value == current
          ? const Icon(Icons.check_circle_rounded, color: AppColors.leaf)
          : null,
      onTap: () => onSelect(value),
    );
  }
}

class _CropList extends StatelessWidget {
  final List<CropModel> crops;
  final bool gridView;

  const _CropList({required this.crops, required this.gridView});

  @override
  Widget build(BuildContext context) {
    if (crops.isEmpty) return _EmptyState();

    if (gridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: crops.length,
        itemBuilder: (_, i) => _CropGridTile(crop: crops[i])
            .animate(delay: Duration(milliseconds: 50 * i))
            .fadeIn()
            .scale(begin: const Offset(0.9, 0.9)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: crops.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) {},
                backgroundColor: AppColors.amber.withValues(alpha: 0.1),
                foregroundColor: AppColors.amber,
                icon: Icons.eco_outlined,
                label: 'Harvest',
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
              SlidableAction(
                onPressed: (_) {},
                backgroundColor: AppColors.red.withOpacity(0.1),
                foregroundColor: AppColors.red,
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(12)),
              ),
            ],
          ),
          child: _CropListTile(crop: crops[i]),
        )
            .animate(delay: Duration(milliseconds: 60 * i))
            .fadeIn()
            .slideY(begin: 0.1),
      ),
    );
  }
}

class _CropListTile extends StatelessWidget {
  final CropModel crop;
  const _CropListTile({required this.crop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/crops/${crop.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: crop.status == CropStatus.concern
                ? AppColors.red.withOpacity(0.3)
                : crop.status == CropStatus.readyToHarvest
                    ? AppColors.amber.withValues(alpha: 0.3)
                    : AppColors.border,
          ),
          boxShadow: [AppShadows.subtle],
        ),
        child: Row(
          children: [
            // Emoji avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: crop.status.bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(crop.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(crop.name,
                            style: AppTextStyles.body(
                              14,
                              weight: FontWeight.w700,
                              color: AppColors.forest,
                            )),
                      ),
                      if (crop.isFavorite)
                        const Icon(Icons.favorite_rounded,
                            size: 14, color: AppColors.red),
                    ],
                  ),
                  Text(
                      '${crop.variety} · ${crop.plotId.replaceAll('_', ' ').toUpperCase()}',
                      style:
                          AppTextStyles.body(11, color: AppColors.slateLight)),
                  const SizedBox(height: 8),

                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: crop.harvestProgress,
                            minHeight: 5,
                            backgroundColor: AppColors.border,
                            valueColor:
                                AlwaysStoppedAnimation(crop.status.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(crop.harvestProgress * 100).toInt()}%',
                        style: AppTextStyles.mono(
                            size: 10, color: AppColors.slateLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right side
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: crop.status.bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    crop.status.emoji + ' ' + crop.status.label,
                    style: AppTextStyles.body(
                      9,
                      weight: FontWeight.w700,
                      color: crop.status.color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  crop.daysToHarvest > 0
                      ? '${crop.daysToHarvest}d to harvest'
                      : 'Ready!',
                  style: AppTextStyles.mono(
                    size: 10,
                    color: crop.isNearHarvest
                        ? AppColors.amber
                        : AppColors.slateLight,
                  ),
                ),
                Text(
                  '~${crop.estimatedYieldKg}kg',
                  style: AppTextStyles.mono(10, color: AppColors.leaf),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CropGridTile extends StatelessWidget {
  final CropModel crop;
  const _CropGridTile({required this.crop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/crops/${crop.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppShadows.subtle],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(crop.emoji, style: const TextStyle(fontSize: 32)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: crop.status.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(crop.status.emoji,
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              crop.name,
              style: AppTextStyles.body(13,
                  weight: FontWeight.w700, color: AppColors.forest),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              crop.variety,
              style: AppTextStyles.body(10, color: AppColors.slateLight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: crop.harvestProgress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(crop.status.color),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  crop.daysToHarvest > 0 ? '${crop.daysToHarvest}d' : 'Now!',
                  style: AppTextStyles.mono(10, color: AppColors.slateLight),
                ),
                Text('${crop.estimatedYieldKg}kg',
                    style: AppTextStyles.mono(10, color: AppColors.leaf)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No crops here yet',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Tap the + button to plant your first crop',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/crops/add'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Crop'),
          ),
        ],
      ),
    );
  }
}
