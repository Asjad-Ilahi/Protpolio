import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_protpolio/protpolio.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameWidget(game: Portfolio()));
}