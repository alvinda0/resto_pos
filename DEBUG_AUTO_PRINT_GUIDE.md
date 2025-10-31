# 🔍 Debug Auto Print - Troubleshooting Guide

## Masalah: Auto Print Tidak Berjalan

### Step 1: Cek Console Log
Buka Developer Console dan lihat log berikut:

```
✅ NORMAL LOG:
KitchenController: Starting auto refresh with 10s interval
KitchenController: Auto refresh tick - enabled: true
KitchenController: Fetching kitchens - autoRefresh: true
KitchenController: API response received - X items
KitchenController: Auto print enabled: true
KitchenController: Checking for new orders to print...
KitchenController: Checking X orders for auto print
KitchenController: Order ABC12345 - Status: processed - Already printed: false
KitchenController: Found 1 orders to auto print
KitchenController: Auto printing order ABC12345 (processed)
KitchenController: Successfully auto printed order ABC12345

❌ ERROR LOG:
- Tidak ada log "Auto refresh tick" → Auto refresh tidak aktif
- Tidak ada log "Checking for new orders" → Auto print tidak aktif
- Log "No new orders to print" → Tidak ada pesanan RECEIVED baru
- Log "Failed to auto print" → Masalah printer
```

### Step 2: Cek UI Status
1. **Toggle Auto Refresh** harus berwarna biru (aktif)
2. **Toggle Auto Print** harus berwarna hijau dengan border tebal
3. **Teks "Pesanan baru otomatis cetak"** harus muncul

### Step 3: Debug dengan Tombol
Gunakan tombol debug yang sudah ditambahkan:

#### 🔄 Reset Print List
- Klik tombol "Reset Print List" (orange)
- Ini akan menghapus daftar pesanan yang sudah dicetak
- Berguna jika pesanan tidak tercetak karena sudah ada di daftar

#### 🖨️ Cek Printer
- Klik tombol "Cek Printer" (blue)
- Akan menampilkan status koneksi printer
- Pastikan ada printer yang terhubung

### Step 4: Test Manual
1. **Pastikan ada pesanan dengan status RECEIVED**
2. **Klik "Reset Print List"** untuk clear history
3. **Tunggu 10 detik** untuk auto refresh
4. **Lihat console log** untuk debug info

## Kemungkinan Masalah & Solusi

### 1. Auto Refresh Tidak Aktif
**Gejala:** Tidak ada log "Auto refresh tick"
**Solusi:** 
- Klik toggle "Auto Refresh" untuk mengaktifkan
- Restart halaman kitchen

### 2. Auto Print Tidak Aktif  
**Gejala:** Tidak ada log "Checking for new orders"
**Solusi:**
- Klik toggle "Auto Print" untuk mengaktifkan
- Pastikan border hijau tebal muncul

### 3. Tidak Ada Pesanan PROCESSED
**Gejala:** Log "No new orders to print"
**Solusi:**
- Cek filter status, pastikan tidak terlalu spesifik
- Buat pesanan baru dari aplikasi lain
- Pastikan pesanan memiliki status "PROCESSED"

### 4. Pesanan Sudah Dicetak
**Gejala:** Log "Already printed: true"
**Solusi:**
- Klik tombol "Reset Print List"
- Atau restart aplikasi

### 5. Printer Tidak Terhubung
**Gejala:** Log "Failed to auto print" atau "No printer connected"
**Solusi:**
- Klik tombol "Cek Printer"
- Pastikan Bluetooth aktif
- Reconnect printer di menu printer management

### 6. API Error
**Gejala:** Log "Error fetching kitchens"
**Solusi:**
- Cek koneksi internet
- Pastikan API server berjalan
- Test dengan refresh manual

## Debug Commands

### Console Commands (untuk developer)
```javascript
// Cek status auto print
console.log('Auto Print:', kitchenController.isAutoPrintEnabled.value);

// Cek daftar pesanan yang sudah dicetak
console.log('Printed Orders:', kitchenController._printedOrderIds);

// Reset daftar print
kitchenController.resetPrintedOrders();
```

### Test Scenario
1. **Buat pesanan baru** dengan status PROCESSED
2. **Klik "Reset Print List"** 
3. **Pastikan toggle aktif** (hijau + biru)
4. **Tunggu 10 detik**
5. **Cek console log** untuk debug info
6. **Pesanan harus otomatis tercetak**

## Expected Behavior

### ✅ Normal Flow:
```
1. Auto refresh setiap 10 detik
2. Deteksi pesanan PROCESSED yang belum dicetak
3. Auto print ke semua printer
4. Notifikasi sukses muncul
5. Order ID disimpan untuk prevent duplikat
```

### ❌ Error Flow:
```
1. Toggle tidak aktif → Tidak ada auto refresh/print
2. Tidak ada printer → Print gagal dengan notifikasi
3. Pesanan sudah dicetak → Skip dengan log
4. API error → Error log tanpa notifikasi
```

## Quick Fix Checklist

- [ ] Toggle Auto Refresh aktif (biru)
- [ ] Toggle Auto Print aktif (hijau + border tebal)
- [ ] Ada pesanan dengan status PROCESSED
- [ ] Printer terhubung (cek dengan tombol)
- [ ] Reset print list jika perlu
- [ ] Cek console log untuk error
- [ ] Test dengan pesanan baru

Jika semua checklist ✅ tapi masih tidak berjalan, restart aplikasi dan ulangi test.