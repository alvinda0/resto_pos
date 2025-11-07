# Implementasi Order Method (DINE_IN / TAKE_AWAY)

## Ringkasan
Menambahkan field `order_method` ke request create order baru dengan pilihan:
- `DINE_IN` - untuk pesanan makan di tempat
- `TAKE_AWAY` - untuk pesanan dibawa pulang

## Perubahan File

### 1. Model Order (`lib/models/order/new_order_model.dart`)
- Menambahkan field `orderMethod` ke class `OrderDetails`
- Field ini akan dikirim sebagai `order_method` dalam request JSON

```dart
class OrderDetails {
  final String orderMethod; // DINE_IN or TAKE_AWAY
  
  Map<String, dynamic> toJson() {
    return {
      'order_method': orderMethod,
      // ... fields lainnya
    };
  }
}
```

### 2. Controller (`lib/controller/order/new_order_controller.dart`)
- Menambahkan observable `orderMethod` dengan default value `'DINE_IN'`
- Menambahkan fungsi `updateReferralCode()` untuk update referral code
- Field `orderMethod` di-reset ke `'DINE_IN'` saat `resetForm()`
- Field `orderMethod` disertakan dalam `CreateOrderRequest` saat `processOrder()`

```dart
final RxString orderMethod = 'DINE_IN'.obs;
```

### 3. Screen UI (`lib/screens/order/new_order_screen.dart`)
- Menambahkan widget `_buildOrderMethodSelector()` untuk memilih metode order
- Widget menampilkan 2 tombol:
  - **Dine In** dengan icon restaurant (warna biru)
  - **Take Away** dengan icon shopping bag (warna orange)
- Tombol yang dipilih akan highlight dengan border lebih tebal dan background berwarna
- Widget ditempatkan setelah field "Nomor Meja" dan "Catatan"

## Format Request JSON

Request create order sekarang akan terlihat seperti ini:

```json
{
  "order": {
    "customer_name": "Customer V3",
    "customer_phone": "082934126123",
    "table_number": 1,
    "notes": "Test Order Customer V2",
    "referral_code": "",
    "order_method": "DINE_IN",
    "promo_code": ""
  },
  "order_details": [
    {
      "product_id": "e0e7474a-52dc-4abe-acaf-1396c336ceda",
      "quantity": 1,
      "note": "Extra sauce please"
    }
  ],
  "payments": [
    {
      "method": "Tunai"
    }
  ]
}
```

## Cara Penggunaan

1. Buka screen New Order
2. Isi detail customer (nama, nomor WA, nomor meja)
3. **Pilih metode order**: Dine In atau Take Away
4. Tambahkan produk ke pesanan
5. Pilih metode pembayaran
6. Proses order

Default metode order adalah **DINE_IN** jika tidak dipilih.

## Testing

Untuk testing, pastikan:
1. ✅ Field `order_method` terkirim dalam request
2. ✅ Default value adalah `DINE_IN`
3. ✅ User bisa switch antara DINE_IN dan TAKE_AWAY
4. ✅ Pilihan tersimpan sampai order selesai
5. ✅ Reset ke DINE_IN setelah order berhasil

## Catatan
- Field ini wajib dikirim dalam request
- Backend harus sudah support field `order_method`
- UI responsive untuk mobile dan desktop
