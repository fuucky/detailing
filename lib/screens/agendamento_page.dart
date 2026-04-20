import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'perfil_cliente_screen.dart';   // ← Adicione esta importação

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _horarioSelecionado;

  final List<Map<String, dynamic>> _horariosDisponiveis = [
    {'hora': '08:00', 'disponivel': true},
    {'hora': '09:00', 'disponivel': true},
    {'hora': '10:00', 'disponivel': false},
    {'hora': '11:00', 'disponivel': true},
    {'hora': '12:00', 'disponivel': false},
    {'hora': '13:00', 'disponivel': true},
    {'hora': '14:00', 'disponivel': true},
    {'hora': '15:00', 'disponivel': false},
    {'hora': '16:00', 'disponivel': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha o dia para o agendamento',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _horarioSelecionado = null;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueGrey[700],
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),

            const SizedBox(height: 24),

            if (_selectedDay != null) ...[
              Text(
                'Horários disponíveis para ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _horariosDisponiveis.map((horario) {
                  final bool disponivel = horario['disponivel'] as bool;
                  final bool selecionado = _horarioSelecionado == horario['hora'];

                  return ChoiceChip(
                    label: Text(horario['hora'] as String),
                    selected: selecionado,
                    backgroundColor: disponivel ? null : Colors.grey[300],
                    selectedColor: Colors.blueGrey[700],
                    labelStyle: TextStyle(
                      color: selecionado
                          ? Colors.white
                          : (disponivel ? Colors.black : Colors.grey),
                    ),
                    onSelected: disponivel
                        ? (selected) {
                            setState(() {
                              _horarioSelecionado = selected ? horario['hora'] as String : null;
                            });
                          }
                        : null,
                  );
                }).toList(),
              ),

              if (_horarioSelecionado != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _confirmarAgendamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Agendamento',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ==================== FUNÇÃO PRINCIPAL ====================
  Future<void> _confirmarAgendamento() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado')),
      );
      return;
    }

    if (_selectedDay == null || _horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione data e horário')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('agendamentos').add({
        'uid': user.uid,
        'cliente': user.email ?? 'Cliente',
        'data': Timestamp.fromDate(_selectedDay!),
        'hora': _horarioSelecionado,
        'status': 'Pendente',
        'criado_em': FieldValue.serverTimestamp(),
        // TODO: Adicionar depois → veiculo, servicos, placa, valor, etc.
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agendamento realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Redireciona para o perfil do cliente
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PerfilClienteScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar agendamento: $e')),
      );
    }
  }
}