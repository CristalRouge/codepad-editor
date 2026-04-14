import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/editor_state.dart';
import '../services/file_service.dart';
import '../utils/syntax_highlighter.dart';
import '../widgets/code_editor.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 双指缩放
  double _baseFontSize = 14.0;

  // 菜单展开状态
  bool _menuExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final state = context.read<EditorState>();
    final savedFontSize = prefs.getDouble('fontSize') ?? 14.0;
    final savedWordWrap = prefs.getBool('wordWrap') ?? true;
    state.setFontSize(savedFontSize);
    _baseFontSize = savedFontSize;
    if (!savedWordWrap) state.toggleWordWrap();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final state = context.read<EditorState>();
    await prefs.setDouble('fontSize', state.fontSize);
    await prefs.setBool('wordWrap', state.wordWrap);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── 文件操作 ─────────────────────────────────────────────

  Future<void> _openFile() async {
    final state = context.read<EditorState>();
    if (state.isModified) {
      final save = await _showUnsavedDialog();
      if (save == null) return;
      if (save) await _saveFile();
    }
    if (!mounted) return;
    final result = await FileService.pickFile(context);
    if (result == null) return;
    if (!mounted) return;

    state.openFile(result['path']!, result['name']!, result['content']!);
    _textController.text = result['content']!;
  }

  Future<void> _newFile() async {
    final state = context.read<EditorState>();
    if (state.isModified) {
      final save = await _showUnsavedDialog();
      if (save == null) return;
      if (save) await _saveFile();
    }
    if (!mounted) return;
    state.newFile();
    _textController.clear();
  }

  Future<void> _saveFile() async {
    final state = context.read<EditorState>();
    if (state.filePath.isEmpty) {
      await _saveFileAs();
      return;
    }
    if (!mounted) return;
    final savedPath = state.filePath;
    final savedName = state.fileName;
    final savedContent = state.content;
    final ok = await FileService.saveFile(context, savedPath, savedContent);
    if (ok && mounted) {
      state.markSaved(savedPath, savedName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已保存'),
          backgroundColor: Color(0xFF6A9955),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _saveFileAs() async {
    final state = context.read<EditorState>();
    if (!mounted) return;
    final content = state.content;
    final fileName = state.fileName;
    final result = await FileService.saveFileAs(context, content, fileName);
    if (result == null) return;
    if (!mounted) return;
    state.markSaved(result['path']!, result['name']!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已保存至 ${result['path']}'),
        backgroundColor: const Color(0xFF6A9955),
      ),
    );
  }

  Future<bool?> _showUnsavedDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('未保存的修改', style: TextStyle(color: Colors.white)),
        content: const Text(
          '当前文件有未保存的修改，是否保存？',
          style: TextStyle(color: Color(0xFFD4D4D4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('取消', style: TextStyle(color: Color(0xFF858585))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('不保存', style: TextStyle(color: Color(0xFFCE9178))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存', style: TextStyle(color: Color(0xFF4EC9B0))),
          ),
        ],
      ),
    );
  }

  // ── UI 构建 ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorState>(
      builder: (context, state, _) {
        // 同步 controller 内容（外部状态更新时）
        if (_textController.text != state.content && !_focusNode.hasFocus) {
          _textController.text = state.content;
        }

        final language = detectLanguage(state.fileName);
        final isMarkdown = language == 'md';

        return Scaffold(
          backgroundColor: const Color(0xFF1E1E1E),
          appBar: _buildAppBar(state, language),
          body: SafeArea(
            child: GestureDetector(
              onScaleStart: (details) {
                _baseFontSize = state.fontSize;
              },
              onScaleUpdate: (details) {
                if (details.pointerCount >= 2) {
                  final newSize = (_baseFontSize * details.scale).clamp(8.0, 48.0);
                  state.setFontSize(newSize);
                  _savePreferences();
                }
              },
              child: Stack(
                children: [
                  // 主内容区
                  _buildMainContent(state, language, isMarkdown),
                  // 悬浮菜单
                  _buildFloatingMenu(state, isMarkdown),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(EditorState state, String language) {
    return AppBar(
      backgroundColor: const Color(0xFF323233),
      elevation: 0,
      titleSpacing: 8,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 修改标记
              if (state.isModified)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('●', style: TextStyle(color: Color(0xFFCE9178), fontSize: 10)),
                ),
              Flexible(
                child: Text(
                  state.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // 语言标签 + 统计
          Row(
            children: [
              _langBadge(language),
              const SizedBox(width: 8),
              Text(
                '${state.lineCount}行 | ${state.charCount}字符',
                style: const TextStyle(
                  color: Color(0xFF858585),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // 只读模式图标
        if (state.isReadOnly)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.lock_outline, color: Color(0xFFCE9178), size: 20),
          ),
        // 换行图标
        IconButton(
          icon: Icon(
            state.wordWrap ? Icons.wrap_text : Icons.notes,
            color: state.wordWrap ? const Color(0xFF4EC9B0) : const Color(0xFF858585),
            size: 22,
          ),
          tooltip: state.wordWrap ? '自动换行（点击关闭）' : '不换行（点击开启）',
          onPressed: () {
            state.toggleWordWrap();
            _savePreferences();
          },
        ),
        // 字体大小提示
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: Text(
              '${state.fontSize.round()}px',
              style: const TextStyle(color: Color(0xFF858585), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _langBadge(String lang) {
    final colorMap = {
      'html': const Color(0xFFE34C26),
      'css': const Color(0xFF264DE4),
      'js': const Color(0xFFF7DF1E),
      'ts': const Color(0xFF3178C6),
      'python': const Color(0xFF3776AB),
      'java': const Color(0xFFB07219),
      'dart': const Color(0xFF00B4AB),
      'xml': const Color(0xFF4EC9B0),
      'json': const Color(0xFF878787),
      'md': const Color(0xFF519ABA),
      'kotlin': const Color(0xFF7F52FF),
      'cpp': const Color(0xFF00599C),
      'c': const Color(0xFF283593),
      'sh': const Color(0xFF89E051),
      'yaml': const Color(0xFFCB171E),
    };
    final color = colorMap[lang] ?? const Color(0xFF858585);
    final displayName = lang == 'python' ? 'PY' : lang.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        displayName,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMainContent(EditorState state, String language, bool isMarkdown) {
    // Markdown 预览模式
    if (isMarkdown && state.isMarkdownPreview) {
      return Container(
        color: const Color(0xFF1E1E1E),
        child: Markdown(
          data: state.content,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: const Color(0xFFD4D4D4), fontSize: state.fontSize),
            h1: TextStyle(color: Colors.white, fontSize: state.fontSize * 2, fontWeight: FontWeight.bold),
            h2: TextStyle(color: Colors.white, fontSize: state.fontSize * 1.6, fontWeight: FontWeight.bold),
            h3: TextStyle(color: Colors.white, fontSize: state.fontSize * 1.3, fontWeight: FontWeight.bold),
            h4: TextStyle(color: Colors.white, fontSize: state.fontSize * 1.1),
            h5: TextStyle(color: Colors.white, fontSize: state.fontSize),
            h6: TextStyle(color: const Color(0xFF858585), fontSize: state.fontSize),
            code: TextStyle(
              color: const Color(0xFFCE9178),
              backgroundColor: const Color(0xFF2D2D2D),
              fontFamily: 'monospace',
              fontSize: state.fontSize,
            ),
            codeblockDecoration: BoxDecoration(
              color: const Color(0xFF252526),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF3A3A3A)),
            ),
            blockquoteDecoration: const BoxDecoration(
              color: Color(0xFF252526),
              border: Border(left: BorderSide(color: Color(0xFF569CD6), width: 4)),
            ),
            blockquote: TextStyle(color: const Color(0xFF858585), fontSize: state.fontSize),
            listBullet: TextStyle(color: const Color(0xFF569CD6), fontSize: state.fontSize),
            tableHead: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            tableBody: TextStyle(color: const Color(0xFFD4D4D4), fontSize: state.fontSize),
            horizontalRuleDecoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A), width: 1)),
            ),
            strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            em: TextStyle(color: const Color(0xFF9CDCFE), fontStyle: FontStyle.italic),
          ),
          padding: EdgeInsets.all(state.fontSize),
        ),
      );
    }

    // 普通编辑 / 只读 + 代码高亮
    if (state.isReadOnly && language != 'txt' && language != 'md') {
      // 只读模式：渲染高亮
      return Container(
        color: const Color(0xFF1E1E1E),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLineNumbersStatic(state),
            Container(width: 1, color: const Color(0xFF3A3A3A)),
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: state.wordWrap ? Axis.vertical : Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 80),
                    child: CodeHighlightView(
                      code: state.content,
                      language: language,
                      fontSize: state.fontSize,
                      wordWrap: state.wordWrap,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 可编辑模式
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: LineNumberedEditor(
          controller: _textController,
          focusNode: _focusNode,
          fontSize: state.fontSize,
          wordWrap: state.wordWrap,
          readOnly: state.isReadOnly,
          onChanged: (text) {
            state.updateContent(text);
          },
        ),
      ),
    );
  }

  Widget _buildLineNumbersStatic(EditorState state) {
    final lines = state.content.split('\n');
    final lineCount = lines.length;
    final fontSize = state.fontSize;
    final lineHeight = fontSize * 1.5;

    final digits = lineCount.toString().length;
    final width = (digits * fontSize * 0.65 + 24).clamp(40.0, 80.0);

    return Container(
      width: width,
      color: const Color(0xFF252526),
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
                  fontSize: fontSize,
                  color: const Color(0xFF858585),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 悬浮菜单 ─────────────────────────────────────────────

  Widget _buildFloatingMenu(EditorState state, bool isMarkdown) {
    return Positioned(
      right: 16,
      bottom: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 展开的菜单项
          if (_menuExpanded) ...[
            _menuItem(
              icon: Icons.create_new_folder_outlined,
              label: '新建',
              color: const Color(0xFF9CDCFE),
              onTap: () { setState(() => _menuExpanded = false); _newFile(); },
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.folder_open_outlined,
              label: '打开',
              color: const Color(0xFFDCDCAA),
              onTap: () { setState(() => _menuExpanded = false); _openFile(); },
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.save_outlined,
              label: '保存',
              color: const Color(0xFF4EC9B0),
              onTap: () { setState(() => _menuExpanded = false); _saveFile(); },
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.save_as_outlined,
              label: '另存为',
              color: const Color(0xFFB5CEA8),
              onTap: () { setState(() => _menuExpanded = false); _saveFileAs(); },
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: state.isReadOnly ? Icons.edit_outlined : Icons.remove_red_eye_outlined,
              label: state.isReadOnly ? '编辑模式' : '只读模式',
              color: const Color(0xFFCE9178),
              onTap: () { setState(() => _menuExpanded = false); state.toggleReadOnly(); },
            ),
            if (isMarkdown) ...[
              const SizedBox(height: 12),
              _menuItem(
                icon: state.isMarkdownPreview ? Icons.code : Icons.preview_outlined,
                label: state.isMarkdownPreview ? '源码视图' : 'MD预览',
                color: const Color(0xFF519ABA),
                onTap: () { setState(() => _menuExpanded = false); state.toggleMarkdownPreview(); },
              ),
            ],
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.text_decrease,
              label: '缩小字体',
              color: const Color(0xFF858585),
              onTap: () {
                state.setFontSize(state.fontSize - 1);
                _savePreferences();
              },
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.text_increase,
              label: '放大字体',
              color: const Color(0xFF858585),
              onTap: () {
                state.setFontSize(state.fontSize + 1);
                _savePreferences();
              },
            ),
            const SizedBox(height: 16),
          ],

          // 主菜单按钮
          GestureDetector(
            onTap: () => setState(() => _menuExpanded = !_menuExpanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _menuExpanded ? const Color(0xFF569CD6) : const Color(0xFF0E639C),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _menuExpanded ? 0.125 : 0,
                child: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 圆形图标
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ],
      ),
    );
  }
}
