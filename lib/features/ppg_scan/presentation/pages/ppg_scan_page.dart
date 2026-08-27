import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ppg_scan_bloc.dart';
import '../widgets/scan_widgets.dart';
import 'vitals_summary_page.dart';

class PPGScanPage extends StatelessWidget {
  const PPGScanPage({super.key});

  @override
  Widget build(BuildContext context) => BlocListener<PPGScanBloc, PPGScanState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ScanStatus.completed && state.result != null) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => VitalsSummaryPage(result: state.result!, onScanAgain: () { Navigator.of(context).pop(); final bloc = context.read<PPGScanBloc>(); bloc.add(ResetScan()); bloc.add(InitializeScan()); })));
          }
        },
        child: Scaffold(body: SafeArea(child: BlocBuilder<PPGScanBloc, PPGScanState>(builder: (context, state) => _body(context, state)))),
      );

  Widget _body(BuildContext context, PPGScanState state) {
    final bloc = context.read<PPGScanBloc>();
    final cameraController = bloc.cameraController;
    if (state.status == ScanStatus.error) return _message(context, 'Camera unavailable', state.errorMessage ?? 'Please check camera permission.', Icons.no_photography_outlined, false);
    if (state.status == ScanStatus.insufficientSignal) return _message(context, 'Signal quality too low', state.errorMessage ?? 'Keep your finger steady and try again.', Icons.signal_cellular_connected_no_internet_0_bar, true);
    return LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 28), child: ConstrainedBox(constraints: BoxConstraints(minHeight: (constraints.maxHeight - 48).clamp(0.0, double.infinity)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Senvo', style: TextStyle(fontSize: 18, letterSpacing: 1.4, fontWeight: FontWeight.w800, color: Color(0xff0b6e69))), const SizedBox(height: 6), const Text('Camera PPG scan', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Cover the rear camera and flash completely. Keep gentle, consistent pressure.', style: TextStyle(color: Color(0xff647477))), const SizedBox(height: 20), AspectRatio(aspectRatio: 0.82, child: state.cameraInitialized && CameraPreviewWidget.canRenderPreview(cameraController) ? CameraPreviewWidget(controller: cameraController) : Container(decoration: BoxDecoration(color: const Color(0xffdbe8e7), borderRadius: BorderRadius.circular(24)), child: const Center(child: CircularProgressIndicator()))), const SizedBox(height: 16), Row(children: [Icon(state.torchEnabled ? Icons.flash_on : Icons.flash_off, color: state.torchEnabled ? const Color(0xffd48a2b) : const Color(0xff89999a)), const SizedBox(width: 8), Text(state.torchEnabled ? 'Torch active' : 'Torch off', style: const TextStyle(fontWeight: FontWeight.w700)), const Spacer(), SignalQualityIndicator(quality: state.signalQuality)]), const SizedBox(height: 18), const Text('Live PPG signal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), const SizedBox(height: 6), Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: WaveformWidget(samples: state.waveformSamples))), const SizedBox(height: 16), Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(minHeight: 10, value: state.progress))), const SizedBox(width: 12), Text('${(state.elapsed.inMilliseconds / 1000).toStringAsFixed(1)} / 10.0 s', style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]))]), const SizedBox(height: 20), if (state.status == ScanStatus.ready) SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => context.read<PPGScanBloc>().add(StartScan()), icon: const Icon(Icons.play_arrow), label: const Text('Start 10-second scan'))) else if (state.status == ScanStatus.scanning) const Center(child: Text('Scanning... keep still', style: TextStyle(fontWeight: FontWeight.w700))) else if (state.status == ScanStatus.processing) const Center(child: CircularProgressIndicator()), ]))));
  }

  Widget _message(BuildContext context, String title, String message, IconData icon, bool retry) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 48, color: const Color(0xff0b6e69)), const SizedBox(height: 18), Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800), textAlign: TextAlign.center), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xff647477))), const SizedBox(height: 24), FilledButton.icon(onPressed: () { final bloc = context.read<PPGScanBloc>(); bloc.add(retry ? ResetScan() : InitializeScan()); if (retry) bloc.add(InitializeScan()); }, icon: const Icon(Icons.refresh), label: const Text('Try again'))])));
}