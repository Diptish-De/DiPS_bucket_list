import 'dart:math';
import 'package:flutter/material.dart';

class CelebrationScreen extends StatefulWidget {
  final String goalName;
  const CelebrationScreen({super.key, required this.goalName});

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;
  final List<ConfettiParticle> _particles = [];
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    // Generate confetti particles
    for (int i = 0; i < 120; i++) {
      _particles.add(ConfettiParticle(
        x: _rand.nextDouble(),
        y: -_rand.nextDouble() * 1.5,
        speed: 0.3 + _rand.nextDouble() * 0.7,
        size: 4 + _rand.nextDouble() * 8,
        color: [
          const Color(0xFFFF6D3B),
          const Color(0xFF4CAF50),
          const Color(0xFF4A90D9),
          const Color(0xFFE91E63),
          const Color(0xFFFF9800),
          const Color(0xFF9C27B0),
          const Color(0xFFFFD700),
        ][_rand.nextInt(7)],
        rotation: _rand.nextDouble() * 2 * pi,
        wobble: _rand.nextDouble() * 2 - 1,
      ));
    }

    _confettiController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addListener(() => setState(() {}))
      ..forward();

    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Stack(
        children: [
          // Confetti layer
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ConfettiPainter(particles: _particles, progress: _confettiController.value),
          ),
          // Center content
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎊', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 20),
                    const Text('Goal Achieved!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A24))),
                    const SizedBox(height: 12),
                    Text(
                      'You completed "${widget.goalName}"!',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF8A8A9E), fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text('Keep crushing it! 💪', style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9E))),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Awesome! 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiParticle {
  double x, y, speed, size, rotation, wobble;
  Color color;
  ConfettiParticle({required this.x, required this.y, required this.speed, required this.size, required this.color, required this.rotation, required this.wobble});
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = p.y + progress * p.speed * 2.5;
      if (currentY > 1.2) continue;
      final currentX = p.x + sin(progress * 6 + p.wobble * 3) * 0.04;

      final paint = Paint()..color = p.color.withValues(alpha: (1 - progress).clamp(0.3, 1.0));
      final rect = Rect.fromCenter(
        center: Offset(currentX * size.width, currentY * size.height),
        width: p.size,
        height: p.size * 0.6,
      );

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(p.rotation + progress * 4);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(p.size * 0.15)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter old) => true;
}
