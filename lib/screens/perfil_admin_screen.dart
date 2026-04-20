import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PerfilAdminScreen extends StatelessWidget {
  const PerfilAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agendamentos')
            .orderBy('criado_em', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum agendamento encontrado'));
          }

          final agendamentos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final doc = agendamentos[index];
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;

              final status = data['status'] as String? ?? 'Pendente';
              Color statusColor = Colors.grey;
              if (status == 'Pendente') statusColor = Colors.orange;
              if (status == 'Aceito') statusColor = Colors.blue;
              if (status == 'Concluído') statusColor = Colors.green;
              if (status == 'Cancelado') statusColor = Colors.red;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ExpansionTile(
                  leading: Icon(Icons.calendar_today, color: statusColor),
                  title: Text(
                    '${data['servico'] ?? 'Serviço'} - ${data['veiculo'] ?? 'Veículo'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${data['cliente'] ?? 'Cliente'} • ${data['data'] ?? ''} ${data['hora'] ?? ''} • $status'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Telefone: ${data['telefone'] ?? 'Não informado'}'),
                          const SizedBox(height: 8),
                          Text('Observação: ${data['observacao'] ?? 'Nenhuma'}'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Aceitar'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () => _atualizarStatus(context, id, 'Aceito'),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.done_all, size: 18),
                                label: const Text('Concluir'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                onPressed: () => _atualizarStatus(context, id, 'Concluído'),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Cancelar'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => _atualizarStatus(context, id, 'Cancelado'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () => _editarObservacao(context, id, data['observacao'] ?? ''),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _atualizarStatus(BuildContext context, String docId, String novoStatus) async {
    try {
      await FirebaseFirestore.instance.collection('agendamentos').doc(docId).update({
        'status': novoStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para: $novoStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e')),
      );
    }
  }

  void _editarObservacao(BuildContext context, String docId, String observacaoAtual) {
    final controller = TextEditingController(text: observacaoAtual);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Observação'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Adicione observações...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('agendamentos').doc(docId).update({
                  'observacao': controller.text,
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Observação atualizada')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao atualizar: $e')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}