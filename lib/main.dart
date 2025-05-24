import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/blocs/auth/auth_bloc.dart';
import 'package:pos/blocs/tables/tables_bloc.dart'; // Tambahkan import ini
import 'package:pos/repositories/auth/auth_repository.dart';
import 'package:pos/repositories/tables/tables_repository.dart';
import 'package:pos/screens/splash_screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Ganti BlocProvider dengan MultiBlocProvider
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          ),
        ),
        BlocProvider<TableBloc>(
          // Tambahkan TableBloc
          create: (context) => TableBloc(
            tableRepository: TableRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
