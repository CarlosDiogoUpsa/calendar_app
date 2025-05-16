// lib/widgets/task_item_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la hora
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../provider/task_provider.dart'; // Lo necesitarás para acciones como completar o eliminar

class TaskItemWidget extends StatelessWidget {
  final Task task;

  const TaskItemWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    String formattedTime = '';
    if (task.time != null) {
      // Asegúrate que el contexto tiene una localización que MaterialLocalizations pueda usar
      // o usa un formato específico si es necesario.
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        task.time!.hour,
        task.time!.minute,
      );
      formattedTime = DateFormat.jm().format(dt); // Formato de hora ej: 5:30 PM
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            if (value != null) {
              // Aquí llamarías a un método en tu TaskProvider para actualizar el estado
              taskProvider.toggleTaskCompletion(task.id);
            }
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
            color:
                task.isCompleted
                    ? Colors.grey
                    : Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        task.isCompleted
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            if (formattedTime.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: task.isCompleted ? Colors.grey : Colors.blueGrey,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[400]),
          onPressed: () {
            // Confirmación antes de borrar
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Confirmar'),
                    content: const Text(
                      '¿Estás seguro de que quieres eliminar esta tarea?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Sí',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          taskProvider.removeTask(task.id);
                          Navigator.of(ctx).pop();
                          // Opcional: Mostrar un SnackBar de confirmación
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tarea eliminada')),
                          );
                        },
                      ),
                    ],
                  ),
            );
          },
        ),
        onTap: () {
          // Podrías navegar a una pantalla de edición de tarea o mostrar un diálogo
          // print('Editar tarea: ${task.title}');
          // Ejemplo: _showEditTaskDialog(context, task);
        },
      ),
    );
  }

  // (Opcional) Si quieres un diálogo simple para editar, podrías añadir un método aquí
  // o navegar a una nueva pantalla.
  // void _showEditTaskDialog(BuildContext context, Task task) { ... }
}
