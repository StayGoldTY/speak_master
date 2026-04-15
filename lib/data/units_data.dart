import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/unit.dart';

class UnitsData {
  UnitsData._();

  static const List<LearningBlock> blocks = [
    LearningBlock(
      id: 'block_1',
      type: BlockType.foundation,
      titleCn: '发音基础',
      titleEn: 'Foundation',
      subtitle: '先认识口腔、气流和音素地图',
      unitCount: 4,
      color: AppColors.primary,
      icon: Icons.mic,
    ),
    LearningBlock(
      id: 'block_2',
      type: BlockType.vowels,
      titleCn: '元音训练',
      titleEn: 'Vowels',
      subtitle: '把最容易混淆的元音边界练清楚',
      unitCount: 6,
      color: AppColors.vowelColor,
      icon: Icons.music_note,
    ),
    LearningBlock(
      id: 'block_3',
      type: BlockType.consonants,
      titleCn: '辅音攻坚',
      titleEn: 'Consonants',
      subtitle: '处理 th、v/w、r/l 等常见难点',
      unitCount: 6,
      color: AppColors.consonantColor,
      icon: Icons.graphic_eq,
    ),
    LearningBlock(
      id: 'block_4',
      type: BlockType.suprasegmental,
      titleCn: '超音段特征',
      titleEn: 'Suprasegmentals',
      subtitle: '重音、节奏、弱读与语调',
      unitCount: 5,
      color: AppColors.suprasegmentalColor,
      icon: Icons.waves,
    ),
    LearningBlock(
      id: 'block_5',
      type: BlockType.grammarPronunciation,
      titleCn: '发音驱动语法',
      titleEn: 'Grammar via Sound',
      subtitle: '从声音规律理解语法形式变化',
      unitCount: 7,
      color: AppColors.grammarColor,
      icon: Icons.menu_book,
    ),
    LearningBlock(
      id: 'block_6',
      type: BlockType.phonics,
      titleCn: '自然拼读',
      titleEn: 'Phonics',
      subtitle: '让看到单词就更容易开口',
      unitCount: 4,
      color: AppColors.phonicsColor,
      icon: Icons.abc,
    ),
  ];

  static const List<LearningUnit> units = [
    LearningUnit(id: 'u1', blockId: 'block_1', order: 1, titleCn: '口腔探险', titleEn: 'Mouth Explorer', description: '认识发音器官和发声位置', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u2', blockId: 'block_1', order: 2, titleCn: '气流的旅程', titleEn: 'Air Journey', description: '理解气流、送气与发音动作', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u3', blockId: 'block_1', order: 3, titleCn: '音素地图', titleEn: 'Phoneme Map', description: '建立英语音素与最小对立体意识', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u4', blockId: 'block_1', order: 4, titleCn: 'IPA 快速上手', titleEn: 'IPA Quick Start', description: '学会读音标并对应到真实发音', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u5', blockId: 'block_2', order: 5, titleCn: '前元音四兄弟', titleEn: 'Front Vowels', description: '/iː/ /ɪ/ /e/ /æ/', lessonCount: 3, targetPhonemes: ['v_iː', 'v_ɪ', 'v_e', 'v_æ']),
    LearningUnit(id: 'u6', blockId: 'block_2', order: 6, titleCn: '中央元音', titleEn: 'Central Vowels', description: '/ɜː/ /ə/ /ʌ/', lessonCount: 3, targetPhonemes: ['v_ɜː', 'v_ə', 'v_ʌ']),
    LearningUnit(id: 'u7', blockId: 'block_2', order: 7, titleCn: '后元音', titleEn: 'Back Vowels', description: '/uː/ /ʊ/ /ɔː/ /ɒ/ /ɑː/', lessonCount: 3, targetPhonemes: ['v_uː', 'v_ʊ', 'v_ɔː', 'v_ɒ', 'v_ɑː']),
    LearningUnit(id: 'u8', blockId: 'block_2', order: 8, titleCn: '双元音上半区', titleEn: 'Diphthongs I', description: '/eɪ/ /aɪ/ /ɔɪ/', lessonCount: 3, targetPhonemes: ['v_eɪ', 'v_aɪ', 'v_ɔɪ']),
    LearningUnit(id: 'u9', blockId: 'block_2', order: 9, titleCn: '双元音下半区', titleEn: 'Diphthongs II', description: '/əʊ/ /aʊ/ /ɪə/ /eə/ /ʊə/', lessonCount: 3, targetPhonemes: ['v_əʊ', 'v_aʊ', 'v_ɪə', 'v_eə', 'v_ʊə']),
    LearningUnit(id: 'u10', blockId: 'block_2', order: 10, titleCn: '元音马拉松', titleEn: 'Vowel Marathon', description: '把前 6 个元音单元串起来复习', lessonCount: 3, targetPhonemes: [], badgeId: 'vowel_master'),
    LearningUnit(id: 'u11', blockId: 'block_3', order: 11, titleCn: '爆破音', titleEn: 'Plosives', description: '/p/ /b/ /t/ /d/ /k/ /g/', lessonCount: 3, targetPhonemes: ['c_p', 'c_b', 'c_t', 'c_d', 'c_k', 'c_g']),
    LearningUnit(id: 'u12', blockId: 'block_3', order: 12, titleCn: '摩擦音', titleEn: 'Fricatives', description: '/f/ /v/ /θ/ /ð/ /s/ /z/ /ʃ/ /ʒ/ /h/', lessonCount: 3, targetPhonemes: ['c_f', 'c_v', 'c_θ', 'c_ð', 'c_s', 'c_z', 'c_ʃ', 'c_ʒ', 'c_h']),
    LearningUnit(id: 'u13', blockId: 'block_3', order: 13, titleCn: '破擦音、鼻音与侧音', titleEn: 'Affricates & Nasals', description: '/tʃ/ /dʒ/ /m/ /n/ /ŋ/ /l/', lessonCount: 3, targetPhonemes: ['c_tʃ', 'c_dʒ', 'c_m', 'c_n', 'c_ŋ', 'c_l']),
    LearningUnit(id: 'u14', blockId: 'block_3', order: 14, titleCn: '半元音和近音', titleEn: 'Approximants', description: '/w/ /j/ /r/', lessonCount: 3, targetPhonemes: ['c_w', 'c_j', 'c_r']),
    LearningUnit(id: 'u15', blockId: 'block_3', order: 15, titleCn: '辅音组合', titleEn: 'Consonant Clusters', description: 'bl, str, spr, sts 等组合', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u16', blockId: 'block_3', order: 16, titleCn: '辅音障碍赛', titleEn: 'Consonant Challenge', description: '把常见辅音难点做一轮集中复盘', lessonCount: 3, targetPhonemes: [], badgeId: 'consonant_master'),
    LearningUnit(id: 'u17', blockId: 'block_4', order: 17, titleCn: '音节与重音', titleEn: 'Syllables & Stress', description: '学会找单词重音和节拍中心', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u18', blockId: 'block_4', order: 18, titleCn: '句子重音与节奏', titleEn: 'Sentence Rhythm', description: '把英语说成有强弱拍的节奏语言', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u19', blockId: 'block_4', order: 19, titleCn: '弱读与缩读', titleEn: 'Weak Forms', description: '练轻重变化和自然口语压缩', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u20', blockId: 'block_4', order: 20, titleCn: '语调', titleEn: 'Intonation', description: '升调、降调与语气变化', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u21', blockId: 'block_4', order: 21, titleCn: '连读、失爆与同化', titleEn: 'Connected Speech', description: '把句子之间的衔接练顺', lessonCount: 3, targetPhonemes: [], badgeId: 'rhythm_master'),
    LearningUnit(id: 'u22', blockId: 'block_5', order: 22, titleCn: 'Be 动词与人称', titleEn: 'Be Verbs & Persons', description: 'I am / you are / he is', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u23', blockId: 'block_5', order: 23, titleCn: '-s 与 -ed 的发音', titleEn: '-s & -ed Pronunciation', description: '通过声音规律理解词尾变化', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u24', blockId: 'block_5', order: 24, titleCn: 'a vs an', titleEn: 'A vs An', description: '用发音来判断冠词形式', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u25', blockId: 'block_5', order: 25, titleCn: '不规则动词', titleEn: 'Irregular Verbs', description: '在读音变化里理解记忆规律', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u26', blockId: 'block_5', order: 26, titleCn: '缩写与比较级', titleEn: 'Contractions', description: '让语法形式更接近日常口语', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u27', blockId: 'block_5', order: 27, titleCn: '句型与语调', titleEn: 'Sentence Patterns', description: '用语调把同一句话说出不同意思', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u28', blockId: 'block_5', order: 28, titleCn: '段落综合朗读', titleEn: 'Paragraph Reading', description: '从单句过渡到整段表达', lessonCount: 3, targetPhonemes: [], badgeId: 'grammar_master'),
    LearningUnit(id: 'u29', blockId: 'block_6', order: 29, titleCn: '字母发音基础', titleEn: 'Letter Sounds', description: '建立字母名与字母音的双重认知', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u30', blockId: 'block_6', order: 30, titleCn: '元音拼读规则', titleEn: 'Vowel Spelling', description: 'Magic E、元音组合与常见拼写模式', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u31', blockId: 'block_6', order: 31, titleCn: '辅音拼读规则', titleEn: 'Consonant Spelling', description: 'ch、sh、th 与常见辅音组合', lessonCount: 3, targetPhonemes: []),
    LearningUnit(id: 'u32', blockId: 'block_6', order: 32, titleCn: '拼读综合实战', titleEn: 'Phonics Challenge', description: '把拼读规则带进真实单词场景', lessonCount: 3, targetPhonemes: [], badgeId: 'phonics_master'),
  ];

  static List<LearningUnit> getUnitsForBlock(String blockId) {
    return units.where((unit) => unit.blockId == blockId).toList();
  }
}
