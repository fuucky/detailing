import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
// import 'package:intl/intl.dart';  // importar se for preciso formatar datas

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estética Auto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData) {
            return const HomeScreen(); // se logado → vai para home
          }
          return const AuthScreen(); // se não logado → tela de login/cadastro

          // Teste simples: mostra se Firebase está ok
          if (Firebase.apps.isEmpty) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Firebase NÃO inicializado!',
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
              ),
            );
          }

        },
      ),
    );
  }
}

