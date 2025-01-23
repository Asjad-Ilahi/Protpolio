
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_protpolio/character/main_character.dart';
import 'package:game_protpolio/ground.dart';

class Portfolio extends FlameGame with HasCollisionDetection,KeyboardEvents{
  late MainCharacter man;
  late Rectangle levelBounds;
  bool movement = false;
  late TiledComponent background1;
  late final CameraComponent cameraComponent;
  late final World world;
  List<Ground> collisionBlocks = [];


  @override
  Future<void> onLoad() async {
    super.onLoad();

    background1 = await TiledComponent.load('tiled.tmx', Vector2.all(32));
    add(background1);

    levelBounds =  Rectangle.fromPoints(
      Vector2(
        0,
        0,
      ),
      Vector2(
        background1.tileMap.map.width.toDouble(),
        background1.tileMap.map.height.toDouble(),
      ) *
          32,
    );
    man = MainCharacter(levelBounds: levelBounds);
    man
      ..size = Vector2(50,52)..position = Vector2(300, 544);

    double width = (32.0 * background1.tileMap.map.width);
    world = World(children: [background1,man]);
    _addCollisions();
    cameraComponent = CameraComponent(
      world: world,
    )..viewport.size = Vector2(450, 50)
      ..viewfinder.position = man.position
    ..viewfinder.anchor = Anchor.topLeft
    ..viewport.position = Vector2(300, 0);
    cameraComponent.follow(man);
    cameraComponent.setBounds(Rectangle.fromPoints(levelBounds.topRight, levelBounds.topLeft));
    await addAll([world, cameraComponent]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    man.updatePlayerState();
    man.updatePlayerMovement(dt);
    man.positionUpdate(dt);


    man.checkHorizontalCollisions();
    man.applyGravity(dt);
    man.checkVerticalCollisions();
  }


  void _addCollisions() {
    final obstacleGroup = background1.tileMap.getLayer<ObjectGroup>('ground');

    for(final obj in obstacleGroup!.objects){
      final block = Ground(position: Vector2(obj.x,obj.y), size: Vector2(obj.width,obj.height),isPlatform: true);
      collisionBlocks.add(block);
      world.add(block);
    }
    man.ground = collisionBlocks;
  }
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
      man.horizontalMovement=0;
      final keyLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
      final keyRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);
      final keyUp = keysPressed.contains(LogicalKeyboardKey.arrowUp);
      if (keyLeft) {
        man.horizontalMovement = -1;
      }
      if (keyRight) {
        man.horizontalMovement = 1;
      }

      if(keyUp){
        man.hasJumped =true;
        man.playerJump(0);
      }

    super.onKeyEvent(event, keysPressed);

    return KeyEventResult.handled;
  }

}
