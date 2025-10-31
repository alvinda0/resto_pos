# 🔍 Debug Print Issue - Panduan Troubleshooting

## Masalah
Printer makanan dan minuman masih ikut print ketika new order dan payment, padahal seharusnya hanya admin.

## Debug Logging yang Ditambahkan

### 1. **PrintServiceOrder.dart (New Order)**
```
PrintService: ===== DEBUGGING PRINT CALL =====
PrintService: About to call printToRoleWithContent for ADMIN ONLY
PrintService: Connected printers: X
PrintService: Available printer roles: [admin, dapur1, dapur2]
PrintService: Admin printer result: true/false
PrintService: ===== END DEBUGGING PRINT CALL =====
```

### 2. **ReceiptPrinterService.dart (Payment)**
```
ReceiptPrinterService: ===== DEBUGGING PAYMENT PRINT CALL =====
ReceiptPrinterService: About to call printToRoleWithContent for ADMIN ONLY
ReceiptPrinterService: Connected printers: X
ReceiptPrinterService: Available printer roles: [admin, dapur1, dapur2]
ReceiptPrinterService: Admin printer result: true/false
ReceiptPrinterService: ===== END DEBUGGING PAYMENT PRINT CALL =====
```

### 3. **BluetoothPrinterManager.dart**
```
MultiPrinterManager: ===== PRINT TO ROLE WITH CONTENT DEBUG =====
MultiPrinterManager: Requested role: admin
MultiPrinterManager: All available printers: [admin, dapur1, dapur2]
MultiPrinterManager: Printing ONLY to role: admin
MultiPrinterManager: NOT printing to other roles: [dapur1, dapur2]
MultiPrinterManager: Print result for admin: true/false
MultiPrinterManager: ===== END PRINT TO ROLE WITH CONTENT DEBUG =====
```

## Cara Debug

### Step 1: Buka Developer Console
- Buka aplikasi
- Buka Developer Tools (F12)
- Buka tab Console

### Step 2: Test New Order
1. Buat pesanan baru
2. Lihat console log
3. Cari log yang dimulai dengan "===== DEBUGGING PRINT CALL ====="
4. Pastikan hanya ada 1 call ke "admin"

### Step 3: Test Payment
1. Bayar pesanan
2. Lihat console log
3. Cari log yang dimulai dengan "===== DEBUGGING PAYMENT PRINT CALL ====="
4. Pastikan hanya ada 1 call ke "admin"

## Kemungkinan Masalah

### 1. **Multiple Print Calls**
**Gejala:** Ada beberapa log debug yang muncul
**Penyebab:** Ada method print lain yang dipanggil
**Solusi:** Cari method print lain yang belum diperbaiki

### 2. **Wrong Role Mapping**
**Gejala:** Log menunjukkan role "admin" tapi printer lain ikut print
**Penyebab:** Printer role mapping salah
**Solusi:** Cek konfigurasi printer role

### 3. **Fallback Print Method**
**Gejala:** Log benar tapi masih print ke semua
**Penyebab:** Ada fallback method yang print ke semua
**Solusi:** Cek BluetoothPrinterManager untuk fallback logic

### 4. **Multiple Printer Instances**
**Gejala:** Log tidak muncul atau berbeda
**Penyebab:** Ada instance PrintService lain
**Solusi:** Cek apakah ada multiple instance

## Expected Console Log (Normal)

### New Order:
```
PrintService: ===== DEBUGGING PRINT CALL =====
PrintService: About to call printToRoleWithContent for ADMIN ONLY
PrintService: Connected printers: 3
PrintService: Available printer roles: [admin, dapur1, dapur2]
MultiPrinterManager: ===== PRINT TO ROLE WITH CONTENT DEBUG =====
MultiPrinterManager: Requested role: admin
MultiPrinterManager: All available printers: [admin, dapur1, dapur2]
MultiPrinterManager: Printing ONLY to role: admin
MultiPrinterManager: NOT printing to other roles: [dapur1, dapur2]
MultiPrinterManager: Print result for admin: true
MultiPrinterManager: ===== END PRINT TO ROLE WITH CONTENT DEBUG =====
PrintService: Admin printer result: true
PrintService: ===== END DEBUGGING PRINT CALL =====
```

### Payment:
```
ReceiptPrinterService: ===== DEBUGGING PAYMENT PRINT CALL =====
ReceiptPrinterService: About to call printToRoleWithContent for ADMIN ONLY
ReceiptPrinterService: Connected printers: 3
ReceiptPrinterService: Available printer roles: [admin, dapur1, dapur2]
MultiPrinterManager: ===== PRINT TO ROLE WITH CONTENT DEBUG =====
MultiPrinterManager: Requested role: admin
MultiPrinterManager: All available printers: [admin, dapur1, dapur2]
MultiPrinterManager: Printing ONLY to role: admin
MultiPrinterManager: NOT printing to other roles: [dapur1, dapur2]
MultiPrinterManager: Print result for admin: true
MultiPrinterManager: ===== END PRINT TO ROLE WITH CONTENT DEBUG =====
ReceiptPrinterService: Admin printer result: true
ReceiptPrinterService: ===== END DEBUGGING PAYMENT PRINT CALL =====
```

## Troubleshooting Actions

### Jika Log Tidak Muncul:
1. Pastikan console terbuka
2. Refresh aplikasi
3. Coba lagi buat/bayar pesanan

### Jika Log Muncul Tapi Printer Lain Ikut Print:
1. Cek apakah ada log lain yang tidak diharapkan
2. Cek apakah ada multiple calls
3. Cek konfigurasi printer role

### Jika Log Menunjukkan Role Salah:
1. Cek printer role mapping
2. Cek apakah printer role sudah benar
3. Restart aplikasi dan reconnect printer

## Next Steps

Setelah melihat console log, kita bisa menentukan:
1. Apakah method print dipanggil dengan benar
2. Apakah ada method print lain yang dipanggil
3. Apakah ada masalah di BluetoothPrinterManager
4. Apakah ada masalah di printer role mapping

Silakan jalankan test dan share console log untuk analisis lebih lanjut! 🔍