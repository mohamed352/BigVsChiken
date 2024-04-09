import 'dart:async';

import 'package:flame/components.dart';
import 'package:mygame/core/utils/constant.dart';
import 'package:mygame/pixel_adventure.dart';

class BackGroundColor extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackGroundColor(positions, this.color) : super(position: positions);
  @override
  FutureOr<void> onLoad() {
    priority = -1;
    size = Vector2.all(64.6);
    sprite = Sprite(game.images.fromCache("Background/$color.png"));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += Constant.scrollSpeed;
    final scrollHeight = (game.size.y / Constant.tileSize).floor();
    if (position.y > scrollHeight * Constant.tileSize) {
      position.y = -Constant.tileSize;
    }

    super.update(dt);
  }
}
