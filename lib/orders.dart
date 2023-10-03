import 'package:flutter/material.dart';

import 'data.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key, required this.app});

  final ActiveAppState app;

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

  @override
  Widget build(BuildContext context) {
    final a = app;

    final ordersLen = a.rrOrdersLen(a.ctx);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: List<Widget>.generate(
          ordersLen - 1,
          (i) => Padding(
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
                      formatTimestamp(
                          a.rrOrderTimestamp(a.ctx, ordersLen - 2 - i)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.currency_yen,
                          size: 10,
                        ),
                        Text(a
                            .rrOrderTotal(a.ctx, ordersLen - 2 - i)
                            .toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
