import 'package:mygame/actor/player.dart';
import 'package:mygame/components/collision.dart';
import 'package:mygame/core/utils/player_methods.dart';

class PlayerMethodsImpl implements PlayerMethods {
  @override
  bool checkCollision(Player player, CollisionBlock block) {
    //? Custom Box
    final box = player.box;
    //? Player
    final playerX = player.position.x + box.offsetX;
    final playerY = player.position.y + box.offsetY;
    final playerHeight = box.height;
    final playerWidth = box.width;
    final fixedX = player.scale.x < 0 ? playerX - (box.offsetX*2) - playerWidth : playerX;
    final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

    //? Block
    final blockX = block.position.x;
    final blockY = block.position.y;
    final blockHeight = block.height;
    final blockWidth = block.width;

    return (fixedY < blockY + blockHeight &&
        playerHeight + playerY > blockY &&
        fixedX < blockX + blockWidth &&
        playerWidth + fixedX > blockX);
  }
}
