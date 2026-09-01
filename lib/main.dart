import 'package:app_config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:my_supabase_service/my_supabase_service.dart';
import 'package:norx/src/login/auth_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final AppConfig appConfig = ConfigFactory.web();
  final SupabaseService supabase = SupabaseService(appConfig);
  runApp(MyApp(supabase: supabase));
}

class MyApp extends StatelessWidget {
  final SupabaseService supabase;
  const MyApp({super.key, required this.supabase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexa Pages',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = supabase.auth.currentUser;
          // 如果已登录则展示主页，否则展示登录/注册页
          if (session != null) {
            return HomePage(supabase: supabase);
          }
          return const AuthPage();
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final SupabaseService supabase; // ✅ 加上 final

  const HomePage({super.key, required this.supabase});
  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      body: Center(child: Text('欢迎回来, ${user?.email}')),
    );
  }
}
