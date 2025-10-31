# ✅ Status Change Detection - Hanya Print Data Baru

## Masalah Sebelumnya
- Sistem mencetak **semua pesanan dengan status PROCESSED**
- Termasuk pesanan lama yang sudah lama berstatus PROCESSED
- Tidak bisa membedakan pesanan baru vs pesanan lama

## Solusi Baru: Status Change Detection

### 🔍 **Logic Baru**
```dart
// Bandingkan data lama vs data baru
Map<String, KitchenModel> oldOrdersMap = {
  for (var order in oldOrders) order.id: order
};

for (var newOrder in newOrders) {
  KitchenModel? oldOrder = oldOrdersMap[newOrder.id];
  
  if (oldOrder == null) {
    // Pesanan benar-benar baru dengan status PROCESSED
    if (newOrder.dishStatus == 'processed') {
      print(); // Will be printed
    }
  } else {
    // Pesanan sudah ada, cek perubahan status
    bool statusChanged = oldOrder.dishStatus != newOrder.dishStatus;
    bool nowProcessed = newOrder.dishStatus == 'processed';
    
    if (statusChanged && nowProcessed) {
      print(); // Will be printed - status berubah ke PROCESSED
    }
  }
}
```

### 📊 **Skenario Print**

#### ✅ **AKAN DICETAK:**
1. **Pesanan baru** langsung dengan status PROCESSED
2. **Status berubah** dari RECEIVED → PROCESSED
3. **Status berubah** dari CANCELLED → PROCESSED
4. **Status berubah** dari apapun → PROCESSED

#### ❌ **TIDAK AKAN DICETAK:**
1. **Pesanan lama** yang sudah lama berstatus PROCESSED
2. **Status tidak berubah** (tetap PROCESSED)
3. **Status berubah** tapi bukan ke PROCESSED
4. **Pesanan sudah pernah dicetak** (ada di _printedOrderIds)

### 🔄 **Workflow Baru**

#### Refresh 1:
```
Data lama: []
Data baru: [Order A (RECEIVED), Order B (PROCESSED)]
Result: Order B dicetak (pesanan baru dengan status PROCESSED)
```

#### Refresh 2:
```
Data lama: [Order A (RECEIVED), Order B (PROCESSED)]
Data baru: [Order A (PROCESSED), Order B (PROCESSED)]
Result: Order A dicetak (status berubah RECEIVED → PROCESSED)
        Order B tidak dicetak (status tidak berubah)
```

#### Refresh 3:
```
Data lama: [Order A (PROCESSED), Order B (PROCESSED)]
Data baru: [Order A (PROCESSED), Order B (PROCESSED), Order C (PROCESSED)]
Result: Order C dicetak (pesanan baru dengan status PROCESSED)
        Order A & B tidak dicetak (status tidak berubah)
```

### 📝 **Console Log Baru**
```
KitchenController: Checking for status changes - Old: 2, New: 3
KitchenController: Order ABC12345 - Old status: received, New status: processed
KitchenController: Status changed: true, Now processed: true, Not printed: true
KitchenController: Order ABC12345 status changed to PROCESSED - will print
KitchenController: Found 1 orders with status changes to print
KitchenController: Auto printing order ABC12345 (status changed to processed)
```

### 🎯 **Keuntungan**

1. **Hanya Print yang Perlu**
   - Tidak print ulang pesanan lama
   - Hanya print ketika ada perubahan status

2. **Deteksi Akurat**
   - Membandingkan data lama vs baru
   - Mendeteksi perubahan status secara real-time

3. **Efisien**
   - Tidak ada print duplikat
   - Tidak membuang kertas printer

4. **Smart Detection**
   - Pesanan baru langsung PROCESSED → Print
   - Status berubah ke PROCESSED → Print
   - Status tetap PROCESSED → Skip

### 🧪 **Testing**

#### Test 1: Pesanan Baru
1. Buat pesanan baru dengan status PROCESSED
2. Harus langsung tercetak dalam 10 detik

#### Test 2: Perubahan Status
1. Buat pesanan dengan status RECEIVED
2. Ubah status ke PROCESSED
3. Harus tercetak dalam 10 detik setelah perubahan

#### Test 3: Tidak Ada Perubahan
1. Pesanan sudah berstatus PROCESSED
2. Refresh data (tidak ada perubahan)
3. Tidak boleh ada print ulang

### 📱 **Notifikasi Baru**
```
"Pesanan ABC12345 berubah ke PROCESSED - berhasil dicetak otomatis"
```

Sekarang sistem hanya akan mencetak pesanan yang **benar-benar baru masuk ke dapur** atau **baru berubah status ke PROCESSED**! 🎯