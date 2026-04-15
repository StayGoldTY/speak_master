# Speak Master

一个面向英语朗读与发音训练的 Flutter 跨端项目，当前主要以 Flutter Web 形态作为“学习网站”来打磨，同时保留移动端运行能力。

## 项目定位

Speak Master 的核心目标不是单纯展示音标，而是把“教程学习 + 自主练习 + 评测反馈 + 成长激励”串成一条完整的学习路径：

- `教程 Learn`：按照单元组织发音知识与练习步骤
- `练习 Practice`：自由朗读、素材跟读、绕口令挑战
- `评测 Assessment`：朗读句子后的发音维度反馈
- `社区 Community`：学习动态、排行榜、互动
- `我的 Profile`：成长数据、徽章、学习偏好

## 当前阶段

这一轮实现的是“教程主线第一阶段”：

- 对外开放 `u1-u10`
- 聚焦 `Foundation + Vowels`
- 课程页改为真实数据驱动，而不是固定演示稿
- 未进入第一阶段的单元统一显示为“即将开放”
- 账号、社区、资料设置页已经具备一轮真实可用化结构

### 已补齐的教程范围

- `u1-u4`：发音基础
- `u5-u10`：元音与双元音

每个已开放单元都包含 3 节真实课程，课程步骤覆盖：

- `text`
- `audio`（当前仅做诚实的听音准备说明，不伪装成已接音频）
- `recordAndCompare`
- `minimalPairQuiz`
- `multipleChoice`
- `readAloud`

### 暂未在主链路开放的内容

- `u11-u32`
- 部分历史上已写入仓库的数据样稿（如 `u12`、`u22`）目前保留在数据层，但不会在第一阶段主学习链路中对外开放

## 当前完成度

### 教程 / 练习主线

- 教程地图、单元详情、课程页已经围绕数据驱动的 `u1-u10` 主链路重构
- `u11-u32` 当前以 `upcoming` / 后续阶段形式展示，不直接放出入口
- `Practice`、`Assessment`、`Home`、`Profile` 已完成一轮可用化整理

### 账号能力

- 已支持邮箱登录 / 注册
- 已支持 Google / Apple OAuth 入口
- 已支持 reset password
- 已支持读取和更新账号资料：`displayName`、`username`、`avatarUrl`、`accentPreference`
- 已新增账号资料页 `lib/screens/profile/edit_profile_screen.dart`
- 登录入口支持带来源页返回，例如从社区或资料页进入登录后回到原页面

### 社区能力

- 已支持 posts / likes / comments / leaderboard 的服务层接入
- 社区 UI 已支持发帖、点赞、查看评论、发表评论
- 已支持用户删除自己的帖子和自己的评论
- 当前没有伪装成“已具备审核流、复杂通知、AI 社区助教”等并不存在的能力

### 诚实边界

- `audio` 步骤当前只做听音准备说明，不假装已有真实播放资源
- `recordAndCompare` 当前是自练入口，不假装已有真实对照回放
- `assessment` 页面当前只展示真实已实现的结构，不假装已有正式发音评分引擎
- 项目明确避免“假播放 / 假评分 / 假波形”

## 技术栈

- Flutter 3 / Dart 3
- Riverpod
- GoRouter
- SharedPreferences
- Supabase（可选）
- Vercel 静态部署输出 `build/web`

## 目录说明

- `lib/data/`
  教程数据、音位数据、单元配置
- `lib/screens/tutorial/`
  教程地图、单元详情、课程页
- `lib/providers/`
  认证、进度、社区等状态管理
- `lib/services/`
  本地存储、同步、认证、社区服务
- `supabase/migrations/`
  项目当前数据库初始化脚本

## 本地运行

1. 安装 Flutter SDK，并确保 `flutter` 命令可用
2. 在项目根目录执行：

```bash
flutter pub get
flutter run -d chrome
```

如果需要启用 Supabase：

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key
```

如果不传这两个环境变量，项目会自动退回本地模式运行。

## 测试与检查

建议在具备 Flutter 工具链的环境执行：

```bash
flutter analyze
flutter test
```

当前这个工作线程所在环境里，`flutter` / `dart` 还没有加入 PATH，所以这轮只能先做静态修正和测试代码收口，无法在这里直接运行上述命令。

本次改动新增的测试主要覆盖：

- `u1-u10` 教程数据完整性
- `targetPhonemes` 与 `phonemes_data.dart` 的映射一致性
- 教程地图的开放 / 即将开放状态
- 单元详情页显示真实课程
- 课程页对 `multipleChoice` / `minimalPairQuiz` / `recordAndCompare` 的关键步骤渲染
- auth 页面来源页返回能力
- 教程地图、单元详情、课程页的手机与桌面宽度渲染

## 部署说明

项目当前使用 `vercel.json` 指向 Flutter Web 输出目录：

- 构建产物目录：`build/web`
- 所有路由重写到 `index.html`

常见部署流程：

```bash
flutter build web
vercel deploy
```

### GitHub Pages

仓库现在也支持通过 GitHub Actions 部署到 GitHub Pages：

- 工作流文件：`.github/workflows/deploy-pages.yml`
- 默认会在推送到 `master` 后自动执行
- 如果仓库名是 `speak_master`，最终地址会类似：
  `https://staygoldty.github.io/speak_master/`
- 如果仓库本身就是 `staygoldty.github.io` 这类用户主页仓库，则会直接部署到根路径 `/`

这个工作流会：

- 自动执行 `flutter analyze`
- 自动执行 `flutter test test/widget_test.dart`
- 自动用匹配仓库路径的 `--base-href` 构建 Flutter Web
- 自动生成 `404.html`，避免 GitHub Pages 下刷新子路由时直接丢失页面

如果需要让已部署站点启用真实账号 / 社区能力，请在目标 GitHub 仓库中配置：

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

如果这两个 secrets 没有配置，页面仍然可以正常发布，但会以本地体验 / 游客模式运行。

## 后续建议

- 接入真实课程音频资源与播放能力
- 把录音步骤升级为可回放、可对照的练习流
- 接入真实发音评分，而不是仅做自练 UI
- 分阶段开放 `u11-u32`
- 继续清理历史数据文件中的旧编码和旧样稿内容
- 为社区补充编辑能力、审核策略和更细的互动反馈
- 在接好 Flutter 工具链后补跑 `flutter analyze` 与 `flutter test`
