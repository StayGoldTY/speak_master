# Speak Master

一个面向中文学习者的英语发音学习 Flutter 项目，当前主打 Flutter Web 形态，同时保留移动端运行能力。产品目标不是单纯展示音标，而是把“主线学习、对比训练、迁移表达、自我评估、社区互助”串成一条真正可走通的学习路径。

线上地址：

- GitHub Pages: [https://staygoldty.github.io/speak_master/](https://staygoldty.github.io/speak_master/)

## 当前状态

当前已经完成教程主线第一阶段：

- `u1-u10` 已开放，聚焦 `Foundation + Vowels`
- `u11-u32` 不再只是简单的 upcoming 占位，而是提供可浏览的路线预告
- 教程地图、单元详情、课程页、首页、练习、评估、社区、个人页都已完成一轮可用化重构
- Web 端已启用更适合 GitHub Pages 的 hash 路由
- 站点主题、色板和图标已升级为更现代的视觉风格

## 已实现能力

### 1. 教程主线

- 教程地图基于 `units_data.dart` 与 `lessons_data.dart` 数据驱动渲染
- `u1-u10` 每个单元提供 3 节真实课程
- 课程步骤覆盖：
  - `text`
  - `multipleChoice`
  - `minimalPairQuiz`
  - `recordAndCompare`
  - `audio`
  - `readAloud`
- lesson 中的 `audio` / `recordAndCompare` / `readAloud` 现已接入：
  - 真实标准发音播放：基于 `flutter_tts`
  - 浏览器语音识别检查：基于 `speech_to_text`
  - 识别覆盖与重点词反馈：基于 `PronunciationCheckEngine`
- `u11-u32` 当前不会假装成已上线课程，但现在都可以点进单元详情查看：
  - 将学什么
  - 常见误区
  - 真实使用场景
  - 计划中的 3 节结构
  - 完成标志

### 2. 学习提效设计

首页和教程页当前强化的是“三段式掌握循环”：

1. `Observe`：先看口型、气流、重音落点
2. `Contrast`：再做最小对立，把边界练出来
3. `Transfer`：最后带进短句、朗读和真实表达

这比只刷单一题型更适合中文学习者快速建立“能分清、能说出、能迁移”的能力。

### 3. 练习与评估

- `Practice` 支持：
  - 自由朗读
  - 跟读参考材料
  - 绕口令挑战
- `Practice` 中的自由朗读 / 跟读参考材料已接入标准发音播放与识别版自动检查
- lesson / practice / assessment 的发音教练面板现已接入真实录音采集与本地回放对照
- `Assessment` 现已支持标准发音播放 + 识别检查 + 引导式自评，并将结果回写到进度系统
- `progress_provider.dart` 已避免重复刷 XP，并支持 `completeAssessment`

### 4. 账号功能

- 已支持邮箱注册 / 登录
- 已支持 Google / Apple OAuth 入口
- 已支持重置密码
- 已支持读取和更新账号资料：
  - `displayName`
  - `username`
  - `avatarUrl`
  - `accentPreference`
- 已新增账号资料页：
  - `lib/screens/profile/edit_profile_screen.dart`
- 登录入口支持带来源页返回，例如从社区或账号资料页进入登录后返回原页面

### 5. 社区功能

- `community_service.dart` 已支持：
  - `posts`
  - `likes`
  - `comments`
  - `leaderboard`
- 社区 UI 已支持：
  - 发帖
  - 点赞
  - 评论
  - 删除自己的帖子
  - 删除自己的评论
  - 查看我的排名

### 6. 偏好与本地存储

- `storage_service.dart` 已支持持久化：
  - accent 偏好
  - reminder 偏好

## 诚实边界

这个项目当前明确坚持以下原则：

- 不做假播放
- 不做假评分
- 不做假波形
- 没有真实能力时必须明确说明，而不是用看起来“像完成了”的 UI 欺骗用户

因此目前：

- `audio` / `recordAndCompare` / `readAloud` 已经有真实标准发音播放，但当前参考音来自系统 TTS，不冒充真人录音素材
- 自动检查基于浏览器语音识别，只会诚实告诉你“有没有把目标词句读出来”
- `assessment` 现在结合识别检查与引导式自评，但依然不是声学口音自动评分

## 本地运行

### 环境

- Flutter 3
- Dart 3

### 安装依赖

```bash
flutter pub get
```

### 运行 Web

```bash
flutter run -d chrome
```

### 可选：接入 Supabase

```bash
flutter run -d chrome ^
  --dart-define=SUPABASE_URL=your-url ^
  --dart-define=SUPABASE_ANON_KEY=your-key
```

如果不传 Supabase 配置，项目会自动以本地体验模式运行。

## 质量检查

```bash
flutter analyze
flutter test test/widget_test.dart
flutter build web --release --base-href /speak_master/
```

当前测试重点覆盖：

- `u1-u10` 教程数据完整性
- `targetPhonemes` 与 `phonemes_data.dart` 的映射合法性
- 教程地图已开放 / 预告单元的关键入口
- 已开放单元详情页与真实课程列表
- lesson 中 `multipleChoice` / `minimalPairQuiz` / `recordAndCompare` 关键步骤
- practice / assessment 中标准发音脚本入口的稳定渲染
- auth 页面来源页返回能力
- 教程主链页面在手机和桌面宽度下的稳定渲染

## 部署

### GitHub Pages

仓库当前已配置 GitHub Pages 自动部署：

- Workflow 文件：`.github/workflows/deploy-pages.yml`
- 推送到 `master` 后会自动执行：
  - `flutter analyze`
  - `flutter test test/widget_test.dart`
  - `flutter build web --release --base-href /speak_master/`

由于 GitHub Pages 的子路径刷新限制，Web 端当前显式使用 hash 路由，所以深层链接会是这种形式：

- `https://staygoldty.github.io/speak_master/#/learn`
- `https://staygoldty.github.io/speak_master/#/unit/u5`

### 需要的 GitHub Secrets

如果希望线上站点启用真实账号 / 社区能力，请配置：

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

未配置时，页面仍然可以部署，但会以本地体验 / 游客模式运行。

## 目录说明

- `lib/data/`：课程、单元、音位、路线预告等数据
- `lib/screens/tutorial/`：教程地图、单元详情、课程页
- `lib/screens/home/`：首页与学习提效入口
- `lib/screens/practice/`：自由练习、跟读、绕口令
- `lib/screens/community/`：动态、评论、排行榜
- `lib/screens/profile/`：个人页、账号资料、偏好设置
- `lib/providers/`：认证、进度、社区等状态管理
- `lib/services/`：认证、社区、存储等服务

## 下一步建议

- 分阶段继续把 `u11-u32` 补成真实可学习课程
- 接入真实标准音频播放能力
- 接入真实录音回放与对照能力
- 在能力真实可用后，再考虑发音评分与更细粒度反馈
- 继续优化社区的编辑、举报与内容治理能力
