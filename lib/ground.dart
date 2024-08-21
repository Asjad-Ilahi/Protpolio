import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Ground extends PositionComponent{
  Ground({required position, required size}): super(position: position,size: size){
    debugMode = true;
  }

  @override
  Future<void> onLoad() async{
    // TODO: implement onLoad
    await super.onLoad();
    add(RectangleHitbox());
  }
}
