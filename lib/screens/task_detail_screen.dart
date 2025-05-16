// lib/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Si generas IDs aquí

import '../models/task.dart';
import '../provider/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task; // Tarea existente para editar, o null si es nueva tarea
  final DateTime? initialDate; // Fecha inicial sugerida para una nueva tarea

  const TaskDetailScreen({super.key, this.task, this.initialDate});

  static const routeNameAdd = '/add-task'; // Opcional
  static const routeNameEdit = '/edit-task'; // Opcional

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isInit = true; // Para cargar datos iniciales solo una vez

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.task != null) {
      // Modo Edición
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedDate = widget.task!.date;
      _selectedTime = widget.task!.time;
    } else {
      // Modo Creación
      _selectedDate = widget.initialDate ?? DateTime.now();
      // _selectedTime = TimeOfDay.now(); // O dejarlo null por defecto
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale(
        'es',
        'ES',
      ), // Asegúrate de tener el soporte de localización
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          // Para formato AM/PM si es necesario
          context: context,
          locale: const Locale(
            'es',
            'ES',
          ), // O tu locale preferido para el picker
          child: child,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!
          .save(); // No es estrictamente necesario si usas controllers

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final title = _titleController.text;
      final description = _descriptionController.text;

      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una fecha.')),
        );
        return;
      }

      if (widget.task != null) {
        // Actualizar tarea existente
        final updatedTask = widget.task!.copyWith(
          title: title,
          description: description.isEmpty ? null : description,
          date: _selectedDate!,
          time: _selectedTime, // Puede ser null
        );
        taskProvider.updateTask(updatedTask);
      } else {
        // Añadir nueva tarea
        // El ID se genera en el TaskProvider o aquí
        taskProvider.addTask(
          title,
          _selectedDate!,
          description: description.isEmpty ? null : description,
          time: _selectedTime, // Puede ser null
        );
      }
      Navigator.of(context).pop(); // Regresar a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Añadir Tarea' : 'Editar Tarea'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTask),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Para evitar overflow si el teclado aparece
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Reunión de equipo',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un título.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (Opcional)',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Discutir avances del proyecto X',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  'Fecha y Hora:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No seleccionada'
                            : 'Fecha: ${DateFormat.yMMMd('es_ES').format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      child: const Text('Elegir Fecha'),
                      onPressed: () => _pickDate(context),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedTime == null
                            ? 'Sin hora específica'
                            // ignore: use_build_context_synchronously
                            : 'Hora: ${_selectedTime!.format(context)}', // Usa el formato localizado
                      ),
                    ),
                    TextButton(
                      child: const Text('Elegir Hora'),
                      onPressed: () => _pickTime(context),
                    ),
                    if (_selectedTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedTime = null;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(
                      widget.task == null ? 'Crear Tarea' : 'Guardar Cambios',
                    ),
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
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
}
