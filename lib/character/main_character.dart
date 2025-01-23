import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:game_protpolio/constants_classes/main_character_sprite.dart';
import 'package:game_protpolio/ground.dart';
import 'package:game_protpolio/hit_box.dart';
import 'package:game_protpolio/protpolio.dart';

enum MainCharacterAnimation {
  idle,
  falling,
  walking,
  jumping,
  doubleJump
}

class MainCharacter extends SpriteAnimationGroupComponent
    with HasGameRef<Portfolio>, KeyboardHandler, CollisionCallbacks{

  late Vector2 _minClamp;
  late Vector2 _maxClamp;

  MainCharacter({required Rectangle levelBounds}):super(){
    debugMode = true;
    anchor = Anchor.center;
    _minClamp = levelBounds.topLeft + (size / 2);
    _maxClamp = levelBounds.bottomRight + (size / 2);
  }

  List <Ground> ground = [];
  double gravity = 15;
  Vector2 velocity = Vector2(0, 0);
  double speed = 100;
  double jump = 220;
  double friction = 0.9;
  bool isRightKey=false;
  bool isLeftKey = false;
  bool isFacingLeft =false;
  bool onGround = false;
  double horizontalMovement = 0;
  bool hasJumped = false;
  double terminalVelocity = 300;
  int jumpCount = 0;
  int maxJumps = 2; // Allow double jump
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  Future<void> onLoad() async {

    final SpriteAnimation idle = await MainCharacterSprites.idle();
    final SpriteAnimation jumping = await MainCharacterSprites.jump();
    final SpriteAnimation walking = await MainCharacterSprites.walking();
    final SpriteAnimation falling = await MainCharacterSprites.falling();
    final SpriteAnimation doubleJump = await MainCharacterSprites.doubleJump(); // Load doubleJump animation



    animations={
      MainCharacterAnimation.idle: idle,
      MainCharacterAnimation.jumping: jumping,
      MainCharacterAnimation.walking: walking,
      MainCharacterAnimation.falling: falling,
      MainCharacterAnimation.doubleJump: doubleJump,

    };
    current = MainCharacterAnimation.idle;
    await super.onLoad();
    add(RectangleHitbox());
  }

  void applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jump, terminalVelocity);
    position.y += velocity.y * dt;
  }

  void checkHorizontalCollisions() {
    for (final block in ground) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }
  void positionUpdate(double dt) {
    // Distance = velocity * time.
    Vector2 distance = velocity * dt;
    position += distance;

    // Screen boundaries for Mario, top left and bottom right points.
    position.clamp(_minClamp, _maxClamp);
  }

  void updatePlayerMovement(double dt) {
    // Horizontal movement while on the ground or in the air
    velocity.x = horizontalMovement * speed;

    // Apply friction when not on the ground to slow down horizontal movement
    if (!onGround) {
      velocity.x *= friction;
    }

    // Apply horizontal movement
    position.x += velocity.x * dt;

    // Apply gravity and vertical movement

    // Update the position, keeping within the screen bounds
    position.clamp(_minClamp, _maxClamp);
  }

  void playerJump(double dt) {
    if (jumpCount < maxJumps) {
      velocity.y = -jump;
      position.y += velocity.y * dt;
      onGround = false;
      hasJumped = false;
      jumpCount++;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Ground) {
      onGround = false;
    }
  }

  void checkVerticalCollisions() {
    for (final block in ground) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            onGround = true;
            jumpCount = 0; // Reset jump count when landing
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            onGround = true;
            jumpCount = 0; // Reset jump count when landing
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void updatePlayerState() {
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Determine the player state based on velocity and jump count
    if (onGround) {
      if (velocity.x > 0 || velocity.x < 0) {
        current = MainCharacterAnimation.walking;
      } else {
        current = MainCharacterAnimation.idle;
      }
    } else {
      if (velocity.y < 0 && jumpCount == 1) {
        current = MainCharacterAnimation.jumping;
      } else if (velocity.y < 0 && jumpCount == 2) {
        current = MainCharacterAnimation.jumping;
      } else if (velocity.y > 0) {
        current = MainCharacterAnimation.falling;
      }
    }
  }




  bool checkCollision(player, block) {
    final hitbox = player.hitbox;
    final playerX = player.position.x + hitbox.offsetX;
    final playerY = player.position.y + hitbox.offsetY;
    final playerWidth = hitbox.width;
    final playerHeight = hitbox.height;

    final blockX = block.x;
    final blockY = block.y;
    final blockWidth = block.width;
    final blockHeight = block.height;

    final fixedX = player.scale.x < 0
        ? playerX - (hitbox.offsetX * 2) - playerWidth
        : playerX;
    final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

    return (fixedY < blockY + blockHeight &&
        playerY + playerHeight > blockY &&
        fixedX < blockX + blockWidth &&
        fixedX + playerWidth > blockX);
  }

}