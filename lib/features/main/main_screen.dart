import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../listings/home_screen.dart';
import '../meetings/meetings_screen.dart';
import '../logs/logs_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final UserModel user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _updateUser(UserModel updated) {
    setState(() => _user = updated);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(user: _user),
      MeetingsScreen(user: _user),
      LogsScreen(user: _user),
      ProfileScreen(user: _user, onUserUpdated: _updateUser),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8F5E9),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF2E7D32)),
            label: 'İlanlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF2E7D32)),
            label: 'Görüşmeler',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Color(0xFF2E7D32)),
            label: 'Loglar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF2E7D32)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
