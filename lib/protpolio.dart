import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_protpolio/character/main_character.dart';
import 'package:game_protpolio/ground.dart';

class Portfolio extends FlameGame with HasCollisionDetection, TapDetector,KeyboardEvents{
  MainCharacter man = MainCharacter();
  double gravity = 9.8;
  Vector2 velocity = Vector2(0, 0);
  double speed = 100;
  double jump = 200;
  late Rectangle _levelBounds;
  bool movement = false;
  double friction = 0.9;
  late TiledComponent background1;
  late final CameraComponent cameraComponent;
  late final World world;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    background1 = await TiledComponent.load('tiled.tmx', Vector2.all(32));
    add(background1);

    _levelBounds = Rectangle.fromPoints(Vector2(0,0), Vector2(32.0 * background1.tileMap.map.height,1080));

    double width = 32.0 * background1.tileMap.map.width;
    final obstacleGroup = background1.tileMap.getLayer<ObjectGroup>('ground');

    for(final obj in obstacleGroup!.objects){
      add(Ground(position: Vector2(obj.x,obj.y), size: Vector2(obj.width,obj.height)));
    }

    man
      ..sprite = await loadSprite('man.png')
      ..size = Vector2(50,64)..position = Vector2(200, 544);

    world = World(children: [background1,man]);
    cameraComponent = CameraComponent(
      world: world,
    );
    cameraComponent.follow(man);
    cameraComponent.setBounds(Rectangle.fromPoints(_levelBounds.topRight, _levelBounds.topLeft));
    await addAll([world, cameraComponent]);
  }
  @override
  void update(double dt) {
    super.update(dt);
    // Apply gravity
    if(!man.onGround){
      velocity.y += gravity;
    }
    if (movement) {
      man.position += velocity * dt;
    } else {
      velocity.x *= friction; // Apply friction to slow down the character gradually
      if (velocity.x.abs() < 0.1) {
        velocity.x = 0; // Stop completely when the velocity is very small
      }
      man.position += velocity * dt;
    }
  }


  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    if (event is KeyDownEvent) {
      movement = true;
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        velocity.x += speed;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        velocity.x -= speed;
      }else if(keysPressed.contains(LogicalKeyboardKey.arrowUp)){
        man.y -= 10;
        velocity.y = -jump;
      }
    } else if (event is KeyUpEvent) {
      movement = false;
    }

    return KeyEventResult.handled;
  }

}
