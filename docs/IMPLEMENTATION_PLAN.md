# Warungku Implementation Notes

## Rencana Implementasi

1. Tahap 1: setup Flutter, theme, helper, model, API service, auth, session, dan routing role admin/user.
2. Tahap 2: dashboard user/admin, kategori, produk, stok, dan low stock.
3. Tahap 3: hutang pelanggan, detail hutang, input pembayaran, dan riwayat pembayaran.
4. Tahap 4: chat realtime Firebase Firestore untuk user-admin saja.
5. Tahap 5: polish UI, loading, empty state, validasi, dan error handling tambahan.

## Struktur Folder Flutter

```text
lib/
  main.dart
  app.dart
  core/
    constants/
    helpers/
    theme/
  models/
  services/
  screens/
    auth/
    user/
    admin/
  widgets/
```

## Struktur Google Spreadsheet

Sheet utama memakai Bahasa Indonesia:

- `pengguna`: id, nama, no_hp, email, kata_sandi, peran, dibuat_pada, diperbarui_pada, aktif
- `kategori`: id, nama, ikon, dibuat_pada, diperbarui_pada, aktif
- `produk`: id, nama, id_kategori, nama_kategori, harga_beli, harga_jual, stok, satuan, url_gambar, barcode, batas_stok_menipis, dibuat_pada, diperbarui_pada, aktif
- `hutang`: id, id_pengguna, nama_pengguna, no_hp_pengguna, total_hutang, sudah_dibayar, sisa_hutang, status, catatan, dibuat_pada, diperbarui_pada, dibuat_oleh_admin_id
- `item_hutang`: id, id_hutang, id_produk, nama_produk, harga, jumlah, satuan, subtotal, dibuat_pada
- `pembayaran_hutang`: id, id_hutang, id_pengguna, nama_pengguna, nominal, catatan, dibuat_pada, dibuat_oleh_admin_id
- `log_stok`: id, id_produk, nama_produk, jenis, jumlah, stok_sebelum, stok_sesudah, catatan, dibuat_pada, dibuat_oleh_admin_id
- `log_aktivitas`: id, id_pengguna, nama_pengguna, peran, aksi, deskripsi, dibuat_pada

Password saat testing masih plain text. Untuk production, password wajib di-hash dan Apps Script sebaiknya diberi proteksi tambahan.

## Cara Menjalankan

1. Buat Google Spreadsheet dengan sheet sesuai struktur di atas.
2. Buka Extensions > Apps Script, tempel isi `backend/google_apps_script/Code.gs`.
3. Jalankan fungsi `setupDatabase()` sekali dari editor Apps Script untuk membuat header otomatis.
4. Jalankan fungsi `seedDummyData()` jika ingin mengisi admin, user contoh, kategori, produk, dan contoh hutang otomatis.
5. Deploy sebagai Web App, akses untuk Anyone atau sesuai kebutuhan testing.
6. Ganti `googleAppsScriptUrl` di `lib/core/constants/app_constants.dart`.
7. Jalankan `flutter pub get`.
8. Tambahkan konfigurasi Firebase dengan `flutterfire configure` untuk memakai chat.
9. Jalankan aplikasi dengan `flutter run`.

Firebase hanya dipakai untuk collection `chats` dan subcollection `messages`. Produk, stok, hutang, pembayaran, dashboard, dan user utama tetap dari Spreadsheet lewat Apps Script.
