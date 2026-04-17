import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/tina_theme.dart';
import '../components/tina_visuals.dart';

/// TINA 主界面 - HUD 风格语音助手
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _textController;
  
  State _currentState = State.idle;
  String _statusText = 'TINA 就绪';
  String _responseText = '';
  bool _isListening = false;
  List<String> _conversation = [];
  
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // 启动后打招呼
    _delayedWelcome();
  }
  
  void _delayedWelcome() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _showGreeting();
  }
  
  void _showGreeting() {
    setState(() {
      _currentState = State.speaking;
      _statusText = 'TINA 在线';
      _responseText = '你好，我是 TINA。\n有什么可以帮助你的吗？';
    });
    _textController.forward();
  }
  
  void _startListening() {
    setState(() {
      _isListening = true;
      _currentState = State.listening;
      _statusText = '正在聆听...';
      _responseText = '';
    });
    HapticFeedback.mediumImpact();
    
    // 模拟接收语音
    Future.delayed(const Duration(seconds: 3), () {
      if (_isListening) {
        _stopListening('打开我的文档');
      }
    });
  }
  
  void _stopListening(String text) {
    setState(() {
      _isListening = false;
      _currentState = State.thinking;
      _statusText = '正在思考...';
      _conversation.add('你: $text');
    });
    
    // 模拟处理
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _currentState = State.speaking;
        _statusText = '正在回复';
        _responseText = '好的，正在为您打开文档文件夹。';
        _conversation.add('TINA: 正在为您打开文档文件夹');
      });
    });
  }
  
  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
  
  void _showCarMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('车载模式开发中...'),
        backgroundColor: TinaColors.surface,
      ),
    );
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TinaColors.background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                TinaColors.background,
                TinaColors.backgroundDark,
                TinaColors.background.withOpacity(0.95),
              ],
            ),
          ),
          child: Column(
            children: [
              // 顶部状态栏
              _buildStatusBar(),
              
              // 主内容区
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景 HUD 网格
                    _buildHUDBackground(),
                    
                    // 中央视觉元素
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TINA 眼睛动画
                        Hero(
                          tag: 'tina_eye',
                          child: TinaEye(
                            state: _currentState,
                            size: 200,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // 音频波形
                        AnimatedAudioWaveform(
                          state: _currentState,
                          maxHeight: 60,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // 状态文字
                        Text(
                          _statusText,
                          style: TextStyle(
                            fontSize: 18,
                            color: _getStateColor(),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: _getStateColor().withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // 回复文字
                        if (_responseText.isNotEmpty)
                          AnimatedBuilder(
                            animation: _textController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textController.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 20,
                                  ),
                                  margin: const EdgeInsets.symmetric(horizontal: 30),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: TinaColors.surface.withOpacity(0.5),
                                    border: Border.all(
                                      color: TinaColors.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _responseText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: TinaColors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 底部控制区
              _buildControlArea(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：时间
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: TinaColors.textPrimary,
                  fontFamily: 'Orbitron',
                ),
              );
            },
          ),
          
          // 右侧：状态指示器
          Row(
            children: [
              // 在线指示
              Container(
                width: 8,
                height: 8,
                decoration:const BoxDecoration(
                  shape: BoxShape.circle,
                  color: TinaColors.online,
                  boxShadow: [
                    BoxShadow(
                      color: TinaColors.online,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'HERMES',
                style: TextStyle(
                  fontSize: 12,
                  color: TinaColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildHUDBackground() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _HUDGridPainter(
            glowOpacity: 0.1 + _glowController.value * 0.1,
          ),
        );
      },
    );
  }
  
  Widget _buildControlArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          children: [
            // 主按钮 - 长按说话
            GestureDetector(
              onTapDown: (_) => _startListening(),
              onTapUp: (_) {
                if (_isListening) {
                  _stopListening('你好 Tina');
                }
              },
              onTapCancel: () {
                if (_isListening) {
                  _stopListening('');
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening 
                    ? TinaColors.listening 
                    : TinaColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening 
                        ? TinaColors.listening 
                        : TinaColors.primary
                      ).withOpacity(0.5),
                      blurRadius: _isListening ? 40 : 20,
                      spreadRadius: _isListening ? 10 : 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: TinaColors.background,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _isListening ? '松开结束' : '按住说话',
              style: TextStyle(
                fontSize: 14,
                color: _isListening 
                  ? TinaColors.listening 
                  : TinaColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 底部按钮行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomButton(
                  icon: Icons.directions_car,
                  label: '车载',
                  onTap: _showCarMode,
                ),
                _buildBottomButton(
                  icon: Icons.history,
                  label: '对话',
                  onTap: () {
                    _showConversationHistory();
                  },
                ),
                _buildBottomButton(
                  icon: Icons.settings,
                  label: '设置',
                  onTap: _showSettings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Icon(
                icon,
                color: TinaColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: TinaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showConversationHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TinaColors.surface.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TinaColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '对话历史',
                style: TextStyle(
                  fontSize: 18,
                  color: TinaColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _conversation.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _conversation[index],
                        style: const TextStyle(
                          color: TinaColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Color _getStateColor() {
    switch (_currentState) {
      case State.idle:
        return TinaColors.idle;
      case State.listening:
        return TinaColors.listening;
      case State.thinking:
        return TinaColors.thinking;
      case State.speaking:
        return TinaColors.speaking;
      case State.error:
        return Colors.red;
      case State.offline:
        return Colors.grey;
    }
  }
}

/// HUD 背景网格绘制
class _HUDGridPainter extends CustomPainter {
  final double glowOpacity;
  
  _HUDGridPainter({required this.glowOpacity});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TinaColors.primary.withOpacity(glowOpacity)
      ..strokeWidth = 0.5;
    
    // 绘制网格
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
    
    // 绘制 HUD 边框装饰
    final borderPaint = Paint()
      ..color = TinaColors.primary.withOpacity(glowOpacity * 2)
      ..strokeWidth = 1;
    
    const cornerSize = 30.0;
    // 左上角
    canvas.drawLine(Offset(20, 20), Offset(20 + cornerSize, 20), borderPaint);
    canvas.drawLine(Offset(20, 20), Offset(20, 20 + cornerSize), borderPaint);
    
    // 右上角
    canvas.drawLine(Offset(size.width - 20, 20), Offset(size.width - 20 - cornerSize, 20), borderPaint);
    canvas.drawLine(Offset(size.width - 20, 20), Offset(size.width - 20, 20 + cornerSize), borderPaint);
    
    // 左下角
    canvas.drawLine(Offset(20, size.height - 20), Offset(20 + cornerSize, size.height - 20), borderPaint);
    canvas.drawLine(Offset(20, size.height - 20), Offset(20, size.height - 20 - cornerSize), borderPaint);
    
    // 右下角
    canvas.drawLine(Offset(size.width - 20, size.height - 20), Offset(size.width - 20 - cornerSize, size.height - 20), borderPaint);
    canvas.drawLine(Offset(size.width - 20, size.height - 20), Offset(size.width - 20, size.height - 20 - cornerSize), borderPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
