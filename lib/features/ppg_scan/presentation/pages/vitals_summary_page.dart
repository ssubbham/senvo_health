import 'package:flutter/material.dart';

import '../../domain/entities/ppg_entities.dart';

class VitalsSummaryPage extends StatelessWidget {
  const VitalsSummaryPage({required this.result, required this.onScanAgain, super.key});

  final VitalsResult result;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vitals summary'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Your reading', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Captured ${_time(result.timestamp)}', style: const TextStyle(color: Color(0xff647477))),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xffe1f2ec),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                const Icon(Icons.verified_outlined, color: Color(0xff0b6e69)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Signal quality', style: TextStyle(fontWeight: FontWeight.w700)), Text('${(result.signalQuality * 100).round()}% confidence', style: const TextStyle(color: Color(0xff48605d)))])),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _VitalCard(title: 'Heart rate', value: result.heartRateBpm.round().toString(), unit: 'BPM', icon: Icons.favorite_outline)), const SizedBox(width: 12), Expanded(child: _VitalCard(title: 'Blood oxygen', value: result.spo2Percent.round().toString(), unit: '% SpO2', icon: Icons.air))]),
          const SizedBox(height: 12),
          _VitalCard(title: 'Estimated blood pressure', value: '${result.bloodPressure.systolic.round()} / ${result.bloodPressure.diastolic.round()}', unit: 'mmHg', icon: Icons.monitor_heart_outlined, wide: true),
          const SizedBox(height: 18),
          Text('Experimental, non-clinical estimates. Do not use this reading for diagnosis or treatment decisions.', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w600)),
          const SizedBox(height: 26),
          FilledButton.icon(onPressed: onScanAgain, icon: const Icon(Icons.refresh), label: const Text('Scan again')),
        ],
      ),
    );
  }

  String _time(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _VitalCard extends StatelessWidget {
  const _VitalCard({required this.title, required this.value, required this.unit, required this.icon, this.wide = false});

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: const Color(0xff0b6e69)), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)))]),
          const SizedBox(height: 18),
          Text(value, style: TextStyle(fontSize: wide ? 32 : 28, fontWeight: FontWeight.w800)),
          Text(unit, style: const TextStyle(color: Color(0xff647477))),
          const SizedBox(height: 8),
          const Text('Screening estimate', style: TextStyle(color: Color(0xff17856e), fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
