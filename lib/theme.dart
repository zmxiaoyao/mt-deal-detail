import 'package:flutter/material.dart';

/// 设计变量：全部按参考截图取色 / 量距（逻辑像素，基准宽度 390）。
/// 关键量测（参考截图 1007px 宽 = 390 逻辑，1 逻辑 ≈ 2.582px）：
///   页面底色 #F5F5F5，白卡左右各外缩 8、圆角 10、内边距 12
///   顶部大图高 195（含状态栏覆盖），价格卡整宽、顶部圆角 4
class C {
  C._();

  // 底色与卡片
  static const Color bg = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFF1F1F1);

  // 主色（价格 / 按钮）
  static const Color primary = Color(0xFFFF4B10);
  static const Color orangeStart = Color(0xFFFFA11E);
  static const Color orangeEnd = Color(0xFFFF5A00);
  static const Color buyStart = Color(0xFFFFC42F);
  static const Color buyEnd = Color(0xFFFE9D1B);
  static const Color buyStart2 = Color(0xFFFF7C21);
  static const Color buyEnd2 = Color(0xFFFF5311);

  // 文字
  static const Color t1 = Color(0xFF1A1A1A); // 主标题
  static const Color t2 = Color(0xFF333333); // 正文
  static const Color t3 = Color(0xFF666666); // 次要
  static const Color t4 = Color(0xFF999999); // 提示
  static const Color t5 = Color(0xFFBBBBBB); // 划线 / 占位

  // 组件底
  static const Color badgeBg = Color(0xFFF5F5F5);
  static const Color tagBg = Color(0xFFFFF1E8); // 折扣标签
  static const Color buyBg = Color(0xFFFFEFD5); // 加入购物车
  static const Color buyText = Color(0xFF9A5A00);
  static const Color thumbBg = Color(0xFFF3EFE9); // 图片占位
}

/// 常用间距（逻辑像素，量自参考截图）
class S {
  S._();

  static const double page = 12; // 卡片左右内边距
  static const double margin = 8; // 白卡距屏幕左右各 8
  static const double gap = 8; // 卡片之间的灰缝
  static const double cardV = 14; // 卡片上下内边距
  static const double radius = 10; // 白卡圆角
  static const double bannerH = 195; // 顶部大图高度（不含状态栏）
}
