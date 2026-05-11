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
};

const ADMIN_ACTIONS = [
  'getAllUsers', 'updateUserStatus', 'addCategory', 'updateCategory', 'deleteCategory',
  'addProduct', 'updateProduct', 'deleteProduct', 'updateStock', 'getAllDebts',
  'addDebt', 'addDebtPayment', 'markDebtAsPaid', 'getAdminDashboard', 'getStockLogs',
  'addStockLog', 'getLowStockProducts',
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
      updateStock, getLowStockProducts, searchProducts, getAllDebts,
      getDebtsByUser, getDebtDetail, addDebt, addDebtPayment, markDebtAsPaid,
      getDebtPaymentsByUser, getDebtPaymentsByDebt, getAdminDashboard,
      getUserDashboard, getStockLogs, addStockLog,
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
