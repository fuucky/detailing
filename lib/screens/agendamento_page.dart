import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:estetica_auto/screens/perfil_admin_screen.dart';
import 'package:estetica_auto/screens/perfil_cliente_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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

  String? _horarioSelecionado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Escolha o dia para o agendamento',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dia selecionado: ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
                ),
              );
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blueGrey,
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
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Horários disponíveis para ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecione um horário:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                clipBehavior: Clip.hardEdge,
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
                          : (disponivel ? Colors.black : Colors.grey[600]),
                      fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: disponivel
                        ? (bool selected) {
                            setState(() {
                              _horarioSelecionado = selected ? horario['hora'] as String : null;
                            });
                            if (selected) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Horário selecionado: ${horario['hora']}')),
                              );
                            }
                          }
                        : null,
                  );
                }).toList(),
              ),
            ),
            if (_horarioSelecionado != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Você precisa estar logado para agendar')),
                        );
                        return;
                    }

                    try {
                        await FirebaseFirestore.instance.collection('agendamentos').add({
                        'uid': user.uid,  // quem agendou
                        'cliente': user.email ?? 'Usuário sem email',  // ou nome se tiver
                        'data': _selectedDay!.toIso8601String(),
                        'hora': _horarioSelecionado,
                        'status': 'Pendente',
                        'criado_em': FieldValue.serverTimestamp(),
                        // Adicione mais campos depois (serviço, veículo, placa, etc.)
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Agendamento confirmado com sucesso!'),
                            backgroundColor: Colors.green,
                        ),
                        );

                        // Limpa seleção (opcional)
                        setState(() {
                        _horarioSelecionado = null;
                        });
                    } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar: $e')),
                        );
                    }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Confirmar Agendamento', style: TextStyle(fontSize: 18)),
              ),

            ],
          ],
        ],
      ),
    );
   }
  }
