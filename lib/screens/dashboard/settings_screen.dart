import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoBackup = true;
  String _currency = 'IDR';
  String _language = 'Bahasa Indonesia';

  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'MYR'];
  final List<String> _languages = ['Bahasa Indonesia', 'English'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // General Settings
                    _buildSettingsSection(
                      'Pengaturan Umum',
                      [
                        _buildDropdownSetting(
                          'Mata Uang',
                          _currency,
                          _currencies,
                          Icons.attach_money,
                          (value) => setState(() => _currency = value!),
                        ),
                        _buildDropdownSetting(
                          'Bahasa',
                          _language,
                          _languages,
                          Icons.language,
                          (value) => setState(() => _language = value!),
                        ),
                        _buildSwitchSetting(
                          'Mode Gelap',
                          'Aktifkan tampilan mode gelap',
                          _darkModeEnabled,
                          Icons.dark_mode,
                          (value) => setState(() => _darkModeEnabled = value),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Notification Settings
                    _buildSettingsSection(
                      'Notifikasi',
                      [
                        _buildSwitchSetting(
                          'Notifikasi',
                          'Terima notifikasi untuk transaksi dan update',
                          _notificationEnabled,
                          Icons.notifications,
                          (value) =>
                              setState(() => _notificationEnabled = value),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Data & Backup Settings
                    _buildSettingsSection(
                      'Data & Backup',
                      [
                        _buildSwitchSetting(
                          'Auto Backup',
                          'Backup otomatis data setiap hari',
                          _autoBackup,
                          Icons.backup,
                          (value) => setState(() => _autoBackup = value),
                        ),
                        _buildActionSetting(
                          'Backup Manual',
                          'Backup data sekarang',
                          Icons.cloud_upload,
                          () => _showBackupDialog(),
                        ),
                        _buildActionSetting(
                          'Restore Data',
                          'Pulihkan data dari backup',
                          Icons.restore,
                          () => _showRestoreDialog(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Store Settings
                    _buildSettingsSection(
                      'Pengaturan Toko',
                      [
                        _buildActionSetting(
                          'Informasi Toko',
                          'Nama, alamat, dan kontak toko',
                          Icons.store,
                          () => _showStoreInfoDialog(),
                        ),
                        _buildActionSetting(
                          'Printer Setting',
                          'Konfigurasi printer untuk struk',
                          Icons.print,
                          () => _showPrinterDialog(),
                        ),
                        _buildActionSetting(
                          'Pajak Setting',
                          'Pengaturan pajak dan diskon',
                          Icons.percent,
                          () => _showTaxDialog(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Account Settings
                    _buildSettingsSection(
                      'Akun',
                      [
                        _buildActionSetting(
                          'Profil Pengguna',
                          'Edit informasi profil Anda',
                          Icons.person,
                          () => _showProfileDialog(),
                        ),
                        _buildActionSetting(
                          'Ubah Password',
                          'Ganti password akun Anda',
                          Icons.lock,
                          () => _showPasswordDialog(),
                        ),
                        _buildActionSetting(
                          'Kelola Pengguna',
                          'Tambah atau hapus pengguna',
                          Icons.group,
                          () => _showUserManagementDialog(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // About Section
                    _buildSettingsSection(
                      'Tentang',
                      [
                        _buildActionSetting(
                          'Versi Aplikasi',
                          'v1.0.0',
                          Icons.info,
                          () => _showAboutDialog(),
                        ),
                        _buildActionSetting(
                          'Bantuan & Support',
                          'Hubungi tim support',
                          Icons.help,
                          () => _showHelpDialog(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.deepPurple,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String value,
    List<String> options,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
            'Apakah Anda yakin ingin melakukan backup data sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Backup berhasil dilakukan');
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
            'Pilih file backup untuk dipulihkan. Data saat ini akan diganti.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Data berhasil dipulihkan');
            },
            child: const Text('Pilih File'),
          ),
        ],
      ),
    );
  }

  void _showStoreInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informasi Toko'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Toko',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Informasi toko berhasil disimpan');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showPrinterDialog() {
    _showInfoDialog(
        'Printer Setting', 'Fitur pengaturan printer akan segera tersedia.');
  }

  void _showTaxDialog() {
    _showInfoDialog(
        'Pajak Setting', 'Fitur pengaturan pajak akan segera tersedia.');
  }

  void _showProfileDialog() {
    _showInfoDialog(
        'Profil Pengguna', 'Fitur edit profil akan segera tersedia.');
  }

  void _showPasswordDialog() {
    _showInfoDialog(
        'Ubah Password', 'Fitur ubah password akan segera tersedia.');
  }

  void _showUserManagementDialog() {
    _showInfoDialog(
        'Kelola Pengguna', 'Fitur kelola pengguna akan segera tersedia.');
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Aplikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shao Kao v1.0.0'),
            SizedBox(height: 8),
            Text(
                'Aplikasi Point of Sale untuk membantu mengelola bisnis Anda.'),
            SizedBox(height: 16),
            Text('Dikembangkan dengan Flutter'),
            Text('© 2025 Shao Kao'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    _showInfoDialog('Bantuan & Support',
        'Hubungi kami di support@possystem.com atau telepon (021) 123-4567');
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
