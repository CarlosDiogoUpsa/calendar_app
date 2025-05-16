import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- Importa esto

import 'screens/calendar_screen.dart';
import 'provider/task_provider.dart';
// Asegúrate de importar TaskDetailScreen si la necesitas para rutas nombradas o onGenerateRoute
// import 'screens/task_detail_screen.dart';
// Asegúrate de importar el modelo Task si lo necesitas para onGenerateRoute
// import 'models/task.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendario de Tareas',
      theme: ThemeData(primarySwatch: Colors.blue),

      // *** Añade estas líneas para la localización ***
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // Inglés (opcional pero recomendado)
        Locale('es', 'ES'), // Español
        // Añade más locales si tu app soporta otros idiomas
      ],

      // ********************************************
      home: const CalendarScreen(),

      // Si usas rutas nombradas para añadir o editar, configúralas aquí o en onGenerateRoute
      // routes: {
      //    CalendarScreen.routeName: (context) => const CalendarScreen(),
      //    TaskDetailScreen.routeNameAdd: (context) => const TaskDetailScreen(),
      //    // La ruta de edición si la manejas con argumentos via onGenerateRoute:
      //    // TaskDetailScreen.routeNameEdit: (context) => const TaskDetailScreen(), // No la declares aquí si usas onGenerateRoute para pasar argumentos
      // },
      //
      // Si usas onGenerateRoute para manejar la edición pasando argumentos (como sugerí antes):
      // onGenerateRoute: (settings) {
      //   if (settings.name == TaskDetailScreen.routeNameEdit) { // Asegúrate que TaskDetailScreen.routeNameEdit esté definido
      //     final task = settings.arguments as Task?; // Asegúrate de importar tu modelo Task
      //     if (task != null) {
      //       return MaterialPageRoute(
      //         builder: (context) {
      //           return TaskDetailScreen(task: task); // Asegúrate de importar TaskDetailScreen
      //         },
      //       );
      //     }
      //   }
      //   // Si no es una ruta manejada aquí, deja que Flutter busque en 'routes'
      //   return null;
      // },
    );
  }
}
