import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:estetica_auto/screens/perfil_admin_screen.dart';
import 'package:estetica_auto/screens/perfil_cliente_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;     // true = login, false = cadastro
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    try {
      UserCredential userCredential;

      // ==================== LOGIN FAKE PARA ADMIN ====================
      if (email == 'admin' && senha == 'admin') {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'admin@fake.com',
            password: 'admin123',
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: 'admin@fake.com',
              password: 'admin123',
            );
          } else {
            rethrow;
          }
        }
      }
      // ==================== LOGIN/CADASTRO REAL ====================
      else {
        if (_isLogin) {
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: senha,
          );
        } else {
          userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: senha,
          );
        }
      }

      // ==================== DECIDE PARA ONDE IR ====================
      final user = userCredential.user;
      final bool isAdmin = user?.email == 'admin@fake.com';

      if (!mounted) return;

      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PerfilAdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PerfilClienteScreen()),
        );
      }

    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Erro ao autenticar';
      switch (e.code) {
        case 'invalid-email':
          errorMsg = 'Email inválido';
          break;
        case 'user-not-found':
          errorMsg = 'Usuário não encontrado';
          break;
        case 'wrong-password':
          errorMsg = 'Senha incorreta';
          break;
        case 'email-already-in-use':
          errorMsg = 'Este email já está cadastrado';
          break;
        case 'weak-password':
          errorMsg = 'Senha muito fraca (mínimo 6 caracteres)';
          break;
        case 'network-request-failed':
          errorMsg = 'Sem conexão com a internet';
          break;
        default:
          errorMsg = 'Erro: ${e.message}';
      }
      setState(() => _errorMessage = errorMsg);
    } catch (e) {
      setState(() => _errorMessage = 'Erro inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Entrar' : 'Cadastrar'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Digite seu email';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Digite sua senha';
                    if (value.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
                    return null;
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isLogin ? 'Entrar' : 'Cadastrar',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Entrar',
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}