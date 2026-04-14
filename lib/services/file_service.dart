import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService {
  // 支持的文本文件扩展名
  static const List<String> supportedExtensions = [
    'txt', 'md', 'markdown',
    'html', 'htm', 'css',
    'js', 'mjs', 'cjs', 'jsx',
    'ts', 'tsx',
    'py', 'pyw',
    'java', 'kt', 'kts',
    'dart',
    'xml', 'svg',
    'json', 'jsonc',
    'sh', 'bash', 'zsh',
    'c', 'h', 'cpp', 'cc', 'cxx', 'hpp',
    'yaml', 'yml',
    'toml', 'ini', 'conf', 'cfg',
    'csv', 'sql',
    'rb', 'go', 'rs', 'php', 'swift',
    'log', 'text',
    'gradle', 'properties', 'makefile',
  ];

  /// 请求存储权限
  static Future<bool> requestPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    // Android 13+ 使用精细化权限
    final sdkVersion = await _getAndroidSdkVersion();

    if (sdkVersion >= 33) {
      // Android 13+ 不需要READ_EXTERNAL_STORAGE，file_picker直接打开SAF
      return true;
    } else if (sdkVersion >= 30) {
      // Android 11-12 尝试申请 MANAGE_EXTERNAL_STORAGE
      final manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isDenied) {
        final result = await Permission.manageExternalStorage.request();
        if (result.isPermanentlyDenied && context.mounted) {
          _showPermissionDialog(context);
          return false;
        }
        return result.isGranted;
      }
      return manageStatus.isGranted;
    } else {
      // Android 10 及以下
      final readStatus = await Permission.storage.status;
      if (readStatus.isDenied) {
        final result = await Permission.storage.request();
        if (result.isPermanentlyDenied && context.mounted) {
          _showPermissionDialog(context);
          return false;
        }
        return result.isGranted;
      }
      return readStatus.isGranted;
    }
  }

  static Future<int> _getAndroidSdkVersion() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 33;
    } catch (_) {
      return 33;
    }
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('需要存储权限', style: TextStyle(color: Colors.white)),
        content: const Text(
          '需要存储权限才能读取和保存文件。\n请在系统设置中手动授予权限。',
          style: TextStyle(color: Color(0xFFD4D4D4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: Color(0xFF569CD6))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('去设置', style: TextStyle(color: Color(0xFF569CD6))),
          ),
        ],
      ),
    );
  }

  /// 打开文件选择器
  static Future<Map<String, String>?> pickFile(BuildContext context) async {
    if (Platform.isAndroid) {
      await requestPermissions(context);
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final path = file.path;
      if (path == null) return null;

      final content = await File(path).readAsString();
      return {
        'path': path,
        'name': p.basename(path),
        'content': content,
      };
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打开文件失败: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
      return null;
    }
  }

  /// 保存文件
  static Future<bool> saveFile(
    BuildContext context,
    String path,
    String content,
  ) async {
    try {
      await File(path).writeAsString(content);
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
      return false;
    }
  }

  /// 另存为
  static Future<Map<String, String>?> saveFileAs(
    BuildContext context,
    String content,
    String defaultName,
  ) async {
    // 弹出对话框让用户输入文件名和选择目录
    String? newName = await _showSaveAsDialog(context, defaultName);
    if (newName == null) return null;

    try {
      // 获取Documents目录
      Directory saveDir;
      if (Platform.isAndroid) {
        // 尝试获取外部存储Documents目录
        final externalDirs = await getExternalStorageDirectories(
          type: StorageDirectory.documents,
        );
        if (externalDirs != null && externalDirs.isNotEmpty) {
          saveDir = externalDirs.first;
        } else {
          saveDir = await getApplicationDocumentsDirectory();
        }
      } else {
        saveDir = await getApplicationDocumentsDirectory();
      }

      final newPath = p.join(saveDir.path, newName);
      await File(newPath).writeAsString(content);

      return {
        'path': newPath,
        'name': newName,
      };
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('另存为失败: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
      return null;
    }
  }

  static Future<String?> _showSaveAsDialog(
    BuildContext context,
    String defaultName,
  ) async {
    final controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('另存为', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '文件名',
            labelStyle: TextStyle(color: Color(0xFF9CDCFE)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF569CD6)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9CDCFE)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: Color(0xFF569CD6))),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(ctx, name);
            },
            child: const Text('保存', style: TextStyle(color: Color(0xFF4EC9B0))),
          ),
        ],
      ),
    );
  }
}
