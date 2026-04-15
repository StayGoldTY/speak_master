import '../models/lesson.dart';

final List<Lesson> u2Lessons = [
  _lesson(
    id: 'u2_L1',
    unitId: 'u2',
    order: 1,
    titleCn: '呼气、阻碍与共鸣',
    titleEn: 'From Air to Sound',
    description: '理解声音从肺部到口腔前沿的完整路线',
    type: LessonType.theory,
    didYouKnowText: '正常说话时，我们几乎总是使用呼气而不是吸气。语言的差异，更多来自气流在哪里受阻、是否带振动，以及共鸣空间如何变化。',
    didYouKnowSource: 'Peter Roach, English Phonetics and Phonology',
    steps: [
      _textStep(
        'u2_L1_s1',
        '看：声音的旅行路线',
        '''可以把一次发音想成三件事同时发生：

1. 肺部把气流推出去。
2. 喉部决定声带振动还是不振动。
3. 口腔和鼻腔负责“塑形”，把同一股气流做成不同的音。

当你说 /s/ 时，重点在前部摩擦；说 /m/ 时，重点在鼻腔通路；说 /ɑː/ 时，重点则是口腔后部的开放共鸣。''',
      ),
      _readAloudStep(
        'u2_L1_s2',
        '说：用身体感受三个环节',
        '''按顺序做三组小练习：

- 先长长地呼出 “ssss”，感觉气流持续往前走。
- 再说 “zzzz”，摸一摸喉咙，确认声带开始振动。
- 最后说 “mmm”，感受鼻腔和嘴唇一起参与。''',
      ),
      _multipleChoiceStep(
        'u2_L1_s3',
        '辨：哪一项最直接决定清音和浊音？',
        '在其他位置相近时，哪一个部位最直接决定 /s/ 和 /z/ 的核心差异？',
        const ['嘴唇的大小', '声带是否振动', '下巴张开的角度', '舌尖是否外伸'],
        1,
        '清浊对立的核心是声带是否振动。/s/ 没有振动，/z/ 有振动。',
      ),
    ],
  ),
  _lesson(
    id: 'u2_L2',
    unitId: 'u2',
    order: 2,
    titleCn: '送气不是浊音',
    titleEn: 'Aspiration Is Not Voicing',
    description: '区分汉语里的送气感和英语里的清浊概念',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '很多中文母语者把英语 /p/ /b/、/t/ /d/、/k/ /g/ 理解成“送气和不送气”，这会导致听得懂、却总是说不准。',
    didYouKnowSource: 'J. C. Catford, A Practical Introduction to Phonetics',
    steps: [
      _textStep(
        'u2_L2_s1',
        '看：英语和汉语的关注点不一样',
        '''汉语里，大家更容易注意到送气强不强。
英语里，/p/ 和 /b/ 的根本区别是“清”和“浊”，不是单纯的气流大小。

试着比较：
- pin /pɪn/：词首通常送气明显
- spin /spɪn/：同样是 /p/，但几乎不送气

这说明“送气多少”会随位置变化，而音位身份不一定变。''',
      ),
      _recordStep(
        'u2_L2_s2',
        '说：对照练习 pin / spin',
        '''先慢读，再加快：

pin - spin
ten - stand
coat - skate

目标不是把 /b d g/ 说得很重，而是学会在相同口型里切换清浊与送气感。''',
        metadata: const {
          'pairs': ['pin|spin', 'ten|stand', 'coat|skate'],
          'note': '本阶段只提供自练录音，不做自动评分。',
        },
      ),
      _multipleChoiceStep(
        'u2_L2_s3',
        '辨：词首 /p/ 和 /b/ 的关键差别是什么？',
        '在英语词首，/p/ 和 /b/ 最核心的区别更接近下面哪一项？',
        const ['声带是否振动', '拼写是 p 还是 b', '元音长短', '嘴巴张得是否更大'],
        0,
        '英语里这组辅音的核心对立是清浊。送气常常伴随 /p/，但它不是唯一标准。',
      ),
    ],
  ),
  _lesson(
    id: 'u2_L3',
    unitId: 'u2',
    order: 3,
    titleCn: '鼻腔和口腔的分流',
    titleEn: 'Nasal and Oral Flow',
    description: '用软腭开关理解口音与鼻音的差别',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '英语里的 /m/ /n/ /ŋ/ 都属于鼻音，但它们不是“鼻子发声”，而是口腔通路暂时关闭、气流改走鼻腔。',
    didYouKnowSource: 'Ladefoged, A Course in Phonetics',
    steps: [
      _textStep(
        'u2_L3_s1',
        '看：软腭像一道闸门',
        '''当软腭抬起时，气流主要走口腔，形成大多数元音和辅音。
当软腭放下时，鼻腔通路打开，就会出现鼻音。

所以 /m/ 的关键不是“嘴唇闭上”这么简单，而是：
- 嘴唇闭合
- 口腔出口被挡住
- 鼻腔仍然保持通气''',
      ),
      _recordStep(
        'u2_L3_s2',
        '说：鼻音共鸣练习',
        '''先拖长鼻音，再进入单词：

mmm -> me -> moon
nnn -> no -> nine
ŋŋŋ -> sing -> long

每组都先感受鼻腔震动，再进入完整单词。''',
        metadata: const {
          'focus': ['m', 'n', 'ŋ'],
          'note': '注意不要把 /ŋ/ 读成 /ng/ 两个音。',
        },
      ),
      _multipleChoiceStep(
        'u2_L3_s3',
        '辨：哪个音最能体现鼻腔通路打开？',
        '下面哪一个音在发音时一定依赖鼻腔通路？',
        const ['/s/', '/m/', '/ɑː/', '/f/'],
        1,
        '/m/ 是典型鼻音。气流不是从嘴里直接出来，而是转向鼻腔。',
      ),
    ],
  ),
];

final List<Lesson> u3Lessons = [
  _lesson(
    id: 'u3_L1',
    unitId: 'u3',
    order: 1,
    titleCn: '44 个音素怎么分区',
    titleEn: 'The 44-Sound Map',
    description: '把英语音素先按功能分清，再谈细节',
    type: LessonType.theory,
    didYouKnowText: '学习发音时，先建立“地图感”通常比一开始死磕单个难音更有效，因为你会知道每个音和谁接近、和谁容易混淆。',
    didYouKnowSource: 'Adrian Underhill, Sound Foundations',
    steps: [
      _textStep(
        'u3_L1_s1',
        '看：先按大类记忆',
        '''第一层先分三组：

- 元音：靠口腔开合、舌位高低前后形成
- 辅音：靠不同位置的阻碍与摩擦形成
- 超音段：重音、节奏、语调这些跨越单个音素的特征

第二层再记高风险对比：
/iː/ vs /ɪ/
/e/ vs /æ/
/θ/ vs /s/
/ð/ vs /d/
/v/ vs /w/
/r/ vs /l/''',
      ),
      _readAloudStep(
        'u3_L1_s2',
        '说：用“分类朗读”建立地图感',
        '''请按类别朗读，而不是按字母顺序：

元音：/iː/ /ɪ/ /e/ /æ/
辅音：/p/ /b/ /t/ /d/
难点：/θ/ /ð/ /v/ /w/ /r/ /l/

把同类音放在一起读，更容易建立边界感。''',
      ),
      _multipleChoiceStep(
        'u3_L1_s3',
        '辨：下面哪一组全部是元音？',
        '选出一组全部属于元音的符号。',
        const ['/p/ /t/ /k/', '/iː/ /ɪ/ /æ/', '/m/ /n/ /ŋ/', '/θ/ /ð/ /s/'],
        1,
        '/iː/ /ɪ/ /æ/ 都是元音，其余几组包含的都是辅音。',
      ),
    ],
  ),
  _lesson(
    id: 'u3_L2',
    unitId: 'u3',
    order: 2,
    titleCn: '最小对立体为什么重要',
    titleEn: 'Why Minimal Pairs Matter',
    description: '理解一个小小音差如何改变整词意义',
    type: LessonType.discrimination,
    estimatedMinutes: 7,
    didYouKnowText: '最小对立体训练并不是“考试题型”，而是在帮大脑重新建立新的声音边界，让你不再把两种不同的英语声音归成同一类。',
    didYouKnowSource: 'Ann Baker, Ship or Sheep?',
    steps: [
      _textStep(
        'u3_L2_s1',
        '看：一对词，只差一个音',
        '''最小对立体指的是：两个词只有一个音不同，但意义不同。

例如：
ship /ʃɪp/ vs sheep /ʃiːp/
full /fʊl/ vs fool /fuːl/
think /θɪŋk/ vs sink /sɪŋk/

如果你的耳朵没有把这条边界听出来，嘴巴通常也很难稳定说出来。''',
      ),
      _recordStep(
        'u3_L2_s2',
        '说：跟读三组高频对比',
        '''每组先慢读，再连读：

ship - sheep
full - fool
think - sink

建议一组读四遍，重点感受口型和舌位的切换。''',
        metadata: const {
          'pairs': ['ship|sheep', 'full|fool', 'think|sink'],
          'note': '本阶段建议先自录回听，再进入辨音练习。',
        },
      ),
      _minimalPairQuizStep(
        'u3_L2_s3',
        '辨：观察这些最小对立体',
        const [
          {'word1': 'ship', 'word2': 'sheep', 'phoneme1': 'ɪ', 'phoneme2': 'iː'},
          {'word1': 'full', 'word2': 'fool', 'phoneme1': 'ʊ', 'phoneme2': 'uː'},
          {'word1': 'think', 'word2': 'sink', 'phoneme1': 'θ', 'phoneme2': 's'},
        ],
      ),
    ],
  ),
  _lesson(
    id: 'u3_L3',
    unitId: 'u3',
    order: 3,
    titleCn: '中国学习者高频混淆图',
    titleEn: 'A Chinese Learner Error Map',
    description: '先抓高频错误，再决定练习顺序',
    type: LessonType.theory,
    didYouKnowText: '最常见的发音问题往往不是“不会发”，而是母语系统会自动把两个英语音归为一类，导致说和听一起偏掉。',
    didYouKnowSource: 'Swan & Smith, Learner English',
    steps: [
      _textStep(
        'u3_L3_s1',
        '看：先练最容易混的六组',
        '''对中文学习者来说，优先级通常是：

1. /iː/ vs /ɪ/
2. /e/ vs /æ/
3. /uː/ vs /ʊ/
4. /θ/ vs /s/
5. /ð/ vs /d/
6. /v/ vs /w/

这些对比既高频，又直接影响理解和自然度。''',
      ),
      _readAloudStep(
        'u3_L3_s2',
        '说：把高频难点放进句子里',
        '''请大声朗读：

She sits in the seat.
That thing is very thin.
The vet wore a warm vest.

句子训练比单词训练更能暴露真实问题。''',
      ),
      _multipleChoiceStep(
        'u3_L3_s3',
        '辨：哪一组最依赖“舌尖伸出齿间”？',
        '下面哪一组对比最需要把舌尖真正放到齿间？',
        const ['/iː/ vs /ɪ/', '/θ/ vs /s/', '/uː/ vs /ʊ/', '/r/ vs /l/'],
        1,
        '/θ/ 和 /s/ 的关键差异之一，就是 /θ/ 需要把舌尖放到齿间，而 /s/ 不需要。',
      ),
    ],
  ),
];

final List<Lesson> u4Lessons = [
  _lesson(
    id: 'u4_L1',
    unitId: 'u4',
    order: 1,
    titleCn: '先读懂斜线、重音和长音',
    titleEn: 'Read the Symbols',
    description: '先掌握最常见的音标标记，再进入具体发音',
    type: LessonType.theory,
    didYouKnowText: 'IPA 不是“另一套拼写”，而是一套直接记录发音的工具。它最大的价值，是帮你绕开拼写误导。',
    didYouKnowSource: 'Sounds Right, British Council',
    steps: [
      _textStep(
        'u4_L1_s1',
        '看：三种最常见的标记',
        '''先记三件事就够用：

- / /：表示音标
- ˈ：表示主重音
- ː：表示长音

例如 teacher /ˈtiːtʃə/：
主重音在第一音节，元音 /iː/ 是长音。''',
      ),
      _audioStep(
        'u4_L1_s2',
        '听：把符号和词连起来',
        '''请对照阅读这些例子：

she /ʃiː/
ship /ʃɪp/
banana /bəˈnɑːnə/

本阶段没有内置标准音频，请先看符号，再自己尝试朗读。''',
      ),
      _multipleChoiceStep(
        'u4_L1_s3',
        '辨：符号 ː 表示什么？',
        '在英语音标里，元音后的 ː 一般表示什么？',
        const ['长音或时值更长', '要升调', '要鼻化', '要更轻读'],
        0,
        'ː 常用来标记长音或更长的时值，例如 /iː/、/ɑː/。',
      ),
    ],
  ),
  _lesson(
    id: 'u4_L2',
    unitId: 'u4',
    order: 2,
    titleCn: '元音图不是地图，是坐标',
    titleEn: 'Use the Vowel Chart',
    description: '用舌位高低前后理解元音之间的距离',
    type: LessonType.theory,
    didYouKnowText: '元音图看起来像一张几何图，但它本质上是在提示舌位和口腔开合，而不是要求你死记每个符号的位置。',
    didYouKnowSource: 'Adrian Underhill, Sound Foundations',
    steps: [
      _textStep(
        'u4_L2_s1',
        '看：用“高低前后”理解元音',
        '''元音图最重要的是三个方向：

- 高 vs 低：下巴张开多少
- 前 vs 后：舌面更多靠前还是靠后
- 紧 vs 松：肌肉控制是否更紧致

所以 /iː/、/ɪ/、/e/、/æ/ 其实是一条逐渐向下、向开的路线。''',
      ),
      _recordStep(
        'u4_L2_s2',
        '说：顺着坐标一路滑下来',
        '''请慢慢朗读这串元音和词：

/iː/ sheep
/ɪ/ ship
/e/ bed
/æ/ bad

不要跳读，让嘴巴和舌位一步一步移动。''',
        metadata: const {
          'focus': ['iː', 'ɪ', 'e', 'æ'],
          'note': '这组练习最适合配合镜子完成。',
        },
      ),
      _multipleChoiceStep(
        'u4_L2_s3',
        '辨：哪一对通常需要把嘴巴张得更大？',
        '下面哪一对元音对比里，后一项通常需要明显更大的开口？',
        const ['/iː/ -> /ɪ/', '/ɪ/ -> /e/', '/e/ -> /æ/', '/uː/ -> /ʊ/'],
        2,
        '/e/ 到 /æ/ 时，下巴通常需要继续下拉，开口更明显。',
      ),
    ],
  ),
  _lesson(
    id: 'u4_L3',
    unitId: 'u4',
    order: 3,
    titleCn: '用音标猜读生词',
    titleEn: 'Decode New Words with IPA',
    description: '遇到陌生单词时，先找重音和元音核',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '很多学习者把 IPA 当成“查完就算了”的信息，但真正高效的方法，是用它来预测重音和元音质量，再回到朗读里验证。',
    didYouKnowSource: 'Cambridge Dictionary Pronunciation Guide',
    steps: [
      _textStep(
        'u4_L3_s1',
        '看：猜读时先抓两个点',
        '''看到音标后，优先找：

1. 主重音落在哪个音节
2. 每个重读音节里的核心元音是什么

例如：
hotel /həʊˈtel/
important /ɪmˈpɔːtənt/
computer /kəmˈpjuːtə/''',
      ),
      _readAloudStep(
        'u4_L3_s2',
        '说：按音标朗读生词',
        '''请根据音标慢读，再正常读：

hotel /həʊˈtel/
important /ɪmˈpɔːtənt/
computer /kəmˈpjuːtə/

关键不是一次读得很快，而是先把重音放对。''',
      ),
      _multipleChoiceStep(
        'u4_L3_s3',
        '辨：hotel 的主重音在哪里？',
        '根据 /həʊˈtel/，hotel 的主重音落在哪个部分？',
        const ['ho-', '-tel', '两部分一样重', '这个词没有重音'],
        1,
        '主重音符号 ˈ 出现在 /tel/ 前面，所以 hotel 的重音在后一个音节。',
      ),
    ],
  ),
];

final List<Lesson> u7Lessons = [
  _lesson(
    id: 'u7_L1',
    unitId: 'u7',
    order: 1,
    titleCn: '/uː/ 和 /ʊ/：紧一点，松一点',
    titleEn: 'Tense vs Relaxed u',
    description: '区分长 /uː/ 和短 /ʊ/ 的嘴唇与舌位差别',
    type: LessonType.practice,
    estimatedMinutes: 7,
    didYouKnowText: '很多学习者把 /uː/ 和 /ʊ/ 都读成汉语“乌”，问题通常不在“长短”，而在于嘴唇收圆程度和舌位是否够高够后。',
    didYouKnowSource: 'Ann Baker, Ship or Sheep?',
    steps: [
      _textStep(
        'u7_L1_s1',
        '看：不要把两个音都读成“乌”',
        '''/uː/ 通常更紧、更长、嘴唇更明显收圆。
/ʊ/ 更短、更松、舌位略低，嘴唇动作也更轻。

对比：
food /fuːd/ vs foot /fʊt/
pool /puːl/ vs pull /pʊl/
Luke /luːk/ vs look /lʊk/''',
      ),
      _audioStep(
        'u7_L1_s2',
        '听：先看词，再自己读',
        '''请逐组对照阅读：

food - foot
pool - pull
Luke - look

当前阶段没有标准音频播放，建议先慢读、再录音回听。''',
      ),
      _recordStep(
        'u7_L1_s3',
        '说：最小对立体跟读',
        '''请按组跟读：

food - foot
pool - pull
Luke - look
fool - full''',
        metadata: const {
          'pairs': ['food|foot', 'pool|pull', 'Luke|look', 'fool|full'],
        },
      ),
    ],
  ),
  _lesson(
    id: 'u7_L2',
    unitId: 'u7',
    order: 2,
    titleCn: '/ɔː/ 和 /ɒ/：同样圆唇，不同开口',
    titleEn: 'Open the Back Vowels',
    description: '识别英式后元音里常见的一组开口差',
    type: LessonType.practice,
    estimatedMinutes: 7,
    didYouKnowText: '英式英语里 /ɔː/ 和 /ɒ/ 往往保持清晰对比，而不少美式口音会在部分词里表现出不同的合并或位移，所以听感可能和课本略有差别。',
    didYouKnowSource: 'Cambridge English Pronunciation in Use',
    steps: [
      _textStep(
        'u7_L2_s1',
        '看：两个音都圆，但 /ɔː/ 更稳更长',
        '''可以先记住一个简单版本：

- /ɔː/：更长、更稳，嘴唇保持圆形
- /ɒ/：更短、更开，下巴更容易落下

对比词：
port /pɔːt/ vs pot /pɒt/
short /ʃɔːt/ vs shock /ʃɒk/''',
      ),
      _recordStep(
        'u7_L2_s2',
        '说：对照朗读',
        '''请放慢速度，先拉开时值，再读整词：

port - pot
short - shock
law - lot''',
        metadata: const {
          'pairs': ['port|pot', 'short|shock', 'law|lot'],
          'note': '如果你的目标口音偏美式，可以把这课当作听辨边界训练。',
        },
      ),
      _multipleChoiceStep(
        'u7_L2_s3',
        '辨：哪一个更接近“长而稳”的后元音？',
        '在这组对比里，通常哪个音更长、更稳定？',
        const ['/ɒ/', '/ɔː/', '/ʊ/', '/æ/'],
        1,
        '/ɔː/ 一般时值更长，圆唇保持也更稳定。',
      ),
    ],
  ),
  _lesson(
    id: 'u7_L3',
    unitId: 'u7',
    order: 3,
    titleCn: '/ɑː/：把声音放到后面',
    titleEn: 'Deep Back a',
    description: '练习更开、更靠后的长元音 /ɑː/',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '/ɑː/ 对很多中文学习者来说难点不在记忆，而在于不敢把口腔后部真的打开，于是常被说得又短又浅。',
    didYouKnowSource: 'Rachel’s English Pronunciation Notes',
    steps: [
      _textStep(
        'u7_L3_s1',
        '看：声音不要停在嘴前面',
        '''发 /ɑː/ 时，注意三点：

- 下巴自然打开
- 舌位放低、略靠后
- 声音感觉从口腔后部出来

练习词：
car /kɑː/
father /ˈfɑːðə/
calm /kɑːm/''',
      ),
      _readAloudStep(
        'u7_L3_s2',
        '说：把 /ɑː/ 拉开',
        '''请先拖长元音，再进入整词：

ɑː - car
ɑː - father
ɑː - calm

最后读句子：
My father parked the car. ''',
      ),
      _multipleChoiceStep(
        'u7_L3_s3',
        '辨：/ɑː/ 的感觉更接近哪种描述？',
        '下面哪种描述更接近 /ɑː/ 的发音感觉？',
        const ['短、前、紧', '长、开、靠后', '高、前、扁嘴', '短、圆唇、靠前'],
        1,
        '/ɑː/ 通常是较长、较开、较靠后的元音。',
      ),
    ],
  ),
];

final List<Lesson> u8Lessons = [
  _lesson(
    id: 'u8_L1',
    unitId: 'u8',
    order: 1,
    titleCn: '/eɪ/：从 /e/ 滑向高位',
    titleEn: 'Build the /eɪ/ Glide',
    description: '练习最常见的上行双元音之一',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '双元音的难点不是把两个元音“拆开发两次”，而是让口型在一次气流里自然滑动。',
    didYouKnowSource: 'BBC Learning English, The Sounds of English',
    steps: [
      _textStep(
        'u8_L1_s1',
        '看：先稳住起点，再轻轻上滑',
        '''/eɪ/ 的起点接近 /e/，结束位置更靠近 /ɪ/。

不要读成两个分开的音节，也不要起点太高。

练习词：
day /deɪ/
make /meɪk/
late /leɪt/''',
      ),
      _recordStep(
        'u8_L1_s2',
        '说：用三组词练滑动感',
        '''请连续朗读：

day - make - late
say - take - name

每个词都要听见“起点 + 滑动”，而不是一口气压扁。''',
        metadata: const {
          'focus': ['eɪ'],
        },
      ),
      _multipleChoiceStep(
        'u8_L1_s3',
        '辨：/eɪ/ 的起点更接近哪个单元音？',
        '下面哪一个更接近 /eɪ/ 的起点？',
        const ['/e/', '/uː/', '/ɑː/', '/ɔː/'],
        0,
        '/eɪ/ 的起点更接近 /e/，然后再向更高的位置滑动。',
      ),
    ],
  ),
  _lesson(
    id: 'u8_L2',
    unitId: 'u8',
    order: 2,
    titleCn: '/aɪ/：先打开，再抬高',
    titleEn: 'Open Then Rise',
    description: '通过嘴巴路线练出 /aɪ/ 的动态感',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '/aɪ/ 如果起点不够开，常会被读得太像 /eɪ/；如果滑动不够明显，又会让整词听起来扁平、缺少英语感。',
    didYouKnowSource: 'English Pronunciation in Use',
    steps: [
      _textStep(
        'u8_L2_s1',
        '看：这条路线比 /eɪ/ 更大',
        '''/aɪ/ 的起点更开、更低，路线也更明显。

练习词：
time /taɪm/
five /faɪv/
light /laɪt/

可以先夸张一点，确保嘴巴真的经历“开 -> 合”的过程。''',
      ),
      _readAloudStep(
        'u8_L2_s2',
        '说：从单词到短句',
        '''请朗读：

time, five, light
I like white rice.

短句里要保持滑动感，不要回到单个汉语元音。''',
      ),
      _multipleChoiceStep(
        'u8_L2_s3',
        '辨：哪项更符合 /aɪ/？',
        '下面哪种描述更符合 /aɪ/ 的发音路径？',
        const ['从高位往低位落下', '从较开的位置滑向较高的位置', '全程保持一个固定元音', '必须圆唇开始'],
        1,
        '/aɪ/ 通常从较开较低的位置出发，再向较高位置滑动。',
      ),
    ],
  ),
  _lesson(
    id: 'u8_L3',
    unitId: 'u8',
    order: 3,
    titleCn: '/ɔɪ/：圆唇起步，向前收口',
    titleEn: 'Round Then Brighten',
    description: '掌握 /ɔɪ/ 的圆唇起点和前移终点',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '/ɔɪ/ 看似少见，但在 boy, voice, choice, enjoy 这些高频词里都很重要，一旦滑动不到位，口音感会很重。',
    didYouKnowSource: 'Sounds Right, British Council',
    steps: [
      _textStep(
        'u8_L3_s1',
        '看：先圆，再亮',
        '''/ɔɪ/ 的起点更圆、更靠后，结束位置更靠前、更明亮。

练习词：
boy /bɔɪ/
voice /vɔɪs/
choice /tʃɔɪs/''',
      ),
      _recordStep(
        'u8_L3_s2',
        '说：集中练三组高频词',
        '''请按顺序朗读：

boy - voice - choice
toy - join - enjoy

先保住圆唇起点，再把后半段滑清楚。''',
        metadata: const {
          'focus': ['ɔɪ'],
        },
      ),
      _readAloudStep(
        'u8_L3_s3',
        '说：把 /ɔɪ/ 放进句子里',
        '''朗读句子：

The boy enjoyed the noisy toy.

注意每个 /ɔɪ/ 都要有明显滑动，而不是变成单一元音。''',
      ),
    ],
  ),
];

final List<Lesson> u9Lessons = [
  _lesson(
    id: 'u9_L1',
    unitId: 'u9',
    order: 1,
    titleCn: '/əʊ/：不要一开始就太圆',
    titleEn: 'Build the /əʊ/ Glide',
    description: '练习从中性位置滑向圆唇后元音',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '很多学习者把 /əʊ/ 直接读成一个固定的 “o”，这样听起来会少了英语双元音的层次感。',
    didYouKnowSource: 'BBC Learning English, The Sounds of English',
    steps: [
      _textStep(
        'u9_L1_s1',
        '看：起点不要太满',
        '''/əʊ/ 的起点比较中性，终点才逐渐圆起。

练习词：
go /gəʊ/
home /həʊm/
open /ˈəʊpən/

不要一开始就把嘴巴收成圆圆的 “喔”。''',
      ),
      _recordStep(
        'u9_L1_s2',
        '说：从单词里练滑动',
        '''请朗读：

go - home - open
no - road - phone

先慢，再快，但都要保留滑动路线。''',
        metadata: const {
          'focus': ['əʊ'],
        },
      ),
      _multipleChoiceStep(
        'u9_L1_s3',
        '辨：/əʊ/ 更合理的路线是什么？',
        '下面哪种描述更适合 /əʊ/？',
        const ['一开始就完全圆唇', '从较中性的起点逐渐滑向圆唇后位', '必须从 /iː/ 开始', '全程保持嘴角外展'],
        1,
        '/əʊ/ 的关键是“先中性，后圆唇”，路线要听得出来。',
      ),
    ],
  ),
  _lesson(
    id: 'u9_L2',
    unitId: 'u9',
    order: 2,
    titleCn: '/aʊ/：嘴巴路线要明显',
    titleEn: 'The Route of /aʊ/',
    description: '从开口音滑向圆唇后位，练出清晰路径',
    type: LessonType.practice,
    estimatedMinutes: 6,
    didYouKnowText: '/aʊ/ 的难点和 /aɪ/ 类似，都在“路线感”。如果路线太短，now 和 no 这类词的边界会开始模糊。',
    didYouKnowSource: 'English Pronunciation in Use',
    steps: [
      _textStep(
        'u9_L2_s1',
        '看：先张开，再收圆',
        '''/aʊ/ 的起点较开，终点向后、向圆唇方向移动。

练习词：
now /naʊ/
house /haʊs/
sound /saʊnd/''',
      ),
      _readAloudStep(
        'u9_L2_s2',
        '说：把 /aʊ/ 放进短句',
        '''请朗读：

now, house, sound
The house is loud now.

每次都要让嘴巴经历“开 -> 收”的路线。''',
      ),
      _multipleChoiceStep(
        'u9_L2_s3',
        '辨：/aʊ/ 的结尾更接近哪种动作？',
        '在 /aʊ/ 的后半段，嘴唇动作通常更接近哪种描述？',
        const ['更圆一些', '更扁一些', '完全不动', '更靠前更展开'],
        0,
        '/aʊ/ 的后半段会逐渐向更圆、偏后的位置靠近。',
      ),
    ],
  ),
  _lesson(
    id: 'u9_L3',
    unitId: 'u9',
    order: 3,
    titleCn: '中心双元音速览',
    titleEn: 'Centering Diphthongs',
    description: '认识 /ɪə/、/eə/、/ʊə/ 的核心感觉与常见词',
    type: LessonType.theory,
    estimatedMinutes: 6,
    didYouKnowText: '中心双元音在英式英语里更常被明确保留；在其他口音中，它们可能发生简化、合并或质量变化，所以要把它们当成“听说边界”来认识。',
    didYouKnowSource: 'Peter Roach, English Phonetics and Phonology',
    steps: [
      _textStep(
        'u9_L3_s1',
        '看：什么叫“滑向中心”？',
        '''所谓中心双元音，可以先理解成：

- /ɪə/：near, here
- /eə/：hair, chair
- /ʊə/：tour, pure

它们的后半段都朝向更居中的元音感觉，而不是一路保持在前或后。''',
      ),
      _audioStep(
        'u9_L3_s2',
        '听：先对照词例建立印象',
        '''请逐词观察并朗读：

near /nɪə/
hair /heə/
tour /tʊə/

如果你的目标口音不常保留这些对比，也建议先把它们作为辨音素材记住。''',
      ),
      _multipleChoiceStep(
        'u9_L3_s3',
        '辨：下面哪一个词最适合用 /eə/ 练习？',
        '哪一个词最适合作为 /eə/ 的入门练习？',
        const ['hair', 'tour', 'food', 'ship'],
        0,
        'hair 是典型的 /eə/ 练习词；tour 更接近 /ʊə/。',
      ),
    ],
  ),
];

final List<Lesson> u10Lessons = [
  _lesson(
    id: 'u10_L1',
    unitId: 'u10',
    order: 1,
    titleCn: '前后元音快速切换',
    titleEn: 'Front-to-Back Drill',
    description: '把前元音和后元音放到同一轮训练里切换',
    type: LessonType.practice,
    estimatedMinutes: 7,
    didYouKnowText: '真正影响自然度的，往往不是你能不能单独发好一个元音，而是你能不能在连续说话时快速切换不同元音位置。',
    didYouKnowSource: 'Adrian Underhill, Sound Foundations',
    steps: [
      _textStep(
        'u10_L1_s1',
        '看：复习不是回顾，是切换训练',
        '''这节的目标不是学新音，而是快速切换：

/iː/ -> /ɪ/ -> /e/ -> /æ/
/uː/ -> /ʊ/ -> /ɔː/ -> /ɑː/

当你能在一口气里切换位置，元音系统才算真正开始稳定。''',
      ),
      _recordStep(
        'u10_L1_s2',
        '说：前后元音连读',
        '''请按顺序朗读：

sheep - ship - bed - bad
food - foot - port - car

先分组，再把两组连起来。''',
        metadata: const {
          'pairs': ['sheep|ship|bed|bad', 'food|foot|port|car'],
        },
      ),
      _minimalPairQuizStep(
        'u10_L1_s3',
        '辨：回顾这些关键边界',
        const [
          {'word1': 'sheep', 'word2': 'ship', 'phoneme1': 'iː', 'phoneme2': 'ɪ'},
          {'word1': 'bed', 'word2': 'bad', 'phoneme1': 'e', 'phoneme2': 'æ'},
          {'word1': 'food', 'word2': 'foot', 'phoneme1': 'uː', 'phoneme2': 'ʊ'},
        ],
      ),
    ],
  ),
  _lesson(
    id: 'u10_L2',
    unitId: 'u10',
    order: 2,
    titleCn: '长短与松紧复盘',
    titleEn: 'Length and Tension Review',
    description: '重新梳理“长短”背后的口型与肌肉控制',
    type: LessonType.theory,
    estimatedMinutes: 6,
    didYouKnowText: '把所有问题都归结为“长短”会让训练失真，因为许多元音差异同时涉及舌位、开口、紧张度和嘴唇形状。',
    didYouKnowSource: 'Ann Baker, Ship or Sheep?',
    steps: [
      _textStep(
        'u10_L2_s1',
        '看：别把所有对比都理解成“拖长一点”',
        '''复习三组典型误区：

- /iː/ vs /ɪ/：不只是长短，也有舌位和紧张度差异
- /uː/ vs /ʊ/：不只是长短，也有嘴唇收圆差异
- /ɔː/ vs /ɒ/：还涉及开口和稳定度

所以复盘时，要一起看“路线 + 口型 + 时值”。''',
      ),
      _readAloudStep(
        'u10_L2_s2',
        '说：把三组放进一句话',
        '''请朗读：

She put good food on the small pot.

这句里同时包含 /iː/、/ʊ/、/uː/、/ɔː/、/ɒ/ 附近的切换感。''',
      ),
      _multipleChoiceStep(
        'u10_L2_s3',
        '辨：下面哪项说法更准确？',
        '关于英语元音对比，下面哪项更准确？',
        const ['只要拖长就能解决所有问题', '只要记拼写，不必看口型', '元音差异常常同时涉及时值、舌位和口型', '所有元音都可以用汉语元音直接替代'],
        2,
        '英语元音差异通常是多维度的，时值只是其中一个维度。',
      ),
    ],
  ),
  _lesson(
    id: 'u10_L3',
    unitId: 'u10',
    order: 3,
    titleCn: '元音段落挑战',
    titleEn: 'Vowel Paragraph Challenge',
    description: '用一小段朗读把前面学过的元音串起来',
    type: LessonType.practice,
    estimatedMinutes: 8,
    didYouKnowText: '段落朗读最大的价值，是让你暴露“单词会、句子不会”的问题。真正的稳定发音，必须能在连续语流里保持下来。',
    didYouKnowSource: 'English Pronunciation in Use',
    steps: [
      _textStep(
        'u10_L3_s1',
        '看：先扫一遍目标元音',
        '''请先圈出你最容易失守的元音，再开始朗读。

建议重点关注：
/iː/ /ɪ/ /e/ /æ/ /uː/ /ʊ/ /ɔː/ /ɑː/ /eɪ/ /aɪ/ /əʊ/ /aʊ/''',
      ),
      _readAloudStep(
        'u10_L3_s2',
        '说：朗读本段',
        '''Kate arrived late, smiled at the boy, and chose a warm room near the road. She put her book on the small table, took a deep breath, and slowly read the lines aloud.

第一次慢读，第二次正常读。''',
      ),
      _recordStep(
        'u10_L3_s3',
        '录：完成本单元收尾挑战',
        '''完成一次整段录音，然后回听这三个问题：

1. 哪一组元音最容易混？
2. 哪些双元音被你读扁了？
3. 哪些词一进句子就丢了口型？''',
        metadata: const {
          'note': '本阶段请以自查清单为主，自动评测将在后续阶段接入。',
        },
      ),
    ],
  ),
];

Lesson _lesson({
  required String id,
  required String unitId,
  required int order,
  required String titleCn,
  required String titleEn,
  required String description,
  required LessonType type,
  required List<LessonStep> steps,
  String? didYouKnowText,
  String? didYouKnowSource,
  int estimatedMinutes = 5,
}) {
  return Lesson(
    id: id,
    unitId: unitId,
    order: order,
    titleCn: titleCn,
    titleEn: titleEn,
    description: description,
    type: type,
    estimatedMinutes: estimatedMinutes,
    didYouKnowText: didYouKnowText,
    didYouKnowSource: didYouKnowSource,
    steps: steps,
  );
}

LessonStep _textStep(String id, String instruction, String content) {
  return LessonStep(
    id: id,
    type: StepType.text,
    instruction: instruction,
    content: content,
  );
}

LessonStep _audioStep(String id, String instruction, String content) {
  return LessonStep(
    id: id,
    type: StepType.audio,
    instruction: instruction,
    content: content,
  );
}

LessonStep _recordStep(
  String id,
  String instruction,
  String content, {
  Map<String, dynamic>? metadata,
}) {
  return LessonStep(
    id: id,
    type: StepType.recordAndCompare,
    instruction: instruction,
    content: content,
    metadata: metadata,
  );
}

LessonStep _minimalPairQuizStep(
  String id,
  String instruction,
  List<Map<String, String>> pairs,
) {
  return LessonStep(
    id: id,
    type: StepType.minimalPairQuiz,
    instruction: instruction,
    metadata: {'pairs': pairs},
  );
}

LessonStep _multipleChoiceStep(
  String id,
  String instruction,
  String content,
  List<String> options,
  int correct,
  String explanation,
) {
  return LessonStep(
    id: id,
    type: StepType.multipleChoice,
    instruction: instruction,
    content: content,
    metadata: {
      'options': options,
      'correct': correct,
      'explanation': explanation,
    },
  );
}

LessonStep _readAloudStep(String id, String instruction, String content) {
  return LessonStep(
    id: id,
    type: StepType.readAloud,
    instruction: instruction,
    content: content,
  );
}
