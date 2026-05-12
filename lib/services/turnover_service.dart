import '../models/debt_model.dart';
import 'debt_service.dart';
import 'product_service.dart';

enum TurnoverPeriod { today, week, month, year }

class TurnoverStats {
  const TurnoverStats({
    required this.period,
    required this.totalTurnover,
    required this.totalProfit,
    required this.totalQty,
    required this.items,
  });

  final TurnoverPeriod period;
  final num totalTurnover;
  final num totalProfit;
  final num totalQty;
  final List<TurnoverItem> items;
}

class TurnoverItem {
  const TurnoverItem({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.qty,
    required this.sellPrice,
    required this.buyPrice,
    required this.subtotal,
    required this.profit,
  });

  final String productId;
  final String productName;
  final String unit;
  final num qty;
  final num sellPrice;
  final num buyPrice;
  final num subtotal;
  final num profit;

  TurnoverItem merge(TurnoverItem other) {
    final totalQty = qty + other.qty;
    final totalSubtotal = subtotal + other.subtotal;
    final totalProfit = profit + other.profit;
    return TurnoverItem(
      productId: productId,
      productName: productName,
      unit: unit,
      qty: totalQty,
      sellPrice: totalQty == 0 ? sellPrice : totalSubtotal / totalQty,
      buyPrice: buyPrice,
      subtotal: totalSubtotal,
      profit: totalProfit,
    );
  }
}

class TurnoverService {
  const TurnoverService({
    required DebtService debtService,
    required ProductService productService,
  }) : _debtService = debtService,
       _productService = productService;

  final DebtService _debtService;
  final ProductService _productService;

  Future<TurnoverStats> getStats({
    required String adminId,
    required TurnoverPeriod period,
  }) async {
    final debts = await _debtService.getAllDebts(adminId);
    final range = _rangeFor(period);
    final periodDebts = debts.where((debt) {
      final createdAt = debt.createdAt;
      return !createdAt.isBefore(range.start) && createdAt.isBefore(range.end);
    }).toList();

    if (periodDebts.isEmpty) {
      return TurnoverStats(
        period: period,
        totalTurnover: 0,
        totalProfit: 0,
        totalQty: 0,
        items: const [],
      );
    }

    final products = await _productService.getProducts();
    final productById = {for (final product in products) product.id: product};
    final details = await Future.wait(
      periodDebts.map((debt) => _debtService.getDebtDetail(debt.id)),
    );

    final grouped = <String, TurnoverItem>{};
    for (final debt in details.whereType<DebtModel>()) {
      for (final item in debt.items) {
        final product = productById[item.productId];
        final buyPrice = product?.buyPrice ?? 0;
        final sellPrice = item.price == 0 && item.qty > 0
            ? item.subtotal / item.qty
            : item.price;
        final profit = (sellPrice - buyPrice) * item.qty;
        final turnoverItem = TurnoverItem(
          productId: item.productId,
          productName: item.productName,
          unit: item.unit,
          qty: item.qty,
          sellPrice: sellPrice,
          buyPrice: buyPrice,
          subtotal: item.subtotal,
          profit: profit,
        );
        final key = item.productId.isEmpty ? item.productName : item.productId;
        grouped[key] = grouped[key]?.merge(turnoverItem) ?? turnoverItem;
      }
    }

    final items = grouped.values.toList()
      ..sort((a, b) => b.subtotal.compareTo(a.subtotal));
    return TurnoverStats(
      period: period,
      totalTurnover: items.fold<num>(0, (sum, item) => sum + item.subtotal),
      totalProfit: items.fold<num>(0, (sum, item) => sum + item.profit),
      totalQty: items.fold<num>(0, (sum, item) => sum + item.qty),
      items: items,
    );
  }

  ({DateTime start, DateTime end}) _rangeFor(TurnoverPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      TurnoverPeriod.today => (
        start: today,
        end: today.add(const Duration(days: 1)),
      ),
      TurnoverPeriod.week => (
        start: today.subtract(const Duration(days: 6)),
        end: today.add(const Duration(days: 1)),
      ),
      TurnoverPeriod.month => (
        start: DateTime(now.year, now.month),
        end: DateTime(now.year, now.month + 1),
      ),
      TurnoverPeriod.year => (
        start: DateTime(now.year),
        end: DateTime(now.year + 1),
      ),
    };
  }
}
