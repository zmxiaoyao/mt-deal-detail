import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'models/deal.dart';
import 'pages/deal_detail_page.dart';
import 'theme.dart';

/// 数据来源一：远程 JSON 地址（编译时注入，代码零改动换数据）
///   flutter build apk --dart-define=DEAL_JSON_URL=https://your.host/deal.json
const String kDealJsonUrl = String.fromEnvironment('DEAL_JSON_URL');

/// 数据来源二：内置示例（默认）
const String kDealAsset =
    String.fromEnvironment('DEAL_ASSET', defaultValue: 'assets/sample_deal.json');

void main() {
  runApp(const MtDealApp());
}

class MtDealApp extends StatelessWidget {
  const MtDealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '团购详情',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: C.bg,
      ),
      home: const DealLoader(),
    );
  }
}

class DealLoader extends StatefulWidget {
  const DealLoader({super.key});

  @override
  State<DealLoader> createState() => _DealLoaderState();
}

class _DealLoaderState extends State<DealLoader> {
  late final Future<DealDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DealDetail> _load() async {
    final String raw;
    if (kDealJsonUrl.isNotEmpty) {
      raw = await _httpGet(kDealJsonUrl);
    } else {
      raw = await rootBundle.loadString(kDealAsset);
    }
    return DealDetail.parse(raw);
  }

  Future<String> _httpGet(String url) async {
    final HttpClient client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final HttpClientRequest req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final HttpClientResponse resp = await req.close();
      return await resp.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DealDetail>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<DealDetail> snap) {
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  '数据加载失败\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: C.t3, height: 1.6),
                ),
              ),
            ),
          );
        }
        final DealDetail? data = snap.data;
        if (data == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return DealDetailPage(deal: data);
      },
    );
  }
}
