import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:mygame/actor/player.dart';
import 'package:mygame/components/jumb_button.dart';
import 'package:mygame/core/manager/Character.dart';
import 'package:mygame/core/manager/tiles_manager.dart';
import 'package:mygame/levels/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  late final JoystickComponent joystickComponent;
  bool showJoyStick = true;
  final Player player = Player(
    character: Character.mask,
  );

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    final myWorld = Level(levelName: TilesAssets.level1, player: player);
    cam = CameraComponent.withFixedResolution(
        width: 540, height: 360, world: myWorld);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, myWorld]);
    if (showJoyStick) {
      joyStick();
      add(JumpButton());
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoyStick) {
      updateJoyStick();
    }
    super.update(dt);
  }

  void joyStick() {
    joystickComponent = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
      background:
          SpriteComponent(sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
    );
    add(joystickComponent);
  }

  void updateJoyStick() {
    switch (joystickComponent.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMoveSpeed = -1;

        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMoveSpeed = 1;
        break;
      default:
        player.horizontalMoveSpeed = 0;
        break;
    }
  }
}
