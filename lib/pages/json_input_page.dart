import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/deal.dart';
import '../theme.dart';

/// 粘贴 JSON 直接出页面：把数据源从"内置文件"换成"你贴进来的这段文本"。
/// 输入框上方写明支持的格式与必填字段，粘进来点「渲染」即可。
class JsonInputPage extends StatefulWidget {
  const JsonInputPage({super.key});

  @override
  State<JsonInputPage> createState() => _JsonInputPageState();
}

class _JsonInputPageState extends State<JsonInputPage> {
  final TextEditingController _ctrl = TextEditingController();
  String _error = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadSample() async {
    final String raw = await rootBundle.loadString('assets/sample_deal.json');
    setState(() {
      _ctrl.text = raw;
      _error = '';
    });
  }

  void _render() {
    final String raw = _ctrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = '先把 JSON 粘进输入框（点「载入示例」可以看一份完整样例）。');
      return;
    }
    try {
      final DealDetail deal = DealDetail.parse(raw);
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop(deal);
    } catch (e) {
      setState(() => _error = '解析失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text('粘贴数据', style: TextStyle(fontSize: 16, color: C.t1)),
        iconTheme: const IconThemeData(color: C.t1),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 输入框上方的格式提示
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '支持的三种 JSON（粘贴后点「渲染」）',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.t1),
                ),
                SizedBox(height: 5),
                Text(
                  '① 本项目规范格式 deal-detail/v1：'
                  '{"schema":"deal-detail/v1","title":…,"price":…,"menu":[…],"terms":[…],"poi":{…},"recommend":[…]}\n'
                  '② 美团接口 meishi/deal/v5/info 的原始响应整包：{"data":{"title":…,"priceArea":{…},"menuArea":{…},"termArea":{…}}}\n'
                  '③ 包装对象：{"deal":{ …同 ①… }}',
                  style: TextStyle(fontSize: 11.5, color: C.t3, height: 1.55),
                ),
                SizedBox(height: 6),
                Text(
                  '关键字段：title 标题 / price 团购价 / retailPrice 零售价 / promotionAmount 优惠额 / '
                  'stats 口碑徽章 / serviceTags 服务标签 / menu 团购详情 / terms 购买须知 / '
                  'poi 适用商户 / recommend 本店团购 / bannerImages 大图',
                  style: TextStyle(fontSize: 11, color: C.t4, height: 1.5),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: TextField(
                controller: _ctrl,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.45, color: C.t2),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '在这里粘贴 JSON…\n\n'
                      '示例：\n'
                      '{"schema":"deal-detail/v1","title":"【金秋丰收】鲜汤鱼粉+鱼丸 2 个",'
                      '"price":"8.9","retailPrice":"10.9","promotionAmount":"2"}',
                  hintStyle: const TextStyle(fontSize: 11.5, color: C.t5, height: 1.5),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: C.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: C.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: C.primary),
                  ),
                ),
              ),
            ),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(_error, style: const TextStyle(fontSize: 11.5, color: Color(0xFFD32F2F), height: 1.45)),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loadSample,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: C.divider),
                      foregroundColor: C.t2,
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('载入示例', style: TextStyle(fontSize: 13.5)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _ctrl.clear();
                      _error = '';
                    }),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: C.divider),
                      foregroundColor: C.t2,
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('清空', style: TextStyle(fontSize: 13.5)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(colors: <Color>[C.orangeStart, C.orangeEnd]),
                    ),
                    child: TextButton(
                      onPressed: _render,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('渲染', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
