/// Pedagogical hints for Chinese L1 English learners.
///
/// These are coaching notes for words/phonemes that were actually weak in
/// this attempt. They are not acoustic scores.
class ChineseL1PhonemeCoach {
  const ChineseL1PhonemeCoach();

  List<String> hintsForWords(Iterable<String> words, {int limit = 3}) {
    final hints = <String>[];
    final seen = <String>{};

    for (final word in words) {
      final hint = hintForWord(word);
      if (hint == null || !seen.add(hint)) {
        continue;
      }
      hints.add(hint);
      if (hints.length >= limit) {
        break;
      }
    }

    return hints;
  }

  String? hintForWord(String word) {
    final normalized = _normalize(word);
    if (normalized.isEmpty) {
      return null;
    }

    final direct = _wordHints[normalized];
    if (direct != null) {
      return '$word：$direct';
    }

    for (final entry in _suffixHints.entries) {
      if (normalized.endsWith(entry.key)) {
        return '$word：${entry.value}';
      }
    }

    if (normalized.contains('th')) {
      return '$word：th 对中文母语者常滑成 /s/ 或 /d/。舌尖轻触上下齿之间，送气，不要用中文「思」。';
    }
    if (normalized.contains('v') && !normalized.startsWith('w')) {
      return '$word：/v/ 需要上齿轻咬下唇，不要发成 /w/。';
    }
    if (RegExp(r'(^r|rr)').hasMatch(normalized)) {
      return '$word：词首 /r/ 不要卷成中文「日」，舌尖不要碰齿龈。';
    }
    if (normalized.contains('l') &&
        (normalized.endsWith('l') || normalized.endsWith('le'))) {
      return '$word：词尾 /l/ 要有舌尖抵齿龈的接触，不要把尾巴吞掉。';
    }

    return null;
  }

  String? hintForPhoneme(String phoneme) {
    final key = _normalizePhoneme(phoneme);
    return _phonemeHints[key];
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll("'", '')
        .replaceAll(RegExp(r'[^a-z]'), '');
  }

  String _normalizePhoneme(String value) {
    return value.trim().toLowerCase().replaceAll('/', '');
  }

  static const _wordHints = <String, String>{
    'please': '词尾 /z/ 要带声，/l/ 舌尖抵齿龈；不要把 please 收成 “pease”。',
    'large': '词尾 /dʒ/ 是浊塞擦音，不要发成 /tʃ/ 或把 r 吞掉。',
    'latte': '重音在第一个音节，/æ/ 口型打开，不要发成中文「拿铁」的 a。',
    'oat': '/əʊ/ 或 /oʊ/ 是双元音，口型要从圆滑向合，不要发成短 o。',
    'milk': '词尾 /k/ 要有轻收束，/l/ 不要省略。',
    'reservation': '重音在 -va-；/z/ 带声，词尾 -tion 是 /ʃən/，不是「神」。',
    'weather': '/ð/ 舌尖轻触齿间并带声，不要发成 /w/ 或 /d/。',
    'better': '美音常是闪音 /ɾ/，英音是 /t/；词尾 schwa 不要再加一个中文「特」。',
    'earlier': '三个音节，重音在 ear；/ɜː/ 口型略圆，不要压成 “er-li-er”。',
    'quieter': '比较级 -er 是轻音节；/aɪ/ 先开口再收。',
    'available': '重音在 -vai-；词尾 -able 是 /əbl/，不要每个音节等重。',
    'thought': '/θ/ 加 /ɔː/，词尾 /t/ 要收住；不要发成 “soght” 或 “taught” 的混淆。',
    'three': '/θr/ 连续：先齿间送气，再马上接 /r/，不要变成 “sree” 或 “tree”。',
    'finished': '词尾 -ed 在清辅音后是 /t/，不要发成多余的 “-id”。',
    'friday': '/aɪ/ 要打开；/r/ 不要碰齿龈。',
    'breath': '清辅音 /θ/ 结尾，不要带成 breathe 的 /ð/。',
    'english': '/ŋ/ 在 ng，不要发成 /n/ + g；/ʃ/ 唇略圆。',
    'missing': '词尾 -ing 是 /ɪŋ/，不要发成 /in/。',
    'arrived': '词尾 -ed 在浊辅音后是 /d/；/aɪ/ 打开。',
    'late': '词尾 /t/ 要有接触，不要把 late 收成 lay。',
    'nights': '词尾 /ts/ 清辅音串，不要吞掉 s。',
    'could': '/ʊ/ 短而圆，不要发成 /uː/。',
    'would': '/ʊ/ 短而圆，词首 /w/ 不要发成 /v/。',
    'the': '元音前常用 /ði/，辅音前 /ðə/；/ð/ 必须带声。',
    'with': '词尾 /θ/ 或 /ð/ 都比 /s/ 更靠齿间。',
    'think': '/θ/ 加 /ɪŋk/，不要发成 sink。',
    'this': '/ð/ 带声，不要发成 dis 或 zis。',
  };

  static const _suffixHints = <String, String>{
    'tion': '-tion 是 /ʃən/，只有一个轻音节，不要读成 “-神 / -先”。',
    'ture': '-ture 常是 /tʃə/，不要读成 “-ture” 三个字母。',
  };

  static const _phonemeHints = <String, String>{
    'θ': '舌尖放在上下齿之间轻轻送气，不要用中文「思」的舌位。',
    'th': '舌尖放在上下齿之间轻轻送气，不要用中文「思」的舌位。',
    'ð': '和 /θ/ 同舌位，但要带声。手指轻触喉头应能感到振动。',
    'dh': '和 /θ/ 同舌位，但要带声。手指轻触喉头应能感到振动。',
    'v': '上齿轻咬下唇并带声，不要发成 /w/。',
    'w': '双唇收圆再放开，齿不要咬唇。',
    'r': '舌尖不要碰齿龈，两侧略收；不要发成中文「日」。',
    'l': '舌尖抵上齿龈，词尾 /l/ 也要有接触。',
    'ʃ': '舌身后缩，唇略圆，比中文「西」更靠后。',
    'sh': '舌身后缩，唇略圆，比中文「西」更靠后。',
    'tʃ': '先堵住再擦出，不要发成 /ʃ/ 或中文「七」。',
    'ch': '先堵住再擦出，不要发成 /ʃ/ 或中文「七」。',
    'dʒ': '和 /tʃ/ 同口型但带声，不要发成 /tʃ/。',
    'jh': '和 /tʃ/ 同口型但带声，不要发成 /tʃ/。',
    'ŋ': '舌面抵软腭，不要发成 /n/。',
    'ng': '舌面抵软腭，不要发成 /n/。',
    'æ': '口型比 /e/ 更开，下巴放下。中文里没有这个音。',
    'ae': '口型比 /e/ 更开，下巴放下。中文里没有这个音。',
    'ɪ': '比 /iː/ 更短更松，不要发成中文「一」。',
    'ih': '比 /iː/ 更短更松，不要发成中文「一」。',
    'i': '长元音 /iː/ 口型略展，持续比中文「一」更长。',
    'iy': '长元音 /iː/ 口型略展，持续比中文「一」更长。',
    'ʊ': '短而圆，不要拉成 /uː/。',
    'uh': '短而圆，不要拉成 /uː/。',
    'u': '长元音 /uː/ 双唇收圆并持续。',
    'uw': '长元音 /uː/ 双唇收圆并持续。',
    'z': '和 /s/ 同舌位但要带声。',
    'n': '舌尖抵齿龈；不要和 /l/ 或 /ŋ/ 混。',
  };
}
