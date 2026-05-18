import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/log_model.dart';
import '../../core/models/user_model.dart';
import '../../core/services/log_service.dart';

class LogsScreen extends StatefulWidget {
  final UserModel user;

  const LogsScreen({super.key, required this.user});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<LogModel> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    try {
      final data = await LogService.getLogs(widget.user.id);
      if (mounted) setState(() => _logs = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'GİRİŞ':
        return Icons.login;
      case 'ÇIKIŞ':
        return Icons.logout;
      case 'KAYIT':
        return Icons.person_add;
      case 'İLAN_EKLEME':
        return Icons.add_home;
      case 'İLAN_GÜNCELLEME':
        return Icons.edit_note;
      case 'İLAN_SİLME':
        return Icons.delete_outline;
      case 'GÖRÜŞME_TALEBİ':
        return Icons.calendar_month;
      case 'GÖRÜŞME_DURUM':
        return Icons.update;
      default:
        return Icons.info_outline;
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'GİRİŞ':
      case 'KAYIT':
        return Colors.green;
      case 'ÇIKIŞ':
        return Colors.grey;
      case 'İLAN_EKLEME':
        return Colors.blue;
      case 'İLAN_GÜNCELLEME':
        return Colors.orange;
      case 'İLAN_SİLME':
        return Colors.red;
      case 'GÖRÜŞME_TALEBİ':
      case 'GÖRÜŞME_DURUM':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('İşlem Logları'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLogs),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Henüz işlem yok',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  color: const Color(0xFF2E7D32),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _logs.length,
                    itemBuilder: (_, i) => _LogCard(
                      log: _logs[i],
                      icon: _actionIcon(_logs[i].action),
                      color: _actionColor(_logs[i].action),
                    ),
                  ),
                ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final LogModel log;
  final IconData icon;
  final Color color;

  const _LogCard({required this.log, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          log.action,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 13,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.details != null && log.details!.isNotEmpty)
              Text(log.details!, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              fmt.format(log.createdAt.toLocal()),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: log.details != null && log.details!.isNotEmpty,
      ),
    );
  }
}
