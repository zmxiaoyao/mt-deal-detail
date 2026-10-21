import 'package:flutter/material.dart';

/// 图标：由参考截图逐像素抠出的 PNG（纯黑 + alpha），用 [color] 染色绘制。
/// 这样图标形状与参考 100% 一致，不依赖 Material Icons 字体。
class TintedIcon extends StatelessWidget {
  final String name;
  final double height;
  final Color color;

  const TintedIcon(this.name, {super.key, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/icons/$name.png',
      height: height,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }
}
