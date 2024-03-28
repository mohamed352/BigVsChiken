import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:mygame/actor/player.dart';
import 'package:mygame/actor/player_enum.dart';
import 'package:mygame/core/manager/Character.dart';
import 'package:mygame/core/manager/tiles_manager.dart';
import 'package:mygame/levels/level.dart';


class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
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
        width: 640, height: 360, world: myWorld);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, myWorld]);
    if (showJoyStick) {
      joyStick();
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
        background: SpriteComponent(
            sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
        margin: const EdgeInsets.only(left: 32, bottom: 32));
    add(joystickComponent);
  }

  void updateJoyStick() {
    switch (joystickComponent.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
        break;
      default:
        player.playerDirection = PlayerDirection.none;
        break;
    }
    
    
  }
}
