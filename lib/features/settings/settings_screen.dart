import 'package:flutter/material.dart';
import '../../core/theme/tina_theme.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _serverUrl = 'ws://192.168.1.100:8765';
  double _voiceVolume = 1.0;
  double _voiceRate = 0.5;
  bool _wakeWordEnabled = false;
  bool _carMode = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TinaColors.background,
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 连接设置
          _buildSectionTitle('Hermes 连接'),
          _buildCard(
            child: Column(
              children: [
                _buildTextField(
                  label: '服务器地址',
                  value: _serverUrl,
                  onChanged: (v) => setState(() => _serverUrl = v),
                ),
                const SizedBox(height: 8),
                _buildButton(
                  label: '测试连接',
                  onTap: () {
                    // TODO: 测试连接
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('连接测试中...'),
                        backgroundColor: TinaColors.surface,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 语音设置
          _buildSectionTitle('语音'),
          _buildCard(
            child: Column(
              children: [
                _buildSlider(
                  label: '音量',
                  value: _voiceVolume,
                  onChanged: (v) => setState(() => _voiceVolume = v),
                ),
                _buildSlider(
                  label: '语速',
                  value: _voiceRate,
                  onChanged: (v) => setState(() => _voiceRate = v),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 功能开关
          _buildSectionTitle('高级功能'),
          _buildCard(
            child: Column(
              children: [
                _buildSwitch(
                  label: '启用唤醒词',
                  subtitle: '"Tina 你在吗？"',
                  value: _wakeWordEnabled,
                  onChanged: (v) => setState(() => _wakeWordEnabled = v),
                ),
                const Divider(color: TinaColors.hudBorderDim),
                _buildSwitch(
                  label: '车载模式',
                  subtitle: 'Android Auto 支持（开发中）',
                  value: _carMode,
                  onChanged: (v) => setState(() => _carMode = v),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 关于
          _buildSectionTitle('关于'),
          _buildCard(
            child: Column(
              children: [
                _buildInfoRow('版本', '1.0.0'),
                const Divider(color: TinaColors.hudBorderDim),
                _buildInfoRow('电脑控制', '已就绪'),
                const Divider(color: TinaColors.hudBorderDim),
                _buildInfoRow('唤醒词', '待配置'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: TinaColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
  
  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: TinaColors.surface.withOpacity(0.3),
        border: Border.all(
          color: TinaColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
  
  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      onChanged: onChanged,
      style: const TextStyle(color: TinaColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: TinaColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: TinaColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: TinaColors.primary, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: TinaColors.primary,
        foregroundColor: TinaColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
  
  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: TinaColors.textSecondary)),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: TinaColors.primary),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: TinaColors.primary,
          inactiveColor: TinaColors.textMuted,
        ),
      ],
    );
  }
  
  Widget _buildSwitch({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        label,
        style: const TextStyle(color: TinaColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: TinaColors.textSecondary, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: TinaColors.primary,
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: TinaColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              color: TinaColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
