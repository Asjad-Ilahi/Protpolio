import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game_protpolio/ground.dart';
import 'package:game_protpolio/protpolio.dart';

class MainCharacter extends SpriteComponent with CollisionCallbacks, HasGameRef<Portfolio>{

  MainCharacter():super(){
    debugMode = true;
    anchor = Anchor.bottomCenter;
  }

  bool onGround = false;
  bool facingRight = false;

  @override
  Future<void> onLoad() async {
    // TODO: implement onLoad
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);
    if(other is Ground){
      if(gameRef.velocity.y > 0){
        gameRef.velocity.y = 0;
        onGround = true;
      }else{
        if(gameRef.velocity.x !=0){
          for(var points in intersectionPoints){
            if(y - 5 >= points[1]){
              gameRef.velocity.x=0;
            }
          }
        }

      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // TODO: implement onCollisionEnd
    super.onCollisionEnd(other);
    onGround =  false;
  }
}