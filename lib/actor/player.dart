import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:mygame/actor/player_enum.dart';
import 'package:mygame/components/collision.dart';
import 'package:mygame/components/custom_hitbox.dart';
import 'package:mygame/components/fruit.dart';
import 'package:mygame/core/manager/character.dart';
import 'package:mygame/core/utils/constant.dart';
import 'package:mygame/core/utils/player_methods.dart';
import 'package:mygame/core/utils/player_methods_impl.dart';
import 'package:mygame/pixel_adventure.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;
  final String character;

  double moveSpeed = 100;
  double horizontalMoveSpeed = 0;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  final PlayerMethods playerMethods = PlayerMethodsImpl();
  bool isOnGround = false;
  bool hasJump = false;
  CustomHitBox box = CustomHitBox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  Player({
    super.position,
    this.character = Character.frog,
  });
  @override
  void update(double dt) {
    _updatePlayerState();
    _updateDirections(dt);
    _checkHorizontalCollision();
    _applyGravity(dt);
    _checkVerticalCollision();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMoveSpeed = 0;
    final isKeyLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isKeyRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    hasJump = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    horizontalMoveSpeed += isKeyLeft ? -1 : 0;
    horizontalMoveSpeed += isKeyRight ? 1 : 0;
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) other.collidedWithPlayer();

    super.onCollision(intersectionPoints, other);
  }

  @override
  FutureOr<void> onLoad() {
    _onLoadAnimation();
    //debugMode = true;
    add(RectangleHitbox(
      position: Vector2(box.offsetX, box.offsetY),
      size: Vector2(box.width, box.height),
    ));
    return super.onLoad();
  }

  void _onLoadAnimation() {
    idleAnimation = initAnimation(CharacterState.idle, 11);
    runningAnimation = initAnimation(CharacterState.run, 12);
    appearingAnimation = specialSpriteAnimation(CharacterState.appearing, 7);
    jumpingAnimation = initAnimation(CharacterState.jump, 1);
    hitAnimation = initAnimation(CharacterState.idle, 7)..loop = false;
    fallingAnimation = initAnimation(CharacterState.fal, 1);
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

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    if (velocity.y < 0) playerState = PlayerState.jumping;
    if (velocity.y > 0) playerState = PlayerState.falling;

    current = playerState;
  }

  void _updateDirections(double dt) {
    if (hasJump && isOnGround) _playerJump(dt);
    if (velocity.y > Constant.gravity) isOnGround = false;
    velocity.x = horizontalMoveSpeed * moveSpeed;

    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -Constant.jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJump = false;
  }

  void _checkHorizontalCollision() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        final isCollision = playerMethods.checkCollision(this, block);
        if (isCollision) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - box.offsetX - box.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + box.offsetX + box.width;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += Constant.gravity;
    velocity.y =
        velocity.y.clamp(-Constant.jumpForce, Constant.terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollision() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (playerMethods.checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - box.height - box.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (playerMethods.checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - box.height - box.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - box.offsetY;
          }
        }
      }
    }
  }
}
