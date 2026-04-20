import 'package:flutter/material.dart';
import 'package:estetica_auto/screens/agendamento_page.dart';
import 'package:estetica_auto/screens/perfil_admin_screen.dart';
import 'package:estetica_auto/screens/perfil_cliente_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin; //parametro de admin

  const HomeScreen({super.key, this.isAdmin = false});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? veiculoSelecionado; // null = tela inicial, 'carro' ou 'moto'

  final List<Map<String, String>> servicosCarro = [
    {'nome': 'Lavagem Simples', 'duracao': '30 min', 'preco': 'R\$ 80'},
    {'nome': 'Lavagem Completa', 'duracao': '1h 30min', 'preco': 'R\$ 180'},
    {'nome': 'Polimento', 'duracao': '3h', 'preco': 'R\$ 350'},
    {'nome': 'Vitrificação', 'duracao': '5h', 'preco': 'R\$ 800'},
    {'nome': 'Cristalização', 'duracao': '4h', 'preco': 'R\$ 450'},
  ];

  final List<Map<String, String>> servicosMoto = [
    {'nome': 'Lavagem Simples', 'duracao': '20 min', 'preco': 'R\$ 50'},
    {'nome': 'Lavagem Completa', 'duracao': '50 min', 'preco': 'R\$ 100'},
    {'nome': 'Polimento', 'duracao': '2h', 'preco': 'R\$ 220'},
    {'nome': 'Vitrificação', 'duracao': '3h', 'preco': 'R\$ 500'},
    {'nome': 'Aplicação de Cera Premium', 'duracao': '1h', 'preco': 'R\$ 120'},
  ];

  Widget _buildServicoCard(Map<String, String> servico) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey[100],
          child: const Icon(Icons.local_car_wash, color: Colors.blueGrey),
        ),
        title: Text(
          servico['nome'] ?? 'Serviço',
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text('${servico['duracao'] ?? ''} • ${servico['preco'] ?? ''}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          setState(() {
            _selectedIndex = 1; // vai para aba Agendar
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Serviço selecionado: ${servico['nome'] ?? ''}')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estética Auto'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Estética Auto',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'O detalhe que transforma o seu carro.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (veiculoSelecionado == null) ...[
                    const Center(
                      child: Text(
                        'Escolha seu veículo',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.directions_car, size: 40),
                            label: const Text('Carro', style: TextStyle(fontSize: 20)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              setState(() {
                                veiculoSelecionado = 'carro';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.two_wheeler, size: 40),
                            label: const Text('Moto', style: TextStyle(fontSize: 20)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              setState(() {
                                veiculoSelecionado = 'moto';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Veículo selecionado: ${veiculoSelecionado == 'carro' ? 'Carro' : 'Moto'}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              veiculoSelecionado = null;
                            });
                          },
                          child: const Text('Trocar veículo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Escolha o serviço:',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ... (veiculoSelecionado == 'carro' ? servicosCarro : servicosMoto)
                        .map(_buildServicoCard),
                  ],
                ],
              ),
            )
          : _selectedIndex == 1
              ? const AgendamentoPage()
              : const Center(child: Text('Meus Agendamentos - Em breve')),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Horários'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey[800],
        onTap: (index) {
          if (index == 2) { // Aba Perfil
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => widget.isAdmin ? PerfilAdminScreen() : PerfilClienteScreen(),
              ),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}
