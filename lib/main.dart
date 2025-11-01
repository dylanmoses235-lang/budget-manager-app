import 'package:flutter/material.dart';
import 'services/budget_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/bills_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Show loading screen while initializing
  runApp(const BudgetManagerApp(isInitializing: true));
  
  // Initialize database with error handling
  bool initialized = false;
  int retries = 0;
  
  while (!initialized && retries < 3) {
    try {
      await BudgetService.initialize();
      initialized = true;
    } catch (e) {
      print('Initialization attempt ${retries + 1} failed: $e');
      retries++;
      if (retries < 3) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }
  
  // Run the actual app
  runApp(const BudgetManagerApp(isInitializing: false));
}

class BudgetManagerApp extends StatelessWidget {
  final bool isInitializing;
  
  const BudgetManagerApp({super.key, this.isInitializing = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: isInitializing 
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ForecastScreen(),
    AccountsScreen(),
    BillsScreen(),
    TransactionsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Forecast',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_outlined),
            selectedIcon: Icon(Icons.receipt),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
