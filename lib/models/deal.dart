import 'dart:convert';

/// 把任意 JSON 值安全转成字符串（数字 8.9 -> "8.9"，整数值不带 .0）
String _s(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is num) {
    if (v is int) return v.toString();
    final d = v.toDouble();
    if (d == d.roundToDouble() && d.abs() < 1e15) return d.toInt().toString();
    return d.toString();
  }
  if (v is bool) return v ? 'true' : 'false';
  return v.toString();
}

List<dynamic> _l(dynamic v) => v is List ? v : const <dynamic>[];

Map<String, dynamic> _m(dynamic v) =>
    v is Map ? v.map((k, val) => MapEntry(k.toString(), val)) : <String, dynamic>{};

/// 团购详情里的一项菜品
class MenuItem {
  final String name;
  final String spec;
  final String price;

  const MenuItem({required this.name, this.spec = '', this.price = ''});

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
        name: _s(j['name']),
        spec: _s(j['spec']),
        price: _s(j['price']),
      );
}

/// 「团购详情」里的一个分组（主食 / 小吃 …）
class MenuGroup {
  final String title;
  final String note; // 分组右侧的说明，如「3选1」
  final List<MenuItem> items;

  const MenuGroup({required this.title, this.items = const [], this.note = ''});
}

/// 「购买须知」里的一条
class TermSection {
  final String title;
  final List<String> lines;
  final String icon; // check / time / rule / price / custom
  final bool bullet; // 行首是否带「·」
  final String actionText; // 右侧说明，如「详情请点击查看」
  final String? actionUrl;

  const TermSection({
    required this.title,
    this.lines = const [],
    this.icon = 'check',
    this.bullet = false,
    this.actionText = '',
    this.actionUrl,
  });
}

/// 「适用商户」
class Poi {
  final String name;
  final String logo;
  final String rating;
  final String avgPrice;
  final String distance;
  final String hours;
  final String summary; // 右上角：3家门店通用
  final String phone;
  final String contactText;

  const Poi({
    this.name = '',
    this.logo = '',
    this.rating = '',
    this.avgPrice = '',
    this.distance = '',
    this.hours = '',
    this.summary = '',
    this.phone = '',
    this.contactText = '联系商家',
  });

  bool get isEmpty => name.isEmpty;
}

/// 「本店团购」列表项
class RecommendDeal {
  final String id;
  final String title;
  final String image;
  final String price;
  final String retailPrice;
  final String discount;
  final String sales;

  const RecommendDeal({
    this.id = '',
    this.title = '',
    this.image = '',
    this.price = '',
    this.retailPrice = '',
    this.discount = '',
    this.sales = '',
  });
}

/// 页面数据总模型
class DealDetail {
  final String id;
  final String title;
  final String price;
  final String retailPrice;
  final String promotionAmount;
  final String discountTag;

  // 口碑/销量
  final String positiveRate; // 96%好评
  final String reviewCount; // 352条评价
  final String repeatBuyers; // 回头客740+
  final String soldCount; // 半年售 1000+

  final List<String> serviceTags; // 周一至周日可用 · 包间不可用 · …
  final List<String> bannerImages;

  final String menuTitle;
  final List<MenuGroup> menu;

  final String termTitle;
  final List<TermSection> terms;

  final String poiTitle;
  final Poi poi;

  final String recommendTitle;
  final String recommendTotal;
  final List<RecommendDeal> recommend;

  final String cartText;
  final String buyText;
  final String buySubText;

  const DealDetail({
    this.id = '',
    this.title = '',
    this.price = '',
    this.retailPrice = '',
    this.promotionAmount = '',
    this.discountTag = '',
    this.positiveRate = '',
    this.reviewCount = '',
    this.repeatBuyers = '',
    this.soldCount = '',
    this.serviceTags = const [],
    this.bannerImages = const [],
    this.menuTitle = '团购详情',
    this.menu = const [],
    this.termTitle = '购买须知',
    this.terms = const [],
    this.poiTitle = '适用商户',
    this.poi = const Poi(),
    this.recommendTitle = '本店团购',
    this.recommendTotal = '',
    this.recommend = const [],
    this.cartText = '加入购物车',
    this.buyText = '立即团购',
    this.buySubText = '',
  });

  /// 唯一入口：吃字符串，自动识别数据形态
  static DealDetail parse(String raw) {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('顶层不是 JSON 对象');
    }
    final root = decoded.map((k, v) => MapEntry(k.toString(), v));
    // 形态 1：美团原始接口 { code, message, data: {...} }
    final data = root['data'];
    if (data is Map && (_m(data).containsKey('menuArea') || _m(data).containsKey('termArea'))) {
      return DealDetail.fromMeituan(_m(data));
    }
    // 形态 2：本项目规范格式 { deal: {...} }
    if (root['deal'] is Map) return DealDetail.fromJson(_m(root['deal']));
    // 形态 3：直接把 deal 对象写在顶层
    return DealDetail.fromJson(root);
  }

  // ───────────────────────────── 规范格式 ─────────────────────────────
  factory DealDetail.fromJson(Map<String, dynamic> j) {
    final stats = _m(j['stats']);
    final menuRaw = _l(j['menu']);
    final termsRaw = _l(j['terms']);
    final rec = _m(j['recommend']);
    final bottom = _m(j['bottomBar']);

    final menu = <MenuGroup>[];
    for (final g in menuRaw) {
      final gm = _m(g);
      menu.add(MenuGroup(
        title: _s(gm['title']),
        note: _s(gm['note']),
        items: _l(gm['items'])
            .map((e) => MenuItem.fromJson(_m(e)))
            .where((e) => e.name.isNotEmpty)
            .toList(),
      ));
    }

    final terms = <TermSection>[];
    for (final t in termsRaw) {
      final tm = _m(t);
      terms.add(TermSection(
        title: _s(tm['title']),
        icon: _s(tm['icon']).isEmpty ? 'check' : _s(tm['icon']),
        bullet: tm['bullet'] == true,
        actionText: _s(tm['actionText']),
        actionUrl: _s(tm['actionUrl']).isEmpty ? null : _s(tm['actionUrl']),
        lines: _l(tm['lines']).map(_s).where((e) => e.isNotEmpty).toList(),
      ));
    }

    final pm = _m(j['poi']);
    final poi = Poi(
      name: _s(pm['name']),
      logo: _s(pm['logo']),
      rating: _s(pm['rating']),
      avgPrice: _s(pm['avgPrice']),
      distance: _s(pm['distance']),
      hours: _s(pm['hours']),
      summary: _s(pm['summary']),
      phone: _s(pm['phone']),
      contactText: _s(pm['contactText']).isEmpty ? '联系商家' : _s(pm['contactText']),
    );

    final recommend = <RecommendDeal>[];
    for (final r in _l(rec['items'])) {
      final rm = _m(r);
      recommend.add(RecommendDeal(
        id: _s(rm['id']),
        title: _s(rm['title']),
        image: _s(rm['image']),
        price: _s(rm['price']),
        retailPrice: _s(rm['retailPrice']),
        discount: _s(rm['discount']),
        sales: _s(rm['sales']),
      ));
    }

    return DealDetail(
      id: _s(j['id']),
      title: _s(j['title']),
      price: _s(j['price']),
      retailPrice: _s(j['retailPrice']),
      promotionAmount: _s(j['promotionAmount']),
      discountTag: _s(j['discountTag']),
      positiveRate: _s(stats['positiveRate']),
      reviewCount: _s(stats['reviewCount']),
      repeatBuyers: _s(stats['repeatBuyers']),
      soldCount: _s(stats['soldCount']),
      serviceTags: _l(j['serviceTags']).map(_s).where((e) => e.isNotEmpty).toList(),
      bannerImages: _l(j['bannerImages']).map(_s).where((e) => e.isNotEmpty).toList(),
      menuTitle: _s(j['menuTitle']).isEmpty ? '团购详情' : _s(j['menuTitle']),
      menu: menu,
      termTitle: _s(j['termTitle']).isEmpty ? '购买须知' : _s(j['termTitle']),
      terms: terms,
      poiTitle: _s(j['poiTitle']).isEmpty ? '适用商户' : _s(j['poiTitle']),
      poi: poi,
      recommendTitle: _s(rec['title']).isEmpty ? '本店团购' : _s(rec['title']),
      recommendTotal: _s(rec['total']),
      recommend: recommend,
      cartText: _s(bottom['cartText']).isEmpty ? '加入购物车' : _s(bottom['cartText']),
      buyText: _s(bottom['buyText']).isEmpty ? '立即团购' : _s(bottom['buyText']),
      buySubText: _s(bottom['buySubText']),
    );
  }

  // ─────────────────────── 美团原始接口（deal/v5/info）───────────────────────
  factory DealDetail.fromMeituan(Map<String, dynamic> d) {
    final bar = _m(_m(d['priceArea'])['minusPriceAreaBar']);
    final finalPrice = _m(bar['finalPrice']);
    final retail = _m(bar['retailPrice']);
    final promo = _l(bar['promotionDetails']);
    final imageInfo = _m(d['imageInfo']);

    final banners = <String>[];
    for (final img in _l(imageInfo['images'])) {
      final u = _s(_m(img)['url']);
      if (u.isNotEmpty) banners.add(u);
    }
    for (final img in _l(imageInfo['imageDishes'])) {
      final u = _s(_m(img)['url']);
      if (u.isNotEmpty && !banners.contains(u)) banners.add(u);
    }

    // 菜单：subtype 1 = 分组标题 / 备注，2 = 菜品
    final menuArea = _m(d['menuArea']);
    final menus = _l(_m(menuArea['menuInfo'])['menus']);
    final groups = <MenuGroup>[];
    var current = <MenuItem>[];
    var currentTitle = '';
    void flush() {
      if (currentTitle.isNotEmpty || current.isNotEmpty) {
        groups.add(MenuGroup(title: currentTitle, items: List<MenuItem>.from(current)));
      }
      current = <MenuItem>[];
    }

    for (final m in menus) {
      final mm = _m(m);
      final subtype = mm['subtype'];
      final content = _s(mm['content']);
      if (subtype == 1 || subtype == '1') {
        flush();
        currentTitle = content;
      } else if (content.isNotEmpty) {
        current.add(MenuItem(
          name: content,
          spec: _s(mm['specification']),
          price: _s(mm['price']),
        ));
      }
    }
    flush();

    // 须知
    final terms = <TermSection>[];
    for (final t in _l(_m(d['termArea'])['terms'])) {
      final tm = _m(t);
      final title = _s(tm['title']);
      final lines = <String>[];
      String actionText = '';
      String? actionUrl;
      for (final c in _l(tm['content'])) {
        final cm = _m(c);
        final text = _s(cm['text']);
        final jump = _s(cm['jumpUrl']);
        if (text.isNotEmpty) lines.add(text);
        if (jump.isNotEmpty) {
          actionUrl = jump;
          if (actionText.isEmpty) actionText = '查看';
        }
      }
      String icon = 'check';
      if (title.contains('时间')) icon = 'time';
      if (title.contains('规则')) icon = 'rule';
      if (title.contains('价格')) icon = 'price';
      if (title.contains('日期')) icon = 'calendar';
      terms.add(TermSection(
        title: title,
        lines: lines,
        icon: icon,
        bullet: title.contains('规则'),
        actionText: actionText,
        actionUrl: actionUrl,
      ));
    }

    // 服务摘要「周一至周日可用 · 包间不可用 · 随时退」
    final tags = <String>[];
    for (final t in _l(_m(d['serviceTermArea'])['tags'])) {
      final txt = _s(_m(t)['text']);
      if (txt.isNotEmpty) tags.add(txt);
    }
    if (tags.isEmpty) {
      for (final r in _l(d['recommendReasonList'])) {
        final txt = _s(_m(r)['desc']);
        if (txt.isNotEmpty) tags.add(txt);
      }
    }

    // 口碑
    final comment = _m(d['commentInfo']);
    final dealComment = _m(d['dealComment']);
    String positive = _s(comment['positiveRate']).isEmpty
        ? _s(dealComment['positiveRate'])
        : _s(comment['positiveRate']);
    if (positive.isNotEmpty && !positive.endsWith('%')) positive = '$positive%';
    final rateNum = _s(comment['rate']).isEmpty ? _s(dealComment['rate']) : _s(comment['rate']);
    if (positive.isEmpty && rateNum.isNotEmpty) positive = rateNum.endsWith('%') ? rateNum : '$rateNum%';
    if (positive.isNotEmpty) positive = '$positive好评';
    final countNum = _s(comment['commentCount']).isEmpty
        ? _s(dealComment['commentCount'])
        : _s(comment['commentCount']);
    final reviewCount = countNum.isEmpty ? '' : '$countNum条评价';

    // 门店
    final poiRaw = _m(d['poi']).isEmpty ? _m(d['branchInfo']) : _m(d['poi']);
    final poiInfo = poiRaw.isEmpty ? _m(d['poiInfo']) : poiRaw;
    final infoTags = _l(_m(poiInfo['currentInfoTags'])['infoTags']);
    final Poi poi = Poi(
      name: _s(poiInfo['title']),
      logo: _s(poiInfo['image']),
      rating: _s(poiInfo['rating']),
      avgPrice: _s(poiInfo['avgPrice']),
      distance: _s(poiInfo['distance']).isEmpty ? _s(poiInfo['range']) : _s(poiInfo['distance']),
      hours: infoTags.isEmpty ? _s(poiInfo['openTime']) : _s(infoTags.first),
      summary: _s(poiInfo['curCityPoiCount']).isEmpty
          ? ''
          : '${_s(poiInfo['curCityPoiCount'])}家门店通用',
      phone: _s(poiInfo['phone']),
      contactText: _s(poiInfo['phoneContext']).isEmpty ? '联系商家' : _s(poiInfo['phoneContext']),
    );

    // 本店团购
    List<dynamic> recRaw = _l(d['recommendDeals']);
    if (recRaw.isEmpty) recRaw = _l(d['sameBrandDealList']);
    if (recRaw.isEmpty) recRaw = _l(d['moreDealList']);
    if (recRaw.isEmpty) recRaw = _l(d['recommendDealList']);
    final recommends = <RecommendDeal>[];
    for (final r in recRaw) {
      final rm = _m(r);
      final priceArea = _m(_m(rm['priceArea'])['minusPriceAreaBar']);
      final rFinal = _m(priceArea['finalPrice']);
      final rRetail = _m(priceArea['retailPrice']);
      recommends.add(RecommendDeal(
        id: _s(rm['id']).isEmpty ? _s(rm['dealId']) : _s(rm['id']),
        title: _s(rm['title']).isEmpty ? _s(rm['name']) : _s(rm['title']),
        image: _s(rm['image']).isEmpty ? _s(rm['imgurl']) : _s(rm['image']),
        price: _s(rm['price']).isEmpty
            ? (rFinal.isEmpty ? _s(rm['finalPrice']) : _s(rFinal['text']))
            : _s(rm['price']),
        retailPrice: _s(rm['value']).isEmpty
            ? (rRetail.isEmpty ? '' : _s(rRetail['text']))
            : _s(rm['value']),
        discount: _s(rm['salesTag']).isEmpty ? _s(rFinal['subText']) : _s(rm['salesTag']),
        sales: _s(rm['soldsDesc']).isEmpty ? _s(_m(rm['soldCount'])['text']) : _s(rm['soldsDesc']),
      ));
    }

    final finalText = _s(finalPrice['text']).isEmpty ? _s(d['finalPrice']) : _s(finalPrice['text']);
    final retailText = _s(retail['text']).isEmpty ? _s(d['value']) : _s(retail['text']);
    final promoText = promo.isEmpty ? '' : _s(_m(promo.first)['text']);

    String discount = _s(d['shareDiscountTag']);
    if (discount.isEmpty) discount = _s(finalPrice['subText']);
    if (discount.isEmpty) discount = _s(d['salesTag']);

    return DealDetail(
      id: _s(d['id']).isEmpty ? _s(d['mtDealId']) : _s(d['id']),
      title: _s(d['title']).isEmpty ? _s(d['shareTitle']) : _s(d['title']),
      price: finalText,
      retailPrice: retailText,
      promotionAmount: promoText,
      discountTag: discount,
      positiveRate: positive,
      reviewCount: reviewCount,
      repeatBuyers: '',
      soldCount: _s(d['soldsDesc']).isEmpty ? _s(_m(bar['soldCount'])['text']) : _s(d['soldsDesc']),
      serviceTags: tags,
      bannerImages: banners,
      menuTitle: _s(_m(menuArea['menuInfo'])['title']).isEmpty
          ? '团购详情'
          : _s(_m(menuArea['menuInfo'])['title']),
      menu: groups,
      termTitle: '购买须知',
      terms: terms,
      poi: poi,
      recommendTotal: recommends.isEmpty ? '' : '${recommends.length}个',
      recommend: recommends,
      buySubText: finalText.isEmpty ? '' : '折后 ¥$finalText',
    );
  }
}
