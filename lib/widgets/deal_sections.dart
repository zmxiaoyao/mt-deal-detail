import 'package:flutter/material.dart';

import '../models/deal.dart';
import '../theme.dart';
import 'remote_image.dart';
import 'tinted_icon.dart';

/// 白卡：左右各缩进 8、圆角 10、内边距 12（量自参考截图）
class MTCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;

  const MTCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(12, 14, 12, 14),
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: S.margin),
      padding: padding,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: radius ?? BorderRadius.circular(S.radius),
      ),
      child: child,
    );
  }
}

/// 统一的灰色小圆点（列表符号 / 分隔用），保证各处大小一致
class _Dot extends StatelessWidget {
  final double size;

  const _Dot({this.size = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: C.t5, shape: BoxShape.circle),
    );
  }
}

/// 价格行下方的灰色虚线：直径 2.6、间距 7 的等距圆点
class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DottedPainter(), size: Size.infinite);
  }
}

class _DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = const Color(0xFFE3E3E3);
    const double r = 1.3; // 直径 2.6
    const double step = 7;
    for (double x = r; x < size.width; x += step) {
      canvas.drawCircle(Offset(x, size.height / 2), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 顶部圆形悬浮按钮：展开态 = 半透明黑底 + 白色抠图图标；
/// 折叠态（滚动吸顶后）= 无底色 + 黑色抠图图标，与参考截图一致。
Widget _circleButton(
  String icon,
  VoidCallback? onTap, {
  bool collapsed = false,
  double iconHeight = 17,
}) {
  final Widget img = TintedIcon(
    icon,
    height: iconHeight,
    color: collapsed ? C.t1 : Colors.white,
  );
  return Material(
    color: collapsed ? Colors.transparent : const Color(0x3D000000),
    shape: const CircleBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Center(child: img),
      ),
    ),
  );
}

/// 顶部大图（含状态栏高度，图片铺满）
class BannerSection extends StatelessWidget {
  final List<String> images;
  final String label;

  const BannerSection({super.key, required this.images, this.label = ''});

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: S.bannerH + top,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (images.isNotEmpty)
            RemoteImage(url: images.first, fit: BoxFit.cover, label: label)
          else
            const ColoredBox(color: C.thumbBg),
          // 顶部压一层浅黑渐变，保证白色图标可读
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const <Color>[Color(0x40000000), Color(0x00000000)],
                stops: const <double>[0.0, 0.34],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部操作条（返回 / 搜索 / 收藏 / 分享 / 更多）
/// [collapsed] 为 true 时（页面下滑吸顶）底色变白、图标变黑。
class DealTopBar extends StatelessWidget {
  final bool collapsed;
  final VoidCallback? onMore;

  const DealTopBar({super.key, this.collapsed = false, this.onMore});

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      color: collapsed ? Colors.white : Colors.transparent,
      padding: EdgeInsets.fromLTRB(10, top + 5, 12, collapsed ? 7 : 0),
      child: Row(
        children: <Widget>[
          _circleButton('back', () => Navigator.maybePop(context), collapsed: collapsed),
          const Spacer(),
          _circleButton('search', null, collapsed: collapsed),
          const SizedBox(width: 6),
          _circleButton('star', null, collapsed: collapsed),
          const SizedBox(width: 6),
          _circleButton('share', null, collapsed: collapsed),
          const SizedBox(width: 6),
          _circleButton('more', onMore, collapsed: collapsed, iconHeight: 4),
        ],
      ),
    );
  }
}

/// 价格 + 标题 + 口碑 + 服务标签
/// 大图 + 价格卡：价格卡向上叠压 12px，
/// 这样卡片顶部的圆角处露出来的是大图，而不是页面底色（否则圆角会变成两个「灰方块」）。
class BannerAndPrice extends StatelessWidget {
  final DealDetail deal;

  const BannerAndPrice({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top;
    const double overlap = 12;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        BannerSection(images: deal.bannerImages, label: deal.title),
        Padding(
          padding: EdgeInsets.only(top: S.bannerH + top - overlap),
          child: PriceSection(deal: deal),
        ),
      ],
    );
  }
}

class PriceSection extends StatelessWidget {
  final DealDetail deal;

  const PriceSection({super.key, required this.deal});

  Widget _badge(String text, {bool thumb = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: C.badgeBg,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (thumb) ...<Widget>[
            const Icon(Icons.thumb_up_alt_outlined, size: 10, color: C.t4),
            const SizedBox(width: 2),
          ],
          Text(text, style: const TextStyle(fontSize: 11, color: C.t3, height: 1.1)),
        ],
      ),
    );
  }

  Widget _equationItem(String label, String value, {bool help = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(label, style: const TextStyle(fontSize: 11.5, color: C.t1, height: 1.1)),
            if (help) ...<Widget>[
              const SizedBox(width: 1.5),
              const Icon(Icons.help_outline, size: 10, color: C.t2),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: C.t1, fontWeight: FontWeight.w500, height: 1.1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String statsText = <String>[
      if (deal.positiveRate.isNotEmpty || deal.reviewCount.isNotEmpty)
        '${deal.positiveRate}${deal.positiveRate.isNotEmpty && deal.reviewCount.isNotEmpty ? '·' : ''}${deal.reviewCount}',
      if (deal.repeatBuyers.isNotEmpty) deal.repeatBuyers,
      if (deal.soldCount.isNotEmpty) deal.soldCount,
    ].where((String s) => s.isNotEmpty).toList().join('|');

    return Container(
      decoration: const BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 17, 12, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 价格行：¥8.9 [8.2折]        ＝ 零售价 ¥10.9 − 团购优惠 ¥2
          // 等式组按参考截图的横向坐标定位（参考量测：＝ 起点 124、团购优惠 右缘 269，
          // 内容区宽 366 → 起点占 33.9%），不随价格块宽度漂移。
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              return SizedBox(
                height: 36,
                child: Stack(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // 参考里价格离左边缘 ≈18.5（卡片内边距 12 + 6.5），这里补 5px 对齐
                        const SizedBox(width: 5),
                        Text(
                          '¥',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: C.primary,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          deal.price,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: C.primary,
                            height: 1.0,
                          ),
                        ),
                        if (deal.discountTag.isNotEmpty) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 2, 2, 2),
                            decoration: BoxDecoration(
                              color: C.tagBg,
                              borderRadius: BorderRadius.circular(3.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  deal.discountTag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: C.primary,
                                    height: 1.1,
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 13, color: C.primary),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                    if (deal.retailPrice.isNotEmpty)
                      Positioned(
                        // 价格位数多（如 ¥1299）时整体右移，避免与价格块重叠
                        left: c.maxWidth * (deal.price.length > 3 ? 0.46 : 0.339),
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Transform.translate(
                            // 参考里等式组整体比价格数字略高一点（组中线在价格墨迹中线之上 ~4）
                            offset: const Offset(0, -6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('＝', style: TextStyle(fontSize: 12, color: C.t1)),
                                const SizedBox(width: 8),
                                _equationItem('零售价', '¥${deal.retailPrice}', help: true),
                                const SizedBox(width: 14),
                                if (deal.promotionAmount.isNotEmpty) ...<Widget>[
                                  const Text('−', style: TextStyle(fontSize: 12, color: C.t1)),
                                  const SizedBox(width: 14),
                                  _equationItem('团购优惠', '¥${deal.promotionAmount}'),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 3),
          // 参考截图里价格行与标题之间是一条灰色虚线（小圆点等距排列）
          const SizedBox(height: 3, width: double.infinity, child: _DottedLine()),
          const SizedBox(height: 10),
          Text(
            deal.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: C.t1,
              height: 1.34,
            ),
          ),
          if (statsText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 9),
            Wrap(
              runSpacing: 6,
              children: <Widget>[
                if (deal.positiveRate.isNotEmpty || deal.reviewCount.isNotEmpty)
                  _badge(
                    '${deal.positiveRate}${deal.positiveRate.isNotEmpty && deal.reviewCount.isNotEmpty ? '·' : ''}${deal.reviewCount}',
                    thumb: true,
                  ),
                if (deal.repeatBuyers.isNotEmpty) _badge(deal.repeatBuyers),
                if (deal.soldCount.isNotEmpty) _badge(deal.soldCount),
              ],
            ),
          ],
          if (deal.serviceTags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 9),
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today_outlined, size: 11, color: C.t4),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    deal.serviceTags.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: C.t3, height: 1.35),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 13, color: C.t3),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 团购详情（分组 + 菜品）
class MenuSection extends StatelessWidget {
  final DealDetail deal;

  const MenuSection({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    return MTCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            deal.menuTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.t1),
          ),
          for (final MenuGroup g in deal.menu) ...<Widget>[
            if (g.title.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Text(
                    g.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: C.t1,
                      height: 1.2,
                    ),
                  ),
                  if (g.note.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 6),
                    Text(g.note, style: const TextStyle(fontSize: 11.5, color: C.t4)),
                  ],
                ],
              ),
            ],
            for (final MenuItem it in g.items)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 9, right: 7),
                      child: _Dot(size: 4),
                    ),
                    Expanded(
                      child: Text(
                        it.name,
                        style: const TextStyle(fontSize: 14, color: C.t2, height: 1.45),
                      ),
                    ),
                    if (it.spec.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 8),
                      Text(
                        '(${it.spec})',
                        style: const TextStyle(fontSize: 12, color: C.t4, height: 1.5),
                      ),
                    ],
                    if (it.price.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 8),
                      Text(
                        '¥${it.price}',
                        style: const TextStyle(fontSize: 13, color: C.t2, height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// 购买须知
class TermsSectionView extends StatelessWidget {
  final DealDetail deal;

  const TermsSectionView({super.key, required this.deal});

  /// 图标名对应从参考截图抠出的 PNG（assets/img/icons/term0..3.png）
  String _icon(String key) {
    switch (key) {
      case 'time':
        return 'term1';
      case 'rule':
        return 'term2';
      case 'price':
        return 'term3';
      default:
        return 'term0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MTCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            deal.termTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.t1),
          ),
          for (int ti = 0; ti < deal.terms.length; ti++) ...<Widget>[
            if (ti == 0)
              const SizedBox(height: 13)
            else ...<Widget>[
              const SizedBox(height: 10),
              Container(height: 0.5, color: const Color(0xFFEFEFEF)),
              const SizedBox(height: 8),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: TintedIcon(_icon(deal.terms[ti].icon), height: 16.5, color: C.t1),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        deal.terms[ti].title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: C.t1,
                          height: 1.25,
                        ),
                      ),
                      for (int i = 0; i < deal.terms[ti].lines.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (deal.terms[ti].bullet) ...<Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(top: 9, right: 7),
                                  child: _Dot(size: 4),
                                ),
                              ],
                              Flexible(
                                child: Text(
                                  deal.terms[ti].lines[i],
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: C.t3,
                                    height: deal.terms[ti].bullet ? 1.55 : 1.6,
                                  ),
                                ),
                              ),
                              if (deal.terms[ti].actionUrl != null && i == deal.terms[ti].lines.length - 1)
                                const Padding(
                                  padding: EdgeInsets.only(top: 3, left: 2),
                                  child: Icon(Icons.chevron_right, size: 15, color: C.t5),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 适用商户
class PoiSection extends StatelessWidget {
  final DealDetail deal;

  const PoiSection({super.key, required this.deal});

  Widget _star() => const Icon(Icons.star, size: 12, color: Color(0xFFFF8A00));

  @override
  Widget build(BuildContext context) {
    final Poi poi = deal.poi;
    if (poi.isEmpty) return const SizedBox.shrink();
    return MTCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                '适用商户',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.t1),
              ),
              const Spacer(),
              if (poi.summary.isNotEmpty)
                Text(
                  poi.summary,
                  style: const TextStyle(fontSize: 12, color: C.t3),
                ),
              const Icon(Icons.chevron_right, size: 14, color: C.t5),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RemoteImage(
                url: poi.logo,
                width: 50,
                height: 50,
                radius: BorderRadius.circular(5),
                label: poi.name.isEmpty ? '' : poi.name.substring(0, 1),
                labelSize: 15,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      poi.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: C.t1,
                        height: 1.25,
                      ),
                    ),
                    if (poi.rating.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          _star(),
                          _star(),
                          _star(),
                          _star(),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              poi.rating,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, color: C.t3),
                            ),
                          ),
                          if (poi.avgPrice.isNotEmpty) ...<Widget>[
                            _dot(),
                            Flexible(
                              child: Text('¥${poi.avgPrice}/人',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11.5, color: C.t3)),
                            ),
                          ],
                          if (poi.distance.isNotEmpty) ...<Widget>[
                            _dot(),
                            Flexible(
                              child: Text(poi.distance,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11.5, color: C.t3)),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (poi.hours.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            poi.hours,
                            style: const TextStyle(fontSize: 12, color: C.t3),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: <Widget>[
                  const Icon(Icons.phone, size: 18, color: C.t2),
                  const SizedBox(height: 1),
                  Text(
                    poi.contactText,
                    style: const TextStyle(fontSize: 10.5, color: C.t3),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('·', style: TextStyle(fontSize: 11, color: C.t4)),
      );
}

/// 本店团购
class RecommendSection extends StatelessWidget {
  final DealDetail deal;

  const RecommendSection({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    if (deal.recommend.isEmpty) return const SizedBox.shrink();
    return MTCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                deal.recommendTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.t1),
              ),
              const Spacer(),
              if (deal.recommendTotal.isNotEmpty)
                Text(
                  '查看全部 (${deal.recommendTotal})',
                  style: const TextStyle(fontSize: 12, color: C.t3),
                ),
              const Icon(Icons.chevron_right, size: 14, color: C.t5),
            ],
          ),
          for (final RecommendDeal r in deal.recommend)
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RemoteImage(
                    url: r.image,
                    width: 58,
                    height: 62,
                    radius: BorderRadius.circular(4),
                    label: r.title,
                    labelSize: 9,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                r.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: C.t1,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 13, color: C.t4),
                          ],
                        ),
                        if (r.sales.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            r.sales,
                            style: const TextStyle(fontSize: 10, color: C.t4),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '¥',
                              style: const TextStyle(
                                fontSize: 12,
                                color: C.primary,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              r.price,
                              style: const TextStyle(
                                fontSize: 17,
                                color: C.primary,
                                height: 1.05,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (r.discount.isNotEmpty) ...<Widget>[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFFF7A45), width: 0.6),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  r.discount,
                                  style: const TextStyle(fontSize: 10, color: C.primary, height: 1.2),
                                ),
                              ),
                            ],
                            if (r.retailPrice.isNotEmpty) ...<Widget>[
                              const SizedBox(width: 5),
                              Text(
                                '¥${r.retailPrice}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: C.t5,
                                  height: 1.55,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: C.t5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    height: 29,
                    child: Material(
                      color: C.orangeEnd,
                      borderRadius: BorderRadius.circular(14.5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.5),
                        onTap: () {},
                        child: const Center(
                          child: Text(
                            '抢购',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// 底部固定操作条
class DealBottomBar extends StatelessWidget {
  final DealDetail deal;

  const DealBottomBar({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).padding.bottom;
    final String sub = deal.buySubText.isNotEmpty
        ? deal.buySubText
        : (deal.price.isEmpty ? '' : '折后 ¥${deal.price}');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: C.divider, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottom),
      child: Row(
        children: <Widget>[
          // 左：门店（图标从参考截图抠出）
          SizedBox(
            width: 111,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TintedIcon('store', height: 21, color: C.t1),
                const SizedBox(height: 2),
                Text(
                  '门店',
                  style: const TextStyle(fontSize: 10, color: C.t1, height: 1.1),
                ),
              ],
            ),
          ),
          // 右：一整颗胶囊，左半「加入购物车」、右半「立即团购」，中间无缝
          Expanded(
            child: SizedBox(
              height: 38,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[Color(0xFFFFC42F), Color(0xFFFE9D1B)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {},
                            child: Center(
                              child: Text(
                                deal.cartText,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[Color(0xFFFF7C21), Color(0xFFFF5311)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {},
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    deal.buyText,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.15,
                                    ),
                                  ),
                                  if (sub.isNotEmpty)
                                    Text(
                                      sub,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        color: Color(0xF2FFFFFF),
                                        height: 1.15,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
