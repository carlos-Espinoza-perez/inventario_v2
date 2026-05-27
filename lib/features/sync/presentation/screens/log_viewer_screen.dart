import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/services/app_logger.dart';

class LogViewerScreen extends ConsumerStatefulWidget {
  const LogViewerScreen({super.key});

  @override
  ConsumerState<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends ConsumerState<LogViewerScreen>
    with AppBarConfigMixin {
  String _logContent = "Cargando logs...";
  String _filterKeyword = "";
  bool _onlyErrors = false;

  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Logs del Sistema',
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadLogs,
          tooltip: 'Recargar',
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: _copyToClipboard,
          tooltip: 'Copiar Logs',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _clearLogs,
          tooltip: 'Limpiar Logs',
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await AppLogger().getLogs();
    if (mounted) {
      setState(() {
        _logContent = logs;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _logContent));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logs copiados al portapapeles")),
      );
    }
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Limpiar Logs"),
        content: const Text("¿Estás seguro de querer borrar el historial de logs?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Limpiar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppLogger().clearLogs();
      await _loadLogs();
    }
  }

  List<String> _getFilteredLines() {
    final lines = _logContent.split('\n');
    return lines.where((line) {
      if (line.trim().isEmpty) return false;
      if (_onlyErrors && !line.contains('[ERROR]')) return false;
      if (_filterKeyword.isNotEmpty && !line.toLowerCase().contains(_filterKeyword.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLines = _getFilteredLines();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[850],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Filtrar por texto...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    onChanged: (val) => setState(() => _filterKeyword = val),
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text("Solo Errores", style: TextStyle(color: Colors.white)),
                  selected: _onlyErrors,
                  selectedColor: Colors.red[800],
                  backgroundColor: Colors.grey[800],
                  onSelected: (val) => setState(() => _onlyErrors = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: filteredLines.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final line = filteredLines[index];
                final isError = line.contains('[ERROR]');
                final isWarn = line.contains('[WARN]');

                Color textColor = Colors.grey[300]!;
                if (isError) textColor = Colors.red[400]!;
                if (isWarn) textColor = Colors.amber[400]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SelectableText(
                    line,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: textColor,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[850],
            width: double.infinity,
            child: Text(
              "Mostrando ${filteredLines.length} líneas",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
