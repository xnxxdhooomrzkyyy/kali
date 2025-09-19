import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatPage extends StatefulWidget {
  final String kodeToko;

  const RiwayatPage({super.key, required this.kodeToko});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _data = [];

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final res = await supabase
          .from('pengiriman_retur')
          .select()
          .eq('kode_toko', widget.kodeToko)
          .order('tgl_pengiriman', ascending: false);

      setState(() {
        _data = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      debugPrint("Error load data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _bukaDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailRiwayatPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pengiriman NRB"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? const Center(child: Text("Belum ada data"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    final item = _data[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: item['bukti_foto'] != null
                            ? Image.network(
                                item['bukti_foto'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported, size: 40),
                        title: Text(
                          "NRB: ${item['nomor_nrb'] ?? '-'}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Tanggal: ${item['tgl_pengiriman'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['tgl_pengiriman'])) : '-'}"),
                            Text("Mobil: ${item['nomor_mobil'] ?? '-'}"),
                            Text("Driver: ${item['nama_driver'] ?? '-'}"),
                          ],
                        ),
                        onTap: () => _bukaDetail(item),
                      ),
                    );
                  },
                ),
    );
  }
}

class DetailRiwayatPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailRiwayatPage({super.key, required this.item});

  void _openPreview(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewPage(imageUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fotoUrl = item['bukti_foto'];

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pengiriman")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fotoUrl != null)
              Center(
                child: GestureDetector(
                  onTap: () => _openPreview(context, fotoUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      fotoUrl,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              const Center(
                child: Icon(Icons.image_not_supported, size: 100),
              ),
            const SizedBox(height: 24),

            Text("Nomor NRB: ${item['nomor_nrb'] ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            Text(
                "Tanggal: ${item['tgl_pengiriman'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['tgl_pengiriman'])) : '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            Text("Nomor Mobil: ${item['nomor_mobil'] ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            Text("Nama Driver: ${item['nama_driver'] ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            Text("Kode Toko: ${item['kode_toko'] ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            Text("Nama Toko: ${item['nama_toko'] ?? '-'}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}