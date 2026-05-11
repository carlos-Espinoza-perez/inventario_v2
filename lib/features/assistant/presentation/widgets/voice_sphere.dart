import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'assistant_voice_button.dart';

class VoiceSphere extends StatefulWidget {
  final VoiceButtonState voiceState;

  const VoiceSphere({super.key, required this.voiceState});

  @override
  State<VoiceSphere> createState() => _VoiceSphereState();
}

class _VoiceSphereState extends State<VoiceSphere>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _applyState(widget.voiceState);
  }

  @override
  void didUpdateWidget(VoiceSphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voiceState != widget.voiceState) {
      _applyState(widget.voiceState);
    }
  }

  void _applyState(VoiceButtonState state) {
    _pulseController.stop();

    switch (state) {
      case VoiceButtonState.idle:
        _pulseController.duration = const Duration(milliseconds: 2400);
        _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
        _rotateController.stop();
      case VoiceButtonState.recording:
        _pulseController.duration = const Duration(milliseconds: 600);
        _pulseAnim = Tween<double>(begin: 0.9, end: 1.15).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
        _rotateController.stop();
      case VoiceButtonState.processing:
        _pulseController.duration = const Duration(milliseconds: 800);
        _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
        _rotateController.repeat();
      case VoiceButtonState.speaking:
        _pulseController.duration = const Duration(milliseconds: 400);
        _pulseAnim = Tween<double>(begin: 0.88, end: 1.12).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
        _rotateController.stop();
    }

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, _) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo exterior
              Transform.scale(
                scale: _pulseAnim.value * 1.3,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Halo medio
              Transform.scale(
                scale: _pulseAnim.value * 1.1,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: 0.10),
                  ),
                ),
              ),
              // Esfera principal con gradiente
              Transform.scale(
                scale: _pulseAnim.value,
                child: Transform.rotate(
                  angle: widget.voiceState == VoiceButtonState.processing
                      ? _rotateController.value * 2 * math.pi
                      : 0,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.4),
                        radius: 0.85,
                        colors: _sphereColors(primary),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Ícono central según estado
              Icon(
                _stateIcon(widget.voiceState),
                color: Colors.white.withValues(alpha: 0.9),
                size: 32,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Color> _sphereColors(Color primary) {
    return switch (widget.voiceState) {
      VoiceButtonState.idle => [
          primary.withValues(alpha: 0.6),
          primary,
          primary.withValues(alpha: 0.8),
        ],
      VoiceButtonState.recording => [
          Colors.redAccent.shade100,
          Colors.red.shade600,
          Colors.red.shade800,
        ],
      VoiceButtonState.processing => [
          primary.withValues(alpha: 0.7),
          Colors.white.withValues(alpha: 0.3),
          primary,
        ],
      VoiceButtonState.speaking => [
          Colors.white.withValues(alpha: 0.5),
          primary,
          primary.withValues(alpha: 0.9),
        ],
    };
  }

  IconData _stateIcon(VoiceButtonState state) {
    return switch (state) {
      VoiceButtonState.idle => Icons.mic_none_rounded,
      VoiceButtonState.recording => Icons.mic_rounded,
      VoiceButtonState.processing => Icons.hourglass_top_rounded,
      VoiceButtonState.speaking => Icons.volume_up_rounded,
    };
  }
}
