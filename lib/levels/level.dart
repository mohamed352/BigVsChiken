import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:mygame/actor/player.dart';
import 'package:mygame/components/collision.dart';
import 'package:mygame/components/fruit.dart';
import 'package:mygame/core/utils/constant.dart';
import 'package:mygame/levels/background_color.dart';
import 'package:mygame/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  late TiledComponent level;
  final String levelName;
  final Player player;
  final List<CollisionBlock> collisionBlocks = [];

  Level(
      {super.children,
      super.priority,
      required this.levelName,
      required this.player});
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(levelName, Vector2.all(16));
    add(level);
    _scrollBackGroundColor();
    _addSpawnLayer();
    _addCollisionLayer();

    return super.onLoad();
  }

  void _addSpawnLayer() {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(Vector2(spawnPoint.x, spawnPoint.y),
                Vector2(spawnPoint.width, spawnPoint.height),
                fruitNames: spawnPoint.name);
            add(fruit);
          default:
        }
      }
    }
  }

  void _addCollisionLayer() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(Vector2(collision.x, collision.y),
                Vector2(collision.width, collision.height),
                isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              Vector2(collision.x, collision.y),
              Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  void _scrollBackGroundColor() {
    final backGroundLayer = level.tileMap.getLayer('Background');
    final numTileSizeY = (game.size.y / Constant.tileSize).floor();
    final numTileSizeX = (game.size.x / Constant.tileSize).floor();

    if (backGroundLayer != null) {
      for (double y = 0; y < game.size.y / numTileSizeY; y++) {
        for (double x = 0; x < numTileSizeX; x++) {
          final backGroundColor =
              backGroundLayer.properties.getValue('BackgroundColor');
          final backGroundTile = BackGroundColor(
              Vector2(x * Constant.tileSize,
                  y * Constant.tileSize - Constant.tileSize),
              backGroundColor ?? 'Gray');
          add(backGroundTile);
        }
      }
    }
  }
}
