import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mygame/components/custom_hitbox.dart';
import 'package:mygame/core/manager/audio_manager.dart';
import 'package:mygame/core/manager/fruit_manager.dart';
import 'package:mygame/core/utils/constant.dart';
import 'package:mygame/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String fruitNames;
  Fruit(position, size, {this.fruitNames = FruitNames.apple})
      : super(
          position: position,
          size: size,
        );
  final CustomHitBox hitBox =
      CustomHitBox(offsetX: 10, offsetY: 10, width: 12, height: 12);
  bool _isCollected = false;
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = -1;
    add(RectangleHitbox(
      position: Vector2(hitBox.offsetX, hitBox.offsetY),
      size: Vector2(hitBox.width, hitBox.height),
      collisionType: CollisionType.passive,
    ));
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache("Items/Fruits/$fruitNames.png"),
        SpriteAnimationData.sequenced(
            amount: 17,
            stepTime: Constant.stepTime,
            textureSize: Vector2.all(32)));

    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!_isCollected) {
      _isCollected = true;
      FlameAudio.play(AudioAssets.collect, volume: 1.0);
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache("Items/Fruits/${FruitNames.collected}.png"),
          SpriteAnimationData.sequenced(
              amount: 6,
              stepTime: Constant.stepTime,
              textureSize: Vector2.all(32),
              loop: false));
      await animationTicker?.completed;
      removeFromParent();
    }
  }
}
