import 'package:flutter/material.dart';

class EntityScreen extends StatefulWidget {
  const EntityScreen({super.key});

  @override
  State<EntityScreen> createState() => _EntityScreenState();
}

class _EntityScreenState extends State<EntityScreen> {
  static const _entities = [
    {
      'name': 'VILLA SAHİBİ',
      'pk': 'SAHİP_ID',
      'attributes': ['AD', 'SOYAD', 'TELEFON', 'E-POSTA'],
    },
    {
      'name': 'BÖLGE',
      'pk': 'BOLGE_ID',
      'attributes': ['BÖLGE_ADI', 'İL', 'İLÇE', 'AÇIKLAMA', 'DARYA_SAYISI'],
    },
    {
      'name': 'VILLA / EMLAK',
      'pk': 'VILLA_ID',
      'attributes': [
        'VILLA_ADI',
        'DURUM',
        'GECELİK_FİYAT',
        'ODA_SAYISI',
        'YATAK_SAYISI',
        'ADRES',
      ],
    },
    {
      'name': 'İLAN',
      'pk': 'İLAN_ID',
      'attributes': [
        'İLAN_BAŞLIĞI',
        'İLAN_AÇIKLAMASI',
        'İLAN_TARİHİ',
        'İLAN_DURUMU',
      ],
    },
    {
      'name': 'REZERVASYON',
      'pk': 'REZERVASYON_ID',
      'attributes': [
        'GİRİŞ_TARİHİ',
        'ÇIKIŞ_TARİHİ',
        'REZERVASYON_DURUMU',
        'TOPLAM_TUTAR',
        'ÖDEME_SAYISI',
        'TOPLAM_HATA',
      ],
    },
    {
      'name': 'ÖDEME',
      'pk': 'ÖDEME_ID',
      'attributes': [
        'ÖDEME_TARİHİ',
        'ÖDEME_TUTARI',
        'ÖDEME_YÖNTEMİ',
        'ÖDEME_DURUMU',
      ],
    },
    {
      'name': 'TEKLİF',
      'pk': 'TEKLİF_ID',
      'attributes': [
        'TEKLİF_TUTARI',
        'TEKLİF_TARİHİ',
        'TEKLİF_DURUMU',
        'AÇIKLAMA',
      ],
    },
    {
      'name': 'MÜŞTERİ',
      'pk': 'MÜŞTERİ_ID',
      'attributes': ['AD', 'SOYAD', 'TELEFON', 'E-POSTA'],
    },
    {
      'name': 'EMLAK DANIŞMANI',
      'pk': 'DANIŞMAN_ID',
      'attributes': ['AD', 'SOYAD', 'E-MAİL', 'TELEFON', 'GÖREV'],
    },
    {
      'name': 'GÖRÜŞME',
      'pk': 'GÖRÜŞME_ID',
      'attributes': [
        'GÖRÜŞME_TARİHİ',
        'GÖRÜŞME_SAATİ',
        'GÖRÜŞME_TİPİ',
        'SONUÇ',
        'GÖRÜŞME_NOTU',
      ],
    },
    {
      'name': 'İLETİŞİM',
      'pk': 'İLETİŞİM_ID',
      'attributes': [
        'AD_SOYAD',
        'TELEFON',
        'KONU',
        'E-POSTA',
        'MESAJ',
        'İLETİŞİM_TARİHİ',
        'DURUM',
      ],
    },
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tabIndex = 0;
  bool _searching = false;
  String _query = '';
  final _searchCtrl = TextEditingController();

  static const _tabEntityNames = ['BÖLGE', 'REZERVASYON', 'İLETİŞİM'];

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return List<Map<String, dynamic>>.from(_entities);
    final q = _query.toLowerCase();
    return _entities
        .where((e) => (e['name'] as String).toLowerCase().contains(q))
        .toList()
        .cast<Map<String, dynamic>>();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showDetail(BuildContext context, Map<String, dynamic> entity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                entity['name'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Primary Key',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFC8E6C9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2E7D32)),
              ),
              child: Text(
                entity['pk'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF1B5E20),
                  decorationThickness: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nitelikler',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ...(entity['attributes'] as List<String>).map(
              (attr) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.circle,
                        size: 6, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 10),
                    Text(attr, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityDetail(Map<String, dynamic> entity) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              entity['name'] as String,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Primary Key',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFC8E6C9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2E7D32)),
            ),
            child: Text(
              entity['pk'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF1B5E20),
                decorationThickness: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Nitelikler',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          ...(entity['attributes'] as List<String>).map(
            (attr) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.circle,
                    size: 8, color: Color(0xFF2E7D32)),
                title: Text(attr,
                    style:
                        const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('"$_query" bulunamadı',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
        ),
        itemCount: _filtered.length,
        itemBuilder: (context, i) {
          final entity = _filtered[i];
          return ElevatedButton(
            onPressed: () => _showDetail(context, entity),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              entity['name'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_tabIndex == 0) return _buildHome();
    final entity = Map<String, dynamic>.from(
      _entities.firstWhere(
          (e) => e['name'] == _tabEntityNames[_tabIndex - 1]),
    );
    return _buildEntityDetail(entity);
  }

  Widget _drawerItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F8E9),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.home_work_outlined,
                        color: Colors.white, size: 44),
                    SizedBox(height: 10),
                    Text(
                      'Villago',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(Icons.home_outlined, 'Ana Sayfa'),
                  const Divider(height: 1, indent: 56),
                  _drawerItem(Icons.map_outlined, 'Bölgeler'),
                  const Divider(height: 1, indent: 56),
                  _drawerItem(Icons.calendar_month_outlined, 'Rezervasyon'),
                  const Divider(height: 1, indent: 56),
                  _drawerItem(Icons.villa_outlined, 'Villanızı Kiraya Verelim'),
                  const Divider(height: 1, indent: 56),
                  _drawerItem(Icons.payment_outlined, 'Ödeme'),
                  const Divider(height: 1, indent: 56),
                  _drawerItem(Icons.business_outlined, 'Kurumsal'),
                  const Divider(height: 1, indent: 56),
                  _drawerItem(Icons.contact_mail_outlined, 'İletişim'),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Varlık ara...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Villago'),
        actions: [
          if (_tabIndex == 0)
            _searching
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _searching = false;
                      _query = '';
                      _searchCtrl.clear();
                    }),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _searching = true),
                  ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() {
          _tabIndex = i;
          _searching = false;
          _query = '';
          _searchCtrl.clear();
        }),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined), label: 'Bölgeler'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Rezervasyon'),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail_outlined), label: 'İletişim'),
        ],
      ),
      body: _buildBody(),
    );
  }
}
