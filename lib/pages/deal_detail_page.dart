import 'package:flutter/material.dart';

import '../models/deal.dart';
import '../theme.dart';
import '../widgets/deal_sections.dart';
import 'json_input_page.dart';

/// 团购详情页：版式与参考截图一致，内容全部来自 [DealDetail]
class DealDetailPage extends StatefulWidget {
  final DealDetail deal;

  const DealDetailPage({super.key, required this.deal});

  @override
  State<DealDetailPage> createState() => _DealDetailPageState();
}

class _DealDetailPageState extends State<DealDetailPage> {
  final ScrollController _scroll = ScrollController();
  bool _collapsed = false;

  /// 大图高度 - 顶栏高度，滚过这段后顶栏吸顶变色
  static const double _collapseOffset = 150;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool next = _scroll.offset > _collapseOffset;
    if (next != _collapsed) {
      setState(() => _collapsed = next);
    }
  }

  Future<void> _openJsonInput() async {
    final DealDetail? parsed = await Navigator.of(context).push<DealDetail>(
      MaterialPageRoute<DealDetail>(builder: (_) => const JsonInputPage()),
    );
    if (parsed != null && mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => DealDetailPage(deal: parsed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DealDetail deal = widget.deal;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ListView(
              controller: _scroll,
              padding: EdgeInsets.only(bottom: 64 + bottomInset),
              physics: const ClampingScrollPhysics(),
              children: <Widget>[
                BannerAndPrice(deal: deal),
                const SizedBox(height: S.gap),
                MenuSection(deal: deal),
                const SizedBox(height: S.gap),
                TermsSectionView(deal: deal),
                const SizedBox(height: S.gap),
                PoiSection(deal: deal),
                const SizedBox(height: S.gap),
                RecommendSection(deal: deal),
                const SizedBox(height: S.gap),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: DealTopBar(collapsed: _collapsed, onMore: _openJsonInput),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: DealBottomBar(deal: deal)),
        ],
      ),
    );
  }
}
