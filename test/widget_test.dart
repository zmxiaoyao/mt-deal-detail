import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mt_deal_app/models/deal.dart';
import 'package:mt_deal_app/pages/deal_detail_page.dart';

/// 冒烟测试：整页 widget 树能正常构建、关键文案能渲染出来
const String _json = '''
{
  "deal": {
    "id": "1",
    "title": "【金秋丰收】鲜汤鱼粉+鱼丸 2 个",
    "price": "8.9",
    "retailPrice": "10.9",
    "promotionAmount": "2",
    "discountTag": "8.2折",
    "stats": {"positiveRate": "96%好评", "reviewCount": "352条评价", "repeatBuyers": "回头客740+", "soldCount": "半年售 1000+"},
    "serviceTags": ["周一至周日可用", "包间不可用", "随时退", "过期自动退"],
    "bannerImages": [],
    "menu": [{"title": "主食", "items": [{"name": "鲜汤无刺芒鱼粉", "spec": "1 碗", "price": "8.9"}]}],
    "terms": [{"title": "有效期", "icon": "check", "lines": ["购买之后30天有效"]}],
    "poi": {"name": "巧二娘米粉便利店(广园店)", "rating": "4.3", "avgPrice": "11", "distance": "4.5km", "hours": "全天营业", "summary": "3家门店通用"},
    "recommend": {"title": "本店团购", "total": "9个", "items": [{"title": "鱼丸汤", "price": "1.99", "retailPrice": "5", "discount": "4折", "sales": "半年销量 500+"}]},
    "bottomBar": {"cartText": "加入购物车", "buyText": "立即团购", "buySubText": "折后 ¥8.9"}
  }
}
''';

void main() {
  testWidgets('详情页可渲染', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final DealDetail deal = DealDetail.parse(_json);
    await tester.pumpWidget(MaterialApp(home: DealDetailPage(deal: deal)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('【金秋丰收】鲜汤鱼粉+鱼丸 2 个'), findsOneWidget);
    expect(find.text('8.9'), findsWidgets);
    expect(find.text('团购详情'), findsOneWidget);
    expect(find.text('购买须知'), findsOneWidget);
    expect(find.text('适用商户'), findsOneWidget);
    expect(find.text('本店团购'), findsOneWidget);
    expect(find.text('立即团购'), findsOneWidget);
    expect(find.text('加入购物车'), findsOneWidget);
    expect(find.textContaining('巧二娘'), findsOneWidget);
  });
}
