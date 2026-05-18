import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/meeting_model.dart';
import '../../core/models/user_model.dart';
import '../../core/services/meeting_service.dart';

class MeetingsScreen extends StatefulWidget {
  final UserModel user;

  const MeetingsScreen({super.key, required this.user});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<MeetingModel> _meetings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadMeetings();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMeetings() async {
    setState(() => _loading = true);
    try {
      final data = await MeetingService.getMeetings(widget.user.id);
      if (mounted) setState(() => _meetings = data);
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

  List<MeetingModel> _filtered(String status) =>
      _meetings.where((m) => m.status == status).toList();

  Future<void> _updateStatus(MeetingModel meeting, String status) async {
    try {
      await MeetingService.updateMeetingStatus(
        id: meeting.id,
        userId: widget.user.id,
        userEmail: widget.user.email,
        userName: widget.user.fullName,
        status: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              status == 'onaylandi' ? 'Görüşme onaylandı' : 'Görüşme iptal edildi'),
          backgroundColor: Colors.green,
        ),
      );
      _loadMeetings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Görüşmeler'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMeetings),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Bekleyen (${_filtered('beklemede').length})',
            ),
            Tab(
              text: 'Onaylı (${_filtered('onaylandi').length})',
            ),
            Tab(
              text: 'İptal (${_filtered('iptal').length})',
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _MeetingList(
                  meetings: _filtered('beklemede'),
                  user: widget.user,
                  onStatusChange: _updateStatus,
                  emptyMsg: 'Bekleyen görüşme yok',
                ),
                _MeetingList(
                  meetings: _filtered('onaylandi'),
                  user: widget.user,
                  onStatusChange: _updateStatus,
                  emptyMsg: 'Onaylanan görüşme yok',
                ),
                _MeetingList(
                  meetings: _filtered('iptal'),
                  user: widget.user,
                  onStatusChange: _updateStatus,
                  emptyMsg: 'İptal edilen görüşme yok',
                ),
              ],
            ),
    );
  }
}

class _MeetingList extends StatelessWidget {
  final List<MeetingModel> meetings;
  final UserModel user;
  final Future<void> Function(MeetingModel, String) onStatusChange;
  final String emptyMsg;

  const _MeetingList({
    required this.meetings,
    required this.user,
    required this.onStatusChange,
    required this.emptyMsg,
  });

  @override
  Widget build(BuildContext context) {
    if (meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(emptyMsg, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => onStatusChange(meetings.first, meetings.first.status),
      color: const Color(0xFF2E7D32),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: meetings.length,
        itemBuilder: (_, i) => _MeetingCard(
          meeting: meetings[i],
          user: user,
          onStatusChange: onStatusChange,
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final UserModel user;
  final Future<void> Function(MeetingModel, String) onStatusChange;

  const _MeetingCard({
    required this.meeting,
    required this.user,
    required this.onStatusChange,
  });

  bool get _isOwner => user.id == meeting.ownerId;

  Color get _statusColor {
    switch (meeting.status) {
      case 'onaylandi':
        return Colors.green;
      case 'iptal':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meeting.listingTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor.withAlpha(128)),
                  ),
                  child: Text(
                    meeting.statusDisplay,
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(meeting.listingLocation,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  dateFmt.format(meeting.meetingDate.toLocal()),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  _isOwner ? Icons.person_search : Icons.real_estate_agent,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOwner
                      ? 'Müşteri: ${meeting.customerName}'
                      : 'Sahip: ${meeting.ownerName}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            if (meeting.notes != null && meeting.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      meeting.notes!,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
            if (_isOwner && meeting.status == 'beklemede') ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onStatusChange(meeting, 'iptal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('İptal Et'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusChange(meeting, 'onaylandi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Onayla'),
                    ),
                  ),
                ],
              ),
            ],
            if (!_isOwner && meeting.status == 'beklemede') ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onStatusChange(meeting, 'iptal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Talebi İptal Et'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
