import 'package:flutter/material.dart';

// 代码高亮配色（VS Code Dark主题风格）
class SyntaxColors {
  static const keyword = Color(0xFF569CD6);
  static const string = Color(0xFFCE9178);
  static const comment = Color(0xFF6A9955);
  static const number = Color(0xFFB5CEA8);
  static const function_ = Color(0xFFDCDCAA);
  static const tag = Color(0xFF4EC9B0);
  static const attribute = Color(0xFF9CDCFE);
  static const type_ = Color(0xFF4EC9B0);
  static const decorator = Color(0xFFDCDCAA);
  static const plain = Color(0xFFD4D4D4);
  static const selector = Color(0xFFD7BA7D);
  static const property = Color(0xFF9CDCFE);
  static const preprocessor = Color(0xFFC586C0);
}

class _Segment {
  final int start;
  final int end;
  final Color? color;
  const _Segment(this.start, this.end, this.color);
}

class SyntaxHighlighter {
  final String language;
  SyntaxHighlighter(this.language);

  TextSpan highlight(String code) {
    switch (language.toLowerCase()) {
      case 'html':
      case 'htm':
        return _highlightHtml(code);
      case 'css':
        return _highlightCss(code);
      case 'js':
      case 'javascript':
      case 'ts':
      case 'typescript':
        return _highlightJs(code);
      case 'python':
        return _highlightPython(code);
      case 'java':
        return _highlightJava(code);
      case 'dart':
        return _highlightDart(code);
      case 'xml':
      case 'svg':
        return _highlightXml(code);
      case 'json':
        return _highlightJson(code);
      case 'sh':
      case 'bash':
      case 'shell':
        return _highlightShell(code);
      case 'cpp':
      case 'c':
        return _highlightCpp(code);
      case 'kotlin':
        return _highlightKotlin(code);
      default:
        return TextSpan(
          text: code,
          style: const TextStyle(color: SyntaxColors.plain),
        );
    }
  }

  // ─── HTML 高亮 ───────────────────────────────────────────
  TextSpan _highlightHtml(String code) {
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'<!--[\s\S]*?-->'), SyntaxColors.comment),
      MapEntry(RegExp(r'<!DOCTYPE[^>]*>', caseSensitive: false), SyntaxColors.keyword),
      MapEntry(RegExp('"[^"]*"'), SyntaxColors.string),
      MapEntry(RegExp(r'</?[\w][\w\-]*'), SyntaxColors.tag),
      MapEntry(RegExp(r'\s[\w\-:@]+(?==)'), SyntaxColors.attribute),
      MapEntry(RegExp(r'>'), SyntaxColors.tag),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── CSS 高亮 ────────────────────────────────────────────
  TextSpan _highlightCss(String code) {
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'/\*[\s\S]*?\*/'), SyntaxColors.comment),
      MapEntry(RegExp('"[^"]*"'), SyntaxColors.string),
      MapEntry(RegExp(r'#[0-9a-fA-F]{3,8}\b'), SyntaxColors.number),
      MapEntry(RegExp(r'\b\d+(\.\d+)?(px|em|rem|%|vh|vw|pt|cm|mm|deg|s|ms)?\b'), SyntaxColors.number),
      MapEntry(RegExp(r'@[\w-]+'), SyntaxColors.preprocessor),
      MapEntry(RegExp(r'!important'), SyntaxColors.keyword),
      MapEntry(RegExp(r'[\w-]+(?=\s*:)'), SyntaxColors.property),
      MapEntry(RegExp(r':[\w-]+'), SyntaxColors.keyword),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── JS / TS 高亮 ────────────────────────────────────────
  TextSpan _highlightJs(String code) {
    final jsKeywords = RegExp(
      r'\b(var|let|const|function|return|if|else|for|while|do|switch|case|break|continue|new|class|extends|import|export|default|from|of|in|typeof|instanceof|this|super|async|await|try|catch|finally|throw|null|undefined|true|false|void|delete|yield|static|get|set|type|interface|enum|implements|abstract|declare|namespace|module|as|readonly|any|string|number|boolean|never|object|symbol)\b',
    );
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'//[^\n]*'), SyntaxColors.comment),
      MapEntry(RegExp(r'/\*[\s\S]*?\*/'), SyntaxColors.comment),
      MapEntry(RegExp(r'`[^`]*`'), SyntaxColors.string),
      MapEntry(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), SyntaxColors.string),
      MapEntry(RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'"), SyntaxColors.string),
      MapEntry(RegExp(r'\b\d+(\.\d+)?\b'), SyntaxColors.number),
      MapEntry(jsKeywords, SyntaxColors.keyword),
      MapEntry(RegExp(r'\b[A-Z][\w]*\b'), SyntaxColors.type_),
      MapEntry(RegExp(r'\b[\w]+(?=\s*\()'), SyntaxColors.function_),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── Python 高亮 ─────────────────────────────────────────
  TextSpan _highlightPython(String code) {
    final pyKeywords = RegExp(
      r'\b(import|from|as|class|def|return|if|elif|else|for|while|in|not|and|or|is|None|True|False|try|except|finally|raise|with|pass|break|continue|yield|lambda|global|nonlocal|del|assert|async|await|print|self|super|property)\b',
    );
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'#[^\n]*'), SyntaxColors.comment),
      MapEntry(RegExp(r'"""[\s\S]*?"""'), SyntaxColors.string),
      MapEntry(RegExp(r"'''[\s\S]*?'''"), SyntaxColors.string),
      MapEntry(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), SyntaxColors.string),
      MapEntry(RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'"), SyntaxColors.string),
      MapEntry(RegExp(r'\b\d+(\.\d+)?\b'), SyntaxColors.number),
      MapEntry(RegExp(r'@[\w.]+'), SyntaxColors.decorator),
      MapEntry(pyKeywords, SyntaxColors.keyword),
      MapEntry(RegExp(r'\b[A-Z][\w]*\b'), SyntaxColors.type_),
      MapEntry(RegExp(r'\b[\w]+(?=\s*\()'), SyntaxColors.function_),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── Java 高亮 ───────────────────────────────────────────
  TextSpan _highlightJava(String code) {
    final javaKeywords = RegExp(
      r'\b(abstract|assert|boolean|break|byte|case|catch|char|class|const|continue|default|do|double|else|enum|extends|final|finally|float|for|goto|if|implements|import|instanceof|int|interface|long|native|new|package|private|protected|public|return|short|static|strictfp|super|switch|synchronized|this|throw|throws|transient|try|void|volatile|while|var|null|true|false|String|Integer|Double|Float|Long|Boolean|Object|List|Map|Set|ArrayList|HashMap)\b',
    );
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'//[^\n]*'), SyntaxColors.comment),
      MapEntry(RegExp(r'/\*[\s\S]*?\*/'), SyntaxColors.comment),
      MapEntry(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), SyntaxColors.string),
      MapEntry(RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'"), SyntaxColors.string),
      MapEntry(RegExp(r'\b\d+(\.\d+)?[lLfFdD]?\b'), SyntaxColors.number),
      MapEntry(RegExp(r'@[\w.]+'), SyntaxColors.decorator),
      MapEntry(javaKeywords, SyntaxColors.keyword),
      MapEntry(RegExp(r'\b[A-Z][\w]*\b'), SyntaxColors.type_),
      MapEntry(RegExp(r'\b[\w]+(?=\s*\()'), SyntaxColors.function_),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── Dart 高亮 ───────────────────────────────────────────
  TextSpan _highlightDart(String code) {
    final dartKeywords = RegExp(
      r'\b(abstract|as|assert|async|await|break|case|catch|class|const|continue|covariant|default|deferred|do|dynamic|else|enum|export|extends|extension|external|factory|false|final|finally|for|Function|get|hide|if|implements|import|in|interface|is|late|library|mixin|new|null|on|operator|part|required|rethrow|return|set|show|static|super|switch|sync|this|throw|true|try|type|typedef|var|void|while|with|yield|String|int|double|bool|List|Map|Set|DateTime|Future|Stream|Widget|BuildContext|State|StatelessWidget|StatefulWidget|Navigator|Scaffold|Column|Row|Text|Container|Padding|Center|Expanded)\b',
    );
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'//[^\n]*'), SyntaxColors.comment),
      MapEntry(RegExp(r'/\*[\s\S]*?\*/'), SyntaxColors.comment),
      MapEntry(RegExp(r"'''[\s\S]*?'''"), SyntaxColors.string),
      MapEntry(RegExp(r'"""[\s\S]*?"""'), SyntaxColors.string),
      MapEntry(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), SyntaxColors.string),
      MapEntry(RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'"), SyntaxColors.string),
      MapEntry(RegExp(r'\b\d+(\.\d+)?\b'), SyntaxColors.number),
      MapEntry(dartKeywords, SyntaxColors.keyword),
      MapEntry(RegExp(r'\b[A-Z][\w]*\b'), SyntaxColors.type_),
      MapEntry(RegExp(r'\b[\w]+(?=\s*\()'), SyntaxColors.function_),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── XML ────────────────────────────────────────────────
  TextSpan _highlightXml(String code) => _highlightHtml(code);

  // ─── JSON ────────────────────────────────────────────────
  TextSpan _highlightJson(String code) {
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'"[^"]*"(?=\s*:)'), SyntaxColors.attribute),
      MapEntry(RegExp(r'"[^"]*"'), SyntaxColors.string),
      MapEntry(RegExp(r'\b\d+(\.\d+)?\b'), SyntaxColors.number),
      MapEntry(RegExp(r'\b(true|false|null)\b'), SyntaxColors.keyword),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── Shell ───────────────────────────────────────────────
  TextSpan _highlightShell(String code) {
    final shKeywords = RegExp(
      r'\b(if|then|else|elif|fi|for|while|do|done|case|esac|function|return|in|echo|export|source|cd|ls|mkdir|rm|cp|mv|cat|grep|sed|awk|find|chmod|chown|sudo|apt|yum|brew|git|python|pip|node|npm)\b',
    );
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'#[^\n]*'), SyntaxColors.comment),
      MapEntry(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), SyntaxColors.string),
      MapEntry(RegExp(r"'[^']*'"), SyntaxColors.string),
      MapEntry(RegExp(r'\$\w+|\$\{[^}]+\}'), SyntaxColors.attribute),
      MapEntry(shKeywords, SyntaxColors.keyword),
      MapEntry(RegExp(r'\b\d+\b'), SyntaxColors.number),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── C/C++ ──────────────────────────────────────────────
  TextSpan _highlightCpp(String code) {
    final cppKeywords = RegExp(
      r'\b(auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|inline|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|class|namespace|template|typename|new|delete|try|catch|throw|virtual|override|nullptr|true|false|bool|string|vector|map|set|pair|cout|cin|endl|std|include|define|ifdef|ifndef|endif|pragma)\b',
    );
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'//[^\n]*'), SyntaxColors.comment),
      MapEntry(RegExp(r'/\*[\s\S]*?\*/'), SyntaxColors.comment),
      MapEntry(RegExp(r'#\s*\w+'), SyntaxColors.preprocessor),
      MapEntry(RegExp(r'<[\w./]+>'), SyntaxColors.string),
      MapEntry(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), SyntaxColors.string),
      MapEntry(RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'"), SyntaxColors.string),
      MapEntry(RegExp(r'\b\d+(\.\d+)?[uUlLfF]?\b'), SyntaxColors.number),
      MapEntry(cppKeywords, SyntaxColors.keyword),
      MapEntry(RegExp(r'\b[A-Z][\w]*\b'), SyntaxColors.type_),
      MapEntry(RegExp(r'\b[\w]+(?=\s*\()'), SyntaxColors.function_),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── Kotlin ─────────────────────────────────────────────
  TextSpan _highlightKotlin(String code) {
    final ktKeywords = RegExp(
      r'\b(abstract|actual|annotation|as|break|by|catch|class|companion|const|constructor|continue|crossinline|data|do|dynamic|else|enum|expect|external|false|final|finally|for|fun|get|if|import|in|infix|init|inline|inner|interface|internal|is|it|lateinit|noinline|null|object|open|operator|out|override|package|private|protected|public|reified|return|sealed|set|super|suspend|tailrec|this|throw|true|try|typealias|typeof|val|var|vararg|when|where|while|String|Int|Long|Float|Double|Boolean|List|Map|Set|Any|Unit|Nothing)\b',
    );
    final patterns = <MapEntry<RegExp, Color>>[
      MapEntry(RegExp(r'//[^\n]*'), SyntaxColors.comment),
      MapEntry(RegExp(r'/\*[\s\S]*?\*/'), SyntaxColors.comment),
      MapEntry(RegExp(r'"""[\s\S]*?"""'), SyntaxColors.string),
      MapEntry(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), SyntaxColors.string),
      MapEntry(RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'"), SyntaxColors.string),
      MapEntry(RegExp(r'\b\d+(\.\d+)?[LFf]?\b'), SyntaxColors.number),
      MapEntry(RegExp(r'@[\w.]+'), SyntaxColors.decorator),
      MapEntry(ktKeywords, SyntaxColors.keyword),
      MapEntry(RegExp(r'\b[A-Z][\w]*\b'), SyntaxColors.type_),
      MapEntry(RegExp(r'\b[\w]+(?=\s*\()'), SyntaxColors.function_),
    ];
    return _applyPatterns(code, patterns);
  }

  // ─── 通用 Pattern 引擎 ───────────────────────────────────
  TextSpan _applyPatterns(String code, List<MapEntry<RegExp, Color>> patterns) {
    final List<_Segment> segments = [_Segment(0, code.length, null)];

    for (final entry in patterns) {
      final regex = entry.key;
      final color = entry.value;
      for (final match in regex.allMatches(code)) {
        _markSegment(segments, match.start, match.end, color);
      }
    }

    final spans = segments.map((seg) {
      return TextSpan(
        text: code.substring(seg.start, seg.end),
        style: TextStyle(
          color: seg.color ?? SyntaxColors.plain,
          fontFamily: 'monospace',
        ),
      );
    }).toList();

    return TextSpan(children: spans);
  }

  void _markSegment(List<_Segment> segments, int start, int end, Color color) {
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if (seg.color != null) continue;
      if (seg.end <= start || seg.start >= end) continue;

      final overlapStart = start > seg.start ? start : seg.start;
      final overlapEnd = end < seg.end ? end : seg.end;
      if (overlapStart >= overlapEnd) continue;

      final newSegs = <_Segment>[];
      if (seg.start < overlapStart) newSegs.add(_Segment(seg.start, overlapStart, null));
      newSegs.add(_Segment(overlapStart, overlapEnd, color));
      if (overlapEnd < seg.end) newSegs.add(_Segment(overlapEnd, seg.end, null));

      segments.replaceRange(i, i + 1, newSegs);
      i += newSegs.length - 1;
    }
  }
}

/// 根据文件扩展名判断语言
String detectLanguage(String filename) {
  final parts = filename.toLowerCase().split('.');
  if (parts.length < 2) return 'txt';
  final ext = parts.last;
  const map = {
    'html': 'html', 'htm': 'html',
    'css': 'css',
    'js': 'js', 'mjs': 'js', 'cjs': 'js', 'jsx': 'js',
    'ts': 'ts', 'tsx': 'ts',
    'py': 'python', 'pyw': 'python',
    'java': 'java',
    'dart': 'dart',
    'xml': 'xml', 'svg': 'xml',
    'json': 'json', 'jsonc': 'json',
    'sh': 'sh', 'bash': 'sh', 'zsh': 'sh',
    'c': 'c', 'h': 'c',
    'cpp': 'cpp', 'cc': 'cpp', 'cxx': 'cpp', 'hpp': 'cpp',
    'kt': 'kotlin', 'kts': 'kotlin',
    'md': 'md', 'markdown': 'md',
    'yaml': 'yaml', 'yml': 'yaml',
  };
  return map[ext] ?? 'txt';
}
