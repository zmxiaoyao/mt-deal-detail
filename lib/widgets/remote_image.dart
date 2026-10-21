import 'package:flutter/material.dart';

import '../theme.dart';

/// 网络图 + 优雅占位（无网/防盗链/空 URL 都不炸）
class RemoteImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius radius;
  final String label;
  final double labelSize;

  const RemoteImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = const BorderRadius.all(Radius.circular(0)),
    this.label = '',
    this.labelSize = 11,
  });

  bool get _isRemote => url.startsWith('http://') || url.startsWith('https://');
  bool get _isAsset => url.startsWith('assets/');

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: C.thumbBg,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant, size: 18, color: C.t5),
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: labelSize, color: C.t4, height: 1.2),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isRemote) {
      child = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (BuildContext c, Object e, StackTrace? s) => _placeholder(),
        loadingBuilder: (BuildContext c, Widget w, ImageChunkEvent? p) {
          if (p == null) return w;
          return _placeholder();
        },
      );
    } else if (_isAsset) {
      child = Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (BuildContext c, Object e, StackTrace? s) => _placeholder(),
      );
    } else {
      child = _placeholder();
    }
    return ClipRRect(borderRadius: radius, child: child);
  }
}
