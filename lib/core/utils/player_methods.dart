import 'package:mygame/actor/player.dart';
import 'package:mygame/components/collision.dart';

abstract class PlayerMethods {
  bool checkCollision(Player player, CollisionBlock block);
}
