import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/ppg_scan/presentation/bloc/ppg_scan_bloc.dart';
import 'features/ppg_scan/presentation/pages/ppg_scan_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SenvoApp());
}

class SenvoApp extends StatelessWidget {
  const SenvoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Senvo',
        theme: AppTheme.data,
        home: BlocProvider(create: (_) => PPGScanBloc()..add(InitializeScan()), child: const PPGScanPage()),
      );
}
