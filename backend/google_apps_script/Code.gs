// Warungku Google Apps Script
// Spreadsheet memakai nama sheet dan header Bahasa Indonesia.
// Response API tetap memakai field teknis Inggris agar Flutter tidak perlu diubah.

const TABLES = {
  users: {
    sheet: 'pengguna',
    headers: ['id', 'nama', 'no_hp', 'email', 'kata_sandi', 'peran', 'dibuat_pada', 'diperbarui_pada', 'aktif'],
    map: {
      id: 'id',
      name: 'nama',
      phone: 'no_hp',
      email: 'email',
      password: 'kata_sandi',
      role: 'peran',
      createdAt: 'dibuat_pada',
      updatedAt: 'diperbarui_pada',
      isActive: 'aktif',
    },
  },
  categories: {
    sheet: 'kategori',
    headers: ['id', 'nama', 'ikon', 'dibuat_pada', 'diperbarui_pada', 'aktif'],
    map: {
      id: 'id',
      name: 'nama',
      icon: 'ikon',
      createdAt: 'dibuat_pada',
      updatedAt: 'diperbarui_pada',
      isActive: 'aktif',
    },
  },
  products: {
    sheet: 'produk',
    headers: ['id', 'nama', 'id_kategori', 'nama_kategori', 'harga_beli', 'harga_jual', 'stok', 'satuan', 'url_gambar', 'barcode', 'batas_stok_menipis', 'dibuat_pada', 'diperbarui_pada', 'aktif'],
    map: {
      id: 'id',
      name: 'nama',
      categoryId: 'id_kategori',
      categoryName: 'nama_kategori',
      buyPrice: 'harga_beli',
      sellPrice: 'harga_jual',
      stock: 'stok',
      unit: 'satuan',
      imageUrl: 'url_gambar',
      barcode: 'barcode',
      lowStockLimit: 'batas_stok_menipis',
      createdAt: 'dibuat_pada',
      updatedAt: 'diperbarui_pada',
      isActive: 'aktif',
    },
  },
  debts: {
    sheet: 'hutang',
    headers: ['id', 'id_pengguna', 'nama_pengguna', 'no_hp_pengguna', 'total_hutang', 'sudah_dibayar', 'sisa_hutang', 'status', 'catatan', 'dibuat_pada', 'diperbarui_pada', 'dibuat_oleh_admin_id'],
    map: {
      id: 'id',
      userId: 'id_pengguna',
      userName: 'nama_pengguna',
      userPhone: 'no_hp_pengguna',
      totalDebt: 'total_hutang',
      paidAmount: 'sudah_dibayar',
      remainingDebt: 'sisa_hutang',
      status: 'status',
      note: 'catatan',
      createdAt: 'dibuat_pada',
      updatedAt: 'diperbarui_pada',
      createdByAdminId: 'dibuat_oleh_admin_id',
    },
  },
  debt_items: {
    sheet: 'item_hutang',
    headers: ['id', 'id_hutang', 'id_produk', 'nama_produk', 'harga', 'jumlah', 'satuan', 'subtotal', 'dibuat_pada'],
    map: {
      id: 'id',
      debtId: 'id_hutang',
      productId: 'id_produk',
      productName: 'nama_produk',
      price: 'harga',
      qty: 'jumlah',
      unit: 'satuan',
      subtotal: 'subtotal',
      createdAt: 'dibuat_pada',
    },
  },
  debt_payments: {
    sheet: 'pembayaran_hutang',
    headers: ['id', 'id_hutang', 'id_pengguna', 'nama_pengguna', 'nominal', 'catatan', 'dibuat_pada', 'dibuat_oleh_admin_id'],
    map: {
      id: 'id',
      debtId: 'id_hutang',
      userId: 'id_pengguna',
      userName: 'nama_pengguna',
      amount: 'nominal',
      note: 'catatan',
      createdAt: 'dibuat_pada',
      createdByAdminId: 'dibuat_oleh_admin_id',
    },
  },
  stock_logs: {
    sheet: 'log_stok',
    headers: ['id', 'id_produk', 'nama_produk', 'jenis', 'jumlah', 'stok_sebelum', 'stok_sesudah', 'catatan', 'dibuat_pada', 'dibuat_oleh_admin_id'],
    map: {
      id: 'id',
      productId: 'id_produk',
      productName: 'nama_produk',
      type: 'jenis',
      qty: 'jumlah',
      beforeStock: 'stok_sebelum',
      afterStock: 'stok_sesudah',
      note: 'catatan',
      createdAt: 'dibuat_pada',
      createdByAdminId: 'dibuat_oleh_admin_id',
    },
  },
  activity_logs: {
    sheet: 'log_aktivitas',
    headers: ['id', 'id_pengguna', 'nama_pengguna', 'peran', 'aksi', 'deskripsi', 'dibuat_pada'],
    map: {
      id: 'id',
      userId: 'id_pengguna',
      userName: 'nama_pengguna',
      role: 'peran',
      action: 'aksi',
      description: 'deskripsi',
      createdAt: 'dibuat_pada',
    },
  },
  user_addresses: {
    sheet: 'user_addresses',
    headers: ['id', 'id_pengguna', 'label_alamat', 'nama_penerima', 'no_hp', 'alamat_lengkap', 'catatan', 'alamat_utama', 'dibuat_pada', 'diperbarui_pada', 'aktif'],
    map: {
      id: 'id',
      userId: 'id_pengguna',
      labelAddress: 'label_alamat',
      recipientName: 'nama_penerima',
      phone: 'no_hp',
      fullAddress: 'alamat_lengkap',
      note: 'catatan',
      isPrimary: 'alamat_utama',
      createdAt: 'dibuat_pada',
      updatedAt: 'diperbarui_pada',
      isActive: 'aktif',
    },
  },
  orders: {
    sheet: 'orders',
    headers: ['id', 'id_pengguna', 'nama_pengguna', 'no_hp_pengguna', 'tipe_order', 'id_alamat', 'snapshot_alamat', 'metode_pembayaran', 'status_pembayaran', 'status_order', 'total', 'catatan', 'dibuat_pada', 'diperbarui_pada', 'dikonfirmasi_oleh_admin_id'],
    map: {
      id: 'id',
      userId: 'id_pengguna',
      userName: 'nama_pengguna',
      userPhone: 'no_hp_pengguna',
      orderType: 'tipe_order',
      addressId: 'id_alamat',
      addressSnapshot: 'snapshot_alamat',
      paymentMethod: 'metode_pembayaran',
      paymentStatus: 'status_pembayaran',
      orderStatus: 'status_order',
      totalAmount: 'total',
      note: 'catatan',
      createdAt: 'dibuat_pada',
      updatedAt: 'diperbarui_pada',
      confirmedByAdminId: 'dikonfirmasi_oleh_admin_id',
    },
  },
  order_items: {
    sheet: 'order_items',
    headers: ['id', 'id_order', 'id_produk', 'nama_produk', 'harga', 'jumlah', 'satuan', 'subtotal', 'dibuat_pada'],
    map: {
      id: 'id',
      orderId: 'id_order',
      productId: 'id_produk',
      productName: 'nama_produk',
      price: 'harga',
      qty: 'jumlah',
      unit: 'satuan',
      subtotal: 'subtotal',
      createdAt: 'dibuat_pada',
    },
  },
};

const ADMIN_ACTIONS = [
  'getAllUsers', 'updateUserStatus', 'addCategory', 'updateCategory', 'deleteCategory',
  'addProduct', 'updateProduct', 'deleteProduct', 'updateStock', 'getAllDebts',
  'addDebt', 'addDebtPayment', 'markDebtAsPaid', 'getAdminDashboard', 'getStockLogs',
  'addStockLog', 'getLowStockProducts', 'uploadProductImage', 'testDriveAccess', 'testUploadSmallImage',
  'getAllOrdersForAdmin', 'updateOrderStatus', 'updateOrderPaymentStatus',
];

function setupDatabase() {
  ensureSheets();
  return 'Setup database Warungku selesai. Semua sheet dan header sudah dibuat.';
}

function seedDummyData() {
  ensureSheets();
  seedRows('users', [
    { id: 'USR001', name: 'Admin Warungku', phone: '08123456789', email: 'admin@gmail.com', password: '123456', role: 'admin', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'USR002', name: 'Budi Santoso', phone: '081211110001', email: 'budi@gmail.com', password: '123456', role: 'user', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'USR003', name: 'Siti Aminah', phone: '081211110002', email: 'siti@gmail.com', password: '123456', role: 'user', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'USR004', name: 'Andi Saputra', phone: '081211110003', email: 'andi@gmail.com', password: '123456', role: 'user', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
  ]);
  seedRows('categories', [
    { id: 'CAT001', name: 'Snack', icon: 'fastfood', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'CAT002', name: 'Roti', icon: 'bakery_dining', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'CAT003', name: 'BBM', icon: 'local_gas_station', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'CAT004', name: 'Sembako', icon: 'rice_bowl', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'CAT005', name: 'Rokok', icon: 'smoking_rooms', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'CAT006', name: 'Obat', icon: 'medication', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'CAT007', name: 'Voucher', icon: 'confirmation_number', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'CAT008', name: 'Peralatan', icon: 'build', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
  ]);
  seedRows('products', [
    { id: 'PRD001', name: 'Indomie Goreng', categoryId: 'CAT001', categoryName: 'Snack', buyPrice: 2800, sellPrice: 3500, stock: 48, unit: 'pcs', imageUrl: '', barcode: '', lowStockLimit: 10, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD002', name: 'Aqua 600ml', categoryId: 'CAT001', categoryName: 'Snack', buyPrice: 2500, sellPrice: 3500, stock: 36, unit: 'botol', imageUrl: '', barcode: '', lowStockLimit: 8, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD003', name: 'Minyak Goreng 1L', categoryId: 'CAT004', categoryName: 'Sembako', buyPrice: 14500, sellPrice: 17000, stock: 12, unit: 'liter', imageUrl: '', barcode: '', lowStockLimit: 4, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD004', name: 'Pertalite Literan', categoryId: 'CAT003', categoryName: 'BBM', buyPrice: 10000, sellPrice: 12000, stock: 30, unit: 'liter', imageUrl: '', barcode: '', lowStockLimit: 5, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD005', name: 'Pertamax Literan', categoryId: 'CAT003', categoryName: 'BBM', buyPrice: 13500, sellPrice: 15000, stock: 20, unit: 'liter', imageUrl: '', barcode: '', lowStockLimit: 5, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD006', name: 'Pertalite Galon', categoryId: 'CAT003', categoryName: 'BBM', buyPrice: 185000, sellPrice: 205000, stock: 4, unit: 'galon', imageUrl: '', barcode: '', lowStockLimit: 1, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD007', name: 'Pertamax Galon', categoryId: 'CAT003', categoryName: 'BBM', buyPrice: 240000, sellPrice: 265000, stock: 3, unit: 'galon', imageUrl: '', barcode: '', lowStockLimit: 1, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD008', name: 'Gula Pasir 1kg', categoryId: 'CAT004', categoryName: 'Sembako', buyPrice: 15500, sellPrice: 18000, stock: 15, unit: 'kg', imageUrl: '', barcode: '', lowStockLimit: 4, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD009', name: 'Tepung Terigu 1kg', categoryId: 'CAT004', categoryName: 'Sembako', buyPrice: 11000, sellPrice: 13500, stock: 18, unit: 'kg', imageUrl: '', barcode: '', lowStockLimit: 4, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD010', name: 'Rokok Sampoerna', categoryId: 'CAT005', categoryName: 'Rokok', buyPrice: 30000, sellPrice: 34000, stock: 10, unit: 'bungkus', imageUrl: '', barcode: '', lowStockLimit: 3, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD011', name: 'Rokok Surya', categoryId: 'CAT005', categoryName: 'Rokok', buyPrice: 28000, sellPrice: 32000, stock: 9, unit: 'bungkus', imageUrl: '', barcode: '', lowStockLimit: 3, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD012', name: 'Paracetamol', categoryId: 'CAT006', categoryName: 'Obat', buyPrice: 2500, sellPrice: 4000, stock: 20, unit: 'pack', imageUrl: '', barcode: '', lowStockLimit: 5, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD013', name: 'Voucher WiFi', categoryId: 'CAT007', categoryName: 'Voucher', buyPrice: 4000, sellPrice: 5000, stock: 50, unit: 'pcs', imageUrl: '', barcode: '', lowStockLimit: 10, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD014', name: 'Lampu', categoryId: 'CAT008', categoryName: 'Peralatan', buyPrice: 12000, sellPrice: 18000, stock: 8, unit: 'pcs', imageUrl: '', barcode: '', lowStockLimit: 2, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD015', name: 'Baut Mesin', categoryId: 'CAT008', categoryName: 'Peralatan', buyPrice: 500, sellPrice: 1000, stock: 100, unit: 'pcs', imageUrl: '', barcode: '', lowStockLimit: 20, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
    { id: 'PRD016', name: 'Selang', categoryId: 'CAT008', categoryName: 'Peralatan', buyPrice: 8000, sellPrice: 12000, stock: 12, unit: 'pcs', imageUrl: '', barcode: '', lowStockLimit: 3, createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', isActive: true },
  ]);
  seedRows('debts', [
    { id: 'DBT001', userId: 'USR002', userName: 'Budi Santoso', userPhone: '081211110001', totalDebt: 39500, paidAmount: 10000, remainingDebt: 29500, status: 'cicil', note: 'Hutang belanja harian', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', createdByAdminId: 'USR001' },
    { id: 'DBT002', userId: 'USR003', userName: 'Siti Aminah', userPhone: '081211110002', totalDebt: 30000, paidAmount: 0, remainingDebt: 30000, status: 'belum_lunas', note: 'Bensin literan', createdAt: '2026-05-11T00:00:00.000Z', updatedAt: '2026-05-11T00:00:00.000Z', createdByAdminId: 'USR001' },
  ]);
  seedRows('debt_items', [
    { id: 'DIT001', debtId: 'DBT001', productId: 'PRD001', productName: 'Indomie Goreng', price: 3500, qty: 3, unit: 'pcs', subtotal: 10500, createdAt: '2026-05-11T00:00:00.000Z' },
    { id: 'DIT002', debtId: 'DBT001', productId: 'PRD003', productName: 'Minyak Goreng 1L', price: 17000, qty: 1, unit: 'liter', subtotal: 17000, createdAt: '2026-05-11T00:00:00.000Z' },
    { id: 'DIT003', debtId: 'DBT001', productId: 'PRD004', productName: 'Pertalite Literan', price: 12000, qty: 1, unit: 'liter', subtotal: 12000, createdAt: '2026-05-11T00:00:00.000Z' },
    { id: 'DIT004', debtId: 'DBT002', productId: 'PRD005', productName: 'Pertamax Literan', price: 15000, qty: 2, unit: 'liter', subtotal: 30000, createdAt: '2026-05-11T00:00:00.000Z' },
  ]);
  seedRows('debt_payments', [
    { id: 'PAY001', debtId: 'DBT001', userId: 'USR002', userName: 'Budi Santoso', amount: 10000, note: 'Cicilan pertama', createdAt: '2026-05-11T00:00:00.000Z', createdByAdminId: 'USR001' },
  ]);
  return 'Dummy data Warungku selesai ditambahkan.';
}

function doGet(e) {
  const params = e && e.parameter ? e.parameter : {};
  const action = params.action || '';
  Logger.log('Warungku doGet action=%s hasPayload=%s', action || '(none)', params.payload ? 'yes' : 'no');
  if (action === 'setup') {
    setupDatabase();
    return responseSuccess('Setup database Warungku selesai. Semua sheet dan header sudah dibuat.');
  }
  if (action === 'seed') {
    seedDummyData();
    return responseSuccess('Dummy data Warungku selesai ditambahkan.');
  }
  if (params.payload) {
    return handleRequest(JSON.parse(params.payload));
  }
  if (action) {
    return handleRequest(params);
  }
  return responseSuccess('API Warungku aktif. Gunakan doPost untuk aplikasi Flutter.');
}

function doPost(e) {
  try {
    Logger.log(
      'Warungku doPost contentType=%s length=%s',
      e && e.postData ? e.postData.type : '(none)',
      e && e.postData && e.postData.contents ? e.postData.contents.length : 0
    );
    const body = e && e.postData && e.postData.contents ? JSON.parse(e.postData.contents) : {};
    return handleRequest(body);
  } catch (error) {
    return responseError(error.message || String(error));
  }
}

function handleRequest(body) {
  try {
    const action = body.action;
    if (!action) return responseError('Action wajib diisi');
    Logger.log('Warungku handleRequest action=%s', action);
    ensureSheets();
    if (ADMIN_ACTIONS.indexOf(action) !== -1) {
      const adminCheck = assertAdmin(body.adminId);
      if (!adminCheck.success) return responseError(adminCheck.message);
    }
    const handlers = {
      login, registerUser, getUserById, getAllUsers, updateUserStatus,
      changePassword,
      getCategories, addCategory, updateCategory, deleteCategory,
      getProducts, getProductById, addProduct, updateProduct, deleteProduct,
      updateStock, getLowStockProducts, searchProducts, uploadProductImage, testDriveAccess, testUploadSmallImage, getAllDebts,
      getDebtsByUser, getDebtDetail, addDebt, addDebtPayment, markDebtAsPaid,
      getDebtPaymentsByUser, getDebtPaymentsByDebt, getAdminDashboard,
      getUserDashboard, getStockLogs, addStockLog,
      getUserAddresses, addUserAddress, updateUserAddress, deleteUserAddress,
      createOrder, getOrdersByUser, getAllOrdersForAdmin, getOrderDetail,
      updateOrderStatus, updateOrderPaymentStatus,
    };
    if (!handlers[action]) return responseError('Action tidak dikenal: ' + action);
    return handlers[action](body);
  } catch (error) {
    return responseError(error.message || String(error));
  }
}

function responseSuccess(message, data) {
  return ContentService.createTextOutput(JSON.stringify({ success: true, message, data: data || null }))
    .setMimeType(ContentService.MimeType.JSON);
}

function responseError(message, data) {
  return ContentService.createTextOutput(JSON.stringify({ success: false, message, data: data || null }))
    .setMimeType(ContentService.MimeType.JSON);
}

function table(name) {
  return TABLES[name];
}

function getSheet(name) {
  const config = table(name);
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = ss.getSheetByName(config.sheet);
  if (!sheet) sheet = ss.insertSheet(config.sheet);
  if (sheet.getLastRow() === 0) sheet.appendRow(config.headers);
  return sheet;
}

function ensureSheets() {
  Object.keys(TABLES).forEach(getSheet);
}

function generateId(prefix) {
  const stamp = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'yyyyMMddHHmmssSSS');
  return prefix + stamp + Utilities.getUuid().slice(0, 6).toUpperCase();
}

function nowIso() {
  return new Date().toISOString();
}

function toApiObject(sheetName, row, rowNumber) {
  const config = table(sheetName);
  const obj = { _rowNumber: rowNumber };
  Object.keys(config.map).forEach(key => obj[key] = row[config.map[key]]);
  return obj;
}

function toSheetObject(sheetName, obj) {
  const config = table(sheetName);
  const out = {};
  Object.keys(obj).forEach(key => {
    const header = config.map[key] || key;
    out[header] = obj[key];
  });
  return out;
}

function getRowsAsObjects(sheetName) {
  const sheet = getSheet(sheetName);
  const values = sheet.getDataRange().getValues();
  if (values.length < 2) return [];
  const headers = values[0].map(String);
  return values.slice(1).filter(row => row.some(cell => cell !== '')).map((row, index) => {
    const raw = {};
    headers.forEach((header, i) => raw[header] = row[i]);
    return toApiObject(sheetName, raw, index + 2);
  });
}

function findRowById(sheetName, id) {
  return getRowsAsObjects(sheetName).find(row => String(row.id) === String(id)) || null;
}

function appendObject(sheetName, obj) {
  const sheet = getSheet(sheetName);
  const config = table(sheetName);
  const sheetObj = toSheetObject(sheetName, obj);
  sheet.appendRow(config.headers.map(header => sheetObj[header] !== undefined ? sheetObj[header] : ''));
}

function updateObject(sheetName, rowNumber, patch) {
  const sheet = getSheet(sheetName);
  const config = table(sheetName);
  const sheetPatch = toSheetObject(sheetName, patch);
  config.headers.forEach((header, index) => {
    if (sheetPatch[header] !== undefined) sheet.getRange(rowNumber, index + 1).setValue(sheetPatch[header]);
  });
}

function seedRows(sheetName, rows) {
  const existingIds = getRowsAsObjects(sheetName).map(row => String(row.id));
  rows.forEach(row => {
    if (existingIds.indexOf(String(row.id)) === -1) appendObject(sheetName, row);
  });
}

function activeOnly(row) {
  return String(row.isActive) !== 'false';
}

function assertAdmin(adminId) {
  if (!adminId) return { success: false, message: 'adminId wajib dikirim' };
  const admin = findRowById('users', adminId);
  if (!admin || String(admin.role) !== 'admin' || !activeOnly(admin)) {
    return { success: false, message: 'Akses ditolak. User bukan admin aktif.' };
  }
  return { success: true };
}

function publicUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    isActive: activeOnly(user),
  };
}

function login(body) {
  const email = String(body.email || '').trim().toLowerCase();
  const password = String(body.password || '');
  const user = getRowsAsObjects('users').find(row =>
    String(row.email).toLowerCase() === email &&
    String(row.password) === password &&
    activeOnly(row)
  );
  if (!user) return responseError('Email atau password salah');
  return responseSuccess('Login berhasil', publicUser(user));
}

function registerUser(body) {
  const email = String(body.email || '').trim().toLowerCase();
  if (!email || !body.password || !body.name) return responseError('Nama, email, dan password wajib diisi');
  const exists = getRowsAsObjects('users').some(row => String(row.email).toLowerCase() === email);
  if (exists) return responseError('Email sudah terdaftar');
  const user = {
    id: generateId('USR'),
    name: body.name,
    phone: body.phone || '',
    email,
    password: body.password,
    role: 'user',
    createdAt: nowIso(),
    updatedAt: nowIso(),
    isActive: true,
  };
  appendObject('users', user);
  return responseSuccess('Register berhasil', publicUser(user));
}

function getUserById(body) {
  const user = findRowById('users', body.userId || body.id);
  if (!user || !activeOnly(user)) return responseError('User tidak ditemukan');
  return responseSuccess('User ditemukan', publicUser(user));
}

function getAllUsers() {
  return responseSuccess('Data user berhasil diambil', getRowsAsObjects('users').map(publicUser));
}

function updateUserStatus(body) {
  const user = findRowById('users', body.userId);
  if (!user) return responseError('User tidak ditemukan');
  updateObject('users', user._rowNumber, { isActive: body.isActive === true || body.isActive === 'true', updatedAt: nowIso() });
  return responseSuccess('Status user diperbarui');
}

function changePassword(body) {
  const user = findRowById('users', body.userId);
  if (!user || !activeOnly(user)) return responseError('User tidak ditemukan');
  if (String(user.password) !== String(body.oldPassword || '')) {
    return responseError('Password lama tidak sesuai');
  }
  if (String(body.newPassword || '').length < 6) {
    return responseError('Password baru minimal 6 karakter');
  }
  // Testing masih plain text mengikuti sistem awal. Production sebaiknya password di-hash.
  updateObject('users', user._rowNumber, {
    password: body.newPassword,
    updatedAt: nowIso(),
  });
  return responseSuccess('Password berhasil diubah');
}

function getCategories() {
  return responseSuccess('Data kategori berhasil diambil', getRowsAsObjects('categories').filter(activeOnly));
}

function addCategory(body) {
  const category = { id: generateId('CAT'), name: body.name, icon: body.icon || '', createdAt: nowIso(), updatedAt: nowIso(), isActive: true };
  appendObject('categories', category);
  return responseSuccess('Kategori berhasil ditambahkan', category);
}

function updateCategory(body) {
  const category = findRowById('categories', body.id);
  if (!category) return responseError('Kategori tidak ditemukan');
  updateObject('categories', category._rowNumber, { name: body.name, icon: body.icon, updatedAt: nowIso() });
  return responseSuccess('Kategori berhasil diperbarui');
}

function deleteCategory(body) {
  const category = findRowById('categories', body.id);
  if (!category) return responseError('Kategori tidak ditemukan');
  updateObject('categories', category._rowNumber, { isActive: false, updatedAt: nowIso() });
  return responseSuccess('Kategori dinonaktifkan');
}

function getProducts(body) {
  let products = getRowsAsObjects('products').filter(activeOnly);
  if (body.categoryId) products = products.filter(p => String(p.categoryId) === String(body.categoryId));
  return responseSuccess('Data produk berhasil diambil', products);
}

function getProductById(body) {
  const product = findRowById('products', body.id || body.productId);
  if (!product || !activeOnly(product)) return responseError('Produk tidak ditemukan');
  return responseSuccess('Produk ditemukan', product);
}

function addProduct(body) {
  if (!body.name || Number(body.sellPrice) <= 0) return responseError('Nama dan harga jual wajib valid');
  const product = {
    id: generateId('PRD'),
    name: body.name,
    categoryId: body.categoryId || '',
    categoryName: body.categoryName || '',
    buyPrice: Number(body.buyPrice || 0),
    sellPrice: Number(body.sellPrice || 0),
    stock: Number(body.stock || 0),
    unit: body.unit || 'pcs',
    imageUrl: body.imageUrl || '',
    barcode: body.barcode || '',
    lowStockLimit: Number(body.lowStockLimit || 0),
    createdAt: nowIso(),
    updatedAt: nowIso(),
    isActive: true,
  };
  if (product.stock < 0) return responseError('Stok tidak boleh minus');
  appendObject('products', product);
  addStockLogInternal(product.id, product.name, 'masuk', product.stock, 0, product.stock, 'Stok awal', body.adminId);
  return responseSuccess('Produk berhasil ditambahkan', product);
}

function updateProduct(body) {
  const product = findRowById('products', body.id);
  if (!product) return responseError('Produk tidak ditemukan');
  updateObject('products', product._rowNumber, {
    name: body.name,
    categoryId: body.categoryId,
    categoryName: body.categoryName,
    buyPrice: Number(body.buyPrice || 0),
    sellPrice: Number(body.sellPrice || 0),
    stock: Number(body.stock || 0),
    unit: body.unit,
    imageUrl: body.imageUrl || '',
    barcode: body.barcode || '',
    lowStockLimit: Number(body.lowStockLimit || 0),
    updatedAt: nowIso(),
  });
  return responseSuccess('Produk berhasil diperbarui');
}

function deleteProduct(body) {
  const product = findRowById('products', body.id || body.productId);
  if (!product) return responseError('Produk tidak ditemukan');
  updateObject('products', product._rowNumber, { isActive: false, updatedAt: nowIso() });
  return responseSuccess('Produk dinonaktifkan');
}

function updateStock(body) {
  const product = findRowById('products', body.productId);
  if (!product || !activeOnly(product)) return responseError('Produk tidak ditemukan');
  const beforeStock = Number(product.stock || 0);
  const qty = Number(body.qty || 0);
  const type = body.type || 'adjustment';
  const afterStock = type === 'keluar' || type === 'hutang' ? beforeStock - qty : type === 'adjustment' ? qty : beforeStock + qty;
  if (qty <= 0) return responseError('Qty harus lebih dari 0');
  if (afterStock < 0) return responseError('Stok tidak cukup');
  updateObject('products', product._rowNumber, { stock: afterStock, updatedAt: nowIso() });
  addStockLogInternal(product.id, product.name, type, qty, beforeStock, afterStock, body.note || '', body.adminId);
  return responseSuccess('Stok berhasil diperbarui', { beforeStock, afterStock });
}

function getLowStockProducts() {
  const products = getRowsAsObjects('products').filter(p => activeOnly(p) && Number(p.stock || 0) <= Number(p.lowStockLimit || 0));
  return responseSuccess('Produk stok menipis berhasil diambil', products);
}

function searchProducts(body) {
  const query = String(body.query || '').toLowerCase();
  const products = getRowsAsObjects('products').filter(p =>
    activeOnly(p) &&
    (!query || String(p.name).toLowerCase().indexOf(query) !== -1 || String(p.categoryName).toLowerCase().indexOf(query) !== -1)
  );
  return responseSuccess('Hasil pencarian produk', products);
}

function uploadProductImage(body) {
  try {
    Logger.log('Warungku uploadProductImage masuk');
    if (typeof body === 'undefined' || body === null) {
      return responseError('uploadProductImage harus dipanggil lewat aplikasi/API dengan payload gambar. Untuk test dari editor, jalankan testUploadSmallImage.');
    }
    let base64Data = String(body.base64Data || '').trim();
    if (base64Data.indexOf(',') !== -1 && base64Data.indexOf('base64') !== -1) {
      base64Data = base64Data.split(',').pop();
    }
    if (!base64Data) return responseError('Data gambar kosong. Pilih gambar produk terlebih dahulu.');

    const mimeType = String(body.mimeType || 'image/jpeg').toLowerCase();
    const rawFileName = String(body.fileName || '');
    Logger.log(
      'Warungku uploadProductImage payload fileName=%s mimeType=%s base64Length=%s estimatedBytes=%s',
      rawFileName || '(auto)',
      mimeType,
      base64Data.length,
      Math.ceil((base64Data.length * 3) / 4)
    );
    const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (allowedMimeTypes.indexOf(mimeType) === -1) {
      return responseError('Format gambar tidak didukung: ' + mimeType + '. Gunakan JPG, PNG, atau WEBP.');
    }

    const maxBytes = 5 * 1024 * 1024;
    const estimatedBytes = Math.ceil((base64Data.length * 3) / 4);
    if (estimatedBytes > maxBytes) {
      return responseError('Ukuran gambar terlalu besar. Maksimal 5 MB setelah kompresi.');
    }

    let bytes;
    try {
      bytes = Utilities.base64Decode(base64Data);
    } catch (decodeError) {
      return responseError('Data gambar tidak valid: ' + (decodeError.message || decodeError));
    }

    if (!bytes || bytes.length === 0) return responseError('Data gambar tidak valid atau kosong.');
    if (bytes.length > maxBytes) return responseError('Ukuran gambar terlalu besar. Maksimal 5 MB.');

    const extension = mimeType === 'image/png' ? '.png' : mimeType === 'image/webp' ? '.webp' : '.jpg';
    const cleanName = sanitizeFileName_(body.fileName || ('produk_' + generateId('IMG') + extension));
    const fileName = cleanName.indexOf('.') === -1 ? cleanName + extension : cleanName;
    const blob = Utilities.newBlob(bytes, mimeType === 'image/jpg' ? 'image/jpeg' : mimeType, fileName);
    const folder = getOrCreateDriveFolder_('Warungku Product Images');
    Logger.log('Warungku uploadProductImage folderId=%s', folder.getId());
    const file = folder.createFile(blob);
    file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
    const fileId = file.getId();
    const imageUrl = 'https://drive.google.com/thumbnail?id=' + fileId + '&sz=w1000';
    Logger.log('Warungku uploadProductImage success fileId=%s imageUrl=%s', fileId, imageUrl);
    return responseSuccess('Gambar berhasil diupload', { fileId, imageUrl, folderId: folder.getId() });
  } catch (error) {
    Logger.log('Warungku uploadProductImage error=%s', error && error.stack ? error.stack : error);
    return responseError('Upload gambar gagal: ' + getDriveErrorMessage_(error));
  }
}

function testDriveAccess() {
  try {
    Logger.log('Warungku testDriveAccess masuk');
    const folder = getOrCreateDriveFolder_('Warungku Product Images');
    Logger.log('Warungku testDriveAccess success folderId=%s', folder.getId());
    return responseSuccess('Akses Google Drive berhasil. Folder siap dipakai.', {
      folderId: folder.getId(),
      folderName: folder.getName(),
    });
  } catch (error) {
    return responseError('Akses Google Drive gagal: ' + getDriveErrorMessage_(error));
  }
}

function testUploadSmallImage(body) {
  Logger.log('Warungku testUploadSmallImage masuk');
  const calledFromEditor = typeof body === 'undefined';
  body = body || {};

  let adminId = body.adminId || '';
  if (!adminId) {
    try {
      const admins = getRowsAsObjects('users').filter(user =>
        String(user.role) === 'admin' && activeOnly(user)
      );
      adminId = admins.length ? admins[0].id : '';
    } catch (error) {
      Logger.log('Warungku testUploadSmallImage gagal ambil admin default: %s', error);
    }
  }
  Logger.log('Warungku testUploadSmallImage adminId=%s', adminId || '(kosong)');

  const payload = {
    action: 'uploadProductImage',
    adminId,
    fileName: 'test-warungku-upload.png',
    mimeType: 'image/png',
    base64Data: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII='
  };

  const result = uploadProductImage(payload);
  const content = result.getContent();
  Logger.log('Warungku testUploadSmallImage result: %s', content);
  return calledFromEditor ? content : result;
}

function getOrCreateDriveFolder_(name) {
  try {
    const folders = DriveApp.getFoldersByName(name);
    if (folders.hasNext()) {
      const existing = folders.next();
      Logger.log('Warungku Drive folder ditemukan name=%s id=%s', name, existing.getId());
      return existing;
    }
    const folder = DriveApp.createFolder(name);
    folder.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
    Logger.log('Warungku Drive folder dibuat name=%s id=%s', name, folder.getId());
    return folder;
  } catch (error) {
    Logger.log('Warungku Drive folder error=%s', error && error.stack ? error.stack : error);
    throw new Error('Tidak bisa membuat/membuka folder Drive "' + name + '": ' + getDriveErrorMessage_(error));
  }
}

function sanitizeFileName_(value) {
  return String(value || 'produk.jpg')
    .replace(/[\\/:*?"<>|#%{}~&]/g, '_')
    .replace(/\s+/g, '_')
    .substring(0, 120);
}

function getDriveErrorMessage_(error) {
  const message = error && error.message ? error.message : String(error);
  if (message.indexOf('Authorization') !== -1 || message.indexOf('permission') !== -1) {
    return message + '. Berikan izin Google Drive pada Apps Script lalu redeploy Web App.';
  }
  return message;
}

function getAllDebts() {
  return responseSuccess('Data hutang berhasil diambil', getRowsAsObjects('debts'));
}

function getDebtsByUser(body) {
  const userId = body.userId;
  if (!userId) return responseError('userId wajib diisi');
  const debts = getRowsAsObjects('debts').filter(row => String(row.userId) === String(userId));
  return responseSuccess('Data hutang user berhasil diambil', debts);
}

function getDebtDetail(body) {
  const debt = findRowById('debts', body.debtId || body.id);
  if (!debt) return responseError('Hutang tidak ditemukan');
  if (body.userId && String(debt.userId) !== String(body.userId)) return responseError('User tidak boleh melihat hutang user lain');
  debt.items = getRowsAsObjects('debt_items').filter(row => String(row.debtId) === String(debt.id));
  debt.payments = getRowsAsObjects('debt_payments').filter(row => String(row.debtId) === String(debt.id));
  return responseSuccess('Detail hutang berhasil diambil', debt);
}

function addDebt(body) {
  const user = findRowById('users', body.userId);
  if (!user || String(user.role) !== 'user') return responseError('Pelanggan tidak ditemukan');
  const items = body.items || [];
  if (!items.length) return responseError('Item hutang wajib diisi');
  const productRows = [];
  let totalDebt = 0;
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    const qty = Number(item.qty || 0);
    if (qty <= 0) return responseError('Qty tidak boleh 0 atau minus');
    const product = findRowById('products', item.productId);
    if (!product || !activeOnly(product)) return responseError('Produk tidak ditemukan: ' + item.productId);
    if (Number(product.stock || 0) < qty) return responseError('Stok tidak cukup untuk ' + product.name);
    const subtotal = Number(product.sellPrice || 0) * qty;
    totalDebt += subtotal;
    productRows.push({ product, qty, subtotal });
  }
  const debt = {
    id: generateId('DBT'),
    userId: user.id,
    userName: user.name,
    userPhone: user.phone,
    totalDebt,
    paidAmount: 0,
    remainingDebt: totalDebt,
    status: 'belum_lunas',
    note: body.note || '',
    createdAt: nowIso(),
    updatedAt: nowIso(),
    createdByAdminId: body.adminId,
  };
  appendObject('debts', debt);
  productRows.forEach(row => {
    const p = row.product;
    const beforeStock = Number(p.stock || 0);
    const afterStock = beforeStock - row.qty;
    appendObject('debt_items', {
      id: generateId('DIT'),
      debtId: debt.id,
      productId: p.id,
      productName: p.name,
      price: Number(p.sellPrice || 0),
      qty: row.qty,
      unit: p.unit,
      subtotal: row.subtotal,
      createdAt: nowIso(),
    });
    updateObject('products', p._rowNumber, { stock: afterStock, updatedAt: nowIso() });
    addStockLogInternal(p.id, p.name, 'hutang', row.qty, beforeStock, afterStock, 'Hutang ' + debt.id, body.adminId);
  });
  return responseSuccess('Hutang berhasil ditambahkan', debt);
}

function addDebtPayment(body) {
  const debt = findRowById('debts', body.debtId);
  if (!debt) return responseError('Hutang tidak ditemukan');
  const amount = Number(body.amount || 0);
  if (amount <= 0) return responseError('Nominal pembayaran harus lebih dari 0');
  const paidAmount = Number(debt.paidAmount || 0) + amount;
  const remainingDebt = Math.max(0, Number(debt.totalDebt || 0) - paidAmount);
  const status = remainingDebt <= 0 ? 'lunas' : 'cicil';
  appendObject('debt_payments', {
    id: generateId('PAY'),
    debtId: debt.id,
    userId: debt.userId,
    userName: debt.userName,
    amount,
    note: body.note || '',
    createdAt: nowIso(),
    createdByAdminId: body.adminId,
  });
  updateObject('debts', debt._rowNumber, { paidAmount, remainingDebt, status, updatedAt: nowIso() });
  return responseSuccess('Pembayaran hutang berhasil disimpan', { paidAmount, remainingDebt, status });
}

function markDebtAsPaid(body) {
  const debt = findRowById('debts', body.debtId);
  if (!debt) return responseError('Hutang tidak ditemukan');
  const amount = Number(debt.remainingDebt || 0);
  if (amount > 0) {
    appendObject('debt_payments', {
      id: generateId('PAY'),
      debtId: debt.id,
      userId: debt.userId,
      userName: debt.userName,
      amount,
      note: body.note || 'Ditandai lunas',
      createdAt: nowIso(),
      createdByAdminId: body.adminId,
    });
  }
  updateObject('debts', debt._rowNumber, { paidAmount: Number(debt.totalDebt || 0), remainingDebt: 0, status: 'lunas', updatedAt: nowIso() });
  return responseSuccess('Hutang ditandai lunas');
}

function getDebtPaymentsByUser(body) {
  const payments = getRowsAsObjects('debt_payments').filter(row => String(row.userId) === String(body.userId));
  return responseSuccess('Riwayat pembayaran user berhasil diambil', payments);
}

function getDebtPaymentsByDebt(body) {
  const payments = getRowsAsObjects('debt_payments').filter(row => String(row.debtId) === String(body.debtId));
  return responseSuccess('Riwayat pembayaran hutang berhasil diambil', payments);
}

function getAdminDashboard() {
  const debts = getRowsAsObjects('debts');
  const products = getRowsAsObjects('products').filter(activeOnly);
  const totalDebt = debts.reduce((sum, row) => sum + Number(row.totalDebt || 0), 0);
  const paidAmount = debts.reduce((sum, row) => sum + Number(row.paidAmount || 0), 0);
  const remainingDebt = debts.reduce((sum, row) => sum + Number(row.remainingDebt || 0), 0);
  const debtUserCount = new Set(debts.filter(row => Number(row.remainingDebt || 0) > 0).map(row => row.userId)).size;
  const lowStockProducts = products.filter(p => Number(p.stock || 0) <= Number(p.lowStockLimit || 0));
  return responseSuccess('Dashboard admin berhasil diambil', {
    totalDebt,
    paidAmount,
    remainingDebt,
    debtUserCount,
    productCount: products.length,
    lowStockCount: lowStockProducts.length,
    lowStockProducts,
    recentActivities: getRowsAsObjects('activity_logs').slice(-10).reverse(),
  });
}

function getUserDashboard(body) {
  const debts = getRowsAsObjects('debts').filter(row => String(row.userId) === String(body.userId));
  return responseSuccess('Dashboard user berhasil diambil', {
    totalDebt: debts.reduce((sum, row) => sum + Number(row.totalDebt || 0), 0),
    paidAmount: debts.reduce((sum, row) => sum + Number(row.paidAmount || 0), 0),
    remainingDebt: debts.reduce((sum, row) => sum + Number(row.remainingDebt || 0), 0),
    debtCount: debts.length,
  });
}

function getStockLogs() {
  return responseSuccess('Log stok berhasil diambil', getRowsAsObjects('stock_logs').slice().reverse());
}

function addStockLog(body) {
  addStockLogInternal(body.productId, body.productName, body.type, Number(body.qty || 0), Number(body.beforeStock || 0), Number(body.afterStock || 0), body.note || '', body.adminId);
  return responseSuccess('Log stok berhasil ditambahkan');
}

function addStockLogInternal(productId, productName, type, qty, beforeStock, afterStock, note, adminId) {
  appendObject('stock_logs', {
    id: generateId('STL'),
    productId,
    productName,
    type,
    qty,
    beforeStock,
    afterStock,
    note,
    createdAt: nowIso(),
    createdByAdminId: adminId || '',
  });
}

function getUserAddresses(body) {
  const userId = body.userId;
  if (!userId) return responseError('userId wajib diisi');
  const addresses = getRowsAsObjects('user_addresses')
    .filter(row => String(row.userId) === String(userId) && activeOnly(row));
  return responseSuccess('Alamat user berhasil diambil', addresses);
}

function addUserAddress(body) {
  const userId = body.userId;
  const user = findRowById('users', userId);
  if (!user || String(user.role) !== 'user') return responseError('User tidak ditemukan');
  const activeAddresses = getRowsAsObjects('user_addresses')
    .filter(row => String(row.userId) === String(userId) && activeOnly(row));
  if (activeAddresses.length >= 3) return responseError('Maksimal 3 alamat tersimpan.');
  if (!body.labelAddress || !body.recipientName || !body.phone || !body.fullAddress) {
    return responseError('Label, penerima, no HP, dan alamat wajib diisi');
  }
  if (body.isPrimary) clearPrimaryAddresses_(userId);
  const address = {
    id: generateId('ADR'),
    userId,
    labelAddress: body.labelAddress,
    recipientName: body.recipientName,
    phone: body.phone,
    fullAddress: body.fullAddress,
    note: body.note || '',
    isPrimary: !!body.isPrimary || activeAddresses.length === 0,
    createdAt: nowIso(),
    updatedAt: nowIso(),
    isActive: true,
  };
  appendObject('user_addresses', address);
  return responseSuccess('Alamat berhasil ditambahkan', address);
}

function updateUserAddress(body) {
  const userId = body.userId;
  const address = findRowById('user_addresses', body.addressId || body.id);
  if (!address || String(address.userId) !== String(userId) || !activeOnly(address)) {
    return responseError('Alamat tidak ditemukan');
  }
  if (body.isPrimary) clearPrimaryAddresses_(userId);
  updateObject('user_addresses', address._rowNumber, {
    labelAddress: body.labelAddress,
    recipientName: body.recipientName,
    phone: body.phone,
    fullAddress: body.fullAddress,
    note: body.note || '',
    isPrimary: !!body.isPrimary,
    updatedAt: nowIso(),
  });
  return responseSuccess('Alamat berhasil diperbarui');
}

function deleteUserAddress(body) {
  const userId = body.userId;
  const address = findRowById('user_addresses', body.addressId || body.id);
  if (!address || String(address.userId) !== String(userId)) return responseError('Alamat tidak ditemukan');
  updateObject('user_addresses', address._rowNumber, { isActive: false, updatedAt: nowIso() });
  return responseSuccess('Alamat berhasil dihapus');
}

function clearPrimaryAddresses_(userId) {
  getRowsAsObjects('user_addresses')
    .filter(row => String(row.userId) === String(userId) && activeOnly(row))
    .forEach(row => updateObject('user_addresses', row._rowNumber, { isPrimary: false, updatedAt: nowIso() }));
}

function createOrder(body) {
  const user = findRowById('users', body.userId);
  if (!user || String(user.role) !== 'user' || !activeOnly(user)) return responseError('User tidak ditemukan');
  const product = findRowById('products', body.productId);
  if (!product || !activeOnly(product)) return responseError('Produk tidak ditemukan');
  const qty = Number(body.qty || 0);
  if (qty <= 0) return responseError('Qty tidak valid');
  if (Number(product.stock || 0) < qty) return responseError('Stok produk tidak cukup');
  const orderType = body.orderType === 'delivery' ? 'delivery' : 'pickup';
  let addressId = '';
  let addressSnapshot = '';
  if (orderType === 'delivery') {
    const address = findRowById('user_addresses', body.addressId);
    if (!address || String(address.userId) !== String(user.id) || !activeOnly(address)) {
      return responseError('Alamat pengantaran wajib dipilih');
    }
    addressId = address.id;
    addressSnapshot = address.labelAddress + '\n' + address.recipientName + ' - ' + address.phone + '\n' + address.fullAddress + (address.note ? '\n' + address.note : '');
  }
  const paymentMethod = ['cod', 'cash_store', 'qris', 'ewallet'].indexOf(body.paymentMethod) !== -1 ? body.paymentMethod : 'cash_store';
  if (paymentMethod === 'qris' || paymentMethod === 'ewallet') return responseError('Metode pembayaran belum tersedia');
  const subtotal = Number(product.sellPrice || 0) * qty;
  const order = {
    id: generateId('ORD'),
    userId: user.id,
    userName: user.name,
    userPhone: user.phone,
    orderType,
    addressId,
    addressSnapshot,
    paymentMethod,
    paymentStatus: 'belum_dibayar',
    orderStatus: 'diterima',
    totalAmount: subtotal,
    note: body.note || '',
    createdAt: nowIso(),
    updatedAt: nowIso(),
    confirmedByAdminId: '',
  };
  appendObject('orders', order);
  appendObject('order_items', {
    id: generateId('ORI'),
    orderId: order.id,
    productId: product.id,
    productName: product.name,
    price: Number(product.sellPrice || 0),
    qty,
    unit: product.unit,
    subtotal,
    createdAt: nowIso(),
  });
  return responseSuccess('Pesanan berhasil dibuat', withOrderItems_(order));
}

function getOrdersByUser(body) {
  const userId = body.userId;
  const orders = getRowsAsObjects('orders')
    .filter(row => String(row.userId) === String(userId))
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .map(withOrderItems_);
  return responseSuccess('Pesanan user berhasil diambil', orders);
}

function getAllOrdersForAdmin() {
  const orders = getRowsAsObjects('orders')
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .map(withOrderItems_);
  return responseSuccess('Semua pesanan berhasil diambil', orders);
}

function getOrderDetail(body) {
  const order = findRowById('orders', body.orderId || body.id);
  if (!order) return responseError('Order tidak ditemukan');
  if (body.userId && String(order.userId) !== String(body.userId)) return responseError('User tidak boleh melihat order ini');
  return responseSuccess('Detail order berhasil diambil', withOrderItems_(order));
}

function updateOrderStatus(body) {
  const order = findRowById('orders', body.orderId || body.id);
  if (!order) return responseError('Order tidak ditemukan');
  const status = body.orderStatus;
  if (['diterima', 'diproses', 'dikirim', 'selesai', 'dibatalkan'].indexOf(status) === -1) {
    return responseError('Status order tidak valid');
  }
  if (String(order.orderStatus) === 'diterima' && status === 'diproses') {
    const items = getRowsAsObjects('order_items').filter(item => String(item.orderId) === String(order.id));
    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      const product = findRowById('products', item.productId);
      if (!product) return responseError('Produk order tidak ditemukan: ' + item.productName);
      if (Number(product.stock || 0) < Number(item.qty || 0)) return responseError('Stok tidak cukup untuk ' + item.productName);
    }
    items.forEach(item => {
      const product = findRowById('products', item.productId);
      const beforeStock = Number(product.stock || 0);
      const afterStock = beforeStock - Number(item.qty || 0);
      updateObject('products', product._rowNumber, { stock: afterStock, updatedAt: nowIso() });
      addStockLogInternal(product.id, product.name, 'keluar', Number(item.qty || 0), beforeStock, afterStock, 'Order ' + order.id, body.adminId);
    });
  }
  updateObject('orders', order._rowNumber, { orderStatus: status, updatedAt: nowIso(), confirmedByAdminId: body.adminId || order.confirmedByAdminId });
  return responseSuccess('Status order berhasil diperbarui');
}

function updateOrderPaymentStatus(body) {
  const order = findRowById('orders', body.orderId || body.id);
  if (!order) return responseError('Order tidak ditemukan');
  const status = body.paymentStatus;
  if (['belum_dibayar', 'menunggu_konfirmasi', 'dibayar', 'dibatalkan'].indexOf(status) === -1) {
    return responseError('Status pembayaran tidak valid');
  }
  updateObject('orders', order._rowNumber, { paymentStatus: status, updatedAt: nowIso(), confirmedByAdminId: body.adminId || order.confirmedByAdminId });
  return responseSuccess('Status pembayaran berhasil diperbarui');
}

function withOrderItems_(order) {
  const copy = Object.assign({}, order);
  copy.items = getRowsAsObjects('order_items').filter(item => String(item.orderId) === String(order.id));
  return copy;
}
