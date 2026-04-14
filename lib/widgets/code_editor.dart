import 'package:flutter/material.dart';
import '../utils/syntax_highlighter.dart';

/// 代码高亮只读展示区（配合 SelectableText.rich）
class CodeHighlightView extends StatelessWidget {
  final String code;
  final String language;
  final double fontSize;
  final bool wordWrap;

  const CodeHighlightView({
    super.key,
    required this.code,
    required this.language,
    required this.fontSize,
    required this.wordWrap,
  });

  @override
  Widget build(BuildContext context) {
    final highlighter = SyntaxHighlighter(language);
    final span = highlighter.highlight(code);

    return SelectableText.rich(
      span,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: fontSize,
        height: 1.5,
        color: SyntaxColors.plain,
      ),
      // 软换行控制
      maxLines: wordWrap ? null : null,
    );
  }
}

/// 带行号的代码编辑器容器
class LineNumberedEditor extends StatefulWidget {
  final TextEditingController controller;
  final double fontSize;
  final bool wordWrap;
  final bool readOnly;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const LineNumberedEditor({
    super.key,
    required this.controller,
    required this.fontSize,
    required this.wordWrap,
    this.readOnly = false,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<LineNumberedEditor> createState() => _LineNumberedEditorState();
}

class _LineNumberedEditorState extends State<LineNumberedEditor> {
  final ScrollController _lineScrollController = ScrollController();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 同步滚动
    _editorScrollController.addListener(() {
      if (_lineScrollController.hasClients) {
        _lineScrollController.jumpTo(_editorScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _lineScrollController.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final lineCount = '\n'.allMatches(value.text).length + 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行号栏
            _buildLineNumbers(lineCount),
            // 分割线
            Container(width: 1, color: const Color(0xFF3A3A3A)),
            // 编辑区
            Expanded(child: _buildEditor()),
          ],
        );
      },
    );
  }

  Widget _buildLineNumbers(int lineCount) {
    final lineHeight = widget.fontSize * 1.5;
    return Container(
      width: _lineNumberWidth(lineCount),
      color: const Color(0xFF252526),
      child: SingleChildScrollView(
        controller: _lineScrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            lineCount,
            (i) => SizedBox(
              height: lineHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: widget.fontSize,
                    color: const Color(0xFF858585),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _lineNumberWidth(int lineCount) {
    final digits = lineCount.toString().length;
    return (digits * widget.fontSize * 0.65 + 24).clamp(40.0, 80.0);
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      controller: _editorScrollController,
      child: SingleChildScrollView(
        scrollDirection: widget.wordWrap ? Axis.vertical : Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.wordWrap ? double.infinity : 0,
          ),
          child: IntrinsicWidth(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              readOnly: widget.readOnly,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: widget.fontSize,
                color: const Color(0xFFD4D4D4),
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                isDense: true,
              ),
              cursorColor: const Color(0xFFAEAFAD),
              cursorWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}
