import 'package:flutter/material.dart';
import 'package:estetica_auto/screens/agendamento_page.dart';
import 'package:estetica_auto/screens/perfil_admin_screen.dart';
import 'package:estetica_auto/screens/perfil_cliente_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;

  const HomeScreen({super.key, this.isAdmin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? veiculoSelecionado;

  final servicosCarro = [
    {'nome': 'Lavagem Simples', 'duracao': '30 min', 'preco': 'R\$ 80'},
    {'nome': 'Lavagem Completa', 'duracao': '1h 30min', 'preco': 'R\$ 180'},
  ];

  final servicosMoto = [
    {'nome': 'Lavagem Simples', 'duracao': '20 min', 'preco': 'R\$ 50'},
    {'nome': 'Lavagem Completa', 'duracao': '50 min', 'preco': 'R\$ 100'},
  ];

  final servicosPicape = [
    {'nome': 'Lavagem Simples', 'duracao': '40 min', 'preco': 'R\$ 120'},
    {'nome': 'Lavagem Completa', 'duracao': '2h', 'preco': 'R\$ 250'},
  ];

  Widget _buildServicoCard(Map<String, String> servico) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueGrey.shade100,
          child: const Icon(Icons.local_car_wash, color: Colors.blueGrey),
        ),
        title: Text(
          servico['nome']!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("${servico['duracao']} • ${servico['preco']}"),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }

  Widget _buildVeiculoCard(String tipo, IconData icon) {
    final bool isSelected = veiculoSelecionado == tipo;

    String nome;
    if (tipo == 'carro') {
      nome = 'Carro';
    } else if (tipo == 'moto') {
      nome = 'Moto';
    } else {
      nome = 'SUV / Picape';
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => veiculoSelecionado = tipo);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // efeito glass
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.25)
                          : Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔥 brilho (efeito água)
                if (isSelected)
                  Positioned(
                    top: -30,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getServicos() {
    if (veiculoSelecionado == 'Carro') return servicosCarro;
    if (veiculoSelecionado == 'Moto') return servicosMoto;
    return servicosPicape;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Estética Auto'),
        backgroundColor: Colors.blueGrey,
      ),

      body: _selectedIndex == 0
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueGrey.shade900,
                          Colors.blueGrey.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Estética Auto",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Escolha o tipo do seu veículo",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  if (veiculoSelecionado == null) ...[
                    Row(
                      children: [
                        _buildVeiculoCard('Carro', Icons.directions_car),
                        const SizedBox(width: 10),
                        _buildVeiculoCard('Moto', Icons.two_wheeler),
                        const SizedBox(width: 10),
                        _buildVeiculoCard('Picape/SUV', Icons.fire_truck),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Serviços ($veiculoSelecionado)"),
                        TextButton(
                          onPressed: () =>
                              setState(() => veiculoSelecionado = null),
                          child: const Text("Trocar"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ..._getServicos().map(_buildServicoCard),
                  ],
                ],
              ),
            )
          : const AgendamentoPage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => widget.isAdmin
                    ? const PerfilAdminScreen()
                    : const PerfilClienteScreen(),
              ),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}