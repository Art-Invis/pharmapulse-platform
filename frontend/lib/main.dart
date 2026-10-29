import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/catalog_repository.dart';
import 'cubits/catalog_cubit.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(const PharmaPulseApp());
}

class PharmaPulseApp extends StatelessWidget {
  const PharmaPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => CatalogRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CatalogCubit>(
            // Одразу при створенні викликаємо loadCatalog()
            create: (context) => CatalogCubit(
              repository: context.read<CatalogRepository>(),
            )..loadCatalog(),
          ),
        ],
        child: MaterialApp(
          title: 'PharmaPulse',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          home: CatalogScreen(),
        ),
      ),
    );
  }
}