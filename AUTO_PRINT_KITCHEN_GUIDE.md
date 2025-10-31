# Auto Print Kitchen - Panduan Implementasi

## Fitur Auto Print untuk Dapur

Fitur ini memungkinkan sistem untuk **otomatis mencetak pesanan** ketika ada data baru yang masuk ke dapur dengan status "PROCESSED" (sedang diproses).

## Cara Kerja

### 1. Auto Detection
- Sistem memantau data dapur setiap 10 detik (auto refresh)
- Ketika ada pesanan dengan status `PROCESSED` yang belum pernah dicetak
- Sistem otomatis akan mencetak pesanan tersebut ke semua printer yang terhubung

### 2. Role-Based Printing
- **Admin Printer**: Mencetak struk lengkap dengan nomor telepon customer
- **Kitchen Printer (dapur1/dapur2)**: Mencetak struk khusus dapur dengan catatan item

### 3. Kontrol Otomatis
- **Toggle Auto Print**: Bisa diaktifkan/nonaktifkan dari UI dapur
- **Auto Detection**: Sistem otomatis mendeteksi pesanan baru tanpa intervensi manual
- **Status Tracking**: Mencegah print duplikat dengan tracking order ID
- **Visual Indicator**: Badge hijau menunjukkan status aktif

## Implementasi

### KitchenController
```dart
// Auto print settings
var isAutoPrintEnabled = true.obs;
Set<String> _printedOrderIds = <String>{}; // Track printed orders

// Check for new orders and auto print
Future<void> _checkAndPrintNewOrders(List<KitchenModel> newOrders) async {
  List<KitchenModel> newOrdersToPrint = newOrders.where((order) {
    return order.dishStatus.toLowerCase() == 'received' && 
           !_printedOrderIds.contains(order.id);
  }).toList();
  
  // Print each new order
  for (KitchenModel order in newOrdersToPrint) {
    bool printSuccess = await _printKitchenOrder(order);
    if (printSuccess) {
      _printedOrderIds.add(order.id);
    }
  }
}
```

### UI Controls
```dart
// Auto Print Toggle dengan Visual Indicator
Widget _buildAutoPrintToggle() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: isAutoPrintEnabled ? Colors.green : Colors.grey,
        width: isAutoPrintEnabled ? 2 : 1,
      ),
    ),
    child: Row(
      children: [
        Stack(
          children: [
            Icon(Icons.print),
            if (isAutoPrintEnabled) // Green dot indicator
              Positioned(child: Container(/* green dot */)),
          ],
        ),
        Text('Auto Print'),
        Switch(value: isAutoPrintEnabled),
      ],
    ),
  );
}
```

## Penggunaan

### 1. Aktivasi Auto Print
- Buka halaman Kitchen
- Toggle "Auto Print" di bagian filter (akan berwarna hijau dengan border tebal)
- Sistem akan otomatis mencetak pesanan PROCESSED setiap 10 detik

### 2. Monitoring Otomatis
- Status auto print ditampilkan dengan:
  - **Aktif**: Border hijau tebal + dot hijau + teks "Pesanan PROCESSED otomatis cetak"
  - **Nonaktif**: Border abu-abu tipis
- Notifikasi muncul ketika pesanan berhasil/gagal dicetak otomatis
- Log print tersimpan untuk mencegah duplikasi

### 3. Tidak Ada Aksi Manual
- **Tidak ada tombol print manual** - semua berjalan otomatis
- Sistem mendeteksi pesanan baru dan langsung mencetak
- User hanya perlu memastikan toggle "Auto Print" aktif

## Keuntungan

1. **Sepenuhnya Otomatis**: Tidak perlu aksi manual sama sekali
2. **Real-time**: Pesanan langsung tercetak dalam 10 detik setelah masuk
3. **Multi-printer**: Support untuk beberapa printer sekaligus
4. **Role-based**: Setiap printer mencetak format sesuai perannya
5. **Zero-touch**: Staff dapur tidak perlu menekan tombol apapun
6. **Visual Feedback**: Indikator jelas untuk status aktif/nonaktif

## Troubleshooting

### Auto Print Tidak Berjalan
1. Pastikan toggle "Auto Print" dalam keadaan aktif
2. Cek koneksi printer di menu printer management
3. Pastikan auto refresh aktif (toggle hijau)

### Print Gagal
1. Cek status koneksi Bluetooth printer
2. Restart koneksi printer jika perlu
3. Test print manual untuk memastikan printer berfungsi

### Duplikasi Print
- Sistem otomatis mencegah duplikasi dengan tracking order ID
- Jika terjadi duplikasi, restart aplikasi untuk reset tracking

## Konfigurasi

### Auto Refresh Interval
```dart
final int autoRefreshInterval = 30; // detik
```

### Print Status Filter
```dart
// Hanya print pesanan dengan status RECEIVED
return order.dishStatus.toLowerCase() == 'received' && 
       !_printedOrderIds.contains(order.id);
```

Fitur ini sangat membantu untuk meningkatkan efisiensi operasional dapur dengan memastikan setiap pesanan baru langsung tercetak tanpa intervensi manual.