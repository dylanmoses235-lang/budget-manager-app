import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/budget_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/bills_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  // Wrap everything in error zone to catch any async errors
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Catch all uncaught Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      print('💥 FLUTTER ERROR CAUGHT:');
      print('Exception: ${details.exception}');
      print('Stack trace: ${details.stack}');
      FlutterError.presentError(details);
    };
    
    print('🚀 App starting...');
    runApp(const BudgetManagerApp());
  }, (error, stack) {
    // Catch any errors not caught by FlutterError.onError
    print('💥 UNCAUGHT ERROR IN ZONE:');
    print('Error: $error');
    print('Stack trace: $stack');
  });
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
  int _rebuildKey = 0; // Key to force FutureBuilder rebuild

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
      // Add slight delay to ensure iOS has fully resumed the app
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _verifyDatabase();
        }
      });
    }
  }

  Future<void> _verifyDatabase() async {
    try {
      print('🔍 Checking if Hive boxes are still open...');
      
      // Check each box individually
      bool allBoxesOpen = true;
      
      if (!Hive.isBoxOpen('accounts')) {
        print('⚠️  accounts box is CLOSED');
        allBoxesOpen = false;
      } else {
        print('✅ accounts box is open');
      }
      
      if (!Hive.isBoxOpen('bills')) {
        print('⚠️  bills box is CLOSED');
        allBoxesOpen = false;
      } else {
        print('✅ bills box is open');
      }
      
      if (!Hive.isBoxOpen('transactions')) {
        print('⚠️  transactions box is CLOSED');
        allBoxesOpen = false;
      } else {
        print('✅ transactions box is open');
      }
      
      if (!Hive.isBoxOpen('config')) {
        print('⚠️  config box is CLOSED');
        allBoxesOpen = false;
      } else {
        print('✅ config box is open');
      }
      
      if (!allBoxesOpen) {
        print('⚠️  Some boxes are closed, reopening...');
        try {
          await BudgetService.reopenBoxes();
          print('✅ Boxes reopened successfully');
        } catch (reopenError) {
          print('❌ Failed to reopen boxes: $reopenError');
          throw reopenError; // Trigger full reinitialization
        }
      }
      
      // Try to actually read data to verify database integrity
      print('🔍 Attempting to read config...');
      final config = BudgetService.getConfig();
      if (config == null) {
        throw Exception('Config is null after box verification');
      }
      print('✅ Config read successfully');
      
      // Try to read accounts to further verify
      print('🔍 Attempting to read accounts...');
      final accounts = BudgetService.getAccounts();
      print('✅ Accounts read successfully: ${accounts.length} found');
      
      print('✅ Database fully verified and accessible');
    } catch (e, stackTrace) {
      print('❌ Database verification failed: $e');
      print('Stack: $stackTrace');
      print('⚠️  Triggering app restart with full database reinitialization...');
      
      // Don't try to close boxes - just mark as uninitialized and rebuild
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _rebuildKey++; // Force FutureBuilder to rebuild
          _initFuture = _reinitializeFromScratch();
        });
      }
    }
  }
  
  Future<bool> _reinitializeFromScratch() async {
    print('🔄 Starting full reinitialization from scratch...');
    
    // Close all boxes if any are open
    try {
      final openBoxNames = ['accounts', 'bills', 'transactions', 'config'];
      for (var boxName in openBoxNames) {
        if (Hive.isBoxOpen(boxName)) {
          print('  📕 Closing box: $boxName');
          await Hive.box(boxName).close();
        }
      }
      print('✅ All boxes closed');
    } catch (closeError) {
      print('⚠️  Error during box closing (ignoring): $closeError');
    }
    
    // Small delay to ensure iOS has fully released resources
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Now reinitialize
    return _initializeDatabase();
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
      key: ValueKey(_rebuildKey), // Force rebuild when key changes
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
