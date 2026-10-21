# 美团团购详情页 · Flutter 复刻（数据驱动）

按「美团商品团购详情」H5 页 1:1 复刻的 Flutter App。**版式固定、数据全可换**：页面里没有一个写死的文案，全部来自一份 JSON（或美团原接口），换数据即换页面。

- 视觉基准：用户提供的两张真机截图（390×844 逻辑分辨率）
- 渲染验证：`docs/shot_844.png`（首屏）、`docs/shot_full.png`（长图）
- 产物：Android APK（GitHub Actions 自动打包）＋ Web 预览（仅供对版）

---

## 1. 目录结构

```
mt-deal-app/
├── lib/
│   ├── main.dart                    # 入口：数据加载（assets / HTTP）+ 主题
│   ├── theme.dart                   # 设计变量：取色 / 间距（改这里统一换肤）
│   ├── models/deal.dart             # 数据契约 + 美团原始接口适配器
│   ├── pages/deal_detail_page.dart  # 页面骨架（Stack：内容 + 顶栏 + 底部条）
│   └── widgets/
│       ├── deal_sections.dart       # 七大版块：banner/价格/菜单/须知/商户/本店团购/底栏
│       └── remote_image.dart        # 网络图 / 本地资源图 + 优雅占位
├── assets/
│   ├── sample_deal.json             # ★ 示例数据（换数据只改这个）
│   └── img/                         # 示例图片（真实美团 CDN 图 + 截图裁切素材）
├── test/                            # 纯逻辑 + 整页渲染冒烟测试
└── .github/workflows/build-apk.yml  # 推上去自动出 APK
```

---

## 2. 三步跑起来

```bash
flutter pub get
flutter run                       # 连手机直接跑
flutter build apk --release       # 出 app-release.apk
```

> 本机若无 Flutter / Android SDK，直接看第 5 节「云端打包」。

---

## 3. 换数据（三种方式，任选其一）

### 方式 A：改本地 JSON（最简单）

编辑 `assets/sample_deal.json`，字段含义见第 4 节。改完重新构建即可。

### 方式 B：运行时拉远程 JSON（不重新打包也能换数据）

```bash
flutter build apk --release \
  --dart-define=DEAL_JSON_URL=https://your.host/deal.json
```

App 启动时用 HTTP GET 该地址（UTF-8 解码），拿到同结构 JSON 直接渲染。

### 方式 C：直连美团原始接口（免写适配层）

`DealDetail.parse()` 会自动识别三种输入：

| 输入形态 | 识别特征 | 处理 |
|---|---|---|
| 美团原始响应 | 有 `data` 且含 `menuArea` / `termArea` | 走内置适配器 `fromMeituan()` |
| 规范化数据 | 有 `deal` 键 | 走 `fromJson()` |
| 裸数据 | 直接是字段对象 | 走 `fromJson()` |

也就是说：把美团 `GET https://apimobile.meituan.com/meishi/deal/v5/info/{dealId}` 的响应原样丢进来就能渲染。字段映射已内置：`priceArea.minusPriceAreaBar`（价格/划线价/优惠）、`menuArea.menuInfo.menus`（`subtype` 1=分组、2=菜品）、`termArea.terms`（含 `jumpUrl` → 行尾箭头）、`serviceTermArea.tags`、门店接口 `group/v3/deal/{id}/branch`。

实测抓包里 `deal/v5/info` 的响应被截断在 6013 字符，**「本店团购」列表与「好评率」两个字段没抓到**，所以适配器对这两处做了多路兜底（`recommendDeals` / `sameBrandDealList` / `moreDealList`），示例数据按截图口径补齐。

---

## 4. 数据契约（`assets/sample_deal.json`）

```jsonc
{
  "schema": "deal-detail/v1",
  "deal": {
    "id": "1640463767",
    "title": "【金秋丰收】鲜汤鱼粉+鱼丸 2 个",
    "price": "8.9",                 // 团购价（大字）
    "retailPrice": "10.9",          // 零售价（等式右）
    "promotionAmount": "2",         // 团购优惠
    "discountTag": "8.2折",          // 价格右侧折扣标签

    "stats": {
      "positiveRate": "96%好评",
      "reviewCount": "352条评价",
      "repeatBuyers": "回头客740+",
      "soldCount": "半年售 1000+"
    },

    "serviceTags": ["周一至周日可用", "包间不可用", "随时退", "过期自动退"],
    "bannerImages": ["assets/img/banner_local.jpg"],   // 也支持 http(s) URL

    "menuTitle": "团购详情",
    "menu": [
      { "title": "主食", "items": [{ "name": "鲜汤无刺芒鱼粉", "spec": "1 碗", "price": "8.9" }] }
    ],

    "termTitle": "购买须知",
    "terms": [
      { "title": "有效期", "icon": "check", "lines": ["购买之后30天有效"] },
      { "title": "使用规则", "icon": "rule", "bullet": true, "lines": ["不可使用包间", "..."] },
      { "title": "价格和销量说明", "icon": "price", "lines": ["详情请点击查看"],
        "actionText": "详情请点击查看", "actionUrl": "https://..." }
    ],

    "poi": {
      "name": "巧二娘米粉便利店(广园店)", "logo": "assets/img/logo_local.jpg",
      "rating": "4.3", "avgPrice": "11", "distance": "4.5km",
      "hours": "全天营业", "summary": "3家门店通用",
      "phone": "020-00000000", "contactText": "联系商家"
    },

    "recommend": {
      "title": "本店团购", "total": "9个",
      "items": [
        { "id": "9001", "title": "【金秋丰收】土家酸汤鱼粉+腐竹套餐", "image": "assets/img/t1.jpg",
          "price": "9.9", "retailPrice": "22", "discount": "4.5折", "sales": "半年销量 1000+" }
      ]
    },

    "bottomBar": { "cartText": "加入购物车", "buyText": "立即团购", "buySubText": "折后 ¥8.9" }
  }
}
```

字段全部可选：缺什么就少渲染什么，不会崩（解析做了类型容错，`"8.9"` / `8.9` 都能吃）。

`terms[].icon` 取值：`check` / `time` / `rule` / `price` / `calendar`。

---

## 5. 云端打包 APK（不用装 Android SDK）

1. 在 GitHub 新建空仓库；
2. 把本目录 `git push` 上去（`main` 分支）；
3. 打开仓库 **Actions → build-apk**，push 会自动跑，也可点 **Run workflow**；
4. 跑完在该次运行页底部 **Artifacts → mt-deal-apk** 下载：
   - `app-release.apk` —— 通用包，直接装；
   - `app-arm64-v8a-release.apk` —— 体积更小，真机优先装这个；
5. 手机安装：

```bash
adb install -r app-release.apk
```

打 tag（如 `v1.0.0`）发 Release 时，APK 会自动挂到 Release 附件。

---

## 6. 视觉对版说明

| 项 | 处理 |
|---|---|
| 尺寸基准 | 390×844 逻辑像素；字体 / 间距全部按截图量取 |
| 主色 | `#FF4B10`；底栏渐变 `#FFA11E → #FF5A00`；页面底 `#F2F2F3` |
| 卡片 | 白卡 + 8px 灰缝，左右内边距 12 |
| 顶栏 | 5 个 30px 圆钮（返回 / 搜索 / 收藏 / 分享 / 更多）；图标是从参考截图**逐像素抠出的 PNG**（`assets/img/icons/`），不是 Material Icons |
| 顶栏吸顶 | 页面下滑 > 150 后整条变白底、图标转黑并吸顶悬浮（与参考第三张图一致） |
| 价格行 | `¥8.9` 26 号主色；右侧 `＝ 零售价 ¥10.9 − 团购优惠 ¥2` 全黑，按参考坐标靠右排布 |
| 底栏 | 左「门店」（抠图图标）+ **一整颗**胶囊：左半 `#FFC42F→#FE9D1B` 加入购物车、右半 `#FF7C21→#FF5311` 立即团购，**中间无缝**，圆角 19 |
| 图片 | 顶部 banner 230 高、`BoxFit.cover`；本店团购缩略图 78×92、圆角 5 |

`docs/` 下是本机用 Edge headless + CDP 渲染 Web 版截的图，与真机像素一致（同一份 Dart 布局代码）：

| 文件 | 内容 |
|---|---|
| `docs/shot_844.png` | 首屏（390×844 @2x） |
| `docs/shot_full.png` | 整页（390×2400 @2x） |
| `docs/shot_scrolled.png` | 下滑后的吸顶态（白底 + 黑图标） |
| `docs/shot_input.png` | 点右上「⋯」进入的**粘贴数据**页 |
| `docs/compare.png` | 与参考真机截图左右对照 |

> 顶部 banner 用的是从参考截图里裁出来的纯食物区域（原图上方叠着状态栏和 5 个悬浮按钮，不能直接用），所以取景比原图更近一点；换成真实商品图后没有任何差异。

---

## 7. 已知差异 / 可继续做

- 示例数据里的门店与商品来自截图（巧二娘米粉便利店·广园店）；图片素材取自截图裁切与美团 CDN，仅作版式演示；
- 「本店团购」「好评率」的真实接口字段名未在抓包里出现，适配器用多路兜底，接口若补齐可直接改 `fromMeituan`；
- 交互（分享、收藏、抢购、进店）目前是空实现，只保留点击态。

---

## 8. 这一页需要哪些数据（对着页面从上往下数）

只要凑齐下面这些字段，页面就完整；缺哪个，对应整块自动隐藏（不会排版错乱）。

| 页面区块 | 字段（本项目 JSON） | 美团接口里的原始位置 |
|---|---|---|
| 顶部大图 | `bannerImages[]` | `data.imageInfo.images[].url` |
| 价格 / 折扣 | `price` `discountTag` | `data.priceArea.minusPriceAreaBar.finalPrice.text` / `shareDiscountTag` |
| 零售价 / 团购优惠 | `retailPrice` `promotionAmount` | `…retailPrice.text` / `…promotionDetails[0].text` |
| 标题 | `title` | `data.title`（`shareTitle` 兜底） |
| 口碑徽章 | `positiveRate` `reviewCount` `repeatBuyers` `soldCount` | `data.soldsDesc` + 评价接口 `commentCount` |
| 服务标签行 | `serviceTags[]` | `data.serviceTermArea.tags[].text` |
| 团购详情 | `menu[]` → `{title, items[{name, spec, price}]}` | `data.menuArea.menuInfo.menus[]`（`subtype:1` 分组、`2` 菜品） |
| 购买须知 | `terms[]` → `{title, lines[], icon, bullet, actionText, actionUrl}` | `data.termArea.terms[]`（`content[].text`、`jumpUrl`） |
| 适用商户 | `poi{name, logo, rating, avgPrice, distance, hours, phone, contactText, summary}` | `/group/v3/deal/{id}/branch` 的 `data` |
| 本店团购 | `recommend[]` → `{title, image, price, retailPrice, discount, sales}` + `recommendTotal` | `data.recommendDeals[]`（多路兜底） |
| 底栏按钮 | `cartText` `buyText` `buySubText` | 文案固定，`buySubText` 默认「折后 ¥价」 |

**只必填 4 个**：`title`、`price`、`bannerImages`、`menu`。其余留空页面依然成立，只是对应区块不显示。

### 把抓包「瘦身」成只剩要用的字段

抓包文件里 90% 是埋点、样式、多语言、未展示的营销字段。`_dev/slim_real.js` 会读抓包 → 修好被截断的响应 → 只抽本页真正渲染的字段，产出规范格式文件：

```bash
node _dev/slim_real.js     # 输出 assets/deal_slim.json（+ .min.json 单行版）
flutter build apk --release --dart-define=DEAL_ASSET=assets/deal_slim.json
```

实测这份样本（小菜园工作日午餐双人餐）：

| 环节 | 体积 |
|---|---|
| 抓包文件 `mt-watch-….json` | 100,504 B |
| 其中的 deal 响应（被工具截断到 6013 字符） | 7,719 B |
| 修好截断、未瘦身 | 7,589 B |
| **瘦身后（格式化 / 单行）** | **4,043 B / 3,203 B** |

保留的顶层键只有 14 个：`schema id title price retailPrice promotionAmount discountTag stats serviceTags bannerImages menu terms poi bottomBar`。

丢掉的是什么：`code/message` 包装、`brandname`/`shareTitle` 等别名、菜单里的 `id/type/subtype` 与样式串、须知里的 `jumpUrl` 以外的交互字段、`imageDishes` 与 `images` 的重复 URL、所有埋点（`lab`/`track`/`abTest`）、以及本页根本不渲染的营销区。

**验证方式**：同一份数据（原始 vs 瘦身）各构建一次、同视口截图逐像素比对，首屏与后半屏均为 **0.000% 差异**（脚本 `_dev/diffpng.ps1`）。


### 粘贴数据直接看效果

详情页右上角 **⋯ → 粘贴数据**：
- 上方框是格式说明（三种 JSON 都吃：本项目规范格式 / 美团接口原始整包 / `{"deal":{…}}` 包装）；
- 输入框内有示例占位；
- 点「载入示例」把内置样例填进去，点「渲染」立即用你粘的数据出页面；
- 解析失败会在按钮上方红字给出原因（不会白屏）。
