import 'dart:async';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/camera/camera_service.dart';
import '../../../../services/camera/frame_processor.dart';
import '../../../../services/permissions/permission_service.dart';
import '../../../../services/signal_processing/signal_processing.dart';
import '../../domain/entities/ppg_entities.dart';
import '../../domain/usecases/vital_estimators.dart';

enum ScanStatus { initial, requestingPermission, initializingCamera, ready, scanning, processing, completed, insufficientSignal, error }

class PPGScanState extends Equatable {
  const PPGScanState({
    this.status = ScanStatus.initial,
    this.elapsed = Duration.zero,
    this.progress = 0,
    this.framesCaptured = 0,
    this.expectedFrames = 300,
    this.currentHeartRateEstimate,
    this.signalQuality = 0,
    this.waveformSamples = const [],
    this.cameraInitialized = false,
    this.torchEnabled = false,
    this.errorMessage,
    this.result,
  });

  final ScanStatus status;
  final Duration elapsed;
  final double progress;
  final int framesCaptured;
  final int expectedFrames;
  final double? currentHeartRateEstimate;
  final double signalQuality;
  final List<double> waveformSamples;
  final bool cameraInitialized;
  final bool torchEnabled;
  final String? errorMessage;
  final VitalsResult? result;

  PPGScanState copyWith({
    ScanStatus? status,
    Duration? elapsed,
    double? progress,
    int? framesCaptured,
    double? currentHeartRateEstimate,
    double? signalQuality,
    List<double>? waveformSamples,
    bool? cameraInitialized,
    bool? torchEnabled,
    String? errorMessage,
    VitalsResult? result,
  }) => PPGScanState(
        status: status ?? this.status,
        elapsed: elapsed ?? this.elapsed,
        progress: progress ?? this.progress,
        framesCaptured: framesCaptured ?? this.framesCaptured,
        expectedFrames: expectedFrames,
        currentHeartRateEstimate: currentHeartRateEstimate ?? this.currentHeartRateEstimate,
        signalQuality: signalQuality ?? this.signalQuality,
        waveformSamples: waveformSamples ?? this.waveformSamples,
        cameraInitialized: cameraInitialized ?? this.cameraInitialized,
        torchEnabled: torchEnabled ?? this.torchEnabled,
        errorMessage: errorMessage,
        result: result ?? this.result,
      );

  @override
  List<Object?> get props => [status, elapsed, progress, framesCaptured, currentHeartRateEstimate, signalQuality, waveformSamples, cameraInitialized, torchEnabled, errorMessage, result];
}

abstract class PPGScanEvent extends Equatable {
  const PPGScanEvent();
  @override
  List<Object> get props => [];
}
class InitializeScan extends PPGScanEvent {}
class StartScan extends PPGScanEvent {}
class ResetScan extends PPGScanEvent {}
class _FrameReceived extends PPGScanEvent { const _FrameReceived(this.frame); final CameraImage frame; }
class _Tick extends PPGScanEvent { const _Tick(this.elapsed); final Duration elapsed; @override List<Object> get props => [elapsed]; }

class PPGScanBloc extends Bloc<PPGScanEvent, PPGScanState> {
  PPGScanBloc({CameraService? camera, PermissionService? permissions, FrameProcessor? processor, SignalProcessor? signalProcessor, VitalEstimator? estimator})
      : _camera = camera ?? CameraServiceImpl(),
        _permissions = permissions ?? PermissionService(),
        _processor = processor ?? CameraFrameProcessor(),
        _signalProcessor = signalProcessor ?? SignalProcessor(),
        _estimator = estimator ?? CameraPpgVitalEstimator(),
        super(const PPGScanState()) {
    on<InitializeScan>(_initialize);
    on<StartScan>(_start);
    on<ResetScan>(_reset);
    on<_FrameReceived>(_frame);
    on<_Tick>(_tick);
  }

  final CameraService _camera;
  final PermissionService _permissions;
  final FrameProcessor _processor;
  final SignalProcessor _signalProcessor;
  final VitalEstimator _estimator;
  final List<PPGSample> _samples = [];
  Timer? _timer;
  DateTime? _startedAt;
  bool _processorBusy = false;

  CameraController? get cameraController => _camera.controller;

  Future<void> _initialize(InitializeScan event, Emitter<PPGScanState> emit) async {
    emit(state.copyWith(status: ScanStatus.requestingPermission));
    final permission = await _permissions.requestCamera();
    if (permission != CameraPermissionStatus.granted) {
      emit(state.copyWith(status: ScanStatus.error, errorMessage: permission == CameraPermissionStatus.permanentlyDenied ? 'Camera access is blocked. Enable it in Settings.' : 'Camera permission is required to scan.'));
      return;
    }
    try {
      emit(state.copyWith(status: ScanStatus.initializingCamera));
      await _camera.initialize();
      await _camera.setTorch(true);
      emit(state.copyWith(status: ScanStatus.ready, cameraInitialized: true, torchEnabled: true));
    } catch (_) {
      await _camera.dispose();
      emit(state.copyWith(status: ScanStatus.error, cameraInitialized: false, torchEnabled: false, errorMessage: 'The rear camera or torch is unavailable.'));
    }
  }

  Future<void> _start(StartScan event, Emitter<PPGScanState> emit) async {
    if (state.status != ScanStatus.ready) return;
    _samples.clear();
    _startedAt = DateTime.now();
    _processorBusy = false;
    emit(state.copyWith(status: ScanStatus.scanning, elapsed: Duration.zero, progress: 0, framesCaptured: 0, waveformSamples: const [], signalQuality: 0, errorMessage: null, result: null));
    await _camera.startStream((frame) => add(_FrameReceived(frame)));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final elapsed = DateTime.now().difference(_startedAt!);
      add(_Tick(elapsed));
    });
  }

  Future<void> _frame(_FrameReceived event, Emitter<PPGScanState> emit) async {
    if (state.status != ScanStatus.scanning || _processorBusy) return;
    _processorBusy = true;
    try {
      final sample = await _processor.process(event.frame);
      if (sample != null && state.status == ScanStatus.scanning) {
        _samples.add(sample);
        final waveform = [...state.waveformSamples, sample.green];
        final bounded = waveform.length > 240 ? waveform.sublist(waveform.length - 240) : waveform;
        emit(state.copyWith(framesCaptured: _samples.length, waveformSamples: bounded));
      }
    } finally {
      _processorBusy = false;
    }
  }

  Future<void> _tick(_Tick event, Emitter<PPGScanState> emit) async {
    if (state.status != ScanStatus.scanning) return;
    final progress = (event.elapsed.inMilliseconds / 10000).clamp(0.0, 1.0);
    emit(state.copyWith(elapsed: event.elapsed, progress: progress));
    if (progress >= 1) await _finish(emit);
  }

  Future<void> _finish(Emitter<PPGScanState> emit) async {
    _timer?.cancel();
    await _camera.stopStream();
    await _camera.setTorch(false);
    emit(state.copyWith(status: ScanStatus.processing, torchEnabled: false));
    try {
      final analysis = _signalProcessor.analyze(_samples);
      emit(state.copyWith(signalQuality: analysis.sqi));
      if (!analysis.passesGate) {
        emit(state.copyWith(status: ScanStatus.insufficientSignal, errorMessage: 'Signal quality too low. Keep your finger steady and cover the camera and flash completely.'));
        return;
      }
      final result = _estimator.estimate(_samples, analysis);
      emit(state.copyWith(status: ScanStatus.completed, result: result, currentHeartRateEstimate: result.heartRateBpm));
    } catch (_) {
      emit(state.copyWith(status: ScanStatus.insufficientSignal, errorMessage: 'Not enough usable signal. Try again with gentle, consistent pressure.'));
    }
  }

  Future<void> _reset(ResetScan event, Emitter<PPGScanState> emit) async {
    await _camera.dispose();
    _samples.clear();
    emit(const PPGScanState(cameraInitialized: false, torchEnabled: false));
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _camera.dispose();
    return super.close();
  }
}