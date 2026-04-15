import '../models/lesson.dart';
import 'phase_one_lessons_data.dart';

/// 参考教材体系：
/// - Cambridge English Pronunciation in Use (Mark Hancock)
/// - Ship or Sheep? / Tree or Three? (Ann Baker)
/// - BBC Learning English: The Sounds of English
/// - Rachel's English: American English Pronunciation
/// - Sounds Right (British Council IPA Chart)
/// - English Phonetics and Phonology (Peter Roach)

class LessonsData {
  LessonsData._();

  // ═══════════════════════════════════════════
  // 板块1：发音基础 (Foundation)
  // ═══════════════════════════════════════════

  static const u1Lessons = [
    // ── 单元1：口腔探险 ──
    Lesson(
      id: 'u1_L1', unitId: 'u1', order: 1,
      titleCn: '认识你的发声引擎', titleEn: 'Meet Your Voice Engine',
      description: '了解发声器官的位置和名称',
      type: LessonType.theory, estimatedMinutes: 5,
      didYouKnowText: '人类能发出的声音种类超过600种，但每种语言只使用其中约40-50种。英语使用44个音素，而汉语普通话使用约32个。这意味着你已经掌握了发声的大部分能力，只需要学会"调整"即可！',
      didYouKnowSource: 'Ladefoged & Maddieson (1996), The Sounds of the World\'s Languages',
      steps: [
        LessonStep(id: 'u1_L1_s1', type: StepType.text, instruction: '发声器官总览',
          content: '''英语发音涉及以下关键部位，请对照示意图依次触摸感受：

🫁 **肺部（Lungs）**——发声的动力源
气流从肺部呼出，提供发声所需的能量。没有气流就没有声音。

🎵 **声带（Vocal Cords）**——声音的开关
位于喉咙里的两条肌肉带。当它们振动时发出"浊音"（如 /b/, /d/, /z/），不振动时发出"清音"（如 /p/, /t/, /s/）。
→ 小实验：手指轻触喉咙，分别说"sssss"和"zzzzz"，感受区别。

👅 **舌头（Tongue）**——最灵活的发音器官
舌头不同部位的位置决定了大部分元音和辅音的区别：
• 舌尖（tip）：抵住齿龈发 /t/, /d/, /n/
• 舌面前部（blade）：靠近硬腭发 /ʃ/, /tʃ/
• 舌面后部（back）：抵住软腭发 /k/, /g/

🦷 **牙齿（Teeth）**
上齿和下唇配合发 /f/, /v/；上下齿间配合舌尖发 /θ/, /ð/

👄 **嘴唇（Lips）**
双唇闭合发 /p/, /b/, /m/；收圆突出发 /uː/, /w/；展开发 /iː/

🏛️ **硬腭（Hard Palate）**——口腔上壁前部
舌面向硬腭抬起发 /j/, /ʃ/

🫧 **软腭（Soft Palate / Velum）**——口腔上壁后部
可以升降：升起时气流从口腔出（口音），降下时气流同时从鼻腔出（鼻音 /m/, /n/, /ŋ/）'''),
        LessonStep(id: 'u1_L1_s2', type: StepType.text, instruction: '杨振宁先生的洞见',
          content: '''杨振宁先生曾指出：

"汉语的发音主要靠口腔前部的肌肉活动——嘴唇、牙齿、舌尖。而英语的主要发声部位更靠后。说英语时应该把发音的张力中心从口腔前部挪到口腔后部。"

这个观察非常精准！对比一下：
• 汉语 "八" → 嘴唇快速开合，动作主要在前部
• 英语 "bar" /bɑːr/ → 嘴巴张大，舌头放低放后，气流感觉从咽喉深处出来

🎯 本课程的核心理念：通过有意识地训练"后部发声"，让你的英语更自然、更地道。'''),
        LessonStep(id: 'u1_L1_s3', type: StepType.multipleChoice, instruction: '发声器官小测验',
          content: '手指触摸喉咙，分别发出 /s/ 和 /z/，哪个能感受到振动？',
          metadata: {
            'options': ['/s/ 振动', '/z/ 振动', '两个都振动', '两个都不振动'],
            'correct': 1,
            'explanation': '/z/ 是浊音，声带振动；/s/ 是清音，声带不振动。这就是清浊对立的核心——同一个口腔位置，声带振不振动决定了不同的音。',
          }),
      ],
    ),

    Lesson(
      id: 'u1_L2', unitId: 'u1', order: 2,
      titleCn: '清音与浊音的秘密', titleEn: 'Voiced vs Voiceless',
      description: '掌握英语最基础的发音分类',
      type: LessonType.practice, estimatedMinutes: 5,
      didYouKnowText: '英语的清浊对立（p/b, t/d, k/g, f/v, s/z）是中国学生最容易忽略的发音特征之一。汉语的 b/p、d/t、g/k 区分的是"送气/不送气"，而英语区分的是"声带振不振动"——这是完全不同的概念！',
      didYouKnowSource: 'Ladefoged (2005), A Course in Phonetics',
      steps: [
        LessonStep(id: 'u1_L2_s1', type: StepType.text, instruction: '清浊对立六组',
          content: '''英语有6组最基础的清浊对立辅音。它们口腔位置完全相同，唯一区别是声带是否振动：

| 清音（声带不振动） | 浊音（声带振动） | 口腔位置 |
|---|---|---|
| /p/ **p**en | /b/ **b**en | 双唇 |
| /t/ **t**en | /d/ **d**en | 舌尖抵齿龈 |
| /k/ **c**ut | /g/ **g**ut | 舌后抵软腭 |
| /f/ **f**an | /v/ **v**an | 上齿咬下唇 |
| /s/ **s**ip | /z/ **z**ip | 舌尖近齿龈 |
| /ʃ/ **sh**ip | /ʒ/ vi**si**on | 舌面近硬腭 |

🎯 练习方法（BBC Learning English 推荐）：
1. 手指轻触喉咙
2. 先发清音 /s/ → 5秒 → 感觉：喉咙安静
3. 切换到浊音 /z/ → 5秒 → 感觉：喉咙在嗡嗡振动
4. 反复切换：sssss-zzzzz-sssss-zzzzz'''),
        LessonStep(id: 'u1_L2_s2', type: StepType.recordAndCompare, instruction: '清浊对比跟读',
          content: 'fan - van, sip - zip, ten - den',
          metadata: {'pairs': ['fan|van', 'sip|zip', 'ten|den', 'few|view', 'seal|zeal']}),
        LessonStep(id: 'u1_L2_s3', type: StepType.minimalPairQuiz, instruction: '听辨练习',
          metadata: {'pairs': [
            {'word1': 'fan', 'word2': 'van', 'phoneme1': 'f', 'phoneme2': 'v'},
            {'word1': 'price', 'word2': 'prize', 'phoneme1': 's', 'phoneme2': 'z'},
            {'word1': 'pig', 'word2': 'big', 'phoneme1': 'p', 'phoneme2': 'b'},
          ]}),
      ],
    ),

    Lesson(
      id: 'u1_L3', unitId: 'u1', order: 3,
      titleCn: '元音与辅音的区别', titleEn: 'Vowels vs Consonants',
      description: '理解英语44个音素的基本分类',
      type: LessonType.theory, estimatedMinutes: 5,
      didYouKnowText: '英语只有5个元音字母（a, e, i, o, u），但却有20个元音音素！这就是为什么英语拼写和发音之间经常"不一致"——一个字母可能对应多个发音。',
      didYouKnowSource: 'Crystal (2003), The Cambridge Encyclopedia of the English Language',
      steps: [
        LessonStep(id: 'u1_L3_s1', type: StepType.text, instruction: '音素分类全景图',
          content: '''英语共有 **44 个音素**（20 元音 + 24 辅音）：

🔴 **元音（Vowels）— 20个**
气流不受阻碍，自由从口腔通过。就像歌唱时的声音。
• 12个单元音：/iː/ /ɪ/ /e/ /æ/ /ɜː/ /ə/ /ʌ/ /uː/ /ʊ/ /ɔː/ /ɒ/ /ɑː/
• 8个双元音：/eɪ/ /aɪ/ /ɔɪ/ /əʊ/ /aʊ/ /ɪə/ /eə/ /ʊə/

🔵 **辅音（Consonants）— 24个**
气流在口腔中受到不同程度的阻碍。
• 6个爆破音：/p/ /b/ /t/ /d/ /k/ /g/
• 9个摩擦音：/f/ /v/ /θ/ /ð/ /s/ /z/ /ʃ/ /ʒ/ /h/
• 2个破擦音：/tʃ/ /dʒ/
• 3个鼻音：/m/ /n/ /ŋ/
• 1个舌侧音：/l/
• 3个近音：/r/ /w/ /j/

🗣️ **判断元音还是辅音的简单方法：**
• 元音：可以无限延长（aaa...eee...ooo...）
• 辅音：大部分不能延长，或延长后和原来不一样

⚡ **对中国学生最关键的：**
英语元音比汉语元音多得多（汉语约6个基础元音），而且区分更精细。很多中国学生把 /ɪ/ 和 /iː/ 不分、/e/ 和 /æ/ 不分，这在英语里会造成意思完全不同！'''),
        LessonStep(id: 'u1_L3_s2', type: StepType.multipleChoice, instruction: '元音辅音判断',
          content: '以下哪个是元音？',
          metadata: {
            'options': ['/p/', '/æ/', '/s/', '/θ/'],
            'correct': 1,
            'explanation': '/æ/ 是前元音（cat 中的元音），气流自由通过口腔。其他三个都是辅音，气流在口腔中受阻。',
          }),
      ],
    ),
  ];

  // ═══════════════════════════════════════════
  // 板块2：元音精通 (Vowels)
  // ═══════════════════════════════════════════

  static const u5Lessons = [
    // ── 单元5：前元音四兄弟 /iː/ /ɪ/ /e/ /æ/ ──
    Lesson(
      id: 'u5_L1', unitId: 'u5', order: 1,
      titleCn: '/iː/ 与 /ɪ/ — 长短之战', titleEn: 'Long vs Short i',
      description: '掌握最容易混淆的一对元音',
      type: LessonType.practice, estimatedMinutes: 8,
      didYouKnowText: '根据 Ann Baker 在 Ship or Sheep? 中的研究，/iː/ 和 /ɪ/ 的区别不仅是长短——舌头位置、嘴唇形状、肌肉紧张度全部不同！/iː/ 舌位更高更前，嘴唇展开像微笑，肌肉紧绷；/ɪ/ 舌位稍低稍中，嘴唇放松，肌肉松弛。',
      didYouKnowSource: 'Ann Baker (2006), Ship or Sheep?, Cambridge University Press',
      steps: [
        LessonStep(id: 'u5_L1_s1', type: StepType.text, instruction: '看：/iː/ 发音详解',
          content: '''📍 **音标：/iː/**
📝 **名称：** 长前高元音（Long close front vowel）

**发音四步法（参考 BBC Learning English）：**
1️⃣ **嘴唇** → 向两侧展开，像在微笑 😊
2️⃣ **舌头** → 舌尖轻抵下齿背，舌面前部尽量向硬腭抬高
3️⃣ **下巴** → 几乎不张开，只留一条窄缝
4️⃣ **时长** → 保持较长时间，至少延续1秒

**常见拼写规则：**
• ee → s**ee**, tr**ee**, b**ee**, fr**ee**, ch**ee**se
• ea → **ea**t, r**ea**d, t**ea**, cl**ea**n, sp**ea**k
• e_e → th**e**s**e**, compl**e**t**e**, Chin**e**s**e**
• ie → bel**ie**ve, ach**ie**ve, f**ie**ld
• ey → k**ey**, monk**ey** (部分)
• i → mach**i**ne, pol**i**ce, mag**a**z**i**ne

**高频词练习（由易到难）：**
初级：see, me, he, she, we, eat, tea, sea, tree, free
中级：people, teacher, easy, reason, believe, machine
高级：achieve, complete, guarantee, technique, unique'''),

        LessonStep(id: 'u5_L1_s2', type: StepType.text, instruction: '看：/ɪ/ 发音详解',
          content: '''📍 **音标：/ɪ/**
📝 **名称：** 短前半高元音（Short near-close near-front vowel）

**发音四步法：**
1️⃣ **嘴唇** → 自然放松，不用刻意展开
2️⃣ **舌头** → 位置比 /iː/ 稍低稍后，肌肉放松
3️⃣ **下巴** → 比 /iː/ 多张开一点
4️⃣ **时长** → 短促有力，快速发完

**常见拼写规则：**
• i → s**i**t, b**i**g, f**i**sh, sw**i**m, th**i**nk
• y → g**y**m, s**y**mbol, s**y**stem, m**y**stery
• ui → b**ui**ld, g**ui**tar, b**ui**lt
• e → pr**e**tty, **E**ngland, bus**y** (特殊)

**高频词练习：**
初级：it, is, in, his, big, sit, six, fish, this, did
中级：children, different, interesting, beginning, little
高级：business, primitive, particular, significant

⚠️ **中国学生最常犯的错：**
把所有 i 都读成 /iː/！比如 sit 读成 seat，it 读成 eat。
记住：/ɪ/ 要更短、更轻、嘴巴更放松！'''),

        LessonStep(id: 'u5_L1_s3', type: StepType.audio, instruction: '听：对比标准发音',
          content: '''逐对听辨，注意长短、紧松的区别：

1. sheep /ʃiːp/ 🐑 → ship /ʃɪp/ 🚢
2. eat /iːt/ 🍽️ → it /ɪt/ 👆
3. feel /fiːl/ 💕 → fill /fɪl/ 🪣
4. seat /siːt/ 💺 → sit /sɪt/ 🧎
5. beat /biːt/ 🥁 → bit /bɪt/ 💾
6. leave /liːv/ 🚪 → live /lɪv/ 🏠
7. heel /hiːl/ 👠 → hill /hɪl/ ⛰️
8. peak /piːk/ 🏔️ → pick /pɪk/ ✅'''),

        LessonStep(id: 'u5_L1_s4', type: StepType.recordAndCompare, instruction: '说：最小对立体跟读',
          content: '''大声跟读每一对，录音对比：

第1组（词级别）：
sheep → ship → sheep → ship
beat → bit → beat → bit
feel → fill → feel → fill

第2组（短语级别）：
"eat it" → 注意两个不同的 i 音
"these things" → /iː/ 然后 /ɪ/
"cheap chips" → /iː/ 然后 /ɪ/

第3组（句子级别）：
"He sits in his seat." /iː/ + /ɪ/ + /ɪ/ + /iː/
"She still feels ill." /iː/ + /ɪ/ + /iː/ + /ɪ/
"Please give me a piece." /iː/ + /ɪ/ + /iː/ + /iː/'''),

        LessonStep(id: 'u5_L1_s5', type: StepType.minimalPairQuiz, instruction: '辨：你听到了哪个？',
          metadata: {'pairs': [
            {'word1': 'sheep', 'word2': 'ship', 'phoneme1': 'iː', 'phoneme2': 'ɪ'},
            {'word1': 'feel', 'word2': 'fill', 'phoneme1': 'iː', 'phoneme2': 'ɪ'},
            {'word1': 'leave', 'word2': 'live', 'phoneme1': 'iː', 'phoneme2': 'ɪ'},
            {'word1': 'beat', 'word2': 'bit', 'phoneme1': 'iː', 'phoneme2': 'ɪ'},
            {'word1': 'seat', 'word2': 'sit', 'phoneme1': 'iː', 'phoneme2': 'ɪ'},
            {'word1': 'heel', 'word2': 'hill', 'phoneme1': 'iː', 'phoneme2': 'ɪ'},
          ]}),
      ],
    ),

    Lesson(
      id: 'u5_L2', unitId: 'u5', order: 2,
      titleCn: '/e/ 与 /æ/ — 嘴巴大小之争', titleEn: 'Open Your Mouth',
      description: '区分中国学生最容易混淆的另一对元音',
      type: LessonType.practice, estimatedMinutes: 8,
      didYouKnowText: '/æ/ 这个音在世界语言中比较少见。它需要嘴巴张到一个中国学生不习惯的大小——比说"诶"大很多，但又不是"啊"。Peter Roach 教授称之为"介于 /e/ 和 /ɑː/ 之间的特殊位置"。很多中国学生因为嘴巴张不够大，把 bad 说成了 bed。',
      didYouKnowSource: 'Peter Roach (2009), English Phonetics and Phonology, Cambridge',
      steps: [
        LessonStep(id: 'u5_L2_s1', type: StepType.text, instruction: '看：/e/ 发音详解',
          content: '''📍 **音标：/e/**（部分教材写作 /ɛ/）
📝 **名称：** 前半开元音

**发音四步法：**
1️⃣ **嘴唇** → 自然微开，不圆不展
2️⃣ **舌头** → 舌面前部稍抬（比 /ɪ/ 低，比 /æ/ 高）
3️⃣ **下巴** → 中等张开，约一指宽
4️⃣ **时长** → 短促

**类比中文：** 接近普通话"诶"(ei) 的开头部分，但不滑动

**常见拼写：**
• e → b**e**d, r**e**d, g**e**t, s**e**t, t**e**n
• ea → h**ea**d, br**ea**d, d**ea**d, r**ea**dy
• a → m**a**ny, **a**ny (特殊)
• ai → s**ai**d, ag**ai**n (特殊)

**高频词：** bed, red, ten, pen, get, set, let, met, best, next, said, bread, head, friend, already'''),

        LessonStep(id: 'u5_L2_s2', type: StepType.text, instruction: '看：/æ/ 发音详解',
          content: '''📍 **音标：/æ/**
📝 **名称：** 前开元音（Open front vowel）

**发音四步法：**
1️⃣ **嘴唇** → 嘴角用力向两侧拉开（关键！）
2️⃣ **舌头** → 舌面前部放到最低位置，舌尖抵住下齿背
3️⃣ **下巴** → 充分下拉，至少两指宽
4️⃣ **时长** → 比 /e/ 长一些

⚡ **最关键的区别：嘴巴大小！**
• /e/ → 嘴巴中等张开（约1指）
• /æ/ → 嘴巴充分张大（约2指）+ 嘴角向两侧拉

**常见拼写：** 几乎只有一种！
• a → c**a**t, b**a**d, m**a**p, h**a**nd, f**a**mily, h**a**ppy

**高频词分组练习（由易到难）：**
单音节：cat, bat, hat, mat, sat, fat, map, cap, tap, sad, bad, had, man, can, ran, fan, back, black, hand, and
双音节：happy, apple, family, animal, matter, travel, happen, rabbit, fashion, practice
三音节：attitude, banana, imagine, exactly, fantastic, romantic, understand, ambulance

⚠️ **自检方法（Ann Baker 推荐）：**
对着镜子说 bed 和 bad：
• 如果嘴巴大小一样 → 你的 /æ/ 不够开！
• 应该看到 bad 时下巴明显比 bed 低很多'''),

        LessonStep(id: 'u5_L2_s3', type: StepType.recordAndCompare, instruction: '说：嘴巴大小对比训练',
          content: '''对着镜子练习，确认下巴在 /æ/ 时明显降低：

第1组（词级别）：
bed → bad → bed → bad
pen → pan → pen → pan
men → man → men → man
set → sat → set → sat
bet → bat → bet → bat

第2组（绕口令）：
"A black cat sat on a man's hat."
—— 每个 /æ/ 都要嘴巴张大！

"The fat man had a bad plan."
—— 6个 /æ/ 连续轰炸！

第3组（对比句）：
"The MEN in the MAN's van."
（/e/ 在 MEN，/æ/ 在 MAN 和 van）'''),

        LessonStep(id: 'u5_L2_s4', type: StepType.minimalPairQuiz, instruction: '辨：你听到了哪个？',
          metadata: {'pairs': [
            {'word1': 'bed', 'word2': 'bad', 'phoneme1': 'e', 'phoneme2': 'æ'},
            {'word1': 'pen', 'word2': 'pan', 'phoneme1': 'e', 'phoneme2': 'æ'},
            {'word1': 'men', 'word2': 'man', 'phoneme1': 'e', 'phoneme2': 'æ'},
            {'word1': 'set', 'word2': 'sat', 'phoneme1': 'e', 'phoneme2': 'æ'},
            {'word1': 'head', 'word2': 'had', 'phoneme1': 'e', 'phoneme2': 'æ'},
          ]}),
      ],
    ),

    Lesson(
      id: 'u5_L3', unitId: 'u5', order: 3,
      titleCn: '前元音四兄弟大比拼', titleEn: 'Front Vowel Battle',
      description: '综合训练 /iː/ /ɪ/ /e/ /æ/ 四个前元音',
      type: LessonType.game, estimatedMinutes: 6,
      steps: [
        LessonStep(id: 'u5_L3_s1', type: StepType.text, instruction: '前元音阶梯',
          content: '''从嘴巴最小到最大，舌位从最高到最低：

🔼 /iː/ — 嘴几乎闭合，像微笑 → see, eat, tea
  ↕ 稍微张开一点
🔽 /ɪ/ — 嘴巴自然放松 → sit, it, big
  ↕ 再张开一点
🔽 /e/ — 嘴巴中等张开 → bed, red, ten
  ↕ 最大程度张开
🔽 /æ/ — 嘴巴张到最大，嘴角拉开 → cat, bad, map

🎯 **阶梯跟读（Rachel's English 方法）：**
连续从高到低："beat - bit - bet - bat"
再从低到高："bat - bet - bit - beat"
反复交替，感受舌位和嘴巴的渐进变化。

📊 **四音对比句：**
"Is this pen and this pan the same?"
 /ɪ/ /ɪ/ /e/ /ɪ/ /æ/ /ə/ /eɪ/

"Please sit and read that black text."
 /iː/ /ɪ/ /iː/ /æ/ /æ/ /e/'''),

        LessonStep(id: 'u5_L3_s2', type: StepType.recordAndCompare, instruction: '阶梯跟读挑战',
          content: '''连续跟读四音阶梯，录音自测：

beat → bit → bet → bat
seat → sit → set → sat
peel → pill → ? → pal
feel → fill → fell → ?

然后试试反向：
bat → bet → bit → beat
map → met → ? → meat'''),

        LessonStep(id: 'u5_L3_s3', type: StepType.multipleChoice, instruction: '综合听辨挑战',
          content: '连续听四个词，判断哪个用了 /æ/ 音？',
          metadata: {
            'options': ['sheep', 'ship', 'shed', 'shall'],
            'correct': 3,
            'explanation': 'shall /ʃæl/ 使用 /æ/ 音。sheep=/iː/, ship=/ɪ/, shed=/e/',
          }),
      ],
    ),
  ];

  // ═══════════════════════════════════════════
  // 板块2续：中央元音（难点攻关）
  // ═══════════════════════════════════════════

  static const u6Lessons = [
    // ── 单元6：中央元音 /ɜː/ /ə/ /ʌ/ ──
    Lesson(
      id: 'u6_L1', unitId: 'u6', order: 1,
      titleCn: 'Schwa /ə/ — 英语第一元音', titleEn: 'The King of English Vowels',
      description: '掌握出现频率最高的英语元音',
      type: LessonType.theory, estimatedMinutes: 8,
      didYouKnowText: 'Schwa /ə/ 是英语中出现频率最高的元音——据统计，英语口语中每5个元音就有1个是 Schwa！它是英语"重音计时节奏"（stress-timed rhythm）的灵魂。中国学生最大的发音问题之一，就是把每个音节都读得一样清楚，而忽略了 Schwa 弱读。',
      didYouKnowSource: 'Gimson (2014), Gimson\'s Pronunciation of English, 8th ed.',
      steps: [
        LessonStep(id: 'u6_L1_s1', type: StepType.text, instruction: 'Schwa 的核心概念',
          content: '''📍 **音标：/ə/**
📝 **名称：** Schwa（中央元音）

**为什么 Schwa 如此重要？**
因为英语是"重音计时语言"——重读音节清晰有力，非重读音节轻快模糊。而 Schwa 就是非重读音节的默认发音！

**发音方法（极其简单）：**
完全放松你的嘴巴和舌头，发出一个模糊的"呃"。
→ 不用努力，越放松越对！

**Schwa 无处不在——看看这些常见词：**
• **a**bout /ə'baʊt/ — 第一个 a 是 Schwa
• b**a**nana /bə'nɑːnə/ — 第一个 a 和最后的 a 都是 Schwa！
• **o**'clock /ə'klɒk/ — o 读成 Schwa
• p**o**lice /pə'liːs/ — 第一个 o 是 Schwa
• sup**po**rt /sə'pɔːt/ — u 读成 Schwa
• teach**er** /ˈtiːtʃə/ — er 读成 Schwa
• doct**or** /ˈdɒktə/ — or 读成 Schwa
• fam**ou**s /ˈfeɪməs/ — ou 读成 Schwa

⚡ **规律总结：** a, e, i, o, u 在非重读位置时，大部分都会弱化成 Schwa！

⚠️ **中国学生的核心问题：**
中文是"音节计时语言"——每个字的时长基本一样。所以中国学生说英语时习惯把每个音节都读得同样清楚，导致节奏"太平"，听起来像机器人。
→ 解决方案：非重读音节放松、缩短、模糊化！'''),

        LessonStep(id: 'u6_L1_s2', type: StepType.recordAndCompare, instruction: '弱读对比练习',
          content: '''对比"逐字清读"和"自然节奏"：

❌ 逐字读（中国学生常见）：
"A cup OF tea AND a piece OF cake"
每个词都一样重、一样长

✅ 自然英语节奏（Schwa 弱读）：
"A cup /əv/ tea /ənd ə/ piece /əv/ cake"
of → /əv/, and → /ənd/, a → /ə/

更多练习句：
1. "I was going to the shop." → /aɪ wəz ˈgəʊɪŋ tə ðə ʃɒp/
2. "Can you give me a glass of water?" → /kən jə gɪv mi ə glɑːs əv ˈwɔːtə/
3. "What are you looking at?" → /wɒt ə jə ˈlʊkɪŋ ət/'''),

        LessonStep(id: 'u6_L1_s3', type: StepType.multipleChoice, instruction: 'Schwa 大搜索',
          content: '单词 "chocolate" /ˈtʃɒklət/ 中，哪个音节包含 Schwa？',
          metadata: {
            'options': ['choc- (第一音节)', '-o- (第二音节)', '-late (第三音节)', '没有 Schwa'],
            'correct': 2,
            'explanation': '"chocolate" 发音为 /ˈtʃɒklət/，只有两个音节：CHOC-lət。最后的 -late 弱化为 /lət/，其中 e 发 Schwa /ə/。',
          }),
      ],
    ),

    Lesson(
      id: 'u6_L2', unitId: 'u6', order: 2,
      titleCn: '/ɜː/ — 口腔后移的关键音', titleEn: 'The Sound of Learning',
      description: '这个音最能体现"发声后移"的理念',
      type: LessonType.practice, estimatedMinutes: 7,
      didYouKnowText: '/ɜː/ 在中文里完全没有对应的音，它是最能体现杨振宁先生所说"发声位置后移"的元音。发这个音时，舌头在口腔正中央，嘴唇既不展也不圆——这种"中性"位置对中国学生来说非常陌生。',
      didYouKnowSource: 'Wells (2008), Longman Pronunciation Dictionary, 3rd ed.',
      steps: [
        LessonStep(id: 'u6_L2_s1', type: StepType.text, instruction: '看：/ɜː/ 发音详解',
          content: '''📍 **音标：/ɜː/**
📝 **名称：** 长中央半开元音

**发音四步法：**
1️⃣ **嘴唇** → 自然微开，既不展开也不圆起（中性位置）
2️⃣ **舌头** → 放在口腔正中央，微微抬起但不碰上颚
3️⃣ **感觉** → 发声时感觉声音从口腔中部偏后发出（不是从前面！）
4️⃣ **时长** → 持续较长，像犹豫时说"嗯——"

**中文类比：** 有点像轻声说"饿"但不要把嘴巴张太大，舌头也不要太靠前

**常见拼写规则：**
• ir → b**ir**d, g**ir**l, f**ir**st, th**ir**d, sh**ir**t, d**ir**ty
• ur → t**ur**n, b**ur**n, n**ur**se, h**ur**t, p**ur**ple
• er → h**er**, p**er**son, t**er**m, v**er**b, s**er**ve
• or → w**or**d, w**or**k, w**or**ld, w**or**th, w**or**m
• ear → **ear**th, l**ear**n, **ear**ly, h**ear**d, s**ear**ch

🎯 **记忆口诀：** ir, ur, er, or(w开头), ear 在重读位置都发 /ɜː/！

**高频词练习：**
初级：bird, word, her, turn, learn, first, work, girl, world
中级：certainly, perfect, purpose, Thursday, birthday, further
高级：determine, alternative, circumstances, controversial'''),

        LessonStep(id: 'u6_L2_s2', type: StepType.recordAndCompare, instruction: '说：/ɜː/ 绕口令',
          content: '''跟读练习：

单词连续：bird — word — heard — learned — turned

短语：a dirty shirt, her first birthday, learn and earn

句子（由易到难）：
1. "Her bird is early." (3个 /ɜː/)
2. "The nurse works on Thursday." (3个 /ɜː/)
3. "She certainly learned her first thirty words." (4个 /ɜː/)
4. "The early bird certainly deserves the first worm." (5个 /ɜː/)'''),
      ],
    ),

    Lesson(
      id: 'u6_L3', unitId: 'u6', order: 3,
      titleCn: '/ʌ/ 与中央元音总复习', titleEn: 'Central Vowel Review',
      description: '掌握 /ʌ/ 并区分三个中央元音',
      type: LessonType.game, estimatedMinutes: 6,
      steps: [
        LessonStep(id: 'u6_L3_s1', type: StepType.text, instruction: '/ʌ/ 发音要点',
          content: '''📍 **音标：/ʌ/**
📝 **名称：** 短后半开元音

**发音要点：**
• 嘴巴半开，发音短促有力
• 舌位比 /ə/ 稍低稍后
• 类比中文：比"啊"短得多、轻得多

**和 /ə/ 的区别：**
• /ʌ/ → 出现在重读音节：cup /kʌp/, love /lʌv/
• /ə/ → 出现在非重读音节：about /əˈbaʊt/
• 口腔位置几乎一样！区别主要是重读/非重读

**常见拼写：**
• u → c**u**p, b**u**s, s**u**n, r**u**n, j**u**st, l**u**ck, f**u**n
• o → l**o**ve, c**o**me, s**o**me, m**o**ney, m**o**nth, d**o**ne
• ou → c**ou**ntry, y**ou**ng, t**ou**ch, tr**ou**ble, c**ou**ple, en**ou**gh
• oo → bl**oo**d, fl**oo**d

**三音对比表：**
| /ɜː/ (长·中央) | /ʌ/ (短·重读) | /ə/ (短·非重读) |
|---|---|---|
| bird | bus | about |
| word | won | support |
| learn | luck | again |
| hurt | hut | particular |'''),

        LessonStep(id: 'u6_L3_s2', type: StepType.minimalPairQuiz, instruction: '三音听辨',
          metadata: {'pairs': [
            {'word1': 'bird', 'word2': 'bud', 'phoneme1': 'ɜː', 'phoneme2': 'ʌ'},
            {'word1': 'heard', 'word2': 'hut', 'phoneme1': 'ɜː', 'phoneme2': 'ʌ'},
            {'word1': 'cup', 'word2': 'cap', 'phoneme1': 'ʌ', 'phoneme2': 'æ'},
            {'word1': 'cut', 'word2': 'cat', 'phoneme1': 'ʌ', 'phoneme2': 'æ'},
          ]}),
      ],
    ),
  ];

  // ═══════════════════════════════════════════
  // 板块3：辅音攻略 — 中国人难点
  // ═══════════════════════════════════════════

  static const u12Lessons = [
    // ── 单元12：摩擦音（重点：/θ/ /ð/ /v/）──
    Lesson(
      id: 'u12_L1', unitId: 'u12', order: 1,
      titleCn: '/θ/ 和 /ð/ — 伸出你的舌头！', titleEn: 'Stick Out Your Tongue!',
      description: '攻克中国人英语发音的最大难关',
      type: LessonType.practice, estimatedMinutes: 10,
      didYouKnowText: '齿间摩擦音 /θ/ 和 /ð/ 在全球约7000种语言中，只有约4%的语言拥有！英语恰好是其中之一。全球大多数英语学习者都觉得它难——不只是中国人！根据 Deterding (2006) 的研究，东亚学习者最常见的替代是：/θ/→/s/ 和 /ð/→/d/。',
      didYouKnowSource: 'Deterding (2006), The North Wind versus a Wolf: short texts for the description and measurement of English pronunciation, JIPA',
      steps: [
        LessonStep(id: 'u12_L1_s1', type: StepType.text, instruction: '看：/θ/ 详细发音指南',
          content: '''📍 **音标：/θ/**（清齿间摩擦音）
📝 **关键词：** think, three, mouth, bath

**分步教学（Cambridge Pronunciation in Use 方法）：**

Step 1️⃣ 准备姿势
• 对着镜子张开嘴
• 把舌尖轻轻放在上下齿之间（约伸出3-5毫米）
• 要能从镜子里看到自己的舌尖！

Step 2️⃣ 发音
• 轻轻吹气，让气流从舌面和上齿之间的缝隙中挤出
• 声带不振动（清音）
• 气流应该是持续的"丝丝"声，而不是爆破

Step 3️⃣ 自检
• 用手掌放在嘴前：能感到温和的气流 ✅
• 摸喉咙：没有振动 ✅
• 看镜子：能看到舌尖 ✅

⚠️ **最常见错误及纠正：**
❌ 发成 /s/（think → sink）→ 舌头在齿龈后面，没伸出来
✅ 纠正：确保舌尖在牙齿之间！

❌ 发成 /f/（three → free）→ 用了上齿咬下唇
✅ 纠正：是舌尖在齿间，不是下唇！

❌ 发成 /t/（think → tink）→ 舌尖堵住了气流
✅ 纠正：不要堵！保持缝隙让气流持续通过

**拼写规则：** 所有 th 组合（但要区分清浊！）
• 清音 /θ/（通常在词首实义词、词尾）：**th**ink, **th**ree, **th**ank, mou**th**, ba**th**, bir**th**, tee**th**, tru**th**, nor**th**, sou**th**, heal**th**, weal**th**, grow**th**, dep**th**
• 记忆技巧：名词/形容词/数词的 th 多为 /θ/

**高频词练习：**
初级：think, three, thank, thing, both, mouth, tooth
中级：nothing, something, birthday, everything, Thursday, method
高级：enthusiasm, thorough, therapy, theology, mathematics'''),

        LessonStep(id: 'u12_L1_s2', type: StepType.text, instruction: '看：/ð/ 详细发音指南',
          content: '''📍 **音标：/ð/**（浊齿间摩擦音）
📝 **关键词：** the, this, that, mother

**发音方法：和 /θ/ 完全相同的舌位——唯一区别是声带要振动！**

Step 1️⃣ 先发 /θ/（thhhh...）
Step 2️⃣ 保持舌头位置不动，打开声带振动 → 变成 /ð/
Step 3️⃣ 摸喉咙确认有振动

**清浊切换练习：**
/θ/ → /ð/ → /θ/ → /ð/（舌头不动，只切换声带）

⚠️ **常见错误：**
❌ 发成 /d/（the → de, this → dis）→ 舌尖堵住了！
✅ 纠正：保持缝隙，是摩擦不是爆破

❌ 发成 /z/（this → zis）→ 舌头在齿龈后面
✅ 纠正：舌尖必须在齿间

**拼写规则：**
• 浊音 /ð/（通常在功能词、词中）：**th**e, **th**is, **th**at, **th**ey, **th**en, **th**ere, **th**em, **th**ose, **th**ese, wi**th**, bro**th**er, mo**th**er, fa**th**er, wea**th**er, o**th**er, toge**th**er, ra**th**er, whe**th**er
• 记忆技巧：代词/冠词/连词的 th 多为 /ð/

**最小对立体（/θ/ vs /ð/）：**
thigh /θaɪ/ 大腿 ↔ thy /ðaɪ/ 你的（古语）
ether /ˈiːθə/ 乙醚 ↔ either /ˈiːðə/ 任一
mouth /maʊθ/ 名词嘴 ↔ mouthe /maʊð/ 动词说'''),

        LessonStep(id: 'u12_L1_s3', type: StepType.recordAndCompare, instruction: '说：分级跟读训练',
          content: '''🥉 初级（单词）：
think, this, that, three, the, them, thank, then, those, mouth

🥈 中级（短语）：
"this and that" "the other thing" "three brothers"
"the weather" "mother and father"

🥇 高级（绕口令）：
1. "I thought a thought, but the thought I thought wasn't the thought I thought I thought."
2. "The thirty-three thieves thought that they thrilled the throne throughout Thursday."
3. "This is the sixth time that those three brothers gathered together."

📊 **对比三组容易混淆的音：**
/θ/ think ↔ /s/ sink ↔ /f/ fink
/θ/ three ↔ /s/ see ↔ /f/ free
/ð/ then ↔ /d/ den ↔ /z/ zen'''),

        LessonStep(id: 'u12_L1_s4', type: StepType.minimalPairQuiz, instruction: '辨：是 th 还是 s/f/d？',
          metadata: {'pairs': [
            {'word1': 'think', 'word2': 'sink', 'phoneme1': 'θ', 'phoneme2': 's'},
            {'word1': 'three', 'word2': 'free', 'phoneme1': 'θ', 'phoneme2': 'f'},
            {'word1': 'thick', 'word2': 'sick', 'phoneme1': 'θ', 'phoneme2': 's'},
            {'word1': 'they', 'word2': 'day', 'phoneme1': 'ð', 'phoneme2': 'd'},
            {'word1': 'then', 'word2': 'den', 'phoneme1': 'ð', 'phoneme2': 'd'},
            {'word1': 'though', 'word2': 'dough', 'phoneme1': 'ð', 'phoneme2': 'd'},
            {'word1': 'bathe', 'word2': 'bays', 'phoneme1': 'ð', 'phoneme2': 'z'},
          ]}),
      ],
    ),

    Lesson(
      id: 'u12_L2', unitId: 'u12', order: 2,
      titleCn: '/v/ vs /w/ — 咬唇还是嘟嘴？', titleEn: 'Bite vs Pucker',
      description: '区分中国学生最常混淆的辅音对',
      type: LessonType.practice, estimatedMinutes: 7,
      didYouKnowText: '把 very 说成 "wery" 是全球范围内中国英语学习者最典型的特征之一。原因是汉语中没有上齿咬下唇的 /v/ 音，而 /w/ 这个音（双唇圆起）在汉语中存在，所以大脑自动用 /w/ 替代了 /v/。',
      didYouKnowSource: 'Swan & Smith (2001), Learner English, Cambridge',
      steps: [
        LessonStep(id: 'u12_L2_s1', type: StepType.text, instruction: '/v/ 和 /w/ 的关键区别',
          content: '''这两个音完全不同！关键在于**嘴唇和牙齿的关系**：

**🦷 /v/ — 上齿咬下唇**
• 上门牙轻轻放在下嘴唇的内侧边缘
• 气流从齿唇之间的缝隙中挤出
• 声带振动（浊音）
• 例词：**v**ery, **v**oice, lo**v**e, li**v**e, dri**v**e

**👄 /w/ — 双唇圆起突出**
• 双唇收圆向前突出（像要吹口哨或亲嘴）
• 牙齿完全不参与！
• 声带振动
• 然后嘴唇快速打开到后面元音位置
• 例词：**w**e, **w**ant, **w**ater, **w**ay, **w**orld

⚡ **对着镜子自检：**
• 说 /v/ 时：能看到上齿在下唇上 ✅
• 说 /w/ 时：只看到圆起的嘴唇，看不到牙齿 ✅

**最小对立体：**
vine 🍇 /vaɪn/ ↔ wine 🍷 /waɪn/
vet 🏥 /vet/ ↔ wet 💧 /wet/
vest 🦺 /vest/ ↔ west 🌅 /west/
veil 👰 /veɪl/ ↔ wail 😭 /weɪl/
vow 💍 /vaʊ/ ↔ wow 😮 /waʊ/
verse 📖 /vɜːs/ ↔ worse 😞 /wɜːs/'''),

        LessonStep(id: 'u12_L2_s2', type: StepType.recordAndCompare, instruction: '对比跟读',
          content: '''确保 /v/ 时牙齿咬下唇，/w/ 时嘴唇嘟起：

vine → wine → vine → wine
vet → wet → vet → wet
very → wary → very → wary

对比句：
"The VET got WET in the VEST heading WEST."
"She VOWED to say WOW at every VIEW from the WINDOW."
"It's VERY WARY to VISIT in WINTER WEATHER."'''),

        LessonStep(id: 'u12_L2_s3', type: StepType.minimalPairQuiz, instruction: '听辨 /v/ vs /w/',
          metadata: {'pairs': [
            {'word1': 'vine', 'word2': 'wine', 'phoneme1': 'v', 'phoneme2': 'w'},
            {'word1': 'vet', 'word2': 'wet', 'phoneme1': 'v', 'phoneme2': 'w'},
            {'word1': 'vest', 'word2': 'west', 'phoneme1': 'v', 'phoneme2': 'w'},
            {'word1': 'vow', 'word2': 'wow', 'phoneme1': 'v', 'phoneme2': 'w'},
            {'word1': 'verse', 'word2': 'worse', 'phoneme1': 'v', 'phoneme2': 'w'},
          ]}),
      ],
    ),
  ];

  // ═══════════════════════════════════════════
  // 板块5：发音驱动语法
  // ═══════════════════════════════════════════

  static const u22Lessons = [
    // ── 单元22：Be 动词与人称 ──
    Lesson(
      id: 'u22_L1', unitId: 'u22', order: 1,
      titleCn: '为什么 I am / you are / he is？', titleEn: 'Be Verbs Through Sound',
      description: '用发音解释杨振宁先生的 Be 动词之谜',
      type: LessonType.theory, estimatedMinutes: 8,
      didYouKnowText: 'Be 动词的形态变化（am/are/is）源于古英语中三个完全不同的词根融合而成。语言学家 Morgan & Demuth (1996) 的研究表明，婴儿在学习语言时，首先掌握的不是语法规则，而是声音模式——他们从语音节奏中"听"出了语法结构。这就是"韵律引导假说"（Prosodic Bootstrapping Hypothesis）。',
      didYouKnowSource: 'Morgan & Demuth (1996), Signal to Syntax: Bootstrapping from Speech to Grammar in Early Acquisition',
      steps: [
        LessonStep(id: 'u22_L1_s1', type: StepType.text, instruction: '发音揭秘：为什么不能说 "I is"？',
          content: '''杨振宁先生当年的疑惑——为什么 I am / you are / he is 要变化？

**答案就在发音里：**

试着大声快速说：
❌ "I is" → /aɪ ɪz/ → 两个 /ɪ/ 音紧挨着，嘴巴来不及调整
✅ "I am" → /aɪ æm/ → /aɪ/ 自然滑向 /æ/，流畅！

❌ "You is" → /juː ɪz/ → /uː/ 到 /ɪ/ 要从后元音跳到前元音，不自然
✅ "You are" → /juː ɑː/ → /uː/ 到 /ɑː/，两个后元音，连贯顺畅！

❌ "He am" → /hiː æm/ → 可以发，但不如...
✅ "He is" → /hiː ɪz/ → /iː/ 和 /ɪ/ 都是前高元音，自然衔接！

🎯 **规律：** 英语在数千年的演化中，自动选择了**最方便发音的组合**！

**日常对话中的证据——缩写更说明问题：**
• I am → I'm /aɪm/ — 一个音节搞定
• You are → You're /jɔː/ — 一个音节
• He is → He's /hiːz/ — 一个音节
• She is → She's /ʃiːz/ — 一个音节

这些缩写在口语中使用率超过90%！因为人类的嘴巴永远在追求"最省力"。'''),

        LessonStep(id: 'u22_L1_s2', type: StepType.readAloud, instruction: '节奏朗读：Be 动词',
          content: '''跟读，感受自然的语音流：

I'm a student. /aɪm ə ˈstjuːdnt/
You're my friend. /jɔː maɪ frend/
He's very tall. /hiːz ˈveri tɔːl/
She's a teacher. /ʃiːz ə ˈtiːtʃə/
It's really cold. /ɪts ˈriːli kəʊld/
We're going home. /wɪə ˈgəʊɪŋ həʊm/
They're always late. /ðeər ˈɔːlweɪz leɪt/

注意：缩写形式是真正自然的英语！完整形式只在强调时使用：
"I AM ready!" (强调：我真的准备好了！)'''),
      ],
    ),

    Lesson(
      id: 'u22_L2', unitId: 'u22', order: 2,
      titleCn: '-s 和 -ed 的三种发音', titleEn: '-s and -ed Pronunciation Rules',
      description: '发音决定语法后缀的形状',
      type: LessonType.practice, estimatedMinutes: 8,
      didYouKnowText: '语言学家 Zwicky (1975) 发现，英语 -s 和 -ed 的三种发音变体并非随意——它们完全由前一个音决定。规则简单到可以用一句话概括：清音后跟清音，浊音后跟浊音。这在语言学上叫做"语音条件变体"（Phonological Conditioning），是语音影响语法的最典型例子。',
      didYouKnowSource: 'Zwicky (1975), Settling on an underlying form: the English inflectional endings',
      steps: [
        LessonStep(id: 'u22_L2_s1', type: StepType.text, instruction: '第三人称 -s 的三种发音',
          content: '''加了 -s/-es 后，发音有三种可能——关键看最后一个辅音！

**规则1️⃣ 前面是清辅音 → 加 /s/**
清音后接清音，声带始终不振动：
• works /wɜːks/, helps /helps/, makes /meɪks/
• looks /lʊks/, takes /teɪks/, stops /stɒps/
• laughs /lɑːfs/, eats /iːts/

**规则2️⃣ 前面是浊辅音或元音 → 加 /z/**
浊音后接浊音，声带一直在振动：
• runs /rʌnz/, plays /pleɪz/, comes /kʌmz/
• goes /gəʊz/, sees /siːz/, does /dʌz/
• lives /lɪvz/, reads /riːdz/, seems /siːmz/

**规则3️⃣ 前面是 /s/,/z/,/ʃ/,/ʒ/,/tʃ/,/dʒ/ → 加 /ɪz/**
（因为直接加 /s/ 或 /z/ 会连在一起听不清）
• watches /ˈwɒtʃɪz/, teaches /ˈtiːtʃɪz/
• washes /ˈwɒʃɪz/, rises /ˈraɪzɪz/
• judges /ˈdʒʌdʒɪz/, uses /ˈjuːzɪz/

🎯 **口诀：清接清，浊接浊，嘶嘶声后加 /ɪz/！**'''),

        LessonStep(id: 'u22_L2_s2', type: StepType.text, instruction: '过去式 -ed 的三种发音',
          content: '''同样的原理！-ed 也有三种发音：

**规则1️⃣ 前面是清辅音 → 发 /t/**
• worked /wɜːkt/, helped /helpt/, stopped /stɒpt/
• looked /lʊkt/, cooked /kʊkt/, washed /wɒʃt/
• laughed /lɑːft/, kicked /kɪkt/

**规则2️⃣ 前面是浊辅音或元音 → 发 /d/**
• played /pleɪd/, called /kɔːld/, used /juːzd/
• lived /lɪvd/, opened /ˈəʊpənd/
• rained /reɪnd/, cleaned /kliːnd/

**规则3️⃣ 前面是 /t/ 或 /d/ → 发 /ɪd/**
（因为 /t/+/t/ 或 /d/+/d/ 发不出来）
• wanted /ˈwɒntɪd/, started /ˈstɑːtɪd/
• needed /ˈniːdɪd/, added /ˈædɪd/
• decided /dɪˈsaɪdɪd/, waited /ˈweɪtɪd/

⚡ **核心洞见：** 这不是语法规则——这是你的嘴巴自动选择的最省力发音方式！
试一下：want + /d/ = wantd → 舌头根本来不及从 /t/ 跳到 /d/
所以必须加 /ɪ/ 做缓冲 → wanted /ˈwɒntɪd/ ✅'''),

        LessonStep(id: 'u22_L2_s3', type: StepType.recordAndCompare, instruction: '分类朗读练习',
          content: '''跟读，注意区分三种发音：

/s/ 组：works, helps, makes, stops, eats, laughs
/z/ 组：runs, plays, goes, lives, reads, comes
/ɪz/ 组：watches, teaches, washes, judges, uses

/t/ 组：worked, stopped, looked, washed, laughed
/d/ 组：played, called, lived, opened, rained
/ɪd/ 组：wanted, needed, started, decided, added

混合句子：
"She watched and waited, then decided to leave."
 /wɒtʃt/ /ˈweɪtɪd/ /dɪˈsaɪdɪd/ /liːvd/'''),

        LessonStep(id: 'u22_L2_s4', type: StepType.multipleChoice, instruction: '-ed 发音判断',
          content: 'played 中的 -ed 怎么发音？',
          metadata: {
            'options': ['/t/', '/d/', '/ɪd/'],
            'correct': 1,
            'explanation': 'play 以元音 /eɪ/ 结尾，元音是浊音，所以 -ed 发 /d/。played = /pleɪd/。',
          }),
      ],
    ),
  ];

  /// 获取指定单元的课程列表
  static const Set<String> _releasedUnitIds = {
    'u1',
    'u2',
    'u3',
    'u4',
    'u5',
    'u6',
    'u7',
    'u8',
    'u9',
    'u10',
  };

  static final Map<String, List<Lesson>> _authoredLessonsByUnit = {
    'u1': u1Lessons,
    'u2': u2Lessons,
    'u3': u3Lessons,
    'u4': u4Lessons,
    'u5': u5Lessons,
    'u6': u6Lessons,
    'u7': u7Lessons,
    'u8': u8Lessons,
    'u9': u9Lessons,
    'u10': u10Lessons,
    'u12': u12Lessons,
    'u22': u22Lessons,
  };

  static final Map<String, Lesson> _lessonsById = {
    for (final lessons in _authoredLessonsByUnit.values)
      for (final lesson in lessons) lesson.id: lesson,
  };

  static List<Lesson> getLessonsForUnit(String unitId) {
    return _authoredLessonsByUnit[unitId] ?? _generatePlaceholderLessons(unitId);
  }

  static Lesson? getLessonById(String lessonId) => _lessonsById[lessonId];

  static bool hasAuthoredLessons(String unitId) => _authoredLessonsByUnit.containsKey(unitId);

  static int getAuthoredLessonCount(String unitId) => _authoredLessonsByUnit[unitId]?.length ?? 0;

  static bool isReleasedUnit(String unitId) => _releasedUnitIds.contains(unitId);

  static List<Lesson> _generatePlaceholderLessons(String unitId) {
    return List.generate(3, (i) => Lesson(
      id: '${unitId}_L${i + 1}',
      unitId: unitId,
      order: i + 1,
      titleCn: '课程 ${i + 1}',
      titleEn: 'Lesson ${i + 1}',
      description: '内容持续更新中...',
      type: LessonType.values[i % LessonType.values.length],
      steps: [
        LessonStep(
          id: '${unitId}_L${i + 1}_s1',
          type: StepType.text,
          instruction: '内容更新中',
          content: '该课程内容正在制作中，敬请期待！\n\n已完成的课程包括：\n• 板块1 发音基础（单元1-4）\n• 板块2 前元音 /iː/ /ɪ/ /e/ /æ/\n• 板块2 中央元音 /ɜː/ /ə/ /ʌ/\n• 板块3 摩擦音 /θ/ /ð/ /v/ /w/\n• 板块5 Be 动词与发音 / -s -ed 规则',
        ),
      ],
    ));
  }
}
