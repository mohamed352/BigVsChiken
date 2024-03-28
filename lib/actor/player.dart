import 'dart:async';

import 'package:flame/components.dart';
import 'package:mygame/actor/player_enum.dart';
import 'package:mygame/core/manager/character.dart';
import 'package:mygame/core/utils/constant.dart';
import 'package:mygame/pixel_adventure.dart';
import 'package:flutter/services.dart';
class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;
  final String character;
  
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  PlayerDirection playerDirection = PlayerDirection.none;
  bool isFacingRight = true;

  Player({super.position,this.character = Character.frog,});
  @override
  void update(double dt) {
    updateDirections(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isKeyRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    if (isKeyRight && isKeyLeft) {
      playerDirection = PlayerDirection.none;
    } else if (isKeyRight) {
      playerDirection = PlayerDirection.right;
    } else if (isKeyLeft) {
      playerDirection = PlayerDirection.left;
    } else {
      playerDirection = PlayerDirection.none;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  FutureOr<void> onLoad() {
    _onLoadAnimation();
    return super.onLoad();
  }

  void _onLoadAnimation() {
    
    idleAnimation = initAnimation(CharacterState.idle, 11);
    runningAnimation = initAnimation(CharacterState.run, 12);
    appearingAnimation = specialSpriteAnimation(CharacterState.appearing, 7);
    jumpingAnimation = initAnimation(CharacterState.jump, 1);
    hitAnimation = initAnimation(CharacterState.idle, 7)..loop = false;
    fallingAnimation = initAnimation(CharacterState.idle, 1);
    disappearingAnimation =
        specialSpriteAnimation(CharacterState.disappearing, 7);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };
    current = PlayerState.running;
  }

  SpriteAnimation initAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(
            amount: amount,
            stepTime: Constant.stepTime,
            textureSize: Vector2.all(32)));
  }

  SpriteAnimation specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: Constant.stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void updateDirections(double dt) {
    double dx = 0.0;
    switch (playerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running;
        dx -= moveSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        dx += moveSpeed;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
      default:
    }
    velocity = Vector2(dx, 0.0);
    position += velocity * dt;
  }
}
