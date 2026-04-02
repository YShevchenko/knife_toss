import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const KnifeTossApp());

class KnifeTossApp extends StatelessWidget {
  const KnifeTossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knife Toss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.red.shade700,
          secondary: Colors.redAccent,
        ),
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔪 Knife Toss'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, size: 80, color: Colors.redAccent),
            const SizedBox(height: 32),
            const Text(
              'Tap to throw knives!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Avoid hitting other knives',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: const Text('START GAME', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class Knife {
  final double angle; // Angle on the target
  final bool isStuck; // Whether knife is stuck on target

  Knife({required this.angle, this.isStuck = true});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _throwController;

  List<Knife> knives = [];
  int knivesRemaining = 7;
  int level = 1;
  int score = 0;
  bool isThrowing = false;
  bool gameOver = false;
  double throwProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Target rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 - (level * 200).clamp(800, 2800)),
    )..repeat();

    // Knife throw animation
    _throwController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _throwController.addListener(() {
      setState(() {
        throwProgress = _throwController.value;
      });
    });

    _throwController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stickKnife();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _throwController.dispose();
    super.dispose();
  }

  void _throwKnife() {
    if (isThrowing || gameOver || knivesRemaining <= 0) return;

    setState(() {
      isThrowing = true;
    });

    _throwController.forward(from: 0);
  }

  void _stickKnife() {
    final currentAngle = _rotationController.value * 2 * math.pi;

    // Check collision with existing knives
    for (var knife in knives) {
      final angleDiff = (knife.angle - currentAngle).abs();
      final normalizedDiff = angleDiff % (2 * math.pi);

      // If knives are too close (within 20 degrees), game over
      if (normalizedDiff < 0.35 || normalizedDiff > 2 * math.pi - 0.35) {
        setState(() {
          gameOver = true;
          isThrowing = false;
        });
        return;
      }
    }

    setState(() {
      knives.add(Knife(angle: currentAngle));
      knivesRemaining--;
      score += 10;
      isThrowing = false;

      // Level complete
      if (knivesRemaining == 0) {
        _nextLevel();
      }
    });
  }

  void _nextLevel() {
    setState(() {
      level++;
      knivesRemaining = 7 + level; // More knives each level
      knives.clear();

      // Speed up rotation
      _rotationController.duration = Duration(
        milliseconds: 3000 - (level * 200).clamp(800, 2800),
      );
      _rotationController.repeat();
    });
  }

  void _restart() {
    setState(() {
      knives.clear();
      knivesRemaining = 7;
      level = 1;
      score = 0;
      gameOver = false;
      isThrowing = false;

      _rotationController.duration = const Duration(milliseconds: 3000);
      _rotationController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gameOver) {
      return Scaffold(
        appBar: AppBar(title: const Text('Game Over!')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dangerous, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text('Game Over!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Level: $level', style: const TextStyle(fontSize: 24)),
              Text('Score: $score', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _restart,
                child: const Text('Try Again', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Menu', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Level $level'),
            Text('Score: $score'),
            Text('Knives: $knivesRemaining'),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: _throwKnife,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Target and stuck knives
              Center(
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(300, 300),
                      painter: TargetPainter(
                        rotation: _rotationController.value * 2 * math.pi,
                        knives: knives,
                      ),
                    );
                  },
                ),
              ),

              // Flying knife
              if (isThrowing)
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 20,
                  bottom: 50 + (MediaQuery.of(context).size.height / 2 - 150) * throwProgress,
                  child: const Icon(Icons.arrow_upward, size: 40, color: Colors.white),
                ),

              // Instruction text
              if (!isThrowing && knivesRemaining > 0)
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'TAP TO THROW',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TargetPainter extends CustomPainter {
  final double rotation;
  final List<Knife> knives;

  TargetPainter({required this.rotation, required this.knives});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw target (wooden log style)
    final targetPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, targetPaint);

    // Draw wood grain circles
    final grainPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * i / 5, grainPaint);
    }

    // Draw center dot
    final centerPaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);

    // Draw stuck knives
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (var knife in knives) {
      canvas.save();
      canvas.rotate(knife.angle);

      // Knife handle
      final handlePaint = Paint()
        ..color = Colors.grey.shade800
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(center: Offset(0, -radius - 30), width: 12, height: 40),
        handlePaint,
      );

      // Knife blade
      final bladePaint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill;

      final bladePath = Path()
        ..moveTo(-6, -radius - 10)
        ..lineTo(0, -radius - 60)
        ..lineTo(6, -radius - 10)
        ..close();

      canvas.drawPath(bladePath, bladePaint);

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(TargetPainter oldDelegate) => true;
}
