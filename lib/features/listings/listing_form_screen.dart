import 'package:flutter/material.dart';
import '../../core/models/listing_model.dart';
import '../../core/models/user_model.dart';
import '../../core/services/listing_service.dart';

class ListingFormScreen extends StatefulWidget {
  final UserModel user;
  final ListingModel? listing;

  const ListingFormScreen({super.key, required this.user, this.listing});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _areaCtrl;

  String _propertyType = 'Daire';
  String? _roomCount;
  String _status = 'active';
  bool _loading = false;

  static const _propertyTypes = [
    'Daire',
    'Müstakil',
    'Villa',
    'İşyeri',
    'Arsa',
    'Depo',
  ];

  static const _roomCounts = [
    '1+0',
    '1+1',
    '2+1',
    '3+1',
    '4+1',
    '5+1',
    '6+',
  ];

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _titleCtrl = TextEditingController(text: l?.title ?? '');
    _descCtrl = TextEditingController(text: l?.description ?? '');
    _priceCtrl = TextEditingController(
        text: l != null ? l.price.toStringAsFixed(0) : '');
    _locationCtrl = TextEditingController(text: l?.location ?? '');
    _areaCtrl = TextEditingController(
        text: l?.area != null ? l!.area!.toStringAsFixed(0) : '');
    if (l != null) {
      _propertyType = l.propertyType;
      _roomCount = l.roomCount;
      _status = l.status;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final price = double.parse(_priceCtrl.text.replaceAll(',', ''));
      final area = _areaCtrl.text.isNotEmpty
          ? double.tryParse(_areaCtrl.text)
          : null;

      if (_isEditing) {
        await ListingService.updateListing(
          id: widget.listing!.id,
          userId: widget.user.id,
          userEmail: widget.user.email,
          userName: widget.user.fullName,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          price: price,
          location: _locationCtrl.text.trim(),
          propertyType: _propertyType,
          roomCount: _roomCount,
          area: area,
          status: _status,
        );
      } else {
        await ListingService.createListing(
          ownerId: widget.user.id,
          ownerEmail: widget.user.email,
          ownerName: widget.user.fullName,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          price: price,
          location: _locationCtrl.text.trim(),
          propertyType: _propertyType,
          roomCount: _roomCount,
          area: area,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'İlan güncellendi' : 'İlan eklendi'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(_isEditing ? 'İlanı Düzenle' : 'Yeni İlan Ekle'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Temel Bilgiler'),
              TextFormField(
                controller: _titleCtrl,
                decoration: _dec('Başlık', Icons.title),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Başlık gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: _dec('Açıklama (isteğe bağlı)', Icons.description_outlined),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _section('Konum & Fiyat'),
              TextFormField(
                controller: _locationCtrl,
                decoration: _dec('Konum', Icons.location_on_outlined),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Konum gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: _dec('Fiyat (₺)', Icons.currency_lira),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Fiyat gerekli';
                  if (double.tryParse(v.replaceAll(',', '')) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _section('Özellikler'),
              DropdownButtonFormField<String>(
                initialValue: _propertyType,
                decoration: _dec('Emlak Türü', Icons.home_outlined),
                items: _propertyTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _roomCount,
                decoration: _dec('Oda Sayısı (isteğe bağlı)', Icons.meeting_room_outlined),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Belirtme')),
                  ..._roomCounts.map(
                    (r) => DropdownMenuItem(value: r, child: Text(r)),
                  ),
                ],
                onChanged: (v) => setState(() => _roomCount = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaCtrl,
                decoration: _dec('Alan (m², isteğe bağlı)', Icons.square_foot),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (double.tryParse(v) == null) return 'Geçerli bir sayı girin';
                  return null;
                },
              ),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                _section('Durum'),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: _dec('İlan Durumu', Icons.toggle_on_outlined),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Aktif')),
                    DropdownMenuItem(value: 'passive', child: Text('Pasif')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Güncelle' : 'İlanı Yayınla',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
