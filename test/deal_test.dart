import 'package:flutter_test/flutter_test.dart';
import 'package:mt_deal_app/models/deal.dart';

/// 规范格式（本项目 schema）
const String _normalized = '''
{
  "deal": {
    "id": "1",
    "title": "【金秋丰收】鲜汤鱼粉+鱼丸 2 个",
    "price": "8.9",
    "retailPrice": "10.9",
    "promotionAmount": "2",
    "discountTag": "8.2折",
    "stats": {
      "positiveRate": "96%好评",
      "reviewCount": "352条评价",
      "repeatBuyers": "回头客740+",
      "soldCount": "半年售 1000+"
    },
    "serviceTags": ["周一至周日可用", "包间不可用"],
    "bannerImages": [],
    "menu": [
      {"title": "主食", "items": [{"name": "鲜汤无刺芒鱼粉", "spec": "1 碗", "price": "8.9"}]}
    ],
    "terms": [
      {"title": "有效期", "icon": "check", "lines": ["购买之后30天有效"]},
      {"title": "使用规则", "icon": "rule", "bullet": true, "lines": ["不可使用包间"]}
    ],
    "poi": {"name": "巧二娘米粉便利店(广园店)", "rating": "4.3", "avgPrice": "11", "distance": "4.5km", "hours": "全天营业", "summary": "3家门店通用"},
    "recommend": {"title": "本店团购", "total": "9个", "items": [{"title": "鱼丸汤", "price": "1.99", "retailPrice": "5", "discount": "4折", "sales": "半年销量 500+"}]},
    "bottomBar": {"cartText": "加入购物车", "buyText": "立即团购", "buySubText": "折后 ¥8.9"}
  }
}
''';

/// 美团原始接口形态（meishi/deal/v5/info 的 data 节点）
const String _meituan = '''
{
  "code": 0,
  "data": {
    "id": 123,
    "title": "惊爆工作日午餐特惠双人餐",
    "shareDiscountTag": "8.2 折",
    "soldsDesc": "半年售 9999+",
    "priceArea": {
      "minusPriceAreaBar": {
        "finalPrice": {"text": "92", "subText": "8.2 折"},
        "retailPrice": {"text": "113"},
        "promotionDetails": [{"text": "21"}]
      }
    },
    "imageInfo": {"images": [{"url": "https://img.example.com/a.jpg"}]},
    "menuArea": {
      "menuInfo": {
        "title": "团购详情",
        "menus": [
          {"subtype": 1, "content": "套餐A"},
          {"subtype": 2, "content": "招牌红烧肉", "specification": "1 份"},
          {"subtype": 1, "content": "主食"},
          {"subtype": 2, "content": "米饭", "specification": "2 碗"}
        ]
      }
    },
    "termArea": {
      "terms": [
        {"title": "有效期", "content": [{"text": "购买之后30天有效"}]},
        {"title": "使用规则", "content": [{"text": "不可使用包间"}, {"text": "仅限堂食"}]},
        {"title": "价格和销量说明", "content": [{"text": "详情请点击查看", "jumpUrl": "https://i.meituan.com/x"}]}
      ]
    },
    "serviceTermArea": {"tags": [{"text": "周一至周五可用"}, {"text": "10:00-16:00"}]},
    "poi": {
      "title": "小菜园新徽菜（汉光百货店）",
      "rating": 4.1,
      "avgPrice": 57,
      "curCityPoiCount": 711,
      "currentInfoTags": {"status": "休息中", "infoTags": ["10:00-21:00"]},
      "phoneContext": "联系商家"
    }
  }
}
''';

void main() {
  test('规范格式解析', () {
    final DealDetail d = DealDetail.parse(_normalized);
    expect(d.title, contains('鲜汤鱼粉'));
    expect(d.price, '8.9');
    expect(d.retailPrice, '10.9');
    expect(d.promotionAmount, '2');
    expect(d.discountTag, '8.2折');
    expect(d.positiveRate, '96%好评');
    expect(d.reviewCount, '352条评价');
    expect(d.serviceTags.length, 2);
    expect(d.menu.length, 1);
    expect(d.menu.first.title, '主食');
    expect(d.menu.first.items.first.name, '鲜汤无刺芒鱼粉');
    expect(d.menu.first.items.first.spec, '1 碗');
    expect(d.terms.length, 2);
    expect(d.terms[1].bullet, isTrue);
    expect(d.poi.name, contains('巧二娘'));
    expect(d.poi.summary, '3家门店通用');
    expect(d.recommend.length, 1);
    expect(d.recommendTotal, '9个');
    expect(d.buySubText, '折后 ¥8.9');
  });

  test('美团原始接口解析', () {
    final DealDetail d = DealDetail.parse(_meituan);
    expect(d.id, '123');
    expect(d.price, '92');
    expect(d.retailPrice, '113');
    expect(d.promotionAmount, '21');
    expect(d.discountTag, '8.2 折');
    expect(d.soldCount, '半年售 9999+');
    expect(d.bannerImages.single, contains('img.example.com'));
    // 分组：套餐A / 主食
    expect(d.menu.length, 2);
    expect(d.menu[0].title, '套餐A');
    expect(d.menu[0].items.single.name, '招牌红烧肉');
    expect(d.menu[0].items.single.spec, '1 份');
    expect(d.menu[1].title, '主食');
    expect(d.menu[1].items.single.name, '米饭');
    // 须知
    expect(d.terms.length, 3);
    expect(d.terms[1].title, '使用规则');
    expect(d.terms[1].bullet, isTrue);
    expect(d.terms[1].lines.length, 2);
    expect(d.terms[2].actionUrl, isNotNull);
    // 服务标签
    expect(d.serviceTags, contains('周一至周五可用'));
    // 门店
    expect(d.poi.name, contains('小菜园'));
    expect(d.poi.rating, '4.1');
    expect(d.poi.avgPrice, '57');
    expect(d.poi.summary, '711家门店通用');
    expect(d.poi.hours, '10:00-21:00');
    expect(d.buySubText, '折后 ¥92');
  });

  test('数字类型容错', () {
    final DealDetail d = DealDetail.parse('{"deal":{"price":8.9,"retailPrice":11,"title":"t"}}');
    expect(d.price, '8.9');
    expect(d.retailPrice, '11');
  });
}
