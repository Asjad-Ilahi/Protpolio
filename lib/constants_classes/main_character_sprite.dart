import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class MainCharacterSprites {


  static const String _idleSpritePath = 'main/biker/biker_idle.png';
  static const String _walkingSpritePath = 'main/biker/Biker_run.png';
  static const String _jumpingSpritePath = 'main/biker/Biker_jump.png';
  static const String _fallingSpritePath = 'main/biker/Biker_fall.png';
  static const String _doubleSpritePath = 'main/biker/Biker_doublejump.png';



  static const int _idleSpriteCount = 6;
  static const int _walkingSpriteCount = 6;
  static const int _jumpingSpriteCount = 4;
  static const int _fallingSpriteCount = 4;
  static const int _doubleJumpSpriteCount = 6;



  static Future<SpriteAnimation> idle() async {
    final spriteSheet = await Images().load(_idleSpritePath);
    return SpriteAnimation.variableSpriteList(
      await _getSpriteList(spriteSheet, _idleSpriteCount),
      stepTimes: List.filled(_idleSpriteCount, 0.1),
    );
  }

  static Future<SpriteAnimation> jump() async {
    final spriteSheet = await Images().load(_jumpingSpritePath);
    return SpriteAnimation.variableSpriteList(
      await _getSpriteList(spriteSheet, _jumpingSpriteCount),
      stepTimes: List.filled(_jumpingSpriteCount, 0.1),
    );
  }

  static Future<SpriteAnimation> walking() async {
    final spriteSheet = await Images().load(_walkingSpritePath);
    return SpriteAnimation.variableSpriteList(
      await _getSpriteList(spriteSheet, _walkingSpriteCount),
      stepTimes: List.filled(_walkingSpriteCount, 0.1),
    );
  }
  static Future<SpriteAnimation> falling() async {
    final spriteSheet = await Images().load(_fallingSpritePath);
    return SpriteAnimation.variableSpriteList(
      await _getSpriteList(spriteSheet, _fallingSpriteCount),
      stepTimes: List.filled(_fallingSpriteCount, 0.1),
    );
  }
  static Future<SpriteAnimation> doubleJump() async {
    final spriteSheet = await Images().load(_doubleSpritePath);
    return SpriteAnimation.variableSpriteList(
      await _getSpriteList(spriteSheet, _doubleJumpSpriteCount),
      stepTimes: List.filled(_doubleJumpSpriteCount, 0.1),
    );
  }


  static Future<List<Sprite>> _getSpriteList(Image spriteSheet, int count) async {
    return List.generate(count, (i) =>
        Sprite(
          spriteSheet,
          srcPosition: Vector2(i *48-3,0),
          srcSize: Vector2(32, 37),
        )
    );
  }
}