// lib/models/task.dart
import 'package:flutter/material.dart'; // Para TimeOfDay, si lo usas

class Task {
  final String id; // Identificador único para la tarea
  final String title;
  final String? description; // Descripción opcional
  final DateTime date; // Fecha a la que pertenece la tarea
  final TimeOfDay? time; // Hora opcional para la tarea
  bool isCompleted;
  // Puedes añadir más propiedades como prioridad, categoría, etc.

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.time,
    this.isCompleted = false,
  });

  // Método para crear una copia de la tarea con algunos campos modificados
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time, // Si time es null, usa el existente.
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // (Opcional) Métodos para convertir a/desde JSON si planeas guardar las tareas
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(), // Guardar fecha como ISO string
      'time':
          time != null
              ? '${time!.hour}:${time!.minute}'
              : null, // Guardar hora como string H:M
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parsedTime;
    if (json['time'] != null) {
      final parts = (json['time'] as String).split(':');
      parsedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: parsedTime,
      isCompleted: json['isCompleted'],
    );
  }
}
