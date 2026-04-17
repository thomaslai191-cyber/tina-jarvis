import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tina_theme.dart';

/// HUD 核心视觉组件 - 钢铁侠风格语音助手

/// 中央眼睛动画 - TINA 的核心视觉
class TinaEye extends StatefulWidget {
  final State state;
  final double size;
  final AnimationController? waveController;
  
  const TinaEye({
    super.key,
    required this.state,
    this.size = 200,
    this.waveController,
  });
  
  @override
  State<TinaEye> createState() => _TinaEyeState();
}

enum State { idle, listening, thinking, speaking, error, offline }

class _TinaEyeState extends State<TinaEye> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _waveController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _waveController = widget.waveController ?? AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  @override
  void dispose() {
    if (widget.waveController == null) {
      _waveController.dispose();
    }
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  Color get _eyeColor {
    switch (widget.state) {
      case State.idle:
        return TinaColors.idle;
      case State.listening:
        return TinaColors.listening;
      case State.thinking:
        return TinaColors.thinking;
      case State.speaking:
        return TinaColors.speaking;
      case State.error:
        return TinaColors.offline;
      case State.offline:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _eyeColor.withOpacity(0.3 + _pulseController.value * 0.3),
                _eyeColor.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.2, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: _eyeColor.withOpacity(0.5 + _pulseController.value * 0.3),
                blurRadius: 40 + _pulseController.value * 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 外圈扫描动画
              if (widget.state == State.listening || widget.state == State.thinking)
                Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _ScanningRingPainter(
                      color: _eyeColor,
                      progress: _rotationController.value,
                    ),
                  ),
                ),
              
              // 核心眼睛
              Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _eyeColor,
                  boxShadow: [
                    BoxShadow(
                      color: _eyeColor.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: widget.size * 0.15,
                    height: widget.size * 0.15,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // 波环效果
              if (widget.state == State.listening)
                ...List.generate(3, (index) {
                  final delay = index * 0.3;
                  final progress = (_pulseController.value + delay) % 1.0;
                  return Container(
                    width: widget.size * (0.5 + progress * 0.5),
                    height: widget.size * (0.5 + progress * 0.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _eyeColor.withOpacity(1 - progress),
                        width: 2,
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

/// 扫描环绘制
class _ScanningRingPainter extends CustomPainter {
  final Color color;
  final double progress;
  
  _ScanningRingPainter({required this.color, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // 绘制扫描线段
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12 + progress) * 2 * math.pi;
      final startRadius = radius * 0.7;
      final endRadius = radius;
      
      final start = center + Offset(
        math.cos(angle) * startRadius,
        math.sin(angle) * startRadius,
      );
      final end = center + Offset(
        math.cos(angle) * endRadius,
        math.sin(angle) * endRadius,
      );
      
      canvas.drawLine(start, end, paint);
    }
    
    // 绘制外圈虚线
    final dashPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 60; i += 2) {
      final angle = (i / 60 + progress * 0.5) * 2 * math.pi;
      final startRadius = radius * 0.9;
      final endRadius = radius * 0.95;
      
      final start = center + Offset(
        math.cos(angle) * startRadius,
        math.sin(angle) * startRadius,
      );
      final end = center + Offset(
        math.cos(angle) * endRadius,
        math.sin(angle) * endRadius,
      );
      
      canvas.drawLine(start, end, dashPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 音频波形可视化
class AudioWaveform extends StatelessWidget {
  final List<double> amplitudes;
  final Color color;
  final double barWidth;
  final double barSpacing;
  final double maxHeight;
  
  const AudioWaveform({
    super.key,
    required this.amplitudes,
    this.color = TinaColors.listening,
    this.barWidth = 4,
    this.barSpacing = 3,
    this.maxHeight = 100,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: amplitudes.map((amplitude) {
        final height = amplitude * maxHeight;
        return Container(
          width: barWidth,
          height: height.clamp(5, maxHeight),
          margin: EdgeInsets.symmetric(horizontal: barSpacing / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(barWidth / 2),
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// 音频可视化动画
class AnimatedAudioWaveform extends StatefulWidget {
  final State state;
  final int barCount;
  final double maxHeight;
  
  const AnimatedAudioWaveform({
    super.key,
    required this.state,
    this.barCount = 20,
    this.maxHeight = 80,
  });
  
  @override
  State<AnimatedAudioWaveform> createState() => _AnimatedAudioWaveformState();
}

class _AnimatedAudioWaveformState extends State<AnimatedAudioWaveform>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<double> _amplitudes;
  
  @override
  void initState() {
    super.initState();
    _controllers = [];
    _amplitudes = List.filled(widget.barCount, 0.2);
    
    for (int i = 0; i < widget.barCount; i++) {
      _controllers.add(
        AnimationController(
          vsync: this,
          duration: Duration(
            milliseconds: 300 + (i * 20) % 200,
          ),
        )..repeat(reverse: true),
      );
    }
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Color get _barColor {
    switch (widget.state) {
      case State.idle:
        return TinaColors.idle;
      case State.listening:
        return TinaColors.listening;
      case State.thinking:
        return TinaColors.thinking;
      case State.speaking:
        return TinaColors.speaking;
      case State.error:
        return Colors.red;
      case State.offline:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.barCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            // 根据状态生成不同的波形
            double amplitude;
            if (widget.state == State.idle) {
              amplitude = 0.2 + _controllers[index].value * 0.1;
            } else if (widget.state == State.listening) {
              amplitude = 0.3 + _controllers[index].value * 0.7;
            } else {
              amplitude = 0.1 + _controllers[index].value * 0.5;
            }
            
            return Container(
              width: 4,
              height: (amplitude * widget.maxHeight).clamp(4, widget.maxHeight),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: _barColor,
                boxShadow: [
                  BoxShadow(
                    color: _barColor.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

/// HUD 边框装饰
class HUDDecoration extends StatelessWidget {
  final Widget child;
  final double corneRadius;
  final double borderWidth;
  
  const HUDDecoration({
    super.key,
    required this.child,
    this.corneRadius = 20,
    this.borderWidth = 2,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(corneRadius),
        border: Border.all(
          color: TinaColors.primary.withOpacity(0.3),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: TinaColors.primary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(corneRadius - borderWidth),
        child: Container(
          decoration: TinaTheme.glowBoxDecoration,
          child: child,
        ),
      ),
    );
  }
}
