import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/tina_theme.dart';
import 'features/hud/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置全屏模式
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  
  // 设置方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const TinaApp());
}

class TinaApp extends StatelessWidget {
  const TinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TINA',
      debugShowCheckedModeBanner: false,
      theme: TinaTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
