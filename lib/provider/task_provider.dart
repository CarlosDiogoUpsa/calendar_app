// lib/provider/task_provider.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Para groupBy y isSameDay
import '../models/task.dart';
import 'package:uuid/uuid.dart'; // Para generar IDs únicos (flutter pub add uuid)

// Función auxiliar para comparar fechas ignorando la hora (similar a table_calendar's isSameDay)
bool isSameDate(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [
    // Ejemplo de tareas iniciales (puedes cargarlas desde almacenamiento)
    Task(
      id: '1',
      title: 'Reunión de equipo',
      date: DateTime.now(),
      time: const TimeOfDay(hour: 10, minute: 0),
    ),
    Task(
      id: '2',
      title: 'Comprar víveres',
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    Task(
      id: '3',
      title: 'Llamar a Juan',
      date: DateTime.now(),
      isCompleted: true,
      time: const TimeOfDay(hour: 14, minute: 30),
    ),
    Task(
      id: '4',
      title: 'Terminar reporte',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<Task> get tasks => [..._tasks];

  // Este es el método que tu CalendarWidget ya está usando via eventLoader
  List<Task> getTasksForDay(DateTime day) {
    return _tasks.where((task) => isSameDate(task.date, day)).toList();
  }

  // Método para obtener tareas agrupadas por fecha, útil para el eventLoader de table_calendar
  Map<DateTime, List<Task>> get groupedTasks {
    return groupBy(
      _tasks,
      (Task task) =>
          DateTime.utc(task.date.year, task.date.month, task.date.day),
    );
  }

  void addTask(
    String title,
    DateTime date, {
    String? description,
    TimeOfDay? time,
  }) {
    const uuid = Uuid();
    final newTask = Task(
      id: uuid.v4(), // Genera un ID único
      title: title,
      description: description,
      date: date,
      time: time,
    );
    _tasks.add(newTask);
    notifyListeners(); // Notifica a los widgets que escuchan para que se reconstruyan
  }

  void removeTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      notifyListeners();
    }
  }

  void updateTask(Task updatedTask) {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    }
  }

  // Aquí podrías añadir métodos para cargar/guardar tareas desde/hacia
  // SharedPreferences, SQLite, Firebase, etc.
}
