# Dummy Data Spreadsheet Warungku Bahasa Indonesia

Gunakan nama sheet dan header berikut. Apps Script sudah membaca header Bahasa Indonesia ini, sementara Flutter tetap menerima data dengan field teknis yang benar.

## Sheet `pengguna`

```csv
id,nama,no_hp,email,kata_sandi,peran,dibuat_pada,diperbarui_pada,aktif
USR001,Admin Warungku,08123456789,admin@gmail.com,123456,admin,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
USR002,Budi Santoso,081211110001,budi@gmail.com,123456,user,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
USR003,Siti Aminah,081211110002,siti@gmail.com,123456,user,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
USR004,Andi Saputra,081211110003,andi@gmail.com,123456,user,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
```

## Sheet `kategori`

```csv
id,nama,ikon,dibuat_pada,diperbarui_pada,aktif
CAT001,Snack,fastfood,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
CAT002,Roti,bakery_dining,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
CAT003,BBM,local_gas_station,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
CAT004,Sembako,rice_bowl,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
CAT005,Rokok,smoking_rooms,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
CAT006,Obat,medication,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
CAT007,Voucher,confirmation_number,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
CAT008,Peralatan,build,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
```

## Sheet `produk`

```csv
id,nama,id_kategori,nama_kategori,harga_beli,harga_jual,stok,satuan,url_gambar,barcode,batas_stok_menipis,dibuat_pada,diperbarui_pada,aktif
PRD001,Indomie Goreng,CAT001,Snack,2800,3500,48,pcs,,,10,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD002,Aqua 600ml,CAT001,Snack,2500,3500,36,botol,,,8,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD003,Minyak Goreng 1L,CAT004,Sembako,14500,17000,12,liter,,,4,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD004,Pertalite Literan,CAT003,BBM,10000,12000,30,liter,,,5,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD005,Pertamax Literan,CAT003,BBM,13500,15000,20,liter,,,5,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD006,Pertalite Galon,CAT003,BBM,185000,205000,4,galon,,,1,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD007,Pertamax Galon,CAT003,BBM,240000,265000,3,galon,,,1,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD008,Gula Pasir 1kg,CAT004,Sembako,15500,18000,15,kg,,,4,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD009,Tepung Terigu 1kg,CAT004,Sembako,11000,13500,18,kg,,,4,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD010,Rokok Sampoerna,CAT005,Rokok,30000,34000,10,bungkus,,,3,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD011,Rokok Surya,CAT005,Rokok,28000,32000,9,bungkus,,,3,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD012,Paracetamol,CAT006,Obat,2500,4000,20,pack,,,5,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD013,Voucher WiFi,CAT007,Voucher,4000,5000,50,pcs,,,10,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD014,Lampu,CAT008,Peralatan,12000,18000,8,pcs,,,2,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD015,Baut Mesin,CAT008,Peralatan,500,1000,100,pcs,,,20,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
PRD016,Selang,CAT008,Peralatan,8000,12000,12,pcs,,,3,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,true
```

## Sheet `hutang`

```csv
id,id_pengguna,nama_pengguna,no_hp_pengguna,total_hutang,sudah_dibayar,sisa_hutang,status,catatan,dibuat_pada,diperbarui_pada,dibuat_oleh_admin_id
DBT001,USR002,Budi Santoso,081211110001,39500,10000,29500,cicil,Hutang belanja harian,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,USR001
DBT002,USR003,Siti Aminah,081211110002,30000,0,30000,belum_lunas,Bensin literan,2026-05-11T00:00:00.000Z,2026-05-11T00:00:00.000Z,USR001
```

## Sheet `item_hutang`

```csv
id,id_hutang,id_produk,nama_produk,harga,jumlah,satuan,subtotal,dibuat_pada
DIT001,DBT001,PRD001,Indomie Goreng,3500,3,pcs,10500,2026-05-11T00:00:00.000Z
DIT002,DBT001,PRD003,Minyak Goreng 1L,17000,1,liter,17000,2026-05-11T00:00:00.000Z
DIT003,DBT001,PRD004,Pertalite Literan,12000,1,liter,12000,2026-05-11T00:00:00.000Z
DIT004,DBT002,PRD005,Pertamax Literan,15000,2,liter,30000,2026-05-11T00:00:00.000Z
```

## Sheet `pembayaran_hutang`

```csv
id,id_hutang,id_pengguna,nama_pengguna,nominal,catatan,dibuat_pada,dibuat_oleh_admin_id
PAY001,DBT001,USR002,Budi Santoso,10000,Cicilan pertama,2026-05-11T00:00:00.000Z,USR001
```

## Sheet kosong yang tetap perlu ada

### `log_stok`

```csv
id,id_produk,nama_produk,jenis,jumlah,stok_sebelum,stok_sesudah,catatan,dibuat_pada,dibuat_oleh_admin_id
```

### `log_aktivitas`

```csv
id,id_pengguna,nama_pengguna,peran,aksi,deskripsi,dibuat_pada
```
