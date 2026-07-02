import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:badges/badges.dart' as badges;
import '../../../core/theme/app_theme.dart';
import '../screens/dashboard_screen.dart';
import '../../crops/screens/crops_screen.dart';
import '../../harvest/screens/harvest_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/quick_action_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  final List<Widget> _pages = const [
    DashboardScreen(),
    CropsScreen(),
    SizedBox.shrink(), // FAB center placeholder
    HarvestScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _showQuickActionSheet();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showQuickActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QuickActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Home'),
      const _NavItem(
          icon: Icons.eco_outlined,
          activeIcon: Icons.eco_rounded,
          label: 'Crops'),
      const _NavItem(
          icon: Icons.add_circle_outline,
          activeIcon: Icons.add_circle,
          label: 'Log',
          isCenter: true),
      const _NavItem(
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront_rounded,
          label: 'Harvest'),
      const _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex > 2 ? _currentIndex - 1 : _currentIndex,
        children: const [
          DashboardScreen(),
          CropsScreen(),
          HarvestScreen(),
          ProfileScreen(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(tabs),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _showQuickActionSheet,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.forest, AppColors.leaf],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [AppShadows.fab],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    )
        .animate()
        .scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildBottomNav(List<_NavItem> tabs) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        boxShadow: [
          BoxShadow(
            color: AppColors.slate.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(tabs.length, (i) {
              if (i == 2) return const SizedBox(width: 60); // FAB space
              final isActive =
                  i < 2 ? _currentIndex == i : _currentIndex == i - 1;
              final tab = tabs[i];

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTapped(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      i == 3 // notifications badge on harvest
                          ? badges.Badge(
                              badgeContent: const Text(
                                '2',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 8),
                              ),
                              badgeStyle: const badges.BadgeStyle(
                                badgeColor: AppColors.amber,
                                padding: EdgeInsets.all(4),
                              ),
                              child: Icon(
                                isActive ? tab.activeIcon : tab.icon,
                                color: isActive
                                    ? AppColors.forest
                                    : AppColors.slateLight,
                                size: 24,
                              ),
                            )
                          : Icon(
                              isActive ? tab.activeIcon : tab.icon,
                              color: isActive
                                  ? AppColors.forest
                                  : AppColors.slateLight,
                              size: 24,
                            ),
                      const SizedBox(height: 4),
                      Text(
                        tab.label,
                        style: AppTextStyles.body(
                          10,
                          weight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppColors.forest
                              : AppColors.slateLight,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.leaf,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCenter;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCenter = false,
  });
}
