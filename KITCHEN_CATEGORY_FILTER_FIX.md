# Fix: Print Kategori Minuman di Dapur2

## Masalah
Di dapur, ketika print detail pesanan, kategori minuman tidak sesuai dengan printer dapur2. Semua item dicetak ke semua printer tanpa memperhatikan kategori.

## Solusi
Menambahkan logika filter kategori di `BluetoothPrinterManager` untuk memisahkan item berdasarkan kategori:
- **dapur1** (Printer Makanan): Hanya mencetak item yang BUKAN kategori "minuman"
- **dapur2** (Printer Minuman): Hanya mencetak item dengan kategori "minuman"
- **admin** (Printer Admin): Mencetak semua item

## Perubahan File

### 1. `lib/screens/printer/BluetoothPrinterManager.dart`
- **Fungsi `_generateRoleSpecificPrintData`**: 
  - Menambahkan filter items berdasarkan role printer
  - Menampilkan store name di header struk
  - Menampilkan jumlah item yang difilter untuk kitchen printers
  - Menambahkan checkbox di setiap item untuk ceklis manual
  
- **Fungsi baru `_filterItemsByRole`**:
  - Memfilter items berdasarkan kategori
  - dapur1: exclude items dengan kategori "minuman"
  - dapur2: hanya items dengan kategori "minuman"
  - admin: semua items
  - Menambahkan debug logging untuk tracking

### 2. `lib/models/kitchen/kitchen_model.dart`
- **Model KitchenModel**:
  - Menambahkan field `storeName` (optional)
  - Update `fromJson` untuk parse `store_name` dari API
  - Update `toJson` untuk include `store_name`

### 3. `lib/screens/kitchen/kitchen_screen.dart`
- **Fungsi `_printOrderDetails`**:
  - Menambahkan `categoryName` ke dalam orderData items
  - Menambahkan `storeName` ke dalam orderData
  - Memastikan data kategori dikirim ke printer manager

### 4. `lib/controller/kitchen/kitchen_controller.dart`
- **Fungsi `_printKitchenOrder`**:
  - Menambahkan `storeName` ke dalam orderData
  - Sudah menyertakan `categoryName` di items

- **Fungsi `_printKitchenReceipt`**:
  - Menghapus logika pemisahan manual items
  - Menggunakan auto-filter dari BluetoothPrinterManager
  - Mencetak ke dapur1 dan dapur2 dengan data lengkap
  - Filter otomatis dilakukan di printer manager

## Cara Kerja

1. **Manual Print** (dari kitchen_screen):
   - User klik tombol Print di detail pesanan
   - Data pesanan disiapkan dengan `categoryName` untuk setiap item
   - `printToAllWithContent()` dipanggil
   - Setiap printer menerima data lengkap
   - Filter kategori diterapkan di `_generateRoleSpecificPrintData`

2. **Auto Print** (dari kitchen_controller):
   - Ketika status pesanan berubah ke "PROCESSED"
   - `_printKitchenOrder()` dipanggil
   - Data pesanan disiapkan dengan `categoryName`
   - `_printKitchenReceipt()` mencetak ke dapur1 dan dapur2
   - Filter kategori diterapkan otomatis

## Kategori yang Dikenali

### Minuman (dapur2):
- Kategori dengan nama "minuman" (case-insensitive)
- Kategori dengan kata "beverage"
- Kategori dengan kata "drink"

### Makanan (dapur1):
- Semua kategori SELAIN yang disebutkan di atas

## Fitur Tambahan

### Checkbox untuk Ceklis Manual
Setiap item di struk print memiliki checkbox `[ ]` di pojok kanan untuk karyawan bisa ceklis dengan pulpen setelah item selesai dibuat.

### Store Name di Header
Nama toko (store_name) dari API akan ditampilkan di header struk menggantikan "SHAOKAO" default.

Format struk lengkap:
```
      KITCHEN MINUMAN
      ---------------

      == GAMMA ==

ID Pesanan: ABC12345
Tanggal: 2024-01-15 10:30
Customer: John Doe
Meja: 5
Status: PAID
Status Masakan: PROCESSED
--------------------------------
ITEMS:
Es Teh Manis             [ ]
  1x @ Rp5000
  Note: Gula sedikit

Es Jeruk                 [ ]
  2x @ Rp7000

--------------------------------
TOTAL ITEM: 2

      Terima kasih!
      2024-01-15 10:30:45
```

## Testing

Untuk menguji perubahan:

1. **Setup Printer**:
   - Hubungkan printer ke dapur1 (Makanan)
   - Hubungkan printer ke dapur2 (Minuman)

2. **Test Manual Print**:
   - Buka detail pesanan yang memiliki item makanan dan minuman
   - Klik tombol Print
   - Verifikasi:
     - dapur1 hanya mencetak item makanan dengan checkbox
     - dapur2 hanya mencetak item minuman dengan checkbox
     - admin mencetak semua item dengan checkbox
     - Checkbox muncul di pojok kanan setiap item

3. **Test Auto Print**:
   - Aktifkan Auto Print di kitchen screen
   - Ubah status pesanan ke PROCESSED
   - Verifikasi print otomatis dengan filter kategori yang benar

4. **Debug Logging**:
   - Periksa console log untuk melihat:
     - Item filtering process
     - Kategori setiap item
     - Hasil filter untuk setiap printer

## Catatan Penting

- Pastikan data `categoryName` ada di API response
- Kategori harus konsisten (gunakan "minuman" untuk semua item minuman)
- Jika item tidak memiliki kategori, akan masuk ke dapur1 (makanan)
- Debug logging dapat dihapus setelah testing selesai
