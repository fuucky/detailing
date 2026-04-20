import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:estetica_auto/screens/home_screen.dart'; // ajuste se o HomeScreen estiver em outro path
import 'package:estetica_auto/screens/perfil_cliente_screen.dart';
import 'package:estetica_auto/screens/perfil_admin_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // true = login, false = cadastro
  bool _isLoading = false;
  String? _errorMessage;

  // submit de auth
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    // Login fake temporário (para teste/protótipo)
    if (email == 'admin' && senha == 'admin') {
      try {
        //cria conta fake admin, unica vez
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'admin@fake.com',
          password: 'admin123',
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // cria conta fake se nao existir nenhuma
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'admin@fake.com',
            password: 'admin123',
          );
        } else {
          rethrow;
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      final isAdminFake = user?.email == 'admin@fake.com';

      //login fake
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isAdminFake
              ? const PerfilAdminScreen()
              : const PerfilClienteScreen(),
        ),
      );
    }


    // Se não for admin/admin → usa o login real do Firebase
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: senha,
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  PerfilClienteScreen()),
      );

      // Sucesso real: StreamBuilder redireciona
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'invalid-email':
          errorMsg = 'Email inválido ou mal formatado.';
          break;
        case 'user-disabled':
          errorMsg = 'Essa conta foi desativada.';
          break;
        case 'user-not-found':
          errorMsg = 'Nenhum usuário encontrado com esse email.';
          break;
        case 'wrong-password':
          errorMsg = 'Senha incorreta.';
          break;
        case 'email-already-in-use':
          errorMsg = 'Esse email já está cadastrado. Tente entrar.';
          break;
        case 'weak-password':
          errorMsg = 'Senha muito fraca (use pelo menos 6 caracteres).';
          break;
        case 'operation-not-allowed':
          errorMsg = 'Cadastro/login por email não está ativado no Firebase.';
          break;
        case 'too-many-requests':
          errorMsg = 'Muitas tentativas. Espere alguns minutos.';
          break;
        case 'network-request-failed':
          errorMsg = 'Sem conexão com a internet. Verifique sua rede.';
          break;
        default:
          errorMsg = 'Erro no Firebase: ${e.code} - ${e.message ?? "Sem detalhes"}';
      }
      setState(() {
        _errorMessage = errorMsg;
      });
      print('FirebaseAuthException: code=${e.code}, message=${e.message}');
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Erro inesperado: $e';
      });
      print('Erro geral: $e');
      print('Stack trace: $stackTrace');
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
                const SizedBox(height: 32),
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
                    if (!value.contains('')) return 'Email inválido';
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
                    if (value.length < 3) return 'Senha deve ter pelo menos 6 caracteres'; // SUBSTITUIR O NUMERO DE LETRAS "1 É APENAS TESTE"
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
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
                    style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
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