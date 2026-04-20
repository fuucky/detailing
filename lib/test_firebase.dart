import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase inicializado com sucesso');

  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'testeteste999@gmail.com',
      password: 'teste12345678',
    );
    print('Cadastro OK');
  } catch (e) {
    print('Erro: $e');
  }
}