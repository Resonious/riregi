import 'dart:developer';

import 'package:flutter/material.dart';

import 'data.dart';
import 'regi.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.app});

  final ActiveAppState app;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late List<Widget> _computedEntries;

  @override
  void initState() {
    super.initState();
    _computedEntries = entries();
  }

  String formatTimestamp(int timestamp) {
    final datetime = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    final y = datetime.year;
    final m = datetime.month;
    final d = datetime.day;
    final hr = datetime.hour;
    final min = datetime.minute.toString().padLeft(2, '0');

    final wk = switch (datetime.weekday) {
      DateTime.sunday => '日',
      DateTime.monday => '月',
      DateTime.tuesday => '火',
      DateTime.wednesday => '水',
      DateTime.thursday => '木',
      DateTime.friday => '金',
      DateTime.saturday => '土',
      _ => '?',
    };

    return '$y-$m-$d ($wk) $hr:$min';
  }

  String justTheDate(DateTime datetime) {
    final y = datetime.year;
    final m = datetime.month;
    final d = datetime.day;

    return '$y-$m-$d';
  }

  Widget total(DateTime lastDate, int runningTotal) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: const BoxDecoration(color: Colors.black12),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(justTheDate(lastDate),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('合計', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.currency_yen,
                      size: 10,
                    ),
                    SelectableText(
                      runningTotal.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> entries() {
    final a = widget.app;
    var result = List<Widget>.empty(growable: true);
    final ordersLen = a.rrOrdersLen(a.ctx);

    DateTime? lastDate;
    int runningTotal = 0;

    log("Computing order history");

    for (var i = 0; i < ordersLen - 1; i += 1) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(a.rrOrderTimestamp(a.ctx, i));

      if (lastDate != null && lastDate.day != date.day) {
        result.add(total(lastDate, runningTotal));
        runningTotal = 0;
      }

      result.add(
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.grey),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatTimestamp(a.rrOrderTimestamp(a.ctx, i)),
                  ),
                  Text(
                    paymentMethodJA(
                        PaymentMethod.values[a.rrOrderPaymentMethod(a.ctx, i)]),
                  ),
                  SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.currency_yen,
                          size: 10,
                        ),
                        SelectableText(a.rrOrderTotal(a.ctx, i).toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      runningTotal += a.rrOrderTotal(a.ctx, i);

      lastDate = date;
    }

    if (lastDate != null) {
      result.add(total(lastDate, runningTotal));
    }

    return result.reversed.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: _computedEntries,
      ),
    );
  }
}
