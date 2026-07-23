import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../education/education_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    EducationScreen(),
    ProfileScreen(),
  ];

  static const List<NavigationDestination> _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.local_florist_outlined),
      selectedIcon: Icon(Icons.local_florist_rounded),
      label: 'Edukasi',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profil',
    ),
  ];

  void selectTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 840;
        if (wide) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: <Widget>[
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: selectTab,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: AppColors.neutral0,
                    indicatorColor: AppColors.green50,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'HydroQ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: Text('Beranda')),
                      NavigationRailDestination(icon: Icon(Icons.local_florist_outlined), selectedIcon: Icon(Icons.local_florist_rounded), label: Text('Edukasi')),
                      NavigationRailDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: Text('Profil')),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: IndexedStack(index: _selectedIndex, children: _pages)),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(child: IndexedStack(index: _selectedIndex, children: _pages)),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: selectTab,
            destinations: _destinations,
          ),
        );
      },
    );
  }
}
