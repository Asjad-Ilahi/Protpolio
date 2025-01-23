import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Ground extends PositionComponent{
  bool isPlatform;
  Ground({required position, required size,this.isPlatform=false}
      ): super(position: position,size: size){
    debugMode = true;
  }

  @override
  Future<void> onLoad() async{
    // TODO: implement onLoad
    await super.onLoad();
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}
