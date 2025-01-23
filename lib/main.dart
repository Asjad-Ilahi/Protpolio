import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_protpolio/protpolio.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: GameScreen(),));
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: Portfolio(), // Pass context here
      ),
    );
  }
}