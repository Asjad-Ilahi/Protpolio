import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:particles_flutter/component/particle/particle.dart';
import 'package:particles_flutter/particles_engine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children:[
          SpriteFollower(),
        ]),
      ),
    );
  }
}

class SpriteFollower extends StatefulWidget {
  const SpriteFollower({super.key});
  @override
  State<SpriteFollower> createState() => _SpriteFollowerState();
}

class _SpriteFollowerState extends State<SpriteFollower> with SingleTickerProviderStateMixin {
  Offset _cursorPosition = Offset.zero;
  Offset _spritePosition = const Offset(100, 100); // Initial position of the cat sprite
  late AnimationController _controller;
  int _currentSpriteIndex = 0;
  List<ui.Image> _idleSprites = [];
  List<ui.Image> _runSprites = [];
  List<ui.Image> _attackSprites = [];

  bool _isLoading = true;
  bool _isFacingRight = true;
  bool _isCursorWithinBounds = false;

  int _frameUpdateCounter = 0; // Counter for frame updates
  final int _frameUpdateThreshold = 2; // Number of ticks before updating the frame

  @override
  void initState() {
    super.initState();
    _loadSprites().then((_) {
      setState(() {
        _isLoading = false;
      });
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50), // Short duration, but we'll control frame rate manually
    )..repeat();

    _controller.addListener(_updateSprite);
  }
  void _updateSprite() {
    _frameUpdateCounter++;
    if (_frameUpdateCounter >= _frameUpdateThreshold) {
      setState(() {
        // Use the correct sprite list length for the current animation state
        int frameCount = _getCurrentSpriteFramesCount();
        _currentSpriteIndex = (_currentSpriteIndex + 1) % frameCount;
        _frameUpdateCounter = 0;
      });
    }

    if (_isCursorWithinBounds) {
      _updateSpritePosition(); // Keep updating the sprite's position
    }
  }

  ui.Image? _getCurrentSprite() {
    if (_idleSprites.isEmpty || _runSprites.isEmpty || _attackSprites.isEmpty) {
      return null; // If any of the sprite lists are empty, return null.
    }

    double distance = (_cursorPosition - _spritePosition).distance;
    if (!_isCursorWithinBounds) {
      return _idleSprites[_currentSpriteIndex % _idleSprites.length];
    } else if (distance < 50) {
      return _attackSprites[_currentSpriteIndex % _attackSprites.length];
    } else if (distance < 1020) {
      return _runSprites[_currentSpriteIndex % _runSprites.length];
    } else {
      return _idleSprites[_currentSpriteIndex % _idleSprites.length];
    }
  }

  int _getCurrentSpriteFramesCount() {
    if (!_isCursorWithinBounds) {
      return _idleSprites.isEmpty ? 1 : _idleSprites.length;
    } else if ((_cursorPosition - _spritePosition).distance < 50) {
      return _attackSprites.isEmpty ? 1 : _attackSprites.length;
    } else {
      return _runSprites.isEmpty ? 1 : _runSprites.length;
    }
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSprites() async {
    _idleSprites = await _loadSpriteFrames('images/main/cat/idle.png', 8);
    _runSprites = await _loadSpriteFrames('images/main/cat/run.png', 10);
    _attackSprites = await _loadSpriteFrames('images/main/cat/attack.png', 8);
    setState(() {});
  }

  Future<List<ui.Image>> _loadSpriteFrames(String assetName, int frameCount) async {
    final ByteData data = await rootBundle.load(assetName);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image fullImage = (await codec.getNextFrame()).image;

    final List<ui.Image> frames = [];
    final int frameWidth = (fullImage.width / frameCount).floor();
    final int frameHeight = fullImage.height;

    for (int i = 0; i < frameCount; i++) {
      final ui.Image frame = await _cropImage(fullImage, Rect.fromLTWH(i * frameWidth.toDouble(), 0, frameWidth.toDouble(), frameHeight.toDouble()));
      frames.add(frame);
    }

    return frames;
  }

  Future<ui.Image> _cropImage(ui.Image image, Rect rect) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint();

    canvas.drawImageRect(image, rect, Rect.fromLTWH(0, 0, rect.width, rect.height), paint);

    return await recorder.endRecording().toImage(rect.width.floor(), rect.height.floor());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _cursorPosition = event.position;
          _isCursorWithinBounds = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isCursorWithinBounds = false;
        });
      },
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            _cursorPosition = details.localPosition;
            _isCursorWithinBounds = true;
          });
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xff222831),
          child: Stack(children: [
            Particles(
              awayRadius: 150,
              particles: createParticles(), // List of particles
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              onTapAnimation: false,
              awayAnimationDuration: const Duration(milliseconds: 600),
              awayAnimationCurve: Curves.linear,
              enableHover: true,
              hoverRadius: 50,
              connectDots: true,
            ),
             CustomPaint(
              painter: SpritePainter(
                spritePosition: _spritePosition,
                currentSprite: _getCurrentSprite(),
                isFacingRight: _isFacingRight,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _updateSpritePosition() {
    double dx = _cursorPosition.dx - _spritePosition.dx;
    double dy = _cursorPosition.dy - _spritePosition.dy;
    double distance = sqrt(dx * dx + dy * dy);

    if (distance > 50) { // Update sprite position only if more than 50 pixels away
      double speed = 2.0; // Slow down the movement speed
      double ratio = speed / distance;
      _spritePosition += Offset(dx * ratio, dy * ratio);

      // Determine the facing direction
      _isFacingRight = dx > 0;
    }
  }

  List<Particle> createParticles() {
    var rng = Random();
    List<Particle> particles = [];
    for (int i = 0; i < 140; i++) {
      particles.add(Particle(
        color: Colors.purple.withOpacity(0.1),
        size: rng.nextDouble() * 50,
        velocity: Offset(rng.nextDouble() * 5 * randomSign(),
            rng.nextDouble() * 50 * randomSign()),
      ));
    }
    return particles;
  }

  double randomSign() {
    var rng = Random();
    return rng.nextBool() ? 1 : -1;
  }

}

class SpritePainter extends CustomPainter {
  final Offset spritePosition;
  final ui.Image? currentSprite;
  final bool isFacingRight;

  SpritePainter({
    required this.spritePosition,
    required this.currentSprite,
    required this.isFacingRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (currentSprite != null) {
      final paint = Paint();
      const double spriteWidth = 64; // Target width
      const double spriteHeight = 64; // Target height

      final double dx = spritePosition.dx - spriteWidth / 2;
      final double dy = spritePosition.dy - spriteHeight / 2;

      // Flip sprite if necessary
      if (isFacingRight) {
        canvas.drawImageRect(
          currentSprite!,
          Rect.fromLTWH(0, 0, currentSprite!.width.toDouble(), currentSprite!.height.toDouble()), // Source rectangle
          Rect.fromLTWH(dx, dy, spriteWidth, spriteHeight), // Destination rectangle (scaled)
          paint,
        );
      } else {
        canvas.save();
        canvas.translate(dx + spriteWidth, dy);
        canvas.scale(-1, 1); // Flip horizontally
        canvas.drawImageRect(
          currentSprite!,
          Rect.fromLTWH(0, 0, currentSprite!.width.toDouble(), currentSprite!.height.toDouble()), // Source rectangle
          const Rect.fromLTWH(0, 0, spriteWidth, spriteHeight), // Destination rectangle (scaled)
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
