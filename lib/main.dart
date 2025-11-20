import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/budget_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/bills_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Catch all uncaught errors
  FlutterError.onError = (FlutterErrorDetails details) {
    print('💥 FLUTTER ERROR CAUGHT:');
    print('Exception: ${details.exception}');
    print('Stack trace: ${details.stack}');
    FlutterError.presentError(details);
  };
  
  print('🚀 App starting...');
  runApp(const BudgetManagerApp());
}

class BudgetManagerApp extends StatelessWidget {
  const BudgetManagerApp({super.key});

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
      home: const InitializationWrapper(),
    );
  }
}

// Wrapper that handles async initialization and app lifecycle
class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> with WidgetsBindingObserver {
  late Future<bool> _initFuture;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _initializeDatabase();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('📱 App lifecycle changed: $state');
    
    // When app comes back to foreground, verify database is still accessible
    if (state == AppLifecycleState.resumed && _isInitialized) {
      print('🔄 App resumed, verifying database...');
      _verifyDatabase();
    }
  }

  Future<void> _verifyDatabase() async {
    try {
      print('🔍 Checking if Hive boxes are still open...');
      
      // Check each box individually
      if (!Hive.isBoxOpen('accounts')) {
        print('⚠️  accounts box is CLOSED');
        throw Exception('accounts box closed');
      }
      print('✅ accounts box is open');
      
      if (!Hive.isBoxOpen('bills')) {
        print('⚠️  bills box is CLOSED');
        throw Exception('bills box closed');
      }
      print('✅ bills box is open');
      
      if (!Hive.isBoxOpen('transactions')) {
        print('⚠️  transactions box is CLOSED');
        throw Exception('transactions box closed');
      }
      print('✅ transactions box is open');
      
      if (!Hive.isBoxOpen('config')) {
        print('⚠️  config box is CLOSED');
        throw Exception('config box closed');
      }
      print('✅ config box is open');
      
      // Try to actually read data
      print('🔍 Attempting to read config...');
      final config = BudgetService.getConfig();
      print('✅ Config read successfully: ${config != null}');
      
      print('✅ Database fully verified and accessible');
    } catch (e, stackTrace) {
      print('❌ Database verification failed: $e');
      print('Stack: $stackTrace');
      print('⚠️  Database not accessible after resume, reinitializing...');
      setState(() {
        _isInitialized = false;
        _initFuture = _initializeDatabase();
      });
    }
  }

  Future<bool> _initializeDatabase() async {
    bool initialized = false;
    int retries = 0;
    
    while (!initialized && retries < 3) {
      try {
        print('⏳ Initialization attempt ${retries + 1}...');
        await BudgetService.initialize();
        initialized = true;
        _isInitialized = true;
        print('✅ Database initialized successfully on attempt ${retries + 1}');
      } catch (e, stackTrace) {
        print('❌ Initialization attempt ${retries + 1} failed: $e');
        print('Stack trace: $stackTrace');
        retries++;
        
        if (retries < 3) {
          print('⏳ Waiting 2 seconds before retry...');
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    
    return initialized;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initFuture,
      builder: (context, snapshot) {
        // Show loading while initializing
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Budget Manager...'),
                ],
              ),
            ),
          );
        }
        
        // Show error if initialization failed
        if (snapshot.hasError || snapshot.data == false) {
          return ErrorScreen(
            error: snapshot.error?.toString() ?? 'Database initialization failed after 3 attempts',
          );
        }
        
        // Show main app if initialization succeeded
        return const MainScreen();
      },
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

// Error screen shown when database initialization fails
class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Database Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize the app database after multiple attempts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Please restart the app. If this persists, you may need to reinstall.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
