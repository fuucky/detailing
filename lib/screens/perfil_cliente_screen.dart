import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:estetica_auto/screens/auth_screen.dart';

class PerfilClienteScreen extends StatelessWidget {
  const PerfilClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) =>  AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${FirebaseAuth.instance.currentUser?.email ?? "Cliente"}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text('Agendamentos Pendentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(Icons.schedule, color: Colors.orange),
                      title: Text('Lavagem Completa - Carro'),
                      subtitle: Text('18/02/2026 - 10:00 • Pendente'),
                      trailing: Text('R\$ 180', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // Adicione mais cards fake
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Vitrificação - Moto'),
                      subtitle: Text('05/02/2026 • Concluído • R\$ 500'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}